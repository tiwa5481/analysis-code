function compare_efficiency_plot(p_list, eff_all, range1, range2, n)

    fig = figure();
    hold on

    for i = 1:n
        name = sprintf('csv%d', i);
        plot(p_list, eff_all{i}, 'LineWidth', 1.5, 'DisplayName', name);
    
        xlabel('smoothing parameter p');
        ylabel('efficiency');
        title(sprintf('Efficiency vs smoothing parameter p = %.3f to %.3f', range1, range2));
        
        legend show
        grid on
        
        plotName = fullfile('plot result', sprintf('efficiency vs p %.3f to %.3f.fig', range1, range2));
        saveas(fig, plotName)
    end

end