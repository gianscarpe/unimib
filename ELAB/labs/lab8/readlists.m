function [images,labels]=readlists()
  f=fopen('images.list');
  z = textscan(f,'%s');
  fclose(f);
  images = z{:}; 

  f=fopen('labels.list');
  l = textscan(f,'%s');
  labels = l{:};
  fclose(f);
end
