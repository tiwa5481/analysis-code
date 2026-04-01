function rough_plot (x, models, n)
    
    fig = figure();
    hold on

    for i = 1:n
        name = sprintf('csv%d', i);
        plot(x{i}, models{i}, 'LineWidth', 1.5, ...
            'DisplayName', name);
    end

    xlabel('step');
    ylabel('lifetime (us)');
    title('raw data plot')
    legend show
    grid on

    plotName = fullfile('plot result', 'rough plot');
    saveas(fig, plotName)
    
end