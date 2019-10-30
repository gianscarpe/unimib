clear

im = im2double(imread('portrait.jpg'));
im_gray = rgb2gray(im);

disk_strel = strel('disk', 2);

out_dil = imdilate(im, disk_strel);
out_open = imopen(im, disk_strel);
out_erode = imerode(im, disk_strel);
out_close = imclose(im, disk_strel);

figure
subplot(2, 4, 2), imshow(im);
subplot(2, 4, 3), imshow(im_gray);
subplot(2, 4, 5), imshow(out_open), title('OPEN');
subplot(2, 4, 6), imshow(out_close), title('CLOSE');
subplot(2, 4, 7), imshow(out_dil), title('DILATE');
subplot(2, 4, 8), imshow(out_erode), title('ERODE');

leaf = im2double(imread('leaf.jpg'));
leaf_gray = rgb2gray(leaf);

disk_strel = strel('disk', 9);

out_dil = imdilate(leaf_gray, disk_strel);
out_open = imopen(leaf_gray, disk_strel);
out_erode = imerode(leaf_gray, disk_strel);
out_close = imclose(leaf_gray, disk_strel);

figure
subplot(2, 4, 2), imshow(leaf);
subplot(2, 4, 3), imshow(leaf_gray);
subplot(2, 4, 5), imshow(out_open), title('OPEN');
subplot(2, 4, 6), imshow(out_close), title('CLOSE');
subplot(2, 4, 7), imshow(out_dil), title('DILATE');
subplot(2, 4, 8), imshow(out_erode), title('ERODE');