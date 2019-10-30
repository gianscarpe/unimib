clear

im = im2double(imread('mondrian.jpg') ) ;
gray = rgb2gray(im) ;

prewitt = edge(gray, 'prewitt') ;
sobel = edge(gray, 'sobel') ;
roberts = edge(gray, 'roberts') ;

figure, title('Automatic thresholding')
subplot(3, 3, 2), imshow(gray), title('Original') ;
subplot(3, 3, 4), imshow(prewitt), title('prewitt') ;
subplot(3, 3, 5), imshow(sobel), title('sobel') ;
subplot(3, 3, 6), imshow(roberts), title('roberts') ;
subplot(3, 3, 7), imshow(sobel - prewitt), title('sobel - prewitt') ;

%% T = 0.1 
T = 0.1 ; % Moltissimi dettagli in più. Occhi ben identificati sul viso

prewitt2 = edge(gray, 'prewitt', T) ;
sobel2 = edge(gray, 'sobel', T) ;
roberts2 = edge(gray, 'roberts', T) ;

figure, title('T = 0.1 thresholding')
subplot(3, 3, 2), imshow(gray), title('Original') ;
subplot(3, 3, 4), imshow(prewitt2), title('prewitt') ;
subplot(3, 3, 5), imshow(sobel2), title('sobel') ;
subplot(3, 3, 6), imshow(roberts2), title('roberts') ;

%% T = 0.01
T = 0.01 ; % Moltissimi dettagli in più. Troppi

prewitt3 = edge(gray, 'prewitt', T) ;
sobel3 = edge(gray, 'sobel', T) ;
roberts3 = edge(gray, 'roberts', T) ;

figure, title('T = 0.01 thresholding')
subplot(3, 3, 2), imshow(gray), title('Original') ;
subplot(3, 3, 4), imshow(prewitt3), title('prewitt') ;
subplot(3, 3, 5), imshow(sobel3), title('sobel') ;
subplot(3, 3, 6), imshow(roberts3), title('roberts') ;
