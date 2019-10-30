skin = im2double(imread('skin.png')) ;
[rs, cs, chs] = size(skin) ;
skin = reshape(skin, [rs * cs, chs]) ;

noskin = im2double(imread('noskin.png')) ;
[rn, cn, chn] = size(noskin) ;
noskin = reshape(noskin, [rn * cn, chn]) ;

%% Calcola classificatore tree e lo salva
train_values = [skin ; noskin] ; % valori da etichettare

train_labels = [ ones(rs * cs, 1) ; zeros(rn * cn, 1) ]; % etichette da usare
% 1 per skin
% 0 per noskin

classifier_cart = fitctree(train_values, train_labels) ;
save ( 'classifier_cart', 'classifier_cart') ; 

%% Applica il classificatore sull'immagine
image = im2double(imread('test4.jpg')) ;
[ri, ci, chi] = size(image) ;
test_values = reshape(image, [ ri * ci, chi] ) ;

test_predicted = predict( classifier_cart, test_values) ;
mask_predicted = reshape(test_predicted, [ri, ci]) ;
predicted = logical(mask_predicted) ;
imshow(mask_predicted), title('Dati originali') ;
view(classifier_cart, 'Mode', 'Graph');

%% Valutazione
gt = logical(imread('test4-gt.png')) ;
eval = confmat(gt, predicted ) 

clear

%% Riduco i dati

skin = im2double(imread('skin.png')) ;
[rs, cs, chs] = size(skin) ;
skin = reshape(skin, [rs * cs, chs]) ;
skin = skin(1 : 400000, 1 : 3);

noskin = im2double(imread('noskin.png')) ;
[rn, cn, chn] = size(noskin) ;
noskin = reshape(noskin, [rn * cn, chn]) ;
noskin = noskin(1 : 400000, 1 : 3);

%% Calcola classificatore tree e lo salva
train_values = [skin ; noskin] ; % valori da etichettare

train_labels = [ ones(size(skin, 1), 1) ; zeros(size(noskin, 1), 1) ]; % etichette da usare
% 1 per skin
% 0 per noskin

classifier_cart = fitctree(train_values, train_labels) ;
save ( 'classifier_cart', 'classifier_cart') ; 

%% Applica il classificatore sull'immagine
image = im2double(imread('test4.jpg')) ;
[ri, ci, chi] = size(image) ;
test_values = reshape(image, [ ri * ci, chi] ) ;

test_predicted = predict( classifier_cart, test_values) ;
mask_predicted = reshape(test_predicted, [ri, ci]) ;
predicted = logical(mask_predicted) ;
imshow(mask_predicted), title('Dati originali')  ;
view(classifier_cart, 'Mode', 'Graph');

%% Valutazione
gt = logical(imread('test4-gt.png')) ;
eval = confmat(gt, predicted ) 

%% Nota:
% Per creare un classificatore dovrei dare lo stesso numero di dati per
% classe. INOLTRE, i dati da inserire devono essere RAPPRESENTATIVI della
% classe: prendere i primi n dati (approccio sistematico) prende dati tra
% loro molto simili (nel caso di noskin in particolare) 
% QUINDI: dati il più possibili eterogenei; più dati è sempre meglio