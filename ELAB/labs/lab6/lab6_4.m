skin = im2double(imread('skin.png')) ;
[rs, cs, chs] = size(skin) ;
skin = reshape(skin, [rs * cs, chs]) ;

noskin = im2double(imread('noskin.png')) ;
[rn, cn, chn] = size(noskin) ;
noskin = reshape(noskin, [rn * cn, chn]) ;

%% Calcola classificatore bayesiano e lo salva
train_values = [skin ; noskin] ; % valori da etichettare

train_labels = [ ones(rs * cs, 1) ; zeros(rn * cn, 1) ]; % etichette da usare
% 1 per skin
% 0 per noskin

classifier_bayes = fitcnb(train_values, train_labels) ;
save ( 'classifier_bayes', 'classifier_bayes') ; 

%% Applica il classificatore sull'immagine
image = im2double(imread('test4.jpg')) ;
[ri, ci, chi] = size(image) ;
test_values = reshape(image, [ ri * ci, chi] ) ;

test_predicted = predict( classifier_bayes, test_values) ;
mask_predicted = reshape(test_predicted, [ri, ci]) ;
predicted = logical(mask_predicted) ;
imshow(mask_predicted) ;


%% Valutazione
gt = logical(imread('test4-gt.png')) ;
eval = confmat(gt, predicted ) 