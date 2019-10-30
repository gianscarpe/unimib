im = imread('buttons2.png');
im_hsv = rgb2hsv(im);
bw = (im_hsv(:, :, 1) < 0.2);
disk_strel = strel('disk', 7);
noholes = imclose(bw, disk_strel);

disk_strel = strel('disk', 30);
buttons = imerode(noholes, disk_strel);


figure
subplot(1, 4, 1), imshow(im);
subplot(1, 4, 2), imshow(bw);
subplot(1, 4, 3), imshow(noholes);
subplot(1, 4, 4), imshow(buttons);