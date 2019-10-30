function out = test_classifier(descriptor, labels, cv)
  % Testa un classificatore dati descrittori, etichette e partizionamento.
  % Parametri: 
  %   descriptor : descrittore/i da usare per la classificazione
  %   labels : etichette delle immagini
  %   cv : output di cvpartition con le partizioni train set / test set
  
  train_values = descriptor(cv.training,:);
  train_labels = labels(cv.training);
  
  test_values  = descriptor(cv.test,:);
  test_labels  = labels(cv.test);
  
  c = fitcknn(train_values, train_labels, 'NumNeighbors', 7);
  
  train_predicted = predict(c, train_values);
  train_perf = confmat(train_labels, train_predicted);

  test_predicted = predict(c, test_values);
  test_perf = confmat(test_labels, test_predicted);
  
  out = [train_perf, test_perf];
  
end