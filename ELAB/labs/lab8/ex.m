clc
clear
f = fopen('images.list');
list = textscan(f, '%s');
fclose(f);
images = list{1};
labels = textread('labels.list', '%s');

descriptors = [];
for i = 1 : size(images, 1)
    im = im2double(imresize(rgb2gray(imread(['simplicity/' images{i}])), [64 96]));
    feature = extractHOGFeatures(im, 'CellSize', [16 8], 'BlockSize', [2 2]);
    descriptors = [descriptors ; feature];
end


%% Machine learning

[trainInd, valInd] = dividerand(size(images, 1), 0.8, 0.2);
model = fitcecoc(descriptors(trainInd, :), labels(trainInd));
eval = predict(model, descriptors(valInd, :));
[c, order] = confusionmat(eval, labels(valInd))

accuracy = sum(diag(c)) / (sum(c(:)))


for i = 1:size(order, 1)
    ['Classe : ', order{i}]
    precision = c(i, i) / sum(c(:, i))
    recall = c(i, i) / sum(c(i, :))
    
end