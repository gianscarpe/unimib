clear

im = im2double(imread('face-noisy.png')) ;
rows = size(im, 1) ;
columns = size(im, 2) ;
R = im(:, :, 1) ;
G = im(:, :, 2) ;
B = im(:, :, 3) ;

n = 7;
sigma = (( n - 1 ) / 2 / 2.5) ;
GF = fspecial('Gaussian', 7, sigma) ;

R2 = imfilter(R, GF) ;
G2= imfilter(G, GF) ;
B2 = imfilter(B, GF) ;
face2 = zeros(rows, columns, 3) ;

face2(:, :, 1) = R2 ;
face2(:, :, 2) = G2 ;
face2(:, :, 3) = B2 ;

face3 = imfilter(im, GF) ;
figure
subplot(1, 4, 1), imshow(im) ;
subplot(1, 4, 2), imshow(face2) ;
subplot(1, 4, 3), imshow(face3) ;
subplot(1, 4, 4), imshow( (face3 - face2)) ;