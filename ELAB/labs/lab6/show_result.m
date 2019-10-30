% Mostra i pixel dell'immagine corrispondenti alla maschera binaria
% image immagine di input
% mask maschera binaria dell'immagine
function show_result(image,mask)
  
  [r,c,ch] = size(image);

  mask3 = double(repmat(mask,[1,1,ch]));

  region = im2double(image).*mask3;

  figure;
  subplot(1,2,1),imshow(image);
  subplot(1,2,2),imshow(region);

end
