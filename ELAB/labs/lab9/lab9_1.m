clear

im = imread('disney.png');
structelement = strel('square', 3);
out_dilate = imdilate(im, structelement);
out_dilate = imdilate(out_dilate, structelement);
out_dilate = imdilate(out_dilate, structelement);
out_dilate = imdilate(out_dilate, structelement);
out_dilate = imdilate(out_dilate, structelement);

figure
subplot(1, 3, 1), imshow(im);
subplot(1, 3, 2), imshow(out_dilate);

%% Secondo punto: relazione tra elementi strutturanti
structelement_new = strel('square', 3 + 2 * 4);
out_dilate = imdilate(im, structelement_new);
subplot(1, 3, 3), imshow(out_dilate);

% Non noto differenze: applicare n elementi strutturanti quadrati di
% dimensione m == applicare un elemento strutturante quadrato di dimensione
% m + 2 * n