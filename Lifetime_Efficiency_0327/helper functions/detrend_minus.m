function y = detrend_minus(x, data, p)
    trend = csaps(x, data, p, x);
    y = data - trend';       % ' can change 1*100 to 100*1
end 