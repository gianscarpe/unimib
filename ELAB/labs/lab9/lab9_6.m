clear

im = im2double(imread('buttons1.png'));
bw = im2bw(im, 0.5);
labels = bwlabel(bw);

nlabels = max(labels(:));
min_area = 9999;
for i = 1 : nlabels
    temp = sum(sum(labels == i));
    if (min_area > temp)
        min_area = temp;
    end
end

count = 0;
for i = 1 : nlabels
    temp = sum(sum(labels == i));
    if (temp >= min_area)
        count = count + round(temp / min_area);
    end
end



figure
subplot(1, 2, 1), imshow(bw);
subplot(1, 2, 2), imagesc(labels), axis image, colorbar;


%% Soluzione
bw = 1 - bw;
labels = bwlabel(bw);
count = round((max(labels(:)) - 1) / 4);

