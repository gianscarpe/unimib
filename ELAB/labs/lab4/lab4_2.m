clear
close all 
%% Threhsolding globale
markers = im2double(imread('markers.png')) ;
T = graythresh(markers) ;
mask = im2bw(markers, T) ;

figure
imshow(markers .* mask) ;
% L'ombra non permette un thresholding efficace

%% Thresholding locale

% default
mask2 = sauvola(markers) ;


figure
subplot(1, 3, 1), imshow(markers) ;
subplot(1, 3, 2), imshow(mask2) ;
subplot(1, 3, 3), imshow(markers .* mask2), title('Sauvola') ;


% default
mask3 = sauvola(markers, [10 10] ) ;


figure
subplot(1, 3, 1), imshow(markers) ;
subplot(1, 3, 2), imshow(mask3) ;
subplot(1, 3, 3), imshow(markers .* mask3), title('Sauvola') ;

% default
mask4 = sauvola(markers, [26 26] ) ;


figure
subplot(1, 3, 1), imshow(markers) ;
subplot(1, 3, 2), imshow(mask4) ;
subplot(1, 3, 3), imshow(markers .* mask4), title('Sauvola') ;

%% Nota
% Sauvola restituisce un immagine binarizzata con un algoritmo di
% binarizzazione automatica. L?algoritmo di binarizzazione di Sauvola, è un
% algoritmo locale. A differenza della semplice sogliatura, che è un 
% algoritmo globale, Sauvola analizza delle regioni locali dell?immagine 
% sulle quali determina la soglia che meglio separa le regioni
% chiare da quelle scure. E? un algoritmo che meglio si adatta in presenza 
% di ombre e variazioni di luminosità nell?immagine. E? in grado di 
% compensare differenze nell?immagine. La dimensione delle regioni di 
% analisi deve essere settata in modo tale da avere estensione pari alla 
% più grande regione che si vuole binarizzare.