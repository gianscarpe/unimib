im = im2double( imread('cosamanca-0.png') ) ;
im = rgb2gray(im) ;
[rows, columns] = size(im) ;
out = 1 - im ;
bw = im2bw(out, 0.42) ;

figure
imshow(bw) ;

maskR = bw ;
Trows = max(sum(bw, 2));
for i = 1 : rows
    maskR(i, :) = (sum(bw(i, :)) > Trows - 10); 
end


maskC = zeros(rows, columns) ;
TColumns = max(sum(bw, 1));
for j = 1 : columns
    maskC(:, j) = (sum(bw(:, j)) > TColumns - 50); 
end

figure
imshow(maskC + maskR) 
iR = 0 ;
fR = 0 ;

for i = 1 : rows
    if (iR == 0 && sum(maskR(i +1, :), 2) == 0 && sum(maskR(i, :), 2) > 0)
        iR = i;
    end
    if (iR > 0 && sum(maskR(i, :), 2) > 0)
        fR = i;
    end
end

V = {};
cont = 1;
iC = 0;
fC = 0;
for j = 1 : columns - 1
    if (iC == 0 && sum(maskC(:, j + 1), 1) == 0 && sum(maskC(:, j), 1) > 0)
        iC = j;
    else
        if (iC > 0 && sum(maskC(:, j + 1), 1) == 0 && sum(maskC(:, j), 1) > 0)
            fC = j;
            V{cont} = bw(iR : fR, iC : fC);
            iC = 0;
            fC = 0;
            cont = cont + 1;
        end
    end
end

im1 = V{1};
[r, c] = size(im1);
im2 = V{2}(1:r, 1:c);
im3 = V{3}(1:r, 1:c);
im4 = V{4}(1:r, 1:c);

dif1 = (im1 - im2);
figure
subplot(2, 3, 2), imshow(im1), title('Originale') ;
subplot(2, 3, 4), imshow(dif1), title('Originale - im2') ;
subplot(2, 3, 5), imshow((im1 - im3)), title('Originale - im3') ;
subplot(2, 3, 6), imshow((im1 - im4)), title('Originale - im4') ;
