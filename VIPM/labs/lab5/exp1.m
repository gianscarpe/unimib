clear all
disp('creazione griglia');
pointPositions=[];
featStep=30; % TBD
imsize=800; % TBD
choice = 'SURF'

tic
for ii=featStep:featStep:imsize-featStep
    for jj=featStep:featStep:imsize-featStep
        pointPositions=[pointPositions; ii jj];
    end
end


%% estrazione features
disp('estrazione features');
Nim4training=70; % TBD, fix nel caso di validation set
features=[];
labels=[];

for class=0:9
    for nimage=0:Nim4training-1 % TBD, random??
        im=im2double(imread(['./image.orig/' num2str(100*class+nimage) '.jpg']));
        im=imresize(im,[imsize imsize]);
        im=rgb2gray(im);
        [imfeatures,dontcare]=extractFeatures(im,pointPositions,'Method', choice);
        features=[features; imfeatures];
        labels=[labels; repmat(class,size(imfeatures,1),1) ...
                        repmat(nimage,size(imfeatures,1),1)];
    end
end

%% creazione vocabolario
disp('kmeans')
K=100; % TBD

[IDX,C]=kmeans(features,K);


%% istogrammi training
disp('rappresentazione BOW training')
BOW_tr=[];
labels_tr=[];
for class=0:9
    for nimage=1:Nim4training-1
        u=find(labels(:,1)==class & labels(:,2)==nimage);
        imfeaturesIDX=IDX(u);
        H=hist(imfeaturesIDX,1:K);
        H=H./sum(H);
        BOW_tr=[BOW_tr; H];
        labels_tr=[labels_tr; class];
    end
end
toc

%% classificatore
disp('Training')

ind = randperm(length(BOW_tr));

template = templateSVM(...
        'KernelFunction', 'polynomial', ...
        'PolynomialOrder', 3, ...
        'KernelScale', 'auto', ...
        'BoxConstraint', 1, ...
        'Standardize', true);
    
classifier = fitcecoc(...
        BOW_tr(ind, :), ...
        labels_tr(ind), ...
        'Learners', template, ...
        'Coding', 'onevsone');

%% istogrammi test
disp('rappresentazione BOW test')
BOW_te=[];
labels_te=[];
tic
for class=0:9
    for nimage=Nim4training:99
        im=im2double(imread(['./image.orig/' num2str(100*class+nimage) '.jpg']));
        im=imresize(im,[imsize imsize]);
        im=rgb2gray(im);
        [imfeatures,dontcare]=extractFeatures(im,pointPositions,'Method',choice);        
        %%%%
        D=pdist2(imfeatures,C);
        [dontcare,words]=min(D,[],2);
        %%%%
        H=hist(words,1:K);
        H=H./sum(H);
        BOW_te=[BOW_te; H];
        labels_te=[labels_te; class];
    end
end
toc

%% classificazione del test set
disp('classificazione test set')
% TBD! aggiornare con il vostro classificatore
tic
predicted_class=predict(classifier, BOW_te);

toc

%% misurazione performance
CM=confusionmat(labels_te,predicted_class);
CM=CM./repmat(sum(CM,2),1,size(CM,2));
CM
accuracy=mean(diag(CM))