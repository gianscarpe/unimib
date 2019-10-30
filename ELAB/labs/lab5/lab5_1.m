im = (imread('sweets.png')) ;
[rows, columns] = size(im);

%% Es 1 : Kmeans
out = compute_local_descriptors(im, 5, 5, @compute_average_color) ;
descriptors = out.descriptors ;
[nrows, ncolumns] = size(descriptors) ;
rowsout = out.nt_rows ;
columnsout = out.nt_cols ;
labels = kmeans(descriptors, 5) ; 
img_labels = reshape(labels, [rowsout columnsout]) ;
img_labels = imresize(img_labels, [rowsout columnsout], 'nearest') ;

figure
subplot(1, 2, 1), imshow(im) ;
subplot(1, 2, 2), title('Original'), imagesc(img_labels), axis image, colorbar ;

%% Altri tentativi

%% 10 cluster
out = compute_local_descriptors(im, 5, 5, @compute_average_color) ;
descriptors = out.descriptors ;
[nrows, ncolumns] = size(descriptors) ;
rowsout = out.nt_rows ;
columnsout = out.nt_cols ;
labels = kmeans(descriptors, 10) ; 
img_labels = reshape(labels, [rowsout columnsout]) ;
img_labels = imresize(img_labels, [rowsout columnsout], 'nearest') ;


figure,
subplot(1, 2, 1), imshow(im) ;
subplot(1, 2, 2), imagesc(img_labels), title('10 cluster'), axis image, colorbar ;

%%  dimensione tasselli = 2
out = compute_local_descriptors(im, 2, 5, @compute_average_color) ;
descriptors = out.descriptors ;
[nrows, ncolumns] = size(descriptors) ;
rowsout = out.nt_rows ;
columnsout = out.nt_cols ;
labels = kmeans(descriptors, 5) ; 
img_labels = reshape(labels, [rowsout columnsout]) ;
img_labels = imresize(img_labels, [rowsout columnsout], 'nearest') ;

figure
subplot(1, 2, 1), imshow(im) ;
subplot(1, 2, 2), imagesc(img_labels), title(' dimensione tasselli = 2'), axis image, colorbar ;

%%  dimensione step = 3
out = compute_local_descriptors(im, 5, 3, @compute_average_color) ;
descriptors = out.descriptors ;
[nrows, ncolumns] = size(descriptors) ;
rowsout = out.nt_rows ;
columnsout = out.nt_cols ;
labels = kmeans(descriptors, 5) ; 
img_labels = reshape(labels, [rowsout columnsout]) ;
img_labels = imresize(img_labels, [rowsout columnsout], 'nearest') ;

figure
subplot(1, 2, 1), imshow(im) ;
subplot(1, 2, 2), imagesc(img_labels), title(' dimensione step = 3'), axis image, colorbar ;