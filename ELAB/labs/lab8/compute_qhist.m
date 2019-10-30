function out=compute_qhist(image)
  if ~isinteger(image)
    error('L''immagine deve essere RGB');
  end

  [r,c,ch] = size(image);
    
  if (ch==1) 
    image = cat(3,image,image,image);
  end

  pixs = double(reshape(image,r*c,3));
  
  pixs = floor(pixs/16);
  
  qvalues = pixs(:,1)+pixs(:,2)*16+pixs(:,3)*16*16;
  
  out = histcounts(qvalues,0:4096)/size(pixs,1);
  
end