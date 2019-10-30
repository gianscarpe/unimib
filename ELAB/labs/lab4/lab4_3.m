close all
clear

%% Es 3

im = im2double(imread('hand2.jpg')) ;

gray = rgb2gray(im) ;

T = graythresh(gray) ;
mask = im2bw(gray, T) ;

%% Risultati 1
figure
subplot(1, 3, 1), imshow(gray) ;

subplot(1, 3, 2), imshow(mask) ;

subplot(1, 3, 3), imshow(gray .* mask) ;

%% Risultati 2

R = im(:, :, 1) ;
G = im(:, :, 2) ;
B = im(:, :, 3) ;

figure
subplot(3, 2, 1), imshow(R) ; 
subplot(3, 2, 2), plot(imhist(R)) ;
subplot(3, 2, 3), imshow(G) ; 
subplot(3, 2, 4), plot(imhist(G)) ;
subplot(3, 2, 5), imshow(B) ; 
subplot(3, 2, 6), plot(imhist(B)) ;

% Posso provare a fare il thresholding usandoi il solo canale B (ci si
% prova)

%% Risultati 3


T = graythresh(B) ;
maskB = im2bw(B, T) ;
figure
subplot(1, 3, 1), imshow(B) ;
subplot(1, 3, 2), imshow(maskB) ;
subplot(1, 3, 3), imshow(B .* maskB) ;
% No, non funziona

%% Cambio spazio colore - Risultati 4

% Uso HSI per escludere la componente di luminosità dal resto (si spera per
% eliminare le ombre), ed estrarre la saturazione

hsi = rgb2hsv(im) ;

H = hsi(:, :, 1) ;

S = hsi(:, :, 2) ;

I = hsi(:, :, 3) ;

figure
subplot(1, 3, 1), imshow(H) ;

subplot(1, 3, 2), imshow(S) ;

subplot(1, 3, 3), imshow(I) ;

T = 0.2 ;
mask_S = im2bw(S, T); 

figure
subplot(2, 3, 1), imshow(S) ;
subplot(2, 3, 2), imshow(mask_S) ;
subplot(2, 3, 3), plot(imhist(S)) ;
subplot(2, 3, 5), imshow(S .* mask_S) ;

S_thresh = S .* mask_S ;
