im = (imread('colortext.png')) ;
gray = rgb2gray(im) ;

%% Es 1
t_size = 5 ;
out = compute_local_descriptors(im, t_size, 8, @compute_average_color) ;
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

%% Es 2
t_size = 5 ;
out = compute_local_descriptors(gray, t_size, 5, @compute_lbp) ;
descriptors = out.descriptors ;
[nrows, ncolumns] = size(descriptors) ;
rowsout = out.nt_rows ;
columnsout = out.nt_cols ;
[rows, columns] = size(gray) ;

labels = kmeans(descriptors, 5) ;

img_labels = reshape(labels, [rowsout columnsout]) ;
img_labels = imresize(img_labels, t_size, 'nearest') ;

figure
subplot(1, 2, 1), imshow(gray) ;
subplot(1, 2, 2), title('text1 per texture'), imagesc(img_labels), axis image, ...
    colorbar ;


%% Es3
t_size = 5 ;
out = compute_local_descriptors(im, t_size, 3, @compute_multi_texture) ;
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
