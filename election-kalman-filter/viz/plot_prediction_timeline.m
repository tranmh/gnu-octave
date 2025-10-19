function fig = plot_prediction_timeline(backtest_results, varargin)
% PLOT_PREDICTION_TIMELINE Plot win probability evolution over 52 weeks
%
% Usage:
%   fig = plot_prediction_timeline(backtest_results)
%   fig = plot_prediction_timeline(backtest_results, 'param', value, ...)
%
% Inputs:
%   backtest_results - Struct from run_backtest() containing:
%                      .predictions (win_prob, win_prob_std, weeks, dates)
%                      .actual_outcome (winner, dem_margin, etc.)
%                      .metrics (final_prediction, brier_score, etc.)
%
% Optional Parameters:
%   'title_text'   - Custom title (default: auto-generated)
%   'show_result'  - Show actual result line (default: true)
%   'save_fig'     - Save figure to file (default: false)
%   'fig_name'     - Output filename (default: 'prediction_timeline.png')
%
% Output:
%   fig - Figure handle
%
% Example:
%   results = run_backtest();
%   plot_prediction_timeline(results, 'save_fig', true);

% Parse optional arguments
p = inputParser();
addParameter(p, 'title_text', '', @ischar);
addParameter(p, 'show_result', true, @islogical);
addParameter(p, 'save_fig', false, @islogical);
addParameter(p, 'fig_name', 'prediction_timeline.png', @ischar);
parse(p, varargin{:});
opts = p.Results;

% Extract data
pred = backtest_results.predictions;
actual = backtest_results.actual_outcome;
metrics = backtest_results.metrics;

weeks = pred.weeks;
win_prob = pred.win_prob;
win_prob_std = pred.win_prob_std;
dates = pred.dates;

% Create figure
fig = figure('Position', [100, 100, 1200, 600]);

% Plot main prediction line
plot(weeks, win_prob, 'b-', 'LineWidth', 2.5);
hold on;

% Add 1-sigma uncertainty band (68% CI)
upper_1sigma = min(win_prob + win_prob_std, 1);
lower_1sigma = max(win_prob - win_prob_std, 0);
fill([weeks; flipud(weeks)], ...
     [upper_1sigma; flipud(lower_1sigma)], ...
     'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');

% Add 50% reference line
plot(xlim, [0.5, 0.5], 'k--', 'LineWidth', 1.5);

% Add actual result line if requested
if opts.show_result
    % Actual outcome: Trump won (Dem probability should be < 0.5)
    actual_prob = 0;  % Trump won decisively
    plot(xlim, [actual_prob, actual_prob], 'r-', 'LineWidth', 2);
    text(max(weeks)*0.95, actual_prob+0.05, sprintf('Actual: %s Wins', actual.winner), ...
         'Color', 'r', 'FontSize', 10, 'HorizontalAlignment', 'right');
end

% Mark candidate transition (Biden -> Harris, Week ~38)
transition_week = 38;
if max(weeks) >= transition_week
    yl = ylim;
    plot([transition_week, transition_week], yl, 'g--', 'LineWidth', 1.5);
    text(transition_week, yl(2)*0.95, 'Biden→Harris', ...
         'Rotation', 90, 'VerticalAlignment', 'bottom', 'FontSize', 9);
end

% Formatting
xlabel('Weeks from Election Start (Nov 5, 2023 → Nov 5, 2024)', ...
       'FontSize', 12, 'FontWeight', 'bold');
ylabel('Democratic Nominee Win Probability', ...
       'FontSize', 12, 'FontWeight', 'bold');

% Generate title
if isempty(opts.title_text)
    title_str = sprintf(['Kalman Filter Election Prediction Timeline\n', ...
                        'Final Prediction: %.1f%% | Actual: %s Wins | ', ...
                        'Brier Score: %.3f'], ...
                        metrics.final_prediction * 100, ...
                        actual.winner, ...
                        metrics.brier_score);
else
    title_str = opts.title_text;
end
title(title_str, 'FontSize', 14, 'FontWeight', 'bold');

% Legend
legend('Prediction', '±1σ Uncertainty', '50% Threshold', ...
       'Location', 'best', 'FontSize', 10);

% Grid and limits
grid on;
ylim([0, 1]);
xlim([min(weeks), max(weeks)]);

% Add x-axis with key dates
xticks([1, 13, 26, 38, 52]);
xticklabels({'Nov 2023', 'Feb 2024', 'May 2024', 'Jul 2024', 'Nov 2024'});

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
