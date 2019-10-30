
  [images, labels] = readlists();
  
  nimages = numel(images);
  
  lbp = [];
  qhist = [];
  cedd = [] ;
  cedd_partitions = [];
  for n = 1 : nimages
    im = imread(['simplicity/' images{n}]);
    lbp = [lbp; compute_lbp(im)] ;
    qhist = [qhist; compute_qhist(im)];
    cedd = [cedd ; compute_CEDD(im) ];
    v = divide_image(im, 4) ;
    cedd_partition = [];
    for i = 1 : length(v) 
        cedd_partition = [ cedd_partition, compute_CEDD(v{i}) ] ;
    end
    cedd_partitions = [cedd_partitions ; cedd_partition];
  end
     
  
  save
