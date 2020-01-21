% Computer e robot vision
% Versione dell'esercizio: 2 del 11.jan.2019
% 
% Compilare i seguenti campi:
% Nome: Gianluca
% Cognome: Scarpellini
% Matricola: 807541
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
%            ______________________________________________________________
%            ______________________________________________________________
%            ______________________________________________________________
%            ______________________________________________________________
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
    pTpDistance = 0.6;                  % distance between two points on the robot
    alpha_slow = 0;
    alpha_fast = 0;
    w_slow = 0.01;
    w_fast = 0.99;
    zhit = 0.6;
    zrand = 0.4;
    unif = 0.01;
    % Read & parse data from the input file
    DATA=read_input_file(filename);    
    odometry  = [DATA(:,3),DATA(:,4)];    
    camera_readings1 = [DATA(:,11),DATA(:,12),DATA(:,13),DATA(:,14)];
    camera_readings2 = [DATA(:,15),DATA(:,16),DATA(:,17),DATA(:,18)];
    camera_readings3 = [DATA(:,19),DATA(:,20),DATA(:,21),DATA(:,22)];
    camera_readings4 = [DATA(:,23),DATA(:,24),DATA(:,25),DATA(:,26)];
    
    steps = size(odometry,1);
    
    % world dimensions (meter)
    w_lenght = 30;
    w_width  = 30;
    
    % number of particles
    number_of_particles = 500;
    
    % initialize the filter with RANDOM samples
    particle_set_a   = rand(3, number_of_particles);
    particle_set_a(1, :) = w_lenght * particle_set_a(1, :);
    particle_set_a(2, :) = w_width * particle_set_a(2, :);
    particle_set_a(3, :) = 2 * pi * particle_set_a(3, :);
    
    particle_set_b   = randn(3, number_of_particles);
    particle_weights = randi(1, number_of_particles);
        
    show_particles(particle_set_a);
    
    for i=1:steps-1
        
        % prediction
        for particle=1:number_of_particles
            particle_set_b(:, particle)=execute_prediction(particle_set_a(:,particle),odometry(i, :), baseline);            
        end
                
        figure(2)
        clf; title('CAMERA READINGS'); set(gca,'YDir','reverse'); hold on        
        plot(camera_readings1(i,1),camera_readings1(i,2),'b*');
        plot(camera_readings2(i,1),camera_readings2(i,2),'b*');
        plot(camera_readings3(i,1),camera_readings3(i,2),'b*');
        plot(camera_readings4(i,1),camera_readings4(i,2),'b*');        
        % weight
        for particle=1:number_of_particles
            particle_weights(particle)= weight_particle(particle_set_b(:,particle),camera_readings1(i, :), ...
            camera_readings2(i, :),camera_readings3(i, :),camera_readings4(i, :),camera_height, ...
            focal, pTpDistance);
 
        end
        hold off
        
        % build sampling method (e.g. roulette wheel)
        % resampling                
        %particle_weights = (particle_weights) / sum(particle_weights);
        particle_weights = zhit * particle_weights + zrand * unif;
        
        index = int8(randi(number_of_particles));
        beta = 0.0;
        mw = max(particle_weights);
        % PARTICLE DEPRIVATION SOLUTION
        particle_weight_avg = mean(particle_weights(:));
        w_slow = w_slow + alpha_slow * (particle_weight_avg - w_slow);
        w_fast = w_fast + alpha_fast * (particle_weight_avg - w_fast);
        
        
        for particle=1:number_of_particles
            random_value = rand;
            pp = max(0, 1 - w_fast / w_slow);
            if random_value < pp
                    particle_set_a(1, particle) = w_lenght * rand;
                    particle_set_a(2, particle) = w_width * rand;
                    particle_set_a(3, particle) = 2 * pi * rand;
    
                
            else
         

                beta = beta + rand * 2.0 * mw;
                while (beta > particle_weights(index))
                    beta = beta - particle_weights(index);
                    index = int8(mod(index, number_of_particles)) +1;
                end

                particle_set_a(:, particle) = particle_set_b(:, index); 

            end
        end        
                
        show_particles(particle_set_a);
        particle_weights=zeros(1,number_of_particles);        
      
    end

end

function prob=weight_particle(particle_pose,camera_readings1,camera_readings2,camera_readings3,camera_readings4,camera_height, focal, pTpDistance)
    x = particle_pose(1);
    y = particle_pose(2);
    theta = particle_pose(3);
    
        
    u1 = x * focal / camera_height;
    v1 = - y * focal / camera_height;
    u2 = (x * focal + pTpDistance * focal * cos(theta))/camera_height;
    v2 = (pTpDistance * focal * sin(theta) - y * focal) / camera_height;
    observation = [u1,v1,u2,v2];
    
    zhit = 0.9;
    zrand = 0.1;
    zmax = 0.05;
    unif = 1 / 100;
    maxvalue = 100;
    
    noise = 50;
    prob = normpdf(norm(camera_readings1 - observation), 0, noise);
    if ~isnan(camera_readings2)
        dist = norm(camera_readings2 - observation);
        prob = prob + normpdf(dist, 0, noise);
        
    end
    if ~isnan(camera_readings3)
        dist = norm(camera_readings3 - observation);
        prob = prob + normpdf(dist, 0, noise);
        
    end
    if ~isnan(camera_readings4)
        dist = norm(camera_readings4 - observation);
        prob = prob + normpdf(dist, 0, noise);
    end

end

function prediction=execute_prediction(particle,odometry,baseline)
    ssx = odometry(1);
    sdx = odometry(2);
    x = particle(1);
    y = particle(2);
    theta = particle(3);
    if ssx ~= sdx
        r = baseline * sdx / (ssx - sdx);
        a = (ssx - sdx) / baseline;
        dx = x - sin(theta) * (baseline / 2 + r - cos(a) * (baseline/2 + r)) + ...
            cos(theta) * sin(a) * (baseline / 2 + r);
    
        dy = y - cos(theta) * (baseline / 2 + r - cos(a) * (baseline/2 + r)) - ...
            sin(a) * sin(theta) * (baseline / 2 + r);
    
        dt = theta + a;
        prediction = [dx + randn * 0.1; dy + randn * 0.1; 
            mod(dt + randn * 0.1, 2 * pi)];
       
    else
        dx = x + ssx * cos(theta);
        dy = y - ssx * sin(theta);
        dt = theta;
        prediction = [dx; dy;dt];
        
    end
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
