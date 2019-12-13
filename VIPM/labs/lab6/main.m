%% Training
positive_bb = {};
positive_images_path = {};
positive_images = 550;


for i=1:positive_images
    positive_bb{i, 1} = ['./CarDataset/train/positives/pos-' num2str(i-1) '.pgm'];
    im=im2double(imread(['./CarDataset/train/positives/pos-' num2str(i-1) '.pgm']));
    positive_bb{i, 2} = [1, 1, size(im, 2), size(im, 1) ];
    
end


negativeImages = imageDatastore('./CarDataset/train/negatives');

positives = cell2table(positive_bb);
trainCascadeObjectDetector('cascade.xml',positives, ...
    negativeImages,'FalseAlarmRate',0.1,'NumCascadeStages',5);

%% Test
images_2_test = 300;

for i=[1, 2, 3, 122, 123, 124, 587, 588, 589, 822, 823, 824]
    im = im2double(imread(['./CarDataset/TestImages_Scale/' num2str(i) '.jpg']));
    detect_image_and_show(im, i);
end

