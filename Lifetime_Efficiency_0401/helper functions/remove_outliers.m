function data = remove_outliers(data, n)
    for k = 1:n
        [~, idx] = max(data);
        data(idx) = [];
    end
end