close
clear

%% Es 5

coins = im2double(imread('euro_coins.png')) ;
gray = rgb2gray(coins) ;
figure
subplot(1, 3, 1), imshow(coins) ;
subplot(1, 3, 2), imshow(gray) ;
subplot(1, 3, 3), plot(imhist(gray)) ;

%% Risultati 1
T = 0.99 ;
mask = im2bw(gray, T) ;
bw = 1 - mask ;
imshow(bw) ;

%% Labeling - risultati 2
labels = bwlabel(bw) ;
figure
subplot(1, 3, 1), imshow(gray) ;
subplot(1, 3, 2), imshow(bw) ;
subplot(1, 3, 3), imagesc(labels), axis image, colorbar ; 

%% Risultati 3 - 50 centesimi
mask50 = (labels == 5) ;
figure
subplot(3, 1, 1), imshow(gray) ;
subplot(3, 1, 2), imshow(mask50) ;
subplot(3, 1, 3), imshow(coins .* mask50) ;

