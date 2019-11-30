im = imread('images/clutteredDesk.jpg');
im_pattern = imread('images/elephant.jpg');
figure, imshow(im)


im_points = detectSURFFeatures(im, 'MetricThreshold', 700);
pattern_points = detectSURFFeatures(im_pattern, 'MetricThreshold', 700);

figure
imshow(im_pattern), hold on
plot(pattern_points), hold off

[features1,valid_points1] = extractFeatures(im,im_points);
[features2,valid_points2] = extractFeatures(im_pattern,pattern_points);


indexPairs = matchFeatures(features1,features2);
matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);
figure; showMatchedFeatures(im,im_pattern,matchedPoints1,matchedPoints2, 'montage');

[tform, inliersPatter, inliersScene] = estimateGeometricTransform(matchedPoints2,matchedPoints1, 'affine');


points = load('elephantContour.mat');
points = points.elephantContour;

result = transformPointsForward(tform, points);

figure
imshow(im)
line(result(:, 1), result(:, 2), 'Color', 'red')

%% Sliding windonw
close all

im = im2double(imread('images/clutteredDesk.jpg'));

pattern_name = 'images/croppedPattern.jpg';

pattern = im2double(imread(pattern_name));
standard = std2(pattern);

avg = mean(mean(pattern)) ;

boxImage = (pattern - avg) ./ standard;
sceneImage = (im - avg) ./ standard;


passo = 5;
mins = [];
mins_position = {};
scale = [0.6];

for scala = scale
    boxImageR = imresize(boxImage, scala);
    map = [];
    indexMap = {};
    riga = size(boxImageR, 1) - 1;
    colonna = size(boxImageR, 2) - 1;
    for rr = 1:passo:size(sceneImage, 1) 
        for cc = 1:passo:size(sceneImage, 2)
            if ((cc+colonna) < size(sceneImage, 2)) && ...
                    ((rr+riga) < size(sceneImage, 1))
                D = sceneImage(rr : rr + riga, ...
                               cc : cc + colonna) - boxImageR;
                D = mean(abs(D(:)));
                map = [map, D];
                indexMap{end+1} = [rr, cc];
            end
        end
    end
    [m, start_pos] = min(map);
    mins = [mins, m];
    mins_position{end+1} = indexMap{start_pos};
end

[m, start_pos] = min(mins);
s = scale(start_pos);
dim = mins_position{start_pos};

box = imresize(boxImage, s);
result = im(dim(1):dim(1) + size(box, 1) - 1, dim(2):dim(2) + size(box, 2) - 1);
figure, imshow(result);


figure, 
imshow(im), hold on
plot(dim(2), dim(1), 'o', 'Color', 'red', 'MarkerSize', 15), hold off
 