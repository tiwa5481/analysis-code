function y = multi_gaussian_model(p, x)
    nPeaks = (numel(p) - 1) / 3;
    y = zeros(size(x));

    for k = 1:nPeaks
        A     = p(3*(k-1) + 1);
        mu    = p(3*(k-1) + 2);
        sigma = p(3*(k-1) + 3);
        y = y + A * exp(-(x - mu).^2 ./ (2*sigma^2));
    end

    y = y + p(end);
end
