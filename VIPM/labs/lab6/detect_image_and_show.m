function detect_image_and_show(img, i)

     detector = vision.CascadeObjectDetector('cascade.xml');
 
     bbox = step(detector, img); % detect a stop sign
 
     % Insert bounding box rectangles and return marked image
     detectedImg = insertObjectAnnotation(img, 'rectangle', bbox, 'car');
     imwrite(detectedImg, ['test' num2str(i) '.png']);
 
     %figure; imshow(detectedImg); % display the detected stop sign
end