function compare_uncertainty1_plot(p_list, unc_all, range1, range2, n)

    fig = figure();
    hold on

    for i = 1:n
        name = sprintf('csv%d', i);
        plot(p_list, unc_all{i}, 'LineWidth', 1.5, 'DisplayName', name);
        
        xlabel('smoothing parameter p');
        ylabel('uncertainty');
        title(sprintf('Uncertainty1 vs smoothing parameter p = %.3f to %.3f', range1, range2));
        
        legend show
        grid on
        
        plotName = fullfile('plot result', sprintf('uncertainty vs p %.3f to %.3f.fig', range1, range2));
        saveas(fig, plotName)
    end

end