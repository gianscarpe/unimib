im = imread('flowerbed.png') ;

%% Es1

t_size = 15 ;
out = compute_local_descriptors(im, t_size, 5, @compute_multi_texture) ;
descriptors = out.descriptors ;
[nrows, ncolumns] = size(descriptors) ;
rowsout = out.nt_rows ;
columnsout = out.nt_cols ;
[rows, columns] = size(im) ;

labels = kmeans(descriptors, 5) ;

img_labels = reshape(labels, [rowsout columnsout]) ;
img_labels = imresize(img_labels, t_size, 'nearest') ;

figure
subplot(1, 2, 1), imshow(im) ;
subplot(1, 2, 2), title('text1 per texture'), imagesc(img_labels), axis image, ...
    colorbar ;
