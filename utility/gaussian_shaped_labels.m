function labels = gaussian_shaped_labels(sigma, sz, mode)
%GAUSSIAN_SHAPED_LABELS
%   Gaussian-shaped labels for all shifts of a sample.
%
%   LABELS = GAUSSIAN_SHAPED_LABELS(SIGMA, SZ)
%   Creates an array of labels (regression targets) for all shifts of a
%   sample of dimensions SZ. The output will have size SZ, representing
%   one label for each possible shift. The labels will be Gaussian-shaped,
%   with the peak at 0-shift (top-left element of the array), decaying
%   as the distance increases, and wrapping around at the borders.
%   The Gaussian function has spatial bandwidth SIGMA.
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/

%evaluate a Gaussian with the peak at the center element
if(strcmp(mode, 'center'))
    [rs, cs] = ndgrid((1:sz(1)) - floor(sz(1)/2), (1:sz(2)) - floor(sz(2)/2));
    labels = exp(-0.5 / sigma^2 * (rs.^2 + cs.^2));
    labels = circshift(labels, -floor(sz(1:2) / 2) + 1);
elseif(strcmp(mode, 'horz'))
    rs = ndgrid((1:sz) - floor(sz/2));
    labels = exp(-0.5 / sigma^2 * (rs.^2));
    labels = circshift(labels, -floor(sz / 2) + 1);
elseif(strcmp(mode, 'vert'))
    cs = ndgrid((1:sz) - floor(sz/2));
    labels = exp(-0.5 / sigma^2 * (cs.^2));
    labels = circshift(labels, -floor(sz / 2) + 1);
end

%sanity check: make sure it's really at top-left
assert(labels(1,1) == 1)

end

