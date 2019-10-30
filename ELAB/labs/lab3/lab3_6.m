clear

im = im2double(imread('lanterns.png') ) ;
figure
imshow(im) ;

imycbcr = rgb2ycbcr(im) ;

FG = fspecial('Gaussian', 33, 6) ;

Y = imycbcr(:, :, 1) ;
Yfiltered = imfilter(Y, FG) ;

CR = imycbcr(:, :, 3) ;
CRfiltered = imfilter(CR, FG) ;

im1 = imycbcr ;
im1(:, :, 1) = Yfiltered ;

im2 = imycbcr ;
im2(:, :, 3) = CRfiltered ;

out1 = ycbcr2rgb(im1) ;
out2 = ycbcr2rgb(im2) ;

figure
subplot(1, 3, 1), imshow(im) ;
subplot(1, 3, 2), imshow(out1) ;
subplot(1, 3, 3), imshow(out2) ;
