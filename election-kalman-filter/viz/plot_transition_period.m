function fig = plot_transition_period(backtest_results, varargin)
% PLOT_TRANSITION_PERIOD Zoom into Biden->Harris transition period (July 2024)
%
% Usage:
%   fig = plot_transition_period(backtest_results)
%   fig = plot_transition_period(backtest_results, 'param', value, ...)
%
% Inputs:
%   backtest_results - Struct from run_backtest()
%
% Optional Parameters:
%   'transition_week' - Week of candidate switch (default: 38)
%   'window'          - Weeks before/after to show (default: 8)
%   'title_text'      - Custom title (default: auto-generated)
%   'save_fig'        - Save figure to file (default: false)
%   'fig_name'        - Output filename (default: 'transition_period.png')
%
% Output:
%   fig - Figure handle
%
% Example:
%   results = run_backtest();
%   plot_transition_period(results, 'window', 10);

% Parse optional arguments
p = inputParser();
addParameter(p, 'transition_week', 38, @isnumeric);
addParameter(p, 'window', 8, @isnumeric);
addParameter(p, 'title_text', '', @ischar);
addParameter(p, 'save_fig', false, @islogical);
addParameter(p, 'fig_name', 'transition_period.png', @ischar);
parse(p, varargin{:});
opts = p.Results;

% Extract data
pred = backtest_results.predictions;
weeks = pred.weeks;
win_prob = pred.win_prob;
win_prob_std = pred.win_prob_std;

% Define transition window
trans_week = opts.transition_week;
window = opts.window;
week_start = max(1, trans_week - window);
week_end = min(length(weeks), trans_week + window);

% Extract transition period data
idx = (weeks >= week_start & weeks <= week_end);
weeks_zoom = weeks(idx);
win_prob_zoom = win_prob(idx);
win_prob_std_zoom = win_prob_std(idx);

% Create figure
fig = figure('Position', [100, 100, 1200, 700]);

% Main plot
subplot(2, 1, 1);
plot(weeks_zoom, win_prob_zoom, 'b-', 'LineWidth', 3);
hold on;

% Add uncertainty bands
upper = min(win_prob_zoom + win_prob_std_zoom, 1);
lower = max(win_prob_zoom - win_prob_std_zoom, 0);
fill([weeks_zoom; flipud(weeks_zoom)], ...
     [upper; flipud(lower)], ...
     'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');

% Mark transition week
xline(trans_week, 'r-', 'LineWidth', 2.5, ...
      'Label', 'Biden→Harris Transition', ...
      'LabelOrientation', 'horizontal');

% Add 50% reference
yline(0.5, 'k--', 'LineWidth', 1.5, 'Alpha', 0.5);

% Formatting
ylabel('Win Probability', 'FontSize', 11, 'FontWeight', 'bold');
title('Prediction During Transition Period', ...
      'FontSize', 12, 'FontWeight', 'bold');
legend('Kalman Estimate', '±1σ', 'Transition', ...
       'Location', 'best', 'FontSize', 9);
grid on;
ylim([0, 1]);
yticks(0:0.1:1);
yticklabels(arrayfun(@(x) sprintf('%.0f%%', x*100), 0:0.1:1, ...
                     'UniformOutput', false));
hold off;

% Uncertainty plot
subplot(2, 1, 2);
plot(weeks_zoom, win_prob_std_zoom, 'r-', 'LineWidth', 2.5);
hold on;

% Mark transition week
xline(trans_week, 'r-', 'LineWidth', 2.5);

% Formatting
xlabel('Week Number', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Prediction Uncertainty (σ)', 'FontSize', 11, 'FontWeight', 'bold');
title('Uncertainty Evolution During Transition', ...
      'FontSize', 12, 'FontWeight', 'bold');
grid on;
ylim([0, max(win_prob_std_zoom) * 1.2]);
hold off;

% Overall title
if isempty(opts.title_text)
    sgtitle(sprintf(['Candidate Transition Analysis (Week %d ± %d)\n', ...
                     'Biden → Harris: July 21, 2024'], ...
                    trans_week, window), ...
            'FontSize', 14, 'FontWeight', 'bold');
else
    sgtitle(opts.title_text, 'FontSize', 14, 'FontWeight', 'bold');
end

% Save if requested
if opts.save_fig
    print(fig, opts.fig_name, '-dpng', '-r300');
    fprintf('Figure saved to: %s\n', opts.fig_name);
end

end
