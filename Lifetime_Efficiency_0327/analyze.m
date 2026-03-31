clear all;
close all;
clc;

%% Common Import

cd('C:\Users\wty00\OneDrive\桌面\牛馬\Lifetime_Effectivity')
addpath("20260324_145414", "20260324_172339", "20260325_184751", "20260326_123101", ...
    "20260326_140744", "20260326_161126", "20260327_191012", "20260328_234055", "helper functions")

csv1 = table2array(readtable("20260324_145414_lifetime"));
csv2 = table2array(readtable("20260324_172339_lifetime"));
csv3 = table2array(readtable("20260325_184751_lifetime"));
csv4 = table2array(readtable("20260326_123101_lifetime"));
csv5 = table2array(readtable("20260326_140744_lifetime"));
csv6 = table2array(readtable("20260326_161126_lifetime"));
csv7 = table2array(readtable("20260327_191012_lifetime"));
csv8 = table2array(readtable("20260328_234055_lifetime"));

timecost1 = table2array(readtable("20260324_145414_time_cost"));
timecost2 = table2array(readtable("20260324_172339_time_cost"));
timecost3 = table2array(readtable("20260325_184751_time_cost"));
timecost4 = table2array(readtable("20260326_123101_time_cost"));
timecost5 = table2array(readtable("20260326_140744_time_cost"));
timecost6 = table2array(readtable("20260326_161126_time_cost"));
timecost7 = table2array(readtable("20260327_191012_time_cost"));
timecost8 = table2array(readtable("20260328_234055_time_cost"));

%% Dataset 

models = {csv1, csv2, csv3, csv4, csv5, csv6, csv7, csv8};
timecosts = {timecost1, timecost2, timecost3, timecost4, timecost5, timecost6, timecost7, timecost8};

%% Rough Plot

if ~exist('plot result','dir')
    mkdir('plot result')
end

x = linspace(1, 100, numel(csv1));   % 數據的x都是一樣的
n = numel(models);

% rough_plot (x, models, n)


%% Detrend with single p

p = 0.01;   % smoothing parameter (tune this!)

trend = cell(1, n);
detrend = cell(1, n);

for i = 1:n
    trend{i} = csaps(x, models{i}, p, x);
    detrend{i} = models{i} - trend{i}';
end 

% check_spline_plot(x, models, trend, detrend, p, n);


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
std1_all = cell(1,n);

for i = 1:n
    for k = 1:n_p
        p = p_list(k);
    
        Detrend = detrend_minus(x, models{i}, p); 
        unc_all{i}(k) = std(Detrend) / mean(models{i});  
        std1_all{i}(k) = std(Detrend);
    end
end

% compare_uncertainty_plot(p_list, unc_all, range1, range2, n)
compare_uncertainty1_plot(p_list, std1_all, range1, range2, n)


%% Time cost

eff_all = cell(1, n);
eff1_all = cell(1,n);

for i = 1:n
    for k = 1:n_p
        p = p_list(k);
        eff_all{i}(k) = unc_all{i}(k)*sqrt(mean(timecosts{i}));
        eff1_all{i}(k) = std1_all{i}(k)*sqrt(mean(timecosts{i}));
    end
end

% compare_efficiency_plot(p_list, eff_all, range1, range2, n)
compare_efficiency1_plot(p_list, eff1_all, range1, range2, n)

%% blank











