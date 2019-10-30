%% Classificatore a regole:
% A partire dai dati, troviamo delle regole sui singoli pixel che
% permettano di ipottizare che un vettore RGB appartenga a SKIN o NOSKIN

% A PARALLELEPIPEDO: Calcolare statistiche sui pixel di pelle, e usare le
% statische sulle immagini

% Media, Deviazione standard -> usiamo per degli INTERVALLI DI CONFIDENZA
% per i vettori RGB

image = im2double(imread('test3.jpg')) ; % immagine da classificare
skin = im2double(imread('skin.png')) ; % insieme di dati
[rows, columns, ch] = size(skin) ;

skin = reshape(skin, [rows * columns, 3]) ;

% Statistiche; parametri del classificatore a regole
m = mean(skin) ;
sd = std(skin) ;
k1 = 1 ;
k2 = 1 ;
k3 = 2 ;
% (r, g, b) = m +- k * sd : equazioni (regole) del classificatore per una
% terna RGB


maskR = and( ( m(1) - k1 * sd(1)  <= image(:, :, 1)), ...
    (image(:, :, 1) <= m(1) + k1 * sd(1) ) );

maskG = and( ( m(2) - k2 * sd(2)  <= image(:, :, 2)), ...
    (image(:, :, 2) <= m(2) + k2 * sd(2) ) ) ;

maskB = and( ( m(3) - k3 * sd(3)  <= image(:, :, 3)), ...
    (image(:, :, 3) <= m(3) + k3 * sd(3) ) ) ;

predicted = (maskR & maskG & maskB) ;
imshow(predicted) 

%% Valutare il classificatore: confmat
gt = imread('test3-gt.png') ;
gt = logical(gt) ;
figure, imshow(gt) ;

eval = confmat(gt, predicted) ;
accuracy = eval.accuracy ; % percentuale di correzione
matrice = eval.cm % matrice con le percenutali OK / falsi positivi / falsi negativi

