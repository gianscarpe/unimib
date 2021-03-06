% Computer e robot vision
% Versione dell'esercizio: 5 del 01.jan.2019
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
%  5) supponiamo che il robot sia un corpo rigido piano che si muove nel piano 2D.
%  6) il vettore di stato è composto dai gradi di libertà  del robot nel
%     piano (x,y,theta), dove theta è l'angolo di rotazione del sistema
%     di riferimento solidale con il robot rispetto al sistema di
%     riferimento del mondo




function EKF

    % Close all windows and reset workspace
    clear all;
    close all;

    % Robot & Environment configuration
    filename = 'simulated_data.txt';    % better not to edit the filename for the simulated data
    baseline = 0.5;                     % distance between the contact points of the robot wheels [m]
    focal = 600;                       % focal length of the camera [pixel]
    camera_height = 10;                 % how far is the camera w.r.t. the world plane [m]
    pTpDistance = 0.6;                    % distance between the two observed points on the robot [m]

    % Read & parse data from the input file
    DATA=read_input_file(filename);    
    odometry  = [DATA(:,3),DATA(:,4)];    
    camera_readings = [DATA(:,11),DATA(:,12),DATA(:,13),DATA(:,14)];

    steps = size(odometry,1); 
    kalmanstate = zeros(steps,3);       % memory for the 3 state variables, for each timestamp
    kalmanstatecov = zeros(3,3,steps);  % memory for the covariance of the 3 state variables, for each timestamp
    prediction = zeros(steps,3);        % memory for the 3 predicted state variables, for each timestamp
    predictedcov = zeros(3,3,steps);    % memory for the covariance of the 3 predicted state variables, for each timestamp

    % Initializations 
    kalmanstate(1,:) = [0, 0, 0];       % initial state estimate
    kalmanstatecov(:,:,1) =  [0.01 0 0; 0 0.01 0; 0 0 pi/18];  % covariance of the initial state estimate, a (3,3) matrix; could it be set to diagonal? insert your reasoning in a comment
    % La matrice di covarianza della stima di stato iniziale viene fissata
    % come una matrice diagonale 3x3. La scelta presuppone che 
    % le tre variabili di stato (X, Y, Theta) siano tra loro indipendenti.
    % Assumo che lo stato iniziale si discosti di 0.01 rispetto al
    % punto stimato (0, 0) lungo entrambi gli assi, e di un errore di
    % angolazione pi/18 (2 gradi) rispetto all'orientamento iniziale 
    % (ossia, theta=0)

    % configuration of uncertainties
    R(:, :) = eye(3);    % covariance of the noise acting on the state, a (3,3) matrix; could it be set to diagonal? insert your reasoning in a comment
    % Stimo che il rumore che agisce sullo stato è rappresentato come una
    % matrice diagonale 3x3, ossia assumo che l'errore che agisce su
    % ciascuna variabile è indipendente dalle altre variabili. Non potendo
    % stimare un valore di scala dell'errore, assumo che la matrice sia
    % l'identità.
    
    Q(:,:) = 8 * eye(4);
    % Stiamo che il rimuore che agisce sulle misure della camera tenga
    % conto del rumore introdotto dal processo di acquisizione. 
    % La matrice di covarianza è diagonale a blocchi. Assumo che la 
    % varianza sia 8, e di conseguenza la deviazione standard di circa 2.8px. 
    
    % Si tratta quindi di una matrice composta come:
    % u1|8 0 0 0|
    % v1|0 8 0 0|
    % u2|0 0 8 0|
    % v2|0 0 0 8|
    % Dove i due blocchi corrispondono alle matrici di covarianza per le
    % variabili (u1, v1) e (u2, v2)
    
    % NOTA: ho ottenuto i valori di cui sopra effetuando diverse prove del
    % filtro e mantenendo la configurazione data (h=10, b=0.5, focal=600px)
    % Ho pertanto determinato la scala delle matrici di covarianza affinché
    % i punti predetti (in azzurro) rientrino nell'incertezza rappresentata
    % dall'elissi.
    
    % Compute symbolic jacobians once and for all! If you do not already know how to use symbolic calculus inside matlab, Please take ten minutes to learn it.
    % Create the symbolic matrices representing the G and H matrices.
    H = calculateSymbolicH; % Use as an example for G, and remind that its analytical form depends on whether the robot is going straight or not



    % And here we go: batch-simulate in this loop the evolution of the system as well as your KF estimate of its state
    for i=1:steps-1
        % Print the current status of the system in the command window
        fprintf('Filtering step %d/%d; Current uncertainty (x,y,ang): %0.6f %0.6f %0.6f\n',i,steps, kalmanstatecov(1,1,i), kalmanstatecov(2,2,i),kalmanstatecov(3,3,i)); 
        
        % Estimating i+1 state given current
        if odometry(i+1, 1) == odometry(i+1, 2)
            new_state = calculateSymbolicNewStateForwardMovement;
            
        else
            new_state = calculateSymbolicNewStateRotationMovement;
        end
        G = calculateSymbolicG(new_state);
        
        [kalmanstate(i+1,:), kalmanstatecov(:,:,i+1), prediction(i+1,:), predictedcov(:,:,i+1)] = execute_kalman_step(kalmanstate(i,:), ...
            kalmanstatecov(:, :, i), odometry(i+1,:), camera_readings(i+1,:), ...
            baseline, R,Q, focal, camera_height, pTpDistance, G, H, new_state);
    end

    % Do not edit the following lines!
    % Plot the results
    figure(3);
    hold on;
        plot(kalmanstate(:,1), kalmanstate(:,2),'g+');      
        plot(prediction(:,1), prediction(:,2),'c.');

        % plot where the robot points would be on the ground plane for a given measurement (if used as a measurement, this expression would be an inverse sensor model)
        plot(camera_readings(:,1)*camera_height/focal, -camera_readings(:,2)*camera_height/focal,'m*');

        % plot of state uncertainty
        for i=1:1:steps
            plot_gaussian_ellipsoid(kalmanstate(i,1:2),kalmanstatecov(1:2,1:2,i),3.0); 
        end

        axis equal
   hold off; 

end




function simulated_data = read_input_file(filename) % Do not edit this function
simulated_data = dlmread(filename,';'); 
end




function [filtered_state, filtered_sigma, predicted_state, predicted_sigma]= ...
    execute_kalman_step(current_state,current_state_sigma,odometry, ...
    camera_readings,baseline,R,Q,focal,camera_height,pTpDistance,G,H, new_state)

    filtered_state = zeros(1,3);       % memory for the 3 state variables, for each timestamp
    filtered_sigma = zeros(3,3,1);  % memory for the covariance of the 3 state variables, for each timestamp
    predicted_state = zeros(1,3);        % memory for the 3 predicted state variables, for each timestamp
    predicted_sigma = zeros(3,3,1);

    % memory for the expected camera readings
    expected_camera_readings = zeros(1,4);

    % Evaluate the symbolic matrix with the values by using the eval function
    % Please note this is a *terrible* habit.
    % DO NOT EVER USE EVAL INSIDE A MATLAB LOOP, except for this excercise, whose execution time is not of concern

    syms symb_x symb_y symb_theta symb_l symb_sdx symb_ssx        
    G = eval(subs(G,[symb_x,symb_y,symb_theta,symb_l,symb_sdx,symb_ssx],[current_state(1), current_state(2), ...
        current_state(3), baseline, odometry(1),odometry(2)]));

    syms symb_focal symb_pTpDistance symb_camera_height symb_x symb_y symb_theta
    H = eval(subs(H,[symb_focal,symb_pTpDistance,symb_camera_height,symb_x, ...
        symb_y, symb_theta], [focal, pTpDistance, camera_height, ...
        current_state(1), current_state(2),current_state(3)]));

    % Generate the expected new pose, based on the previous pose and the controls, i.e., the dead reckoning data
    predicted_state(1,:)= eval(subs(new_state, [symb_x,symb_y,symb_theta,symb_l,symb_sdx,symb_ssx],[current_state(1), current_state(2), ...
        current_state(3), baseline, odometry(1),odometry(2)]));
    
    predicted_sigma(:,:,1) = G * current_state_sigma * G' + R;

    % then integrate the expected new pose with the measurements
    K = predicted_sigma(:,:,1) * H' / (H * predicted_sigma(:,:,1) * H' + Q);
    
    
    symb_observation = calculateSymbolicObservationPrediction;
    camera = eval(subs(symb_observation,[symb_focal,symb_pTpDistance,symb_camera_height,symb_x, ...
        symb_y,symb_theta], [focal, pTpDistance, camera_height, ...
        predicted_state(1,1), predicted_state(1,2),predicted_state(1,3)]));
    filtered_state = predicted_state(1,:)' + K * (camera_readings - expected_camera_readings)';
    filtered_sigma = (eye(3) - K * H) * predicted_sigma(:,:,1);
end

function symb_state = calculateSymbolicNewStateForwardMovement
    syms symb_ssx symb_sdx symb_l symb_x symb_y symb_theta

    dx = symb_x + symb_ssx * cos(symb_theta);
    dy = symb_y - symb_ssx * sin(symb_theta);
    dt = symb_theta;
    symb_state = [dx; dy; dt];

end

function symb_state = calculateSymbolicNewStateRotationMovement
    syms symb_ssx symb_sdx symb_l symb_x symb_y symb_theta
    r = symb_l * symb_sdx / (symb_ssx - symb_sdx);
    a = (symb_ssx - symb_sdx) / symb_l;
    dx = symb_x - sin(symb_theta) * (symb_l / 2 + r - cos(a) * (symb_l/2 + r)) + ...
        cos(symb_theta) * sin(a) * (symb_l / 2 + r);
    
    dy = symb_y - cos(symb_theta) * (symb_l / 2 + r - cos(a) * (symb_l/2 + r)) - ...
        sin(a) * sin(symb_theta) * (symb_l / 2 + r);
    
    dt = symb_theta + a;
    symb_state = [dx; dy; dt];

end

function G=calculateSymbolicG(symb_state)
    % *** H MATRIX STEP, CALCULATION OF DERIVATIVES aka JACOBIANS ***
    % Please write here the measurement equation(s)
    syms symb_ssx symb_sdx symb_l symb_x symb_y symb_theta
    % derivatives in Matlab can be calculted in this compact way. 
    % This is the same of (you can check it in the command window):
    % syms x    --- declare x as symbolic variable
    % diff(x)  
    G = jacobian(symb_state,[symb_x,symb_y,symb_theta]);
end


function observation=calculateSymbolicObservationPrediction
    syms symb_focal symb_x symb_y symb_theta symb_pTpDistance symb_camera_height
    u1 = symb_x * symb_focal / symb_camera_height;
    v1 = - symb_y * symb_focal / symb_camera_height;
    u2 = (symb_x * symb_focal + symb_pTpDistance * symb_focal * cos(symb_theta))/symb_camera_height;
    v2 = (symb_pTpDistance * symb_focal * sin(symb_theta) - symb_y * symb_focal) / symb_camera_height;
    observation = [u1;v1;u2;v2];
end

function H=calculateSymbolicH
    % *** H MATRIX STEP, CALCULATION OF DERIVATIVES aka JACOBIANS ***
    syms symb_focal symb_x symb_y symb_theta symb_pTpDistance symb_camera_height
    observation = calculateSymbolicObservationPrediction;
    % derivatives in Matlab can be calculted in this compact way. 
    % This is the same of (you can check it in the command window):
    % syms x    --- declare x as symbolic variable
    % diff(x)  
    H = jacobian(observation,[symb_x,symb_y,symb_theta]);
end
