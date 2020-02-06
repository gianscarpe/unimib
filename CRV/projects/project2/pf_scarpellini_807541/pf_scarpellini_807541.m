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
%            Ho impiegato il metodo roulette wheel, di cui propongo 
%            l'implementazione (commentata) nel codice alla riga 266. 

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
%            Nella precedente consegna avevo implementato la versione di
%            particle filters Augmented MCL. In particolare,
%            a ogni istante t calcolo due coefficienti (w_slow e w_fast),
%            in funzione dei coefficienti stessi al tempo t-1, al peso
%            medio e a due parametri alpha_slow e alpha_fast. Per ogni
%            particle, determino se assegnare una particle RANDOMICA con
%            probabilita' max(0, 1 - w_fast / w_slow). Ho deciso di
%            rimuovere la particle deprivation in questa soluzione: ho
%            migliorato difatti la funzione di weigth, rendendola più
%            robusta, e ho valutato che 500 particles sono sufficienti.
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
    clear;
    close all;
        
    % Robot & Environment configuration
    filename = 'simulated_data4t.txt';        
    baseline = 0.5;                   % wheels base / interaxis
    focal = 600;                     % focal length of the camera (in pixels)
    camera_height = 10;               % how far is the camera w.r.t. the robot ground plane
    pTpDistance = 0.6;                  % distance between two points on the robot
    
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
    
    particle_set_b   = zeros(3, number_of_particles);
    predicted_observations = zeros(2, number_of_particles);
    particle_weights = ones(1, number_of_particles) / number_of_particles;
    
    
    

    
    for i=1:steps-1
        figure(2)
       clf; title('CAMERA READINGS'); set(gca,'YDir','reverse'); hold on        
        plot(camera_readings1(1:i,1),camera_readings1(1:i,2),'k*');
        plot(camera_readings2(1:i,1),camera_readings2(1:i,2),'r*');
        plot(camera_readings3(1:i,1),camera_readings3(1:i,2),'g*');
        plot(camera_readings4(1:i,1),camera_readings4(1:i,2),'y*');  
        plot(predicted_observations(1, :), predicted_observations(2, :), 'b*');
        hold off
        legend('Obs 1','Obs 2','Obs 3', 'Obs 4', 'Prediction')
        show_particles(particle_set_a);
        
        % PREDICTION
        % Per ogni particle al tempo t-1, effettuo sample della
        % distribuzione di probabilità di STATO, ottenendo un sample
        % "dell'evoluzione" della particle al tempo t
        
        for particle=1:number_of_particles
            particle_set_b(:, particle)=execute_prediction(particle_set_a(:,particle),odometry(i, :), baseline);            
        end
                
        % WEIGHT
        % Per ogni particle, calcolo il suo importance factor 
        % (funzione weight_particle), che successivamente converto in un
        % valore compreso tra 0 e 1, e ottengo la sua location sul piano
        % immagine (in predicted_observations), che uso per visualizzare
        % graficamente le particles e confrontarle visivamente con la 
        % risposta del sensore
        
        for particle=1:number_of_particles
            [w, obs] = weight_particle(particle_set_b(:,particle),camera_readings1(i, :), ...
            camera_readings2(i, :),camera_readings3(i, :),camera_readings4(i, :),camera_height, ...
            focal, pTpDistance);

            particle_weights(1, particle) = w;
            predicted_observations(:, particle) = obs(1:2);
        end
        
        % Normalizzazione dei pesi, al fine di riportare i valori in un
        % range compreso tra 0 e 1 affinché la somma sia 1. 
        % In primis rimappo i weights ottenuti dal passo precendete ponendo
        % il massimo uguale a 1 e il minimo uguale a 0. Succssivamente,
        % inverto i valori (la distanza massima, ossia 1, 
        % è anche la meno probabile). Concludo normalizzando al fine di 
        % ottenere un array di pesi che sommi a 1
        % (ossia, l'equivalente di una distribuzione di probabilita')
        
       
        min_weight = min(particle_weights);
        max_weight = max(particle_weights);
        particle_weights = (particle_weights - min_weight) / ...
            (max_weight - min_weight);
        particle_weights = 1 - particle_weights;
        particle_weights = particle_weights / sum(particle_weights);  
        

        % build sampling method (e.g. roulette wheel)        
        
        % PARTICLE DEPRIVATION SOLUTION
        % Ho deciso di non impiegare la soluzione di particle deprivation,
        % un numero di particles >=500 e' sufficiente a ottenere un filtro
        % robusto
        
        % RESAMPLING
        
         inds = resample_wheel(particle_weights);
         particle_set_a = particle_set_b(:, inds);
         particle_weights=zeros(1,number_of_particles);
    end

end

function [prob, observation]=weight_particle(particle_pose,camera_readings1,camera_readings2,camera_readings3,camera_readings4,camera_height, focal, pTpDistance)
    x = particle_pose(1);
    y = particle_pose(2);
    theta = particle_pose(3);
    % Eq. misura
    u1 = x * focal / camera_height;
    v1 = - y * focal / camera_height;
    u2 = (x * focal + pTpDistance * focal * cos(theta))/camera_height;
    v2 = (pTpDistance * focal * sin(theta) - y * focal) / camera_height;
    observation = [u1;v1 ;u2 ;v2];
   
    readings = [camera_readings1; camera_readings2; camera_readings3; camera_readings4]';
   
    mu = observation;
    prob = inf;
    alpha = 15;
    
    
    for x=readings
        if ~isnan(x)
            % Calcolo la distanza tra la lettura x del sensore e
            % l'observation predetta dalla particle tramite equazioni di
            % misura. A valore aggiungo una camponente gaussiana centrata
            % in 0 con varianza ALPHA. Lo scopo è effettuare sampling da
            % una distribuzione di probabilità di DISTANZA di una particle
            % dalla osservazione reale. La componente di noise aggiunge
            % robustezza all'approccio.
            
            x_prob = norm(x - mu) + randn * alpha; 
            % Restituisco la distanza MINORE tra observation e i valori di
            % misura del sensore
            prob = min(x_prob, prob); 
        end
    end
    

end

function prediction=execute_prediction(particle,odometry,base)
    x = particle(1);
    y = particle(2);
    theta = particle(3);
    ssx = odometry(1);
    sdx = odometry(2);
    if ssx == sdx % Eq. stato nel caso in cui il robot si muova in avanti
        dx = x + ssx*cos(theta);
        dy = y - ssx*sin(theta);
        dt = theta;
    else % Eq. stato nel caso in cui il robot viri
            r = base * sdx / (ssx - sdx);
            a = (ssx - sdx) / base;
            dx = x - sin(theta) * (base / 2 + r - cos(a) * (base/2 + r)) + ...
                cos(theta) * sin(a) * (base / 2 + r);

            dy = y - cos(theta) * (base / 2 + r - cos(a) * (base/2 + r)) - ...
                sin(a) * sin(theta) * (base / 2 + r);

            dt = theta + a;

    end
    % Ho notato che il filtro è più sensibile al noise su theta
    % (ovviamente, dall'orientamento del robot dipende la direzione del
    % movimento successivo). Ho effettuato delle prove per ricavare i
    % valori "ottimali" di noise sulle tre componenti [0.1 0.1 .3]
    prediction = [dx; dy; dt] + [randn*0.01; randn*0.01; randn  * 0.3];
end
    
function show_particles(particle_set)
% Do not edit this function 
        figure(1);
        clf
        hold on
        plot(particle_set([1],:),particle_set([2],:),'k*')
        arrow=0.5;
        line([particle_set(1,:); particle_set(1,:)+arrow*(cos(particle_set(3,:).*-1))], [particle_set(2,:); particle_set(2,:)+arrow*(-sin(particle_set(3,:).*-1))],'Color','b');         
        hold off
end


function simulated_data = read_input_file(filename)
% Do not edit this function 
    simulated_data = dlmread(filename,';');
    
end


function inds = resample_wheel(weights)
    tot_particles = size(weights,2);
    inds = zeros(size(weights));
 
    rand_value = rand(1) / tot_particles;
    rand_weight = weights(1);
    index = 1;
    
    for m = 1:tot_particles
        check = rand_value + (m-1) / tot_particles;
        while check > rand_weight 
            index = index + 1;
            rand_weight = rand_weight + weights(index); % Incrementa random_weight
        end
        inds(m) = index; % Termina assegnando l'indice index per la particle m
    end
    
end
