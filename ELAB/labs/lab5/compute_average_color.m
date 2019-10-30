function out = compute_average_color(image)
    R = image(:, : , 1) ;
    G = image(:, : , 2) ;
    B = image(:, :, 3) ;
    
    r_mean = mean(R(:)) ;
    g_mean = mean(G(:));
    b_mean = mean(B(:)) ;
    out = [r_mean, g_mean, b_mean] ;
end