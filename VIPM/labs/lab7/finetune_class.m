clear all
clc
close all

%% caricamento rete
net=alexnet;
sz=net.Layers(1).InputSize;

%% cut layers
layersTransfer=net.Layers(1:end-2);
layersTransfer=freezeWeights(layersTransfer);

%% replace layers
numClasses=10;
layers=[
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,...
    'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

%% preparazione dati
imds=imageDatastore('image.orig/');
labels=[];
for ii=1:size(imds.Files,1)
    name=imds.Files{ii,1};
    [p,n,ex]=fileparts(name);
    class=floor(str2double(n)/100);
    labels=[labels; class];
end
labels=categorical(labels);
imds=imageDatastore('image.orig/','labels',labels);

%% divisione train-tes
[imdsTrain,imdsTest]=splitEachLabel(imds,0.7,'randomized');

%% data augmentation
pixelRange=[-5 5];
imageAugmengter=imageDataAugmenter(...
    'RandXReflection',true,...
    'RandXTranslation',pixelRange,...
    'RandYTranslation',pixelRange);
augimdsTrain=augmentedImageDatastore(sz(1:2),imdsTrain,...
    'DataAugmentation',imageAugmengter);
augimdsTest=augmentedImageDatastore(sz(1:2),imdsTest);

%% configurazione fine tuning
options=trainingOptions('rmsprop',...
    'MiniBatchSize',32,...
    'MaxEpochs',1,...
    'InitialLearnRate',1e-3,...
    'Shuffle','every-epoch',...
    'ValidationData',augimdsTest,...
    'ValidationFrequency',3,...
    'Verbose',false,...
    'Plots','training-progress');

%% training vero e proprio
netTransfer=trainNetwork(augimdsTrain,layers,options);

%% test
[lab_pred_te,scores]=classify(netTransfer,augimdsTest);

%% performance
acc=numel(find(lab_pred_te==imdsTest.Labels))/numel(lab_pred_te)
