function fig = plot_confidence_bands(backtest_results, varargin)
% PLOT_CONFIDENCE_BANDS Plot multiple confidence interval levels
%
% Usage:
%   fig = plot_confidence_bands(backtest_results)
%   fig = plot_confidence_bands(backtest_results, 'param', value, ...)
%
% Inputs:
%   backtest_results - Struct from run_backtest() with predictions
%
% Optional Parameters:
%   'ci_levels'    - Confidence levels to plot (default: [0.68, 0.95, 0.99])
%   'title_text'   - Custom title (default: auto-generated)
%   'save_fig'     - Save figure to file (default: false)
%   'fig_name'     - Output filename (default: 'confidence_bands.png')
%
% Output:
%   fig - Figure handle
%
% Example:
%   results = run_backtest();
%   plot_confidence_bands(results, 'ci_levels', [0.68, 0.95]);

% Parse optional arguments
p = inputParser();
addParameter(p, 'ci_levels', [0.68, 0.95, 0.99], @isnumeric);
addParameter(p, 'title_text', '', @ischar);
addParameter(p, 'save_fig', false, @islogical);
addParameter(p, 'fig_name', 'confidence_bands.png', @ischar);
parse(p, varargin{:});
opts = p.Results;

% Extract data
pred = backtest_results.predictions;
weeks = pred.weeks;
win_prob = pred.win_prob;
win_prob_std = pred.win_prob_std;

% Create figure
fig = figure('Position', [100, 100, 1200, 600]);

% Plot central estimate
plot(weeks, win_prob, 'b-', 'LineWidth', 3);
hold on;

% Define colors for different CI levels (lighter to darker)
colors = [0.7, 0.85, 1.0;    % Light blue (99%)
          0.5, 0.7, 1.0;      % Medium blue (95%)
          0.3, 0.5, 0.9];     % Darker blue (68%)

% Z-scores for different confidence levels
z_scores = [2.576, 1.96, 1.0];  % 99%, 95%, 68%

% Plot confidence bands (largest to smallest for proper layering)
ci_levels_sorted = sort(opts.ci_levels, 'descend');
legend_entries = cell(1, length(ci_levels_sorted) + 1);
legend_entries{1} = 'Prediction';

for i = 1:length(ci_levels_sorted)
    ci_level = ci_levels_sorted(i);
    
    % Find corresponding z-score
    if ci_level >= 0.99
        z = 2.576;
        color_idx = 1;
    elseif ci_level >= 0.95
        z = 1.96;
        color_idx = 2;
    else
        z = 1.0;
        color_idx = 3;
    end
    
    % Calculate bounds
    upper = min(win_prob + z * win_prob_std, 1);
    lower = max(win_prob - z * win_prob_std, 0);
    
    % Fill band
    fill([weeks; flipud(weeks)], ...
         [upper; flipud(lower)], ...
         colors(color_idx, :), ...
         'FaceAlpha', 0.3, 'EdgeColor', 'none');
    
    legend_entries{i+1} = sprintf('%.0f%% CI', ci_level * 100);
end

% Add 50% reference line
plot(xlim, [0.5, 0.5], 'k--', 'LineWidth', 1.5);

% Formatting
xlabel('Week Number', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Democratic Nominee Win Probability', ...
       'FontSize', 12, 'FontWeight', 'bold');

% Title
if isempty(opts.title_text)
    title_str = 'Prediction Confidence Bands (Multiple CI Levels)';
else
    title_str = opts.title_text;
end
title(title_str, 'FontSize', 14, 'FontWeight', 'bold');

% Legend
legend(legend_entries, 'Location', 'best', 'FontSize', 10);

% Grid and limits
grid on;
ylim([0, 1]);
xlim([min(weeks), max(weeks)]);

% Format y-axis as percentages
yticks(0:0.1:1);
yticklabels(arrayfun(@(x) sprintf('%.0f%%', x*100), 0:0.1:1, ...
                     'UniformOutput', false));

hold off;

% Save if requested
if opts.save_fig
    print(fig, opts.fig_name, '-dpng', '-r300');
    fprintf('Figure saved to: %s\n', opts.fig_name);
end

end
