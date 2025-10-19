function fig = plot_final_comparison(backtest_results, varargin)
% PLOT_FINAL_COMPARISON Compare final prediction with actual election result
%
% Usage:
%   fig = plot_final_comparison(backtest_results)
%   fig = plot_final_comparison(backtest_results, 'param', value, ...)
%
% Inputs:
%   backtest_results - Struct from run_backtest()
%
% Optional Parameters:
%   'title_text'   - Custom title (default: auto-generated)
%   'save_fig'     - Save figure to file (default: false)
%   'fig_name'     - Output filename (default: 'final_comparison.png')
%
% Output:
%   fig - Figure handle
%
% Example:
%   results = run_backtest();
%   plot_final_comparison(results);

% Parse optional arguments
p = inputParser();
addParameter(p, 'title_text', '', @ischar);
addParameter(p, 'save_fig', false, @islogical);
addParameter(p, 'fig_name', 'final_comparison.png', @ischar);
parse(p, varargin{:});
opts = p.Results;

% Extract data
pred = backtest_results.predictions;
actual = backtest_results.actual_outcome;
metrics = backtest_results.metrics;

final_pred = pred.win_prob(end);
final_std = pred.win_prob_std(end);

% Actual outcome (Trump won)
actual_dem_prob = 0;  % Trump victory
actual_dem_vote = actual.dem_vote_share;
actual_rep_vote = actual.rep_vote_share;

% Create figure with two subplots
fig = figure('Position', [100, 100, 1000, 600]);

% Subplot 1: Bar chart comparison
subplot(1, 2, 1);

% Data for bars
categories = {'Prediction', 'Actual'};
dem_values = [final_pred * 100, actual_dem_prob * 100];
rep_values = [(1 - final_pred) * 100, 100];

% Create grouped bar chart
x = 1:2;
bar_width = 0.35;

% Plot bars with explicit colors (Octave compatible)
b1 = bar(x - bar_width/2, dem_values, bar_width, 'FaceColor', [0.2, 0.4, 0.8]);  % Blue for Democrat
hold on;
b2 = bar(x + bar_width/2, rep_values, bar_width, 'FaceColor', [0.8, 0.2, 0.2]);  % Red for Republican

% Add error bar for prediction uncertainty (Octave compatible)
he = errorbar(x(1) - bar_width/2, dem_values(1), final_std * 100);
set(he, 'Color', 'k', 'LineWidth', 2);

% Formatting
ylabel('Win Probability (%)', 'FontSize', 11, 'FontWeight', 'bold');
title('Predicted vs Actual Outcome', 'FontSize', 12, 'FontWeight', 'bold');
xticks(x);
xticklabels(categories);
ylim([0, 110]);
grid on;
legend('Harris (Dem)', 'Trump (Rep)', 'Location', 'northwest');
hold off;

% Subplot 2: Vote share comparison
subplot(1, 2, 2);

% Vote shares
vote_categories = {'Actual Vote'};
dem_vote = actual_dem_vote;
rep_vote = actual_rep_vote;

% Create stacked horizontal bar
barh(1, [dem_vote, rep_vote], 'stacked');
colormap([0.2, 0.4, 0.8; 0.8, 0.2, 0.2]);

% Add vote percentage labels
text(dem_vote/2, 1, sprintf('Harris\n%.1f%%', dem_vote), ...
     'HorizontalAlignment', 'center', 'FontSize', 11, ...
     'FontWeight', 'bold', 'Color', 'w');
text(dem_vote + rep_vote/2, 1, sprintf('Trump\n%.1f%%', rep_vote), ...
     'HorizontalAlignment', 'center', 'FontSize', 11, ...
     'FontWeight', 'bold', 'Color', 'w');

% Formatting
xlabel('Popular Vote Share (%)', 'FontSize', 11, 'FontWeight', 'bold');
title('Actual 2024 Election Results', 'FontSize', 12, 'FontWeight', 'bold');
yticks(1);
yticklabels(vote_categories);
xlim([0, 100]);
grid on;

% Overall title with metrics
if isempty(opts.title_text)
    title_str = sprintf(['Final Prediction vs Actual Outcome\n', ...
                        'Final Prediction: %.1f%% Dem | Brier Score: %.3f'], ...
                        final_pred * 100, ...
                        metrics.brier_score);
else
    title_str = opts.title_text;
end
% Note: sgtitle not supported in Octave

% Save if requested
if opts.save_fig
    print(fig, opts.fig_name, '-dpng', '-r300');
    fprintf('Figure saved to: %s\n', opts.fig_name);
end

end
