clear
close all

signs = im2double(imread('signs.jpg')) ;

%% Noto:
% I cartelli sono un BLU saturo e un verde/blue
% Provo con YCBCR per estarre il verde-blu

signs_YCBCR = rgb2ycbcr(signs);

Y = signs_YCBCR(:, :, 1) ;

CB = signs_YCBCR(:, :, 2) ; % Per i cartelli blu

CR = signs_YCBCR(:, :, 3) ;

CR_inverso = 1 - CR ; % Per i caretelli verde/blu

%% Risultati 1
figure

subplot(2, 4, 2), imshow(signs) ;
subplot(2, 4, 5), imshow(Y) ;
subplot(2, 4, 6), imshow(CB) ;
subplot(2, 4, 7), imshow(CR) ;
subplot(2, 4, 8), imshow(CR_inverso) ;

%% Thresholding

T1 = graythresh(CB) ;
maskCB = im2bw(CB, T1) ;

T2 = graythresh(CR_inverso) ;
maskVB = im2bw(CR_inverso, T2) ;

T3 = 0.37 ;
maskCR = im2bw(CR, T3) ;

maskCR_invertita = 1 - maskCR ;

figure
subplot(1, 4, 1), imshow(maskCB), title('Mask su CB con Otsu'); 
subplot(1, 4, 2), imshow(maskVB), title('Mask su CR^-^1 con Otsu') ;
subplot(1, 4, 3), imshow(maskCR), title('Mask su CR con T = 0.37') ;
subplot(1, 4, 4), imshow(maskCR_invertita), title('Mask su CR^-^1') ;

%% Noto: maskB
