function out=divide_image(im,n)
    [rows, columns, ch] = size(im);
    im_rgb = reshape(im, [rows * columns, ch]) ;
    out = {};
    
    x1 = 1 ;
    for i = 1 : n * n
        x2 =  x1 + rows * columns / (n * n) ;
        out{i} = reshape(im_rgb(x1 : x2 -1, 1 : ch), [rows / n,  columns / n, ch]);
        x1 = x2 ;
        
    end
    
end