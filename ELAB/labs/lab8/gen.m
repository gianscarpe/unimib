[trainInd, testInd] = dividerand(1000, 0.8, 0.2);

for i = trainInd
    imread(['simplicity/' images{i}]);
    im = imread(['simplicity/' images{i}]);
    mkdir(['dataset/train/' labels{i}]);
    imwrite(im, ['dataset/train/' labels{i} '/' images{i}])
end

for i = testInd
    imread(['simplicity/' images{i}]);
    im = imread(['simplicity/' images{i}]);
    mkdir(['dataset/test/' labels{i}]);
    imwrite(im, ['dataset/test/' labels{i} '/' images{i}])
end