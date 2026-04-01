function check_spline_plot(x, models, trend, detrend, p, n)

    for i =1:n

        fig = figure();

        plot(x{i}, models{i}, 'o', 'DisplayName', 'raw data'); 
        hold on
        plot(x{i}, trend{i}, 'LineWidth', 1, 'DisplayName', 'trend');
        plot(x{i}, detrend{i}, 'LineWidth', 1.5, 'DisplayName', 'detrend')
        
        name = sprintf('csv%d', i);
        legend show
        title(sprintf('check spline trend (%s) with p = %.3f', name, p))
        grid on
    
        plotName = fullfile('plot result', sprintf('detrend %s with p=%.3f.fig', name, p));
        saveas(fig, plotName)

    end

end