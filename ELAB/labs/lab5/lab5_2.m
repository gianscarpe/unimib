segm = im2double(imread('segmentation.png')) ;

out = compute_local_descriptors(segm, 5, 5, @compute_standard_deviation) ;
descriptors = out.descriptors ;
[nrows, ncolumns] = size(descriptors) ;
rowsout = out.nt_rows ;
columnsout = out.nt_cols ;
labels = kmeans(descriptors, 5) ; 
img_labels = reshape(labels, [rowsout columnsout]) ;
img_labels = imresize(img_labels, 5, 'nearest') ;

figure
subplot(1, 2, 1), imshow(segm) ;
subplot(1, 2, 2), title('Original'), imagesc(img_labels), axis image, ...
    colorbar ;