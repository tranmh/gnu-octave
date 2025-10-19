function fig = plot_polls_vs_estimate(backtest_results, weekly_polls, varargin)
% PLOT_POLLS_VS_ESTIMATE Compare raw polling observations with Kalman estimates
%
% Usage:
%   fig = plot_polls_vs_estimate(backtest_results, weekly_polls)
%   fig = plot_polls_vs_estimate(..., 'param', value, ...)
%
% Inputs:
%   backtest_results - Struct from run_backtest()
%   weekly_polls     - Struct with raw polling data:
%                      .weeks, .dem_avg, .rep_avg, .num_polls
%
% Optional Parameters:
%   'title_text'   - Custom title (default: auto-generated)
%   'save_fig'     - Save figure to file (default: false)
%   'fig_name'     - Output filename (default: 'polls_vs_estimate.png')
%
% Output:
%   fig - Figure handle
%
% Example:
%   results = run_backtest();
%   polls = load('weekly_polls.mat');
%   plot_polls_vs_estimate(results, polls);

% Parse optional arguments
p = inputParser();
addParameter(p, 'title_text', '', @ischar);
addParameter(p, 'save_fig', false, @islogical);
addParameter(p, 'fig_name', 'polls_vs_estimate.png', @ischar);
parse(p, varargin{:});
opts = p.Results;

% Extract Kalman filter data
pred = backtest_results.predictions;
weeks = pred.weeks;
win_prob = pred.win_prob;
win_prob_std = pred.win_prob_std;

% Convert polling percentages to win probabilities
% Using simple logistic transformation
k = 15;  % Scaling parameter
margin = (weekly_polls.dem_avg - weekly_polls.rep_avg) / 100;
poll_win_prob = 1 ./ (1 + exp(-k * margin));

% Create figure
fig = figure('Position', [100, 100, 1200, 600]);

% Plot Kalman filter estimate with uncertainty
plot(weeks, win_prob, 'b-', 'LineWidth', 2.5);
hold on;

upper = min(win_prob + win_prob_std, 1);
lower = max(win_prob - win_prob_std, 0);
fill([weeks; flipud(weeks)], ...
     [upper; flipud(lower)], ...
     'b', 'FaceAlpha', 0.15, 'EdgeColor', 'none');

% Plot raw polling observations as scatter points
scatter(weekly_polls.weeks, poll_win_prob, 50, 'r', 'filled', ...
        'MarkerFaceAlpha', 0.6);

% Add 50% reference line
plot(xlim, [0.5, 0.5], 'k--', 'LineWidth', 1.5);

% Formatting
xlabel('Week Number', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Democratic Nominee Win Probability', ...
       'FontSize', 12, 'FontWeight', 'bold');

% Title
if isempty(opts.title_text)
    title_str = sprintf(['Polling Observations vs Kalman Filter Estimates\n', ...
                        'Total Polls: %d across %d weeks'], ...
                        sum(weekly_polls.num_polls), ...
                        length(weekly_polls.weeks));
else
    title_str = opts.title_text;
end
title(title_str, 'FontSize', 14, 'FontWeight', 'bold');

% Legend
legend('Kalman Estimate', '±1σ Uncertainty', 'Raw Polls', ...
       'Location', 'best', 'FontSize', 10);

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
