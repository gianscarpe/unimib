
function out=confmat(gt,predicted)

  [cm_raw,order]=confusionmat(gt(:),predicted(:));
  
  out.cm_raw = cm_raw;
  out.cm = cm_raw./repmat(sum(cm_raw,2),1,size(cm_raw,2));
  out.labels = order;
  out.accuracy = sum(diag(cm_raw))/numel(gt);
end