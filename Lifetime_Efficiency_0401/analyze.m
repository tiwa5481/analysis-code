clear all;
close all;
clc;

%% Common Import

cd('C:\Users\wty00\OneDrive\桌面\牛馬\Lifetime_Efficiency_2')
addpath("data", "helper functions")

scan = readtable("20260331_133353_scan_result");

%% Data process

filename_column = scan.wait_times_file;
csvs = unique(filename_column);

n_csv = length(csvs);
models = cell(n_csv, 1);
timecosts = cell(n_csv, 1);

for i = 1:n_csv
    idx = strcmp(filename_column, csvs{i});    % 找到當前文件名的所有行
    
    models{i} = scan.lifetime(idx);
    timecosts{i} = scan.lifetime(idx);

    fprintf('csv %d 來自文件: %s\n', i, csvs{i});
end

models{4} = remove_outliers(models{4}, 1);
models{5} = remove_outliers(models{5}, 1);
models{3} = remove_outliers(models{3}, 2);      % csv3 有兩個異常值，處理兩次


%% Rough Plot

if ~exist('plot result','dir')
    mkdir('plot result')
end

x = cell(n_csv, 1);

for i = 1:length(models)
    x{i} = linspace(1, 100, length(models{i}));
end

n = length(models);

rough_plot (x, models, n)


%% Detrend with single p

p = 0.01;   % smoothing parameter (tune this!)

trend = cell(1, n);
detrend = cell(1, n);

for i = 1:n
    trend{i} = csaps(x{i}, models{i}, p, x{i});
    detrend{i} = models{i} - trend{i}';
end 

check_spline_plot(x, models, trend, detrend, p, n);


%% Find std, mean and Uncertainty

std_all = zeros(1, n);
mean_all = zeros(1, n);
uncertainty_all = zeros(1, n);

for i = 1:n
    std_all(i) = std(detrend{i});
    mean_all(i) = mean(models{i});
    uncertainty_all(i) = std_all(i)/mean_all(i);
end

%% Uncertainty vs. p

range1 = 0.001;
range2 = 0.1;
p_list = linspace(range1, range2, 500);
n_p = numel(p_list);

unc_all = cell(1, n);

for i = 1:n
    for k = 1:n_p
        p = p_list(k);
    
        Detrend = detrend_minus(x{i}, models{i}, p); 
        unc_all{i}(k) = std(Detrend) / mean(models{i});  
    end
end

compare_uncertainty_plot(p_list, unc_all, range1, range2, n)


%% Time cost

eff_all = cell(1, n);

for i = 1:n
    for k = 1:n_p
        p = p_list(k);
        eff_all{i}(k) = unc_all{i}(k)*sqrt(mean(timecosts{i}));
    end
end

compare_efficiency_plot(p_list, eff_all, range1, range2, n)


%% blank











