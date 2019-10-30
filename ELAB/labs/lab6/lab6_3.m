skin = im2double(imread('skin.png')) ;
[rs, cs, chs] = size(skin) ;
skin = reshape(skin, [rs * cs, chs]) ;

noskin = im2double(imread('noskin.png')) ;
[rn, cn, chn] = size(noskin) ;
noskin = reshape(noskin, [rn * cn, chn]) ;

%% Classificatore MINIMA DISTANZA (EUCLIDEA)
ms = mean(skin) ;
mns = mean(noskin) ;

image = im2double(imread('test4.jpg')) ;
[ri, ci, chi] = size(image) ;
pixs = reshape(image, [ ri * ci, chi] ) ;

dist_s = pdist2(pixs, ms) ; % distanza di Pi da ms (per ogni i)
dist_ns = pdist2(pixs, mns) ; % distanza di Pi da msn (per ogni i)

predicted = dist_s < dist_ns ; % TRUE se dist_s < dist_ns
predicted = reshape(predicted, [ri, ci] ) ;
imshow(predicted) ;

%% Valutazione
gt = logical(imread('test4-gt.png')) ;
eval = confmat(gt, predicted) 