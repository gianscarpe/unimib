clear
im = im2double(imread('lawrence2.png')) ;
imF = medfilt2(im, [3 3]) ;



figure
subplot(2, 2, 1), imshow(im)
subplot(2, 2, 2), imshow(imF) 

