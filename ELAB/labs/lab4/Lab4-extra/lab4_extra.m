clear
close all

%% ES extra - Mario
coin_RGB = im2double(imread('mario_coin.png')) ;
coin = rgb2gray(coin_RGB) ;

mario1_RGB = im2double(imread('mario1.png')) ;
mario1 = rgb2gray(mario1_RGB) ;

figure
subplot(1, 2, 1), imshow(coin), title('Texture moneta') ;
subplot(1, 2, 2), imshow(mario1), title('Mario 1') ;

%% Risultati 1
out = imfilter(mario1, coin) ;
figure
imagesc(out), axis image, colorbar ;

%% Valore medio template - risultati 2
avg = mean(mean(coin)) ;

coinB = (coin - avg) ;
mario1B = mario1 - avg  ;

figure
subplot(1, 2, 1), imshow(coinB), title('Texture moneta') ;
subplot(1, 2, 2), imshow(mario1B), title('Mario 1') ;


out2 = imfilter(mario1, coinB) ;

figure
imagesc(out2), axis image, colorbar ;

%% Extra
valorePuntoCentraleCalcolato = sum(sum(coinB .^2)) ;
valorePuntiMassimiImmagine = max(unique(out2)) ;

HoRagione = (round(valorePuntoCentraleCalcolato, 3) == round(valorePuntiMassimiImmagine, 3)) ;


%% Posizione delle monete
coinsInMario = (out2 > (valorePuntoCentraleCalcolato - 1.3  )) ;
figure
imshow(coinsInMario); 

%% Consierazioni circa Extra e altre cose
% (1) Noto che semplicemente applicando coin come filtro di convoluzione
% all'immagine ottengo out INUTILE. Difatti, coin (immagine in scala di
% grigi di soli valori positivi) applicata a mario1 genera valori molto
% alti in corrispondenza dei bianchi (nuvole, etc...). Posso comunque
% sapere il valore che assume nella moneta (vedi (4) )

% (2) Sottrando da coin un valore, ottengo una maschera di valori sia
% positivi sia negativi. Per avere equilibrio, decido di sottrarre per la
% media dei valori di grigio. Il nuovo template coinB non fa più schizzare
% i valori di binaco su mario1 (noto che mario1 e mario1B portano allo
% stesso risultato) in out2. Anzi, so che in out2 i valori massimi in un punto
% si  ottengono se per ogni pixel della regione del punto, questo ha valori
% alti se in CoinB lo stesso pixel è positivo, bassi altrimenti

% (3) I valori massimi in out2 saranno i centri delle monete (o i centri di
% regioni molto molto molto simili per dimensioni e livelli di grigio).
% Nota che il valore è esattamente quello previsto IFF la moneta è
% interamente visibile nella schermata di mario, altrimenti il valore
% potrebbe essere leggermente inferiore

% (4) Posso predire il valore dei pixel di centro della moneta, che saranno
% pari a sum(sum(coinB .^2)) (vedi Extra HoRagione)