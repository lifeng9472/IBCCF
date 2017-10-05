function G = argmin_g(U, Sigma, miu, zeta, W, P)
   tmp = U' *(W(:) - P(:));
   G = (W(:) - P(:)) - U * diag((miu* diag(Sigma .^2)) ./ ((miu* diag(Sigma .^2)) + zeta * diag(eye(size(Sigma,1))))) * tmp;
end


