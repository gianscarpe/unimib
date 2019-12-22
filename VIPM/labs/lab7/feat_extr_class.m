net=alexnet;
%  analyzeNetwork(net) % visualizzazione
sz=net.Layers(1).InputSize;
layer='fc6'; % fc6

%% estrazione features
indir='image.orig/';
ims=dir([indir '*.jpg']);
feat_tr=[];
labels_tr=[];
Nim4tr=70;
tic
for class=0:9
    for nimage=0:Nim4tr-1
        disp([num2str(class) '-' num2str(nimage)]);
        im=double(imread([indir num2str(100*class+nimage) '.jpg']));
        im=imresize(im,sz(1:2));
        feat_tmp=activations(net,im,layer,'OutputAs','rows');
        feat_tr=[feat_tr; feat_tmp];
    end
    labels_tr=[labels_tr; class*ones(Nim4tr,1)];
end
toc

labels_te=[];
feat_te=[];
tic
for class=0:9
    for nimage=Nim4tr:99
        disp([num2str(class) '-' num2str(nimage)]);
        im=double(imread([indir num2str(100*class+nimage) '.jpg']));
        im=imresize(im,sz(1:2));
        feat_tmp=activations(net,im,layer,'OutputAs','rows');
        feat_te=[feat_te; feat_tmp];
    end
    labels_te=[labels_te; class*ones(100-Nim4tr,1)];
end
toc

%% feat normalization
feat_tr=feat_tr./sqrt(sum(feat_tr.^2,2));
feat_te=feat_te./sqrt(sum(feat_te.^2,2));

%% classificazione con 1-NN
template = templateSVM(...
        'KernelFunction', 'polynomial', ...
        'PolynomialOrder', 3, ...
        'KernelScale', 'auto', ...
        'BoxConstraint'q, 1, ...
        'Standardize', true);
    
classifier = fitcecoc(...
        feat_tr, ...
        labels_tr, ...
        'Learners', template, ...
        'Coding', 'onevsone');
    t
%%
lab_pred_te=labels_tr(idx_pred_te);
acc=numel(find(lab_pred_te==labels_te))/numel(labels_te)
