disp('creazione griglia');
pointPositions=[];
featStep=30; % TBD
imsize=500; % TBD
tic
for ii=featStep:featStep:imsize-featStep
    for jj=featStep:featStep:imsize-featStep
        pointPositions=[pointPositions; ii jj];
    end
end
toc

%% estrazione features
disp('estrazione features');
Nim4training=70; % TBD, fix nel caso di validation set
features=[];
labels=[];
tic
for class=0:9
    for nimage=0:Nim4training-1 % TBD, random??
        im=im2double(imread(['./image.orig/' num2str(100*class+nimage) '.jpg']));
        im=imresize(im,[imsize imsize]);
        im=rgb2gray(im);
        [imfeatures,dontcare]=extractFeatures(im,pointPositions,'Method','SURF');
        features=[features; imfeatures];
        labels=[labels; repmat(class,size(imfeatures,1),1) ...
                        repmat(nimage,size(imfeatures,1),1)];
    end
end
toc

%% creazione vocabolario
disp('kmeans')
K=100; % TBD
tic
[IDX,C]=kmeans(features,K);
toc

%% istogrammi training
disp('rappresentazione BOW training')
BOW_tr=[];
labels_tr=[];
tic
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
% TBD!!!
% input: BOW_tr e labels_tr

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
        [imfeatures,dontcare]=extractFeatures(im,pointPositions,'Method','SURF');        
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
predicted_class=[];
tic
for ii=1:size(BOW_te,1)
    H=BOW_te(ii,:);
    DH=pdist2(H,BOW_tr);
    u=find(DH==min(DH));
    predicted_class=[predicted_class; labels_tr(u(1))];
end
toc

%% misurazione performance
CM=confusionmat(labels_te,predicted_class);
CM=CM./repmat(sum(CM,2),1,size(CM,2));
CM
accuracy=mean(diag(CM))