function generate_report(backtest_results, varargin)
% GENERATE_REPORT Create comprehensive visualization report with all plots
%
% Usage:
%   generate_report(backtest_results)
%   generate_report(backtest_results, 'param', value, ...)
%
% Inputs:
%   backtest_results - Struct from run_backtest()
%
% Optional Parameters:
%   'weekly_polls'    - Weekly polling data struct (for polls vs estimate plot)
%   'output_dir'      - Directory for saving figures (default: './viz_output/')
%   'save_individual' - Save individual plots (default: true)
%   'save_combined'   - Save combined figure (default: true)
%   'show_plots'      - Display plots interactively (default: true)
%
% Output:
%   Saves PNG files of all visualization plots
%
% Example:
%   results = run_backtest();
%   polls = load('weekly_polls.mat');
%   generate_report(results, 'weekly_polls', polls, 'output_dir', './figures/');

% Parse optional arguments
p = inputParser();
addParameter(p, 'weekly_polls', [], @(x) isstruct(x) || isempty(x));
addParameter(p, 'output_dir', './viz_output/', @ischar);
addParameter(p, 'save_individual', true, @islogical);
addParameter(p, 'save_combined', true, @islogical);
addParameter(p, 'show_plots', true, @islogical);
parse(p, varargin{:});
opts = p.Results;

% Create output directory if it doesn't exist
if opts.save_individual || opts.save_combined
    if ~exist(opts.output_dir, 'dir')
        mkdir(opts.output_dir);
        fprintf('Created output directory: %s\n', opts.output_dir);
    end
end

fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║     GENERATING KALMAN FILTER VISUALIZATION REPORT         ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

% Generate timestamp for filenames
timestamp = datestr(now, 'yyyymmdd_HHMMSS');

% --- Plot 1: Prediction Timeline ---
fprintf('Generating Plot 1/6: Prediction Timeline...\n');
fig1 = plot_prediction_timeline(backtest_results);
if opts.save_individual
    fname = fullfile(opts.output_dir, sprintf('1_timeline_%s.png', timestamp));
    print(fig1, fname, '-dpng', '-r300');
    fprintf('  ✓ Saved: %s\n', fname);
end
if ~opts.show_plots
    close(fig1);
end

% --- Plot 2: Confidence Bands ---
fprintf('Generating Plot 2/6: Confidence Bands...\n');
fig2 = plot_confidence_bands(backtest_results);
if opts.save_individual
    fname = fullfile(opts.output_dir, sprintf('2_confidence_%s.png', timestamp));
    print(fig2, fname, '-dpng', '-r300');
    fprintf('  ✓ Saved: %s\n', fname);
end
if ~opts.show_plots
    close(fig2);
end

% --- Plot 3: Polls vs Estimate (optional) ---
if ~isempty(opts.weekly_polls)
    fprintf('Generating Plot 3/6: Polls vs Estimate...\n');
    fig3 = plot_polls_vs_estimate(backtest_results, opts.weekly_polls);
    if opts.save_individual
        fname = fullfile(opts.output_dir, sprintf('3_polls_vs_estimate_%s.png', timestamp));
        print(fig3, fname, '-dpng', '-r300');
        fprintf('  ✓ Saved: %s\n', fname);
    end
    if ~opts.show_plots
        close(fig3);
    end
else
    fprintf('Skipping Plot 3/6: Polls vs Estimate (no weekly_polls provided)\n');
end

% --- Plot 4: Transition Period ---
fprintf('Generating Plot 4/6: Transition Period...\n');
fig4 = plot_transition_period(backtest_results);
if opts.save_individual
    fname = fullfile(opts.output_dir, sprintf('4_transition_%s.png', timestamp));
    print(fig4, fname, '-dpng', '-r300');
    fprintf('  ✓ Saved: %s\n', fname);
end
if ~opts.show_plots
    close(fig4);
end

% --- Plot 5: Final Comparison ---
fprintf('Generating Plot 5/6: Final Comparison...\n');
fig5 = plot_final_comparison(backtest_results);
if opts.save_individual
    fname = fullfile(opts.output_dir, sprintf('5_final_comparison_%s.png', timestamp));
    print(fig5, fname, '-dpng', '-r300');
    fprintf('  ✓ Saved: %s\n', fname);
end
if ~opts.show_plots
    close(fig5);
end

% --- Plot 6: Diagnostics ---
fprintf('Generating Plot 6/6: Filter Diagnostics...\n');
fig6 = plot_diagnostics(backtest_results);
if opts.save_individual
    fname = fullfile(opts.output_dir, sprintf('6_diagnostics_%s.png', timestamp));
    print(fig6, fname, '-dpng', '-r300');
    fprintf('  ✓ Saved: %s\n', fname);
end
if ~opts.show_plots
    close(fig6);
end

fprintf('\n');
fprintf('✓ All individual plots generated successfully!\n');

% --- Generate Combined Report Figure (optional) ---
if opts.save_combined
    fprintf('\nGenerating combined report figure...\n');
    
    % Create large figure with all plots
    fig_combined = figure('Position', [50, 50, 1600, 1200]);
    
    % Plot arrangement: 3x2 grid
    
    % Top row
    subplot(3, 2, 1);
    copyobj(allchild(fig1), gca);
    title('Prediction Timeline', 'FontSize', 10);
    
    subplot(3, 2, 2);
    copyobj(allchild(fig2), gca);
    title('Confidence Bands', 'FontSize', 10);
    
    % Middle row
    subplot(3, 2, 3);
    copyobj(allchild(fig4), gca);
    title('Transition Period', 'FontSize', 10);
    
    subplot(3, 2, 4);
    copyobj(allchild(fig5), gca);
    title('Final Comparison', 'FontSize', 10);
    
    % Bottom row
    subplot(3, 2, 5);
    copyobj(allchild(fig6), gca);
    title('Diagnostics', 'FontSize', 10);
    
    if ~isempty(opts.weekly_polls)
        subplot(3, 2, 6);
        copyobj(allchild(fig3), gca);
        title('Polls vs Estimate', 'FontSize', 10);
    end
    
    % Overall title
    metrics = backtest_results.metrics;
    sgtitle(sprintf(['Kalman Filter Election Prediction Report\n', ...
                     'Brier Score: %.3f | Performance: %s | ', ...
                     'Final Prediction: %.1f%% Dem'], ...
                    metrics.brier_score, ...
                    metrics.performance_grade, ...
                    metrics.final_prediction * 100), ...
            'FontSize', 14, 'FontWeight', 'bold');
    
    % Save combined figure
    combined_fname = fullfile(opts.output_dir, ...
                              sprintf('COMBINED_REPORT_%s.png', timestamp));
    print(fig_combined, combined_fname, '-dpng', '-r300');
    fprintf('  ✓ Saved combined report: %s\n', combined_fname);
    
    if ~opts.show_plots
        close(fig_combined);
    end
end

fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║         VISUALIZATION REPORT GENERATION COMPLETE           ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

% Print summary
fprintf('Summary:\n');
fprintf('  - Output directory: %s\n', opts.output_dir);
if opts.save_individual
    fprintf('  - Individual plots: 6 files saved\n');
end
if opts.save_combined
    fprintf('  - Combined report: 1 file saved\n');
end
if opts.show_plots
    fprintf('  - Interactive display: Enabled\n');
else
    fprintf('  - Interactive display: Disabled (all figures closed)\n');
end
fprintf('\n');

end
