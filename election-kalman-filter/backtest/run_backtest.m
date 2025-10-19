function backtest_results = run_backtest(varargin)
    % RUN_BACKTEST Main backtesting script for election predictions
    %
    % Usage:
    %   results = run_backtest()
    %   results = run_backtest('weekly_data', data_file)
    %   results = run_backtest('params', params_struct)
    %   results = run_backtest('save_results', true)
    %
    % Optional Name-Value Pairs:
    %   'weekly_data'   - Path to weekly polling data CSV (default: auto-detect)
    %   'params'        - Kalman filter parameters struct (default: from kalman_init)
    %   'save_results'  - Save results to file (default: true)
    %   'output_dir'    - Directory for results (default: 'backtest/results/')
    %   'verbose'       - Display detailed output (default: true)
    %
    % Outputs:
    %   backtest_results - Struct containing:
    %                      .predictions: Kalman filter predictions
    %                      .actual_outcome: 2024 election results
    %                      .metrics: Performance metrics
    %                      .confidence_intervals: CI analysis
    %                      .params: Kalman filter parameters used
    %                      .data_source: Path to data file
    %
    % Example:
    %   results = run_backtest();
    %   results = run_backtest('save_results', true, 'verbose', true);
    %
    % Notes:
    %   - Processes all 52 weeks of polling data (Nov 2023 - Nov 2024)
    %   - Handles Biden→Harris transition (July 21, 2024)
    %   - Compares predictions against actual 2024 election outcome
    %   - Generates comprehensive performance metrics
    
    % Add paths
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(script_dir);
    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'pipeline'));
    addpath(fullfile(project_root, 'data'));
    addpath(fullfile(project_root, 'utils'));
    addpath(script_dir);
    
    % ===== PARSE INPUT ARGUMENTS =====
    p = inputParser;
    addParameter(p, 'weekly_data', '', @ischar);
    addParameter(p, 'params', [], @(x) isempty(x) || isstruct(x));
    addParameter(p, 'save_results', true, @islogical);
    addParameter(p, 'output_dir', fullfile(script_dir, 'results'), @ischar);
    addParameter(p, 'verbose', true, @islogical);
    parse(p, varargin{:});
    
    weekly_data_file = p.Results.weekly_data;
    custom_params = p.Results.params;
    save_results = p.Results.save_results;
    output_dir = p.Results.output_dir;
    verbose = p.Results.verbose;
    
    % ===== LOAD OR LOCATE WEEKLY DATA =====
    if isempty(weekly_data_file)
        % Try to auto-detect data file
        data_dir = fullfile(project_root, 'data', 'processed');
        weekly_data_file = fullfile(data_dir, 'weekly_polls.csv');
        
        if ~exist(weekly_data_file, 'file')
            error('Weekly polling data not found. Please run data processing first or specify data file.');
        end
    end
    
    if verbose
        fprintf('\n=== KALMAN FILTER BACKTESTING ===\n');
        fprintf('Data Source: %s\n', weekly_data_file);
        fprintf('Processing 52 weeks of polling data...\n\n');
    end
    
    % ===== DEFINE ACTUAL 2024 ELECTION OUTCOME =====
    actual_outcome.winner = 'Trump';
    actual_outcome.dem_vote_share = 48.3;  % Harris
    actual_outcome.rep_vote_share = 50.1;  % Trump
    actual_outcome.dem_margin = actual_outcome.dem_vote_share - actual_outcome.rep_vote_share;
    actual_outcome.electoral_votes_dem = 226;
    actual_outcome.electoral_votes_rep = 312;
    actual_outcome.election_date = '2024-11-05';
    
    % ===== INITIALIZE KALMAN FILTER =====
    if isempty(custom_params)
        params = kalman_init();
    else
        params = custom_params;
    end
    
    if verbose
        fprintf('Kalman Filter Parameters:\n');
        fprintf('  Q (process noise): %.6f\n', params.Q);
        fprintf('  R (measurement noise): %.6f\n', params.R);
        fprintf('  Initial state: %.4f\n', params.x0);
        fprintf('  Initial uncertainty: %.4f\n\n', params.P0);
    end
    
    % ===== RUN WEEKLY PROCESSOR =====
    % This processes all 52 weeks through the Kalman filter
    try
        if verbose
            fprintf('Running weekly processor...\n');
        end
        
        % Process weekly data
        weekly_results = weekly_processor('data_file', weekly_data_file, ...
                                          'params', params, ...
                                          'verbose', verbose);
        
        if verbose
            fprintf('✓ Weekly processing complete\n\n');
        end
        
    catch err
        fprintf('ERROR in weekly processor: %s\n', err.message);
        rethrow(err);
    end
    
    % ===== EXTRACT PREDICTIONS =====
    predictions.win_prob = weekly_results.win_prob_history;
    predictions.win_prob_std = weekly_results.uncertainty_history;
    predictions.weeks = weekly_results.week_numbers;
    predictions.dates = weekly_results.dates;
    
    % ===== CALCULATE PERFORMANCE METRICS =====
    if verbose
        fprintf('\n=== CALCULATING PERFORMANCE METRICS ===\n');
    end
    
    metrics = calculate_metrics(predictions, actual_outcome);
    
    % ===== COMPUTE CONFIDENCE INTERVALS =====
    if verbose
        fprintf('\n=== COMPUTING CONFIDENCE INTERVALS ===\n');
    end
    
    ci_results = confidence_intervals(predictions, [0.68, 0.95, 0.99]);
    
    % ===== ASSEMBLE RESULTS =====
    backtest_results.predictions = predictions;
    backtest_results.actual_outcome = actual_outcome;
    backtest_results.metrics = metrics;
    backtest_results.confidence_intervals = ci_results;
    backtest_results.params = params;
    backtest_results.data_source = weekly_data_file;
    backtest_results.weekly_results = weekly_results;
    backtest_results.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    
    % ===== DISPLAY FINAL SUMMARY =====
    if verbose
        fprintf('\n');
        fprintf('╔════════════════════════════════════════════════════════════╗\n');
        fprintf('║           BACKTESTING RESULTS SUMMARY                     ║\n');
        fprintf('╠════════════════════════════════════════════════════════════╣\n');
        fprintf('║ Final Prediction:     %.4f (Dem win probability)        ║\n', metrics.final_prediction);
        fprintf('║ Actual Winner:        %-35s║\n', actual_outcome.winner);
        fprintf('║ Predicted Winner:     %-35s║\n', ...
                char(conditional_string(metrics.final_prediction > 0.5, 'Harris', 'Trump')));
        fprintf('║ Correct Prediction:   %-35s║\n', ...
                mat2str(metrics.correct_winner_prediction));
        fprintf('╠════════════════════════════════════════════════════════════╣\n');
        fprintf('║ ACCURACY METRICS                                           ║\n');
        fprintf('║ Brier Score:          %.6f  (optimal = 0)               ║\n', metrics.brier_score);
        fprintf('║ Final Error:          %.6f                              ║\n', metrics.final_error);
        fprintf('║ Log Score:            %.6f  (lower is better)         ║\n', metrics.log_score);
        fprintf('║ RMSE:                 %.6f                              ║\n', metrics.rmse);
        fprintf('║ Performance Grade:    %-35s║\n', metrics.grade);
        fprintf('╠════════════════════════════════════════════════════════════╣\n');
        fprintf('║ 95%% CONFIDENCE INTERVAL                                   ║\n');
        fprintf('║ Final CI:             [%.4f, %.4f]                     ║\n', ...
                ci_results.final_intervals(2, 1), ci_results.final_intervals(2, 2));
        fprintf('║ Actual in CI:         %-35s║\n', ...
                mat2str(metrics.outcome_in_final_ci));
        fprintf('╚════════════════════════════════════════════════════════════╝\n\n');
    end
    
    % ===== SAVE RESULTS =====
    if save_results
        if ~exist(output_dir, 'dir')
            mkdir(output_dir);
        end
        
        % Save to MAT file
        timestamp_str = datestr(now, 'yyyymmdd_HHMMSS');
        results_file = fullfile(output_dir, sprintf('backtest_results_%s.mat', timestamp_str));
        save(results_file, 'backtest_results');
        
        % Save metrics to CSV
        metrics_file = fullfile(output_dir, sprintf('metrics_%s.csv', timestamp_str));
        save_metrics_to_csv(metrics, metrics_file);
        
        if verbose
            fprintf('Results saved to:\n');
            fprintf('  %s\n', results_file);
            fprintf('  %s\n\n', metrics_file);
        end
    end
    
    if verbose
        fprintf('Backtesting complete!\n\n');
    end
end

% Helper function for conditional string
function str = conditional_string(condition, true_str, false_str)
    if condition
        str = true_str;
    else
        str = false_str;
    end
end

% Helper function to save metrics to CSV
function save_metrics_to_csv(metrics, filename)
    % Extract key metrics
    metric_names = {'Final_Prediction', 'Final_Error', 'Brier_Score', ...
                    'Log_Score', 'RMSE', 'MAE', 'Correct_Winner', ...
                    'Prediction_Confidence', 'Grade'};
    
    metric_values = {metrics.final_prediction, ...
                     metrics.final_error, ...
                     metrics.brier_score, ...
                     metrics.log_score, ...
                     metrics.rmse, ...
                     metrics.mae, ...
                     double(metrics.correct_winner_prediction), ...
                     metrics.prediction_confidence, ...
                     metrics.grade};
    
    % Write to file
    fid = fopen(filename, 'w');
    if fid == -1
        warning('Could not open file for writing: %s', filename);
        return;
    end
    
    % Header
    fprintf(fid, 'Metric,Value\n');
    
    % Data rows
    for i = 1:length(metric_names)
        if ischar(metric_values{i})
            fprintf(fid, '%s,%s\n', metric_names{i}, metric_values{i});
        else
            fprintf(fid, '%s,%.6f\n', metric_names{i}, metric_values{i});
        end
    end
    
    fclose(fid);
end
