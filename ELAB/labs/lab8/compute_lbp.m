function out=compute_lbp(image)

  if ~isinteger(image)
    error('L''immagine deve essere RGB');
  end

  ch = size(image,3);
  
  if (ch==3) 
    image = rgb2gray(image);
  end

  out = extractLBPFeatures(image,'NumNeighbors',8,'Radius',1,'Upright',true);
    

end