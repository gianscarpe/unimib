clear
close

%% Trovare la regione di componenti connesse più piccola

gray = im2double(imread('coins.png')) ;

imshow(gray) ;
T = 0.90 ; % Soggetti su sfondo bianco
mask = im2bw(gray, T) ;
bw = 1 - mask ;
labels = bwlabel(bw) ;
figure
imagesc(labels), axis image, colorbar ; 


%% Algoritmo
labels_value = unique(labels) ; % estrae i valori presenti nella matrice

frequency = [labels_value,histc(labels(:),labels_value)]; 
% Creo una matrice n x 2 : nella prima colonna ho i valori delle label,
% nella seconda ho la relativa frequenza (ottenuta con histc( Matrice,
% valori da contare nella matrice)


%%% Descrittore: la regione connessa più piccola è quella con la minore
%%% area (nell'esempio, la moneta da un centesimo)

[minVal, minInd] = min( frequency(:,2) );
% Estraggo la frequenza minima e l'indice di riga corrispondente

T = frequency(minInd, 1); % Valore della label con frequenza minima

mask_smallest = (labels == T) ; % Mascherea delle label
imshow(mask_smallest) ;

s = strel('disk', 3);
result = imdilate(mask_smallest, s);
figure
imshow(result)