%% Script riassuntivo
clc
clear
load('matlab');
load('cnn');
cv = cvpartition(labels, 'Holdout', 0.2) ;

out = test_classifier(cedd, labels, cv);
cedd_result = out(2).accuracy;

out = test_classifier(lbp, labels, cv);
lbp_result = out(2).accuracy;

out = test_classifier(qhist, labels, cv);
qhist_result = out(2).accuracy;

out = test_classifier(cnn, labels, cv);
cnn_result = out(2).accuracy;

out = test_classifier(cedd_partitions, labels, cv);
ceddp_result = out(2).accuracy;

descriptors = ["CEDD", "LBP", "QHIST", "CNN", "CEDD con 16 sottoimmagini"];
results = [cedd_result, lbp_result, qhist_result, cnn_result, ceddp_result] ;

ndescriptors = 5 ;
figure
bar(1:ndescriptors, results)     
xlabel('Descriptors')
ylabel('% of accuracy')
set(gca, 'XTick', 1:ndescriptors, 'XTickLabel', descriptors);
