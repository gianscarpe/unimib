clear

balls = im2double(imread('balls.jpg')) ;
R = balls( :, :, 1) ;
G = balls( :, :, 2) ;
B = balls( :, :, 3) ;

figure
subplot(2, 3, 2), imshow(balls), title('original');
subplot(2, 3, 4), imshow(R), title('R') ;
subplot(2, 3, 5), imshow(G), title('G') ;
subplot(2, 3, 6), imshow(B), title('B') ;



wedding = im2double(imread('wedding.jpg')) ;
R = wedding( :, :, 1) ;
G = wedding( :, :, 2) ;
B = wedding( :, :, 3) ;

figure
subplot(2, 3, 2), imshow(wedding), title('original');
subplot(2, 3, 4), imshow(R), title('R') ;
subplot(2, 3, 5), imshow(G), title('G') ;
subplot(2, 3, 6), imshow(B), title('B') ;