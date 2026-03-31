clear all;
close all;
clc;

%% Import the Data

cd('C:\Users\wty00\OneDrive\桌面\牛馬\Scan_Spectrum\Scan_U2\Data')
addpath('20260112','20260109','20260108','20260107', ...
    '20251224','20251223','20251222','20251219','20251218','20251217')

% 選取你想擬合的peak
timestamp = '20251218_174818';

tickling_freq = readmatrix(timestamp + "_arr_of_setpoints");     % 加.csv後反而無法識別
ratio_lost = readmatrix(timestamp + "_ratio_lost");

% 導入對應U2
U2_file = fullfile(timestamp + "_conf");
txt = fileread(U2_file);
U2 = regexp(txt, '\[U2\]\s*val\s*=\s*([+-]?\d*\.?\d+)', 'tokens', 'once');
U2 = str2double(U2{1});


%% Rough Plot

plot (tickling_freq, ratio_lost, linewidth=1.5)
xlabel("tickling frequency (Hz)");
ylabel('ratio lost');
title("lost ratio vs. tikling frequency");


%% Models for Fitting
% 不跑，給Curve Fitting Toolbox作參考函數的

Gaussian = fittype('a1*exp(-((x-b1)/c1)^2)+C', ...
                   'independent','x', ...
                   'coefficients',{'a1','b1','c1','C'});

Lorentzian = fittype('a1*(gamma^2 ./ ((x - b1).^2 + gamma^2))+C', ...
                     'independent', 'x', ...
                     'coefficients', {'a1','b1','gamma','C'});

Multi_Gaussian = fittype('a1*exp(-((x-b1)/c1)^2)+a2*exp(-((x-b2)/c2)^2)+C', ...
                         'independent','x','coefficients',{'a1','b1','c1','a2','b2','c2','C'});


%% 劃定擬合範圍
% 不一定用得到

xmin = 103;
xmax = 200;
idx = (tickling_freq >= xmin) & (tickling_freq <= xmax);

x_fit = tickling_freq(idx);
y_fit = ratio_lost(idx);


%% 處理擬合output

R_sqrt = goodness.rsquare;

% 提取b及其上下限
names = coeffnames(fittedmodel);
b_idx = find(startsWith(names,'b'));
a_idx = find(startsWith(names,'a'));
CI = confint(fittedmodel, 0.6827);

% 改寫成能導出的格式
b = zeros(1, numel(b_idx));
a = zeros(1, numel(a_idx));
b_lower = zeros(1, numel(b_idx));
b_upper = zeros(1, numel(b_idx));

for k = 1:numel(b)
    b(k) = fittedmodel.(names{b_idx(k)});
    a(k) = fittedmodel.(names{a_idx(k)});
    b_lower(k) = CI(1, b_idx(k));
    b_upper(k) = CI(2, b_idx(k));
end


% 由上下限計算std
std = zeros(1, numel(b_idx));
for i =1:numel(b)
    std(i) = abs(b_upper(i)-b_lower(i))/2;
end

% 擴寫U2
U2 = repmat(U2, numel(b), 1);


%% 保存擬合結果

T = table(U2, a(:), b(:), std(:), 'VariableNames', {'U2','amp','b','std'});
writetable(T,'results.csv','WriteMode','append');






