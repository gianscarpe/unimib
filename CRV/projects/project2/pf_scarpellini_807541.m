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
%            Ho impiegato il metodo roulette wheel, di cui propongo due
%            implementazioni. 

%       R2.  in cosa consiste il problema noto come 'particle deprivation'?
%            Accade quando non ci sono particle nella vicinanza dello stato
%            corretto. In particolare, puo' essere causato da un parametro
%            number_of_particles troppo basso per coprire tutte le regioni
%            di likelihood
%
%       R3.  OPZIONALE
%            se hai avuto problemi di 'particle deprivation', prova a
%            risolverli utilizzando i metodi descritti a lezione (adattando
%            il codice per risolvere questo problema si otterrà un voto più
%            alto). Descrivi qui la tecnica che hai utilizzato.
%            Disponendo di una potenza di calcolo limitata, ho lavorato con
%            un numero relativamente basso di number_of_particles. Per
%            ovviare il problema di particle deprivation, ho implementato
%            la versione di particle filters Augmented MCL. In particolare,
%            a ogni istante t calcolo due coefficienti (w_slow e w_fast),
%            in funzione dei coefficienti stessi al tempo t-1, al peso
%            medio e a due parametri alpha_slow e alpha_fast. Per ogni
%            particle, determino se assegnare una particle randomica con
%            probabilita' max(0, 1 - w_fast / w_slow)
%            
%
%       R4.  il numero delle particelle è fisso nella
%            implementazione standard. E' possibile rendere variabile il
%            numero di particelle? Descrivere vantaggi e svantaggi.
%            E' possibile rendere variabile il numero di particles KLD.
%            Migliorando le prestazioni, impiegando un numero maggiore di
%            particles all'inizio per poi ridurre il numero di particles
%            quando queste si concentrano in zone specifiche dello spazio
%            dello stato. Si fissa un threshold che permetta di valutare
%            quando ridurre il numero di particles. Tra i contro, la
%            necessita' di individuare i parametri ottimali.
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
    w_lenght = 30;
    w_width  = 30;
    
    % number of particles
    number_of_particles = 1000;
    
    % initialize the filter with RANDOM samples
    particle_set_a   = rand(3, number_of_particles);
    particle_set_a(1, :) = w_lenght * particle_set_a(1, :);
    particle_set_a(2, :) = w_width * particle_set_a(2, :);
    particle_set_a(3, :) = 2 * pi * particle_set_a(3, :);
    
    particle_set_b   = zeros(3, number_of_particles);
    particle_weights = ones(1, number_of_particles) / number_of_particles;
        
    show_particles(particle_set_a);
    

    
    for i=1:steps-1
                    figure(2)
        clf; title('CAMERA READINGS'); set(gca,'YDir','reverse'); hold on        
        plot(camera_readings1(1:i,1),camera_readings1(1:i,2),'b*');
        plot(camera_readings2(1:i,1),camera_readings2(1:i,2),'b*');
        plot(camera_readings3(1:i,1),camera_readings3(1:i,2),'b*');
        plot(camera_readings4(1:i,1),camera_readings4(1:i,2),'b*');  
        hold off
        
        % prediction
        for particle=1:number_of_particles
            particle_set_b(:, particle)=execute_prediction(particle_set_a(:,particle),odometry(i, :), baseline);            
        end
                
        best = zeros(1, 5);
        % weight
        for particle=1:number_of_particles
            [w,b] = weight_particle(particle_set_b(:,particle),camera_readings1(i, :), ...
            camera_readings2(i, :),camera_readings3(i, :),camera_readings4(i, :),camera_height, ...
            focal, pTpDistance);
            best(b) = best(b) + 1;
            particle_weights(1, particle) = w * particle_weights(1, particle);
        end
        
        
        w_tot = sum(particle_weights(1, particle)) + 1e-40;
        particle_weights(1, particle) = particle_weights(1, particle) ./ w_tot;  
        
        display(best);
        % build sampling method (e.g. roulette wheel)        
        particle_weights = particle_weights;
        
        
        
        
        % PARTICLE DEPRIVATION SOLUTION
        particle_weight_avg = mean(particle_weights(:));
        w_slow = w_slow + alpha_slow * (particle_weight_avg - w_slow);
        w_fast = w_fast + alpha_fast * (particle_weight_avg - w_fast);
        factor = 1 - w_fast / w_slow;
        
        ind = multinomial_sampling(particle_weights);
        particle_set_a = particle_set_b(:,ind); 
                
%         for particle=1:number_of_particles
%             random_value = rand;
%             pp = max(0, factor);
%             if random_value < pp
%                     particle_set_a(1, particle) = w_lenght * rand;
%                     particle_set_a(2, particle) = w_width * rand;
%                     particle_set_a(3, particle) = 2 * pi * rand;
%     
%                 
%             else
%          
% 
% 
% 
%             end
%         end        
                
        show_particles(particle_set_a);
        particle_weights=zeros(1,number_of_particles);
        
      
    end

end

function [prob, best]=weight_particle(particle_pose,camera_readings1,camera_readings2,camera_readings3,camera_readings4,camera_height, focal, pTpDistance)
    x = particle_pose(1);
    y = particle_pose(2);
    theta = particle_pose(3);
    
        
    u1 = x * focal / camera_height;
    v1 = - y * focal / camera_height;
    u2 = (x * focal + pTpDistance * focal * cos(theta))/camera_height;
    v2 = (pTpDistance * focal * sin(theta) - y * focal) / camera_height;
    observation = [u1;v1 ;u2 ;v2];
    
    readings = [camera_readings1; camera_readings2; camera_readings3; camera_readings4]';
    %readings = camera_readings1';
    
    
    mu = observation;
    noise = sqrt(350);
    
    prob = 0;
    i = 1;
    best = 5;
    for reading=readings
        if ~isnan(reading)
            x = reading;
            x_prob = normpdf(norm(x(1:2)- mu(1:2)), 0, noise) * normpdf(norm(x(3:4) - mu(3:4)), 0, noise);
            if x_prob > prob
                best = i;
            end
            prob = max(prob, x_prob);
            
         end
        i = i+1;
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
        prediction = [dx + randn * .1; dy + randn * .1; 
            mod(dt + randn * .1, 2*pi)];
       
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

function [index] = roulette_wheel(weights)
    [sorted_weights, id] = sort(weights);
    sum_w = sum(weights);
    p = sorted_weights / sum_w;
    r = rand;
    i = 1;
    while r>0
       r = r - p(i);
       i = i +1;
    end
    index = id(i-1);
end

function idxs = multinomial_sampling(weights)
    Ns = size(weights, 2);
    idxs = randsample(1:Ns, Ns, true, weights);

end
function particle_index = resample_index(weights)
    total_weight = sum(weights);
    sample = rand *total_weight;
    w_index = 1;
    for w = 1:length(weights)
        if sample <= sum(weights(1:w))
            w_index = w;
            break;
        end
    end
    particle_index = w_index;
end
