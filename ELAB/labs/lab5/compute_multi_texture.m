function out=compute_multi_texture(image)
  gray = rgb2gray(image);
  out = [compute_lbp(gray), compute_average_color(image) ] ;

end