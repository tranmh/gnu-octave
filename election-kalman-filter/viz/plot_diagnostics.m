function fig = plot_diagnostics(backtest_results, varargin)
% PLOT_DIAGNOSTICS Show Kalman filter diagnostic plots
%
% Usage:
%   fig = plot_diagnostics(backtest_results)
%   fig = plot_diagnostics(backtest_results, 'param', value, ...)
%
% Inputs:
%   backtest_results - Struct from run_backtest() with full state history
%
% Optional Parameters:
%   'title_text'   - Custom title (default: auto-generated)
%   'save_fig'     - Save figure to file (default: false)
%   'fig_name'     - Output filename (default: 'diagnostics.png')
%
% Output:
%   fig - Figure handle
%
% Note: Assumes backtest_results contains innovation and gain history
%
% Example:
%   results = run_backtest();
%   plot_diagnostics(results);

% Parse optional arguments
p = inputParser();
addParameter(p, 'title_text', '', @ischar);
addParameter(p, 'save_fig', false, @islogical);
addParameter(p, 'fig_name', 'diagnostics.png', @ischar);
parse(p, varargin{:});
opts = p.Results;

% Extract data
pred = backtest_results.predictions;
weeks = pred.weeks;
win_prob_std = pred.win_prob_std;

% Check if innovation and gain data exist
has_innovation = isfield(pred, 'innovation');
has_gain = isfield(pred, 'kalman_gain');

% Create figure with 3 subplots
fig = figure('Position', [100, 100, 1200, 800]);

% Plot 1: Prediction uncertainty over time
subplot(3, 1, 1);
plot(weeks, win_prob_std, 'b-', 'LineWidth', 2);
hold on;

% Mark transition period
plot([38, 38], ylim, 'r--', 'LineWidth', 1.5); text(38, max(ylim)*0.95, 'Transition', 'Rotation', 90, 'VerticalAlignment', 'bottom');

ylabel('Uncertainty (σ)', 'FontSize', 10, 'FontWeight', 'bold');
title('Prediction Uncertainty Evolution', 'FontSize', 11, 'FontWeight', 'bold');
grid on;
xlim([min(weeks), max(weeks)]);
hold off;

% Plot 2: Innovation (residuals)
subplot(3, 1, 2);
if has_innovation
    innovation = pred.innovation;
    plot(weeks, innovation, 'g-', 'LineWidth', 1.5);
    hold on;
    plot(xlim, [0, 0], 'k--', 'LineWidth', 1);
    
    % Mark transition
    plot([38, 38], ylim, 'r--', 'LineWidth', 1.5);
    
    ylabel('Innovation', 'FontSize', 10, 'FontWeight', 'bold');
    title('Filter Innovation (Measurement Residuals)', ...
          'FontSize', 11, 'FontWeight', 'bold');
    grid on;
    xlim([min(weeks), max(weeks)]);
    hold off;
else
    % Plot placeholder if no innovation data
    text(0.5, 0.5, 'Innovation data not available', ...
         'HorizontalAlignment', 'center', 'FontSize', 12);
    axis off;
end

% Plot 3: Kalman gain
subplot(3, 1, 3);
if has_gain
    kalman_gain = pred.kalman_gain;
    plot(weeks, kalman_gain, 'r-', 'LineWidth', 1.5);
    hold on;
    
    % Mark transition
    plot([38, 38], ylim, 'r--', 'LineWidth', 1.5);
    
    xlabel('Week Number', 'FontSize', 10, 'FontWeight', 'bold');
    ylabel('Kalman Gain', 'FontSize', 10, 'FontWeight', 'bold');
    title('Kalman Gain Evolution (Filter Responsiveness)', ...
          'FontSize', 11, 'FontWeight', 'bold');
    grid on;
    xlim([min(weeks), max(weeks)]);
    ylim([0, 1]);
    hold off;
else
    % Plot placeholder if no gain data
    text(0.5, 0.5, 'Kalman gain data not available', ...
         'HorizontalAlignment', 'center', 'FontSize', 12);
    axis off;
end

% Overall title (sgtitle not supported in Octave)
% Would display: Kalman Filter Diagnostic Plots

% Save if requested
if opts.save_fig
    print(fig, opts.fig_name, '-dpng', '-r300');
    fprintf('Figure saved to: %s\n', opts.fig_name);
end

end
