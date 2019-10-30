function out=compute_lbp(image)

  out = extractLBPFeatures(image,'NumNeighbors',8,'Radius',1,'Upright',true);
    

end