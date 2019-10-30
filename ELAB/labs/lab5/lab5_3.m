text1 = im2double(imread('text1.png')) ;

t = 5 ;
out = compute_local_descriptors(text1, t, 5, @compute_standard_deviation) ;
descriptors = out.descriptors ;
[nrows, ncolumns] = size(descriptors) ;
rowsout = out.nt_rows ;
columnsout = out.nt_cols ;
[rows, columns] = size(text1) ;

labels = kmeans(descriptors, 5) ; 
img_labels = reshape(labels, [rowsout columnsout]) ;
img_labels = imresize(img_labels, t, 'nearest') ;

figure
subplot(1, 2, 1), imshow(text1) ;
subplot(1, 2, 2), title('text1 per texture'), imagesc(img_labels), axis image, ...
    colorbar ;

%% Es 2

text2 = im2double(imread('text2.png')) ;

t = 12 ;
out = compute_local_descriptors(text2, t, 12, @compute_standard_deviation) ;
descriptors = out.descriptors ;
[nrows, ncolumns] = size(descriptors) ;
rowsout = out.nt_rows ;
columnsout = out.nt_cols ;
[rows, columns] = size(text2) ;

labels = kmeans(descriptors, 4) ; 
img_labels = reshape(labels, [rowsout columnsout]) ;
img_labels = imresize(img_labels, t, 'nearest') ;

figure
subplot(1, 2, 1), imshow(text2) ;
subplot(1, 2, 2), title('Original'), imagesc(img_labels), axis image, ...
    colorbar ;

%% Es 3

text3 = im2double(imread('text3.png')) ;

t = 26 ;
out = compute_local_descriptors(text3, t, 10, @compute_standard_deviation) ;
descriptors = out.descriptors ;
[nrows, ncolumns] = size(descriptors) ;
rowsout = out.nt_rows ;
columnsout = out.nt_cols ;
[rows, columns] = size(text3) ;

labels = kmeans(descriptors, 5) ; 
img_labels = reshape(labels, [rowsout columnsout]) ;
img_labels = imresize(img_labels, t, 'nearest') ;

figure
subplot(1, 2, 1), imshow(text3) ;
subplot(1, 2, 2), title('Original'), imagesc(img_labels), axis image, ...
    colorbar ;