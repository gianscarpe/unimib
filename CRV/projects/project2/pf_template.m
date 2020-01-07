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
    baseline = ___;                   % wheels base / interaxis
    focal = ____;                     % focal length of the camera (in pixels)
    camera_height = __;               % how far is the camera w.r.t. the robot ground plane
    pTpDistance = _;                  % distance between two points on the robot
    
    % Read & parse data from the input file
    DATA=read_input_file(filename);    
    odometry  = [DATA(:,3),DATA(:,4)];    
    camera_readings1 = [DATA(:,11),DATA(:,12),DATA(:,13),DATA(:,14)];
    camera_readings2 = [DATA(:,15),DATA(:,16),DATA(:,17),DATA(:,18)];
    camera_readings3 = [DATA(:,19),DATA(:,20),DATA(:,21),DATA(:,22)];
    camera_readings4 = [DATA(:,23),DATA(:,24),DATA(:,25),DATA(:,26)];
    
    steps = size(odometry,1);
    
    % world dimensions (meter)
    lenght = ____;
    width  = ____;
    
    % number of particles
    number_of_particles = ____;
    
    % initialize the filter with RANDOM samples
    particle_set_a   = ____;
    particle_set_b   = ____;
    particle_weights = ____;
        
    show_particles(particle_set_a);
    
    for i=1:steps-1
        
        % prediction
        for particle=1:number_of_particles
            particle_set_b(:, particle)=execute_prediction(particle_set_a(:,particle),________________);            
        end
                
        figure(2)
        clf; title('CAMERA READINGS'); set(gca,'YDir','reverse'); hold on        
        plot(camera_readings1(:,1),camera_readings1(:,2),'b*');
        plot(camera_readings2(:,1),camera_readings2(:,2),'b*');
        plot(camera_readings3(:,1),camera_readings3(:,2),'b*');
        plot(camera_readings4(:,1),camera_readings4(:,2),'b*');        
        % weight
        for particle=1:number_of_particles
            particle_weights(particle)=weight_particle(particle_set______(:,particle),____________________);
        end
        hold off
        
        % build sampling method (e.g. roulette wheel)
        ____________________________________________________
        ____________________________________________________
        ____________________________________________________
        
        % resampling                
        for particle=1:number_of_particles            
            ____________________________________________________
            ____________________________________________________
            ____________________________________________________
        end        
                
        show_particles(particle_set_a);
        particle_weights=zeros(1,number_of_particles);        
%         pause(0.01);
    end

end

function weight_particle=weight_particle(particle_pose,camera_readings1,camera_readings2,camera_readings3,camera_readings4,camera_height, focal, pTpDistance)

    ____________________________________________________
    ____________________________________________________
    ____________________________________________________
    ____________________________________________________

end

function prediction=execute_prediction(particle,odometry,baseline)
       
    ____________________________________________________
    ____________________________________________________
    ____________________________________________________
    ____________________________________________________

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
