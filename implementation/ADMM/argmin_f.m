function [w, alpha_f, X_f] = argmin_f(X, zeta, lambda, yf, G, P)
    gp =  (G + P);
    
    % compute auxiliary variable terms
    X_f = fft2(X);
    gp_res_f = zeta * sum(conj(X_f) .* fft2(gp), 3) / numel(X_f);
    
    X_f_sum = sum(X_f .* conj(X_f),3)/ numel(X_f);
   
    % compute dual variables
    alpha_f =  (yf + gp_res_f ./ X_f_sum) ./ (X_f_sum + zeta + lambda); 
    
    % transform to w for linear kernel
    w =real(ifft2(bsxfun(@times, alpha_f, X_f)));
end


