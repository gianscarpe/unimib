clear

im = im2double(imread('hand1.jpg')) ;
s = strel('diamond', 3);

figure

subplot(1, 2, 1), imshow(im) ;
subplot(1, 2, 2), plot(imhist(im)) ;

T1 = 0.15 ;
mask = im2bw(im, T1) ;

result = imerode(mask, s);
result = imdilate(result, s);

T2 = graythresh(im) ;
mask2 = im2bw(im, T2) ;
result2 = imdilate(mask, s);

figure
subplot(2, 4, 1), imshow(im) ;
subplot(2, 4, 2), imshow(mask) ;
subplot(2, 4, 3), imshow(result) ;
subplot(2, 4, 4), imshow(im .* result) ;

subplot(2, 4, 5), imshow(im) ;
subplot(2, 4, 6), imshow(mask2) ;
subplot(2, 4, 7), imshow(result2) ;
subplot(2, 4, 8), imshow(im .* result2) ;