clear all;
close all;
clc;

%% Common Import

cd('C:\Users\wty00\OneDrive\桌面\牛馬\Scan_Spectrum\Scan_U2')
addpath('helper_functions')

cd('Data')
addpath('20260112','20260109','20260108','20260107', ...
    '20251224','20251223','20251222','20251219','20251218','20251217')

Folders = {'20260112','20260109','20260108','20260107',...
    '20251224','20251223','20251222','20251219','20251218','20251217'};


%% Startpoints

map = containers.Map();

map('20260112_154417') = [30.2];
map('20260112_155333') = [52];
map('20260112_160951') = [86, 87.8];
map('20260112_161748') = [119];
map('20260112_183932') = [41.5];
map('20260112_184616') = [62];
map('20260112_185613') = [102, 103];
map('20260112_190611') = [144];

map('20260109_134208') = [42, 45.5, 47.5];
map('20260109_140336') = [80, 92, 96, 101];
map('20260109_171414') = [37, 40];
map('20260109_172409') = [49];
map('20260109_173049') = [77, 80];
map('20260109_174042') = [91, 92];

map('20260108_162813') = [46, 49.5];
map('20260108_164243') = [88, 96.5, 99];

map('20260107_174740') = [43.5, 44];
map('20260107_175216') = [53.8];
map('20260107_180137') = [84, 87.8];
map('20260107_181704') = [100];
map('20260107_182743') = [107];

map('20251224_144819') = [42];
map('20251224_145254') = [62.5];
map('20251224_150102') = [81, 83];
map('20251224_150934') = [102, 103.5];

map('20251223_142531') = [34];
map('20251223_143329') = [56, 61];
map('20251223_144635') = [83.5];
map('20251223_145237') = [94, 97];
map('20251223_150033') = [110];
map('20251223_150438') = [120.5];
map('20251223_192919') = [37];
map('20251223_193638') = [56, 61];
map('20251223_194955') = [82];
map('20251223_195354') = [99, 101];
map('20251223_200839') = [142, 144, 146];

map('20251222_142532') = [21.8, 23.2];
map('20251222_143229') = [63, 66, 69];
map('20251222_145548') = [89, 90.2];
map('20251222_150242') = [107];
map('20251222_151117') = [116];
map('20251222_185258') = [29, 32];
map('20251222_190012') = [62, 64.2];
map('20251222_191539') = [83, 85];
map('20251222_192232') = [95, 97];
map('20251222_193035') = [129];

map('20251219_152324') = [13, 14];
map('20251219_152848') = [26, 28];
map('20251219_153648') = [58, 66, 70, 74, 79, 81.5, 88, 94, 99, 101, 114];
map('20251219_174546') = [14, 15];
map('20251219_175228') = [29, 30];
map('20251219_175909') = [46];
map('20251219_180433') = [62, 64, 74, 77, 81, 91, 93, 105, 108, 120, 124];

map('20251218_145950') = [9.27];
map('20251218_150250') = [16];
map('20251218_150947') = [64, 69, 73, 77.5, 79.5, 82, 86.5, 88.5, 93, 96];
map('20251218_174138') = [12];
map('20251218_174818') = [22, 24, 25];
map('20251218_175457') = [55, 67, 74, 77, 79, 87, 91, 98.5, 104, 110];

map('20251217_165722') = [9, 16, 18];
map('20251217_171011') = [60, 69, 77, 86, 90, 94, 98];


%% Reading, Fitting and Saving

% 創建空的圖像文件夾，如果沒有檢測到同名的
if ~exist('fit_plots','dir')
    mkdir('fit_plots')
end


for i = 1:numel(Folders)

    % 提取數據part 1
    files = dir(Folders{i});
    Tickling_Freq_Files = files(contains({files.name}, 'arr_of_setpoints'));
    Lost_Ratio_Files = files(contains({files.name}, 'ratio_lost'));
    U2_Files = files(contains({files.name}, 'conf'));

    for j = 1:numel(Lost_Ratio_Files)

        % 提取數據part 2
        tickleName = Tickling_Freq_Files(j).name;
        ratioName = Lost_Ratio_Files(j).name;
        U2Name = U2_Files(j).name;

        % 提取數據part 3
        tickling_freq = readmatrix(fullfile(Folders{i}, tickleName));
        ratio_lost = readmatrix(fullfile(Folders{i}, ratioName));
        U2 = fileread(fullfile(Folders{i}, U2Name));

        % 提取數據part 4
        U2 = regexp(U2, '\[U2\]\s*val\s*=\s*([+-]?\d*\.?\d+)', 'tokens', 'once');
        U2 = str2double(U2{1});

        % 確定 timestamp
        timestamp = erase(ratioName, '_ratio_lost');

        % 由 timestamp 確定 startpoint
        if isKey(map, timestamp)
            start_points = map(timestamp);
        else
        error('No start points defined for timestamp %s', stamp);
        end

        % 確定peak個數
        nPeaks = numel(start_points);

        % 根據startpoint個數準備fitting要用的參數p
        p0 = [];
        for k = 1:nPeaks
            A0 = max(ratio_lost);        % 或局部最大
            b0 = start_points(k);
            sigma0 = 0.5;                  % 數量級1
            p0 = [p0, A0, b0, sigma0]; 
        end 
        C0 = min(ratio_lost);            % base
        p0 = [p0, C0];

        % 執行擬合
        opts = optimoptions('lsqcurvefit', ...
            'Display','off', ...
            'MaxFunctionEvaluations',1e5);

        lb = -inf(1, 3*nPeaks + 1);     % 約束
        ub = inf(1, 3*nPeaks + 1);

        [p_fit, resnorm, residual, ~, ~, ~, jacobian] = lsqcurvefit( ...
            @(p,x) multi_gaussian_model(p,x), ...
            p0, ...
            tickling_freq, ...
            ratio_lost, ...
            lb, ub, opts);


        % 出圖part 1
        x_fit = linspace(min(tickling_freq), max(tickling_freq), 500);
        y_fit = multi_gaussian_model(p_fit, x_fit);

        % 出圖part 2
        fig = figure('Visible','off');
        plot(tickling_freq, ratio_lost);
        hold on
        plot(x_fit, y_fit, '-','LineWidth',1.5)
        
        % 寫圖像title        
        xlabel('Tickling Frequency (MHz)')
        ylabel('Ratio Lost')
        timestamp = erase(ratioName, '_ratio_lost');
        titleText = strrep(timestamp, '_', ' ');
        title(titleText, 'Interpreter','none')
        grid on

        % 存圖
        plotName = fullfile('fit_plots', [timestamp '_fit.png']);
        saveas(fig, plotName)
        close(fig)

        % 讀取peak center 及其他所需參數 part 1
        a = zeros(nPeaks,1);
        b = zeros(nPeaks,1);
        c = zeros(nPeaks,1);
        std = zeros(nPeaks, 1);
        CI = nlparci(p_fit, residual, 'jacobian', jacobian, 'alpha', 1 - 0.6827);

        % 讀取peak center 及其他所需參數 part 2
        for k = 1:nPeaks
            idx = 3*(k-1) + 2;
            b(k) = p_fit(idx);          % 讀取b
            a(k) = p_fit(3*(k-1) + 1);  % 讀取amplitude
            c(k) = p_fit(3*(k-1) + 3);  % 讀取width
            b_lower = CI(idx, 1);       % 讀取b上限
            b_upper = CI(idx, 2);       % 讀取b下限
            std(k) = abs(b_upper - b_lower) / 2;       % 計算std (<1為好數據)  
        end

        % 求R^2 (直接上公式)
        SS_res = sum(residual.^2);
        SS_tot = sum((ratio_lost - mean(ratio_lost)).^2);
        R2 = 1 - SS_res / SS_tot;

        % 擴寫U2 & timestamp & R2
        U2 = repmat(U2, numel(b), 1);
        time_stamps = repmat(string(timestamp), nPeaks, 1);
        R2 = repmat(R2, nPeaks, 1);

        % 寫進csv
        T = table(time_stamps, U2, a(:), b(:), c(:), std(:), R2, ...
            'VariableNames', {'timestamps','U2','amp','b','sigma','std_b','R2'});
        writetable(T,'results.csv','WriteMode','append');


    end 

end 

%% 返回原路徑

cd('C:\Users\wty00\OneDrive\桌面\牛馬\Scan_Spectrum\Scan_U2')










