building = im2double(imread('building.jpg')) ;

R = building( :, :, 1) ;
G = building( :, :, 2) ;
B = building( :, :, 3) ;

figure
subplot(2, 3, 2), imshow(building), title('original');
subplot(2, 3, 4), imshow(R), title('R') ;
subplot(2, 3, 5), imshow(G), title('G') ;
subplot(2, 3, 6), imshow(B), title('B') ;

building2 = rgb2ycbcr(building) ;
Y = building2( :, :, 1) ;
CB = building2( :, :, 2) ;
CR = building2( :, :, 3) ;

figure
subplot(2, 3, 2), imshow(building), title('original');
subplot(2, 3, 4), imshow(Y), title('Y') ;
subplot(2, 3, 5), imshow(CB), title('CB') ;
subplot(2, 3, 6), imshow(CR), title('CR') ;


building3 = building2 ;
building4 = building2 ;
building5 = building2 ;
building6 = building2 ;


building3(:, :, 1) =  0 ;
buildingRGB1 = ycbcr2rgb(building3) ;

building4(:, :, 2) =  0.5 ;
buildingRGB2 = ycbcr2rgb(building4) ;

building5(:, :, 3) =  0.5 ;
buildingRGB3 = ycbcr2rgb(building5) ;

building6(:, :, 3) =  0.5 ;
building6(:, :, 2) =  0.5 ;
buildingRGB4 = ycbcr2rgb(building6) ;

buildind7 = building; 
building7(:, :, 1 ) = 0 ;

figure
subplot(3, 3, 5), imshow(building), title('original') ;
subplot(3, 3, 1), imshow(buildingRGB1), title('Without Y') ;
subplot(3, 3, 2), imshow(buildingRGB2), title('Without CB') ; % Da blu a giallo
subplot(3, 3, 3), imshow(buildingRGB3), title('Without CR') ; % Da rosso a verde
subplot(3, 3, 4), imshow(buildingRGB4) ;
subplot(3, 3, 6), imshow(building7), title('Without R');

buildingHSV = rgb2hsv(building) ;
H = buildingHSV(:, : , 1) ;
S = buildingHSV(:, : , 2) ;
V = buildingHSV(:, : , 3) ;

figure
subplot(2, 3, 2), imshow(building) ;
subplot(2, 3, 4), imshow(H) ;
subplot(2, 3, 5), imshow(S) ;
subplot(2, 3, 6), imshow(V) ;