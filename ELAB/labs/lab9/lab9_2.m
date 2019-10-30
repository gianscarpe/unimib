clear

im = imread('panda.png');
im = (im > 0);

disk_structel = strel('disk', 2);

dil = imdilate(im, disk_structel);

out = dil & (1 - im);
figure
subplot(1, 3, 1), imshow(im);
subplot(1, 3, 2), imshow(dil);
subplot(1, 3, 3), imshow(out);

% Nota: le operazioni di morfologia matematica considerano le regioni di 1
% come oggetto, 2 quelle di 0 come background -> imdilate nel nostro
% esempio rimuove il bianco di fondo, espandendo l'oggetto (panda) in nero

%% imerode

dil = imerode(im, disk_structel);

out = im & (1 - dil);
figure
subplot(1, 3, 1), imshow(im);
subplot(1, 3, 2), imshow(dil);
subplot(1, 3, 3), imshow(out);