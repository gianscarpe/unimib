clear
im = im2double(imread('coins.png'));
bw = im < 0.80;

disk_se = strel('disk', 2);
out = imclose(bw, disk_se);

figure
subplot(1, 3, 1), imshow(bw);
subplot(1, 3, 2), imshow(out);
subplot(1, 3, 3), imshow(out - bw);