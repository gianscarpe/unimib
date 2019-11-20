%%% Lab3

im1 = rgb2gray(imread('images/left.png'));
im2 = rgb2gray(imread('images/right.png'));

surf_im1 = detectSURFFeatures(im1);
surf_im2 = detectSURFFeatures(im2);

[features_im1,validPoints_im1] = extractFeatures(im1,surf_im1);

[features_im2,validPoints_im2] = extractFeatures(im2,surf_im2);

indexPairs = matchFeatures(features_im1, features_im2) ;
matchedPoints1 = validPoints_im1(indexPairs(:, 1));
matchedPoints2 = validPoints_im2(indexPairs(:, 2));
 
% Visualize putative matches
figure; showMatchedFeatures(im1,im2,matchedPoints1,matchedPoints2);

[F, inliersIndex, status] =estimateFundamentalMatrix(matchedPoints1,matchedPoints2,...
       'Method', 'MSAC', 'NumTrials', 2000);
   
   
matchedPoints1 = validPoints_im1(indexPairs(inliersIndex, 1));
matchedPoints2 = validPoints_im2(indexPairs(inliersIndex, 2));
 
% Visualize putative matches
figure; showMatchedFeatures(im1,im2,matchedPoints1,matchedPoints2);
% Compute the rectification transformations.
[t1, t2] = estimateUncalibratedRectification(F, matchedPoints1, ...
                 matchedPoints2, size(im2));
    
% Rectify the stereo images using projective transformations t1 and t2.
[I1Rect, I2Rect] = rectifyStereoImages(im1, im2, t1, t2);
figure; imshowpair(I1Rect, I2Rect, 'diff')

disparityMap = disparity(I1Rect,I2Rect);
figure; imshow(disparityMap, [0, 64])