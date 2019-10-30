clear

balloons = im2double(imread('balloons_noisy.png')) ;
rows = size(balloons, 1) ;
cols = size(balloons, 2) ;
figure
imshow(balloons) ;

R = balloons(:, :, 1) ;
G = balloons(:, :, 2) ;
B = balloons(:, :, 3) ;

R2 = medfilt2(R, [5 5] ) ;
G2 = medfilt2(G, [5 5] ) ;
B2 = medfilt2(B, [5 5] ) ;

result = zeros(rows, cols, 3) ;
result(:, :, 1) = R2 ;
result(:, :, 2) = G2 ;
result(:, :, 3) = B2 ;

figure
imshow(result)

