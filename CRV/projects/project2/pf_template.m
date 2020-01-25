% Computer e robot vision
% Versione dell'esercizio: 2 del 11.jan.2019
% 
% Compilare i seguenti campi:
% Nome: Federico
% Cognome: Bottoni
% Matricola: 806944
% 
% Note:
%  1) utilizzare il Sistema Internazionale per ogni grandezza dotata di dimensioni,
%  2) per la lunghezza focale usare i pixel,
%  3) utilizzare in modo intensivo i commenti, 
%  4) le sezioni su cui lavorare sono identificate con dei caratteri underscore ("_"), come qui sotto
%     ____________________________________________________________
%  5) supponiamo che il robot sia un corpo rigido piano che si muove nel piano
%     2D ed il sistema di riferimento robot abbia l'asse X in avanti, l'asse Y
%     verso la sinistra e l'asse Z verso l'alto.
%  6) il vettore di stato è composto dai gradi di libertà  del robot nel
%     piano (x,y,theta), dove theta è l'angolo di rotazione del sistema
%     di riferimento solidale con il robot rispetto al sistema di
%     riferimento del mondo
%  7) per la gestione della prediction delle particelle, utilizzare due 
%     vettori <particle_set_a> e <particle_set_b>.
%  8) in B mettete la prediction e poi copiate i dati di nuovo in A dopo
%     aver pesato le particelle e fatto resampling.
%  9) iniziate a creare il particle filter nel più semplice modo possibile,
%     come da libro Probabilistic robotics pag. 98, rispondendo alle domande
%     seguenti ed implementando il codice.
% 10) vi consiglio di utilizzare in modo intensivo le funzioni di matlab
%     per la gestione delle distribuzioni di probabilità (e.g. mvnpdf, pdf,
%     gmdistribution .....)
% DOMANDE:
%       R1.  build sampling method: quale metodo di resampling avete
%            utilizzato? 
%            ______________________________________________________________
%            ______________________________________________________________
%            ______________________________________________________________
%            ______________________________________________________________
%       R2.  in cosa consiste il problema noto come 'particle deprivation'?
%             Essendo l'algoritmo di resampling di tipo Monte Carlo, questo
%             potrebbe cancellare le particelle valide e lasciare
%             la zona da localizzare senza particles
%
%       R3.  OPZIONALE
%            se hai avuto problemi di 'particle deprivation', prova a
%            risolverli utilizzando i metodi descritti a lezione (adattando
%            il codice per risolvere questo problema si otterrà un voto più
%            alto). Descrivi qui la tecnica che hai utilizzato.
%            ______________________________________________________________
%            ______________________________________________________________
%            ______________________________________________________________
%
%       R4.  il numero delle particelle è fisso nella
%            implementazione standard. E' possibile rendere variabile il
%            numero di particelle? Descrivere vantaggi e svantaggi.
%            ______________________________________________________________
%            ______________________________________________________________
%            ______________________________________________________________
%            ______________________________________________________________
%
%       R5.  OPZIONALE prova ad introdurre una tecnica per rendere
%            variabile il numero di particelle (adattando il codice per
%            introdurre questa tecnica si otterrà un voto più alto).
%            Descrivi qui la tecnica che hai utilizzato.
%            ______________________________________________________________
%            ______________________________________________________________
%            ______________________________________________________________
%
%   FORMATO DI INPUT 
%   nomefile: simulated_data4t.txt
   

function PF

    % Close all windows and reset workspace
    clear all;
    close all;
        
    % Robot & Environment configuration
    filename = 'simulated_data4t.txt';        
    baseline = 0.5;                   % wheels base / interaxis
    focal = 600;                     % focal length of the camera (in pixels)
    camera_height = 10;               % how far is the camera w.r.t. the robot ground plane
    pTpDistance = 0.6;                  % distance between two points on the robot                % distance between two points on the robot
    alpha_slow = 0.1;
    alpha_fast = 0.9;
    w_slow = 0;
    w_fast = 0;
    
    % Read & parse data from the input file
    DATA=read_input_file(filename);    
    odometry  = [DATA(:,3),DATA(:,4)];    
    camera_readings1 = [DATA(:,11),DATA(:,12),DATA(:,13),DATA(:,14)];
    camera_readings2 = [DATA(:,15),DATA(:,16),DATA(:,17),DATA(:,18)];
    camera_readings3 = [DATA(:,19),DATA(:,20),DATA(:,21),DATA(:,22)];
    camera_readings4 = [DATA(:,23),DATA(:,24),DATA(:,25),DATA(:,26)];
    
    steps = size(odometry,1);
    
    % world dimensions (meter)
    length = 30;
    width  = 30;
    
    % number of particles
    number_of_particles = 100;
    
    % initialize the filter with RANDOM samples
    particle_set_a   = rand(3, number_of_particles);
    particle_set_a(1, :) = length * particle_set_a(1, :);
    particle_set_a(2, :) = width * particle_set_a(2, :);
    particle_set_a(3, :) = 2 * pi * particle_set_a(3, :);
    
    particle_set_b   = randn(3, number_of_particles);
    particle_weights = ones(1, number_of_particles);
        
    show_particles(particle_set_a);
    for i=1:steps-1
        % prediction
        for particle=1:number_of_particles
            particle_set_b(:, particle)=execute_prediction(particle_set_a(:,particle),odometry(i,:), baseline);            
        end
                
        figure(2)
        clf; title('CAMERA READINGS'); set(gca,'YDir','reverse'); hold on        
        plot(camera_readings1(:,1),camera_readings1(:,2),'b*');
        plot(camera_readings2(:,1),camera_readings2(:,2),'b*');
        plot(camera_readings3(:,1),camera_readings3(:,2),'b*');
        plot(camera_readings4(:,1),camera_readings4(:,2),'b*');        
        % weight
        for particle=1:number_of_particles
            particle_weights(particle)=weight_particle(particle_set_b(:,particle),camera_readings1(i,:),...
                camera_readings2(i,:),camera_readings3(i,:),camera_readings4(i,:),camera_height, focal, pTpDistance) + 0.001;
        end
        
        hold off
        
        % build sampling method (e.g. roulette wheel)
        % counter particle deprivation
        p_weight_avg = mean(particle_weights(:));
        w_slow = alpha_slow * (p_weight_avg - w_slow) + w_slow ;
        w_fast = alpha_fast * (p_weight_avg - w_fast) + w_fast ;
        total_weight = sum(particle_weights);
        % resampling                
        for particle=1:number_of_particles 
            random_value = rand;
            pp = max(0, 1 - w_fast / w_slow);
            display(1 - w_fast/w_slow);
            if random_value < pp
                particle_set_a(1, particle) = lenght * rand;
                particle_set_a(2, particle) = width * rand;
                particle_set_a(3, particle) = 2 * pi * rand;
            else 
                ind = resample_index(particle_weights, total_weight);
                particle_set_a(:,particle) = particle_set_b(:,ind);
            end
        end       
                
        show_particles(particle_set_a);
        particle_weights=zeros(1,number_of_particles);        
%         pause(0.01);
    end
end

function prob=weight_particle(particle_pose,camera_readings1,camera_readings2,camera_readings3,camera_readings4,...
    camera_height, focal, pTpDistance)

    p_x = particle_pose(1);
    p_y = particle_pose(2);
    p_theta = particle_pose(3);
    u1 = (focal*p_x)/camera_height;
    v1 = -(focal*p_y)/camera_height;
    u2 = (pTpDistance*focal*cos(p_theta) + focal*p_x)/camera_height;
    v2 = -(pTpDistance*focal*sin(p_theta) + focal*p_y)/camera_height;
    observation = [u1,v1,u2,v2];
    
    noise = 100 * eye(4);
    
    prob = + mvnpdf(camera_readings1, observation, noise);
    if ~isnan(camera_readings2)
        %dist = norm(camera_readings2 - observation);
        prob = prob + mvnpdf(camera_readings2, observation, noise);
    end
    if ~isnan(camera_readings3)
        %dist = norm(camera_readings3 - observation);
        prob = prob + mvnpdf(camera_readings3, observation, noise);
    end
    if ~isnan(camera_readings4)
        %dist = norm(camera_readings4 - observation);
        prob = prob + mvnpdf(camera_readings4, observation, noise);
    end
    
    
end

function prediction=execute_prediction(particle,odometry,base)
    x = particle(1);
    y = particle(2);
    a = particle(3);
    ssx = odometry(1);
    sdx = odometry(2);
    if ssx == sdx
        x1 = x + ssx*cos(a);
        y1 = y - ssx*sin(a);
        theta1 = a;
    else
        dis = (sdx * base)/(ssx - sdx);
        dtheta = (ssx - sdx)/base;
        x1 = x + (dis + base/2)*(cos(a)*sin(dtheta) + sin(a)*cos(dtheta)) - (sin(a)*(dis + base/2));
        y1 = y + (dis + base/2)*(cos(a)*cos(dtheta) - sin(a)*sin(dtheta)) - (cos(a)*(dis + base/2));
        theta1 = a + dtheta;
    end
    prediction = [x1; y1; theta1] + [randn*0.1; randn*0.1; mod(randn * 0.1, 2 * pi)];
end

function particle_index = resample_index(weights, total_weight)
    sample = rand(1)*total_weight;
    w_index = 0;
    for w = 1:length(weights)
        if sample <= sum(weights(1:w))
            w_index = w;
            break;
        end
    end
    particle_index = w_index;
end
    
function show_particles(particle_set)
% Do not edit this function 
    figure(1);      
    clf(1);
    title('PARTICLES');
    hold on;        
        plot(particle_set([1],:),particle_set([2],:),'k*')
        arrow=0.5;
        line([particle_set(1,:); particle_set(1,:)+arrow*(cos(particle_set(3,:).*-1))], [particle_set(2,:); particle_set(2,:)+arrow*(-sin(particle_set(3,:).*-1))],'Color','b');         
    hold off;
    
end


function simulated_data = read_input_file(filename)
% Do not edit this function 
    
    simulated_data = dlmread(filename,';');
    
end