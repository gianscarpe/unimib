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

classifier_knn = fitcknn(train_values, train_labels) ;
save ( 'classifier_knn', 'classifier_knn') ; 

%% Applica il classificatore sull'immagine
image = im2double(imread('test4.jpg')) ;
[ri, ci, chi] = size(image) ;
test_values = reshape(image, [ ri * ci, chi] ) ;

test_predicted = predict( classifier_knn, test_values) ;
mask_predicted = reshape(test_predicted, [ri, ci]) ;
predicted = logical(mask_predicted) ;
imshow(mask_predicted) ;


%% Valutazione
gt = logical(imread('test4-gt.png')) ;
eval = confmat(gt, predicted ) 

clear
%% Punto E

skin = im2double(imread('skin.png')) ;
[rs, cs, chs] = size(skin) ;
skin = reshape(skin, [rs * cs, chs]) ;
skin = skin(1 : 5000, 1 : chs) ;
N = 5000;

noskin = im2double(imread('noskin.png')) ;
[rn, cn, chn] = size(noskin) ;
noskin = reshape(noskin, [rn * cn, chn]) ;
noskin = noskin(1 : 5000, 1 : chn) ;

%% Calcola classificatore bayesiano e lo salva
train_values = [skin ; noskin] ; % valori da etichettare

train_labels = [ ones(N, 1) ; zeros(N, 1) ]; % etichette da usare
% 1 per skin
% 0 per noskin

NumNeigh = 15 ;
classifier_knn = fitcknn(train_values, train_labels, 'NumNeighbors', NumNeigh) ;
save ( 'classifier_knn', 'classifier_knn') ; 

%% Applica il classificatore sull'immagine
image = im2double(imread('test4.jpg')) ;
[ri, ci, chi] = size(image) ;
test_values = reshape(image, [ ri * ci, chi] ) ;

test_predicted = predict( classifier_knn, test_values) ;
mask_predicted = reshape(test_predicted, [ri, ci]) ;
predicted = logical(mask_predicted) ;
figure
imshow(mask_predicted) ;


%% Valutazione
gt = logical(imread('test4-gt.png')) ;
eval = confmat(gt, predicted ) 

% NumNeigh = 3
% Noto che con meno dati il classificatore peggiora sensibilmente, da 95% a
% 82 %

% NumNeigh = 7
% Noto che con meno dati il classificatore peggiora sensibilmente, da 95% a
% 81 % -> l'accuratezza diminuisce

% NumNeigh = 11
% Noto che con meno dati il classificatore peggiora sensibilmente, da 95% a
% 81 % -> l'accuratezza diminuisce

% NumNeigh = 15
% Noto che con meno dati il classificatore peggiora sensibilmente, da 95% a
% 80.77 % -> l'accuratezza diminuisce