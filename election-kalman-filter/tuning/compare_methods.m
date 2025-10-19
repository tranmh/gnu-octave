function results = compare_methods(varargin)
    % COMPARE_METHODS - Compare Kalman filter against baseline methods
    %
    % Benchmarks the Kalman filter election prediction against simpler
    % baseline methods to validate its added value.
    %
    % USAGE:
    %   results = compare_methods()
    %   results = compare_methods('methods', {'kalman', 'moving_avg'}, ...)
    %
    % OPTIONAL PARAMETERS:
    %   'methods'        - Cell array of methods to compare:
    %                      'kalman', 'moving_avg', 'exponential', 'latest_poll', 'naive'
    %                      (default: all methods)
    %   'kalman_params'  - [Q, R, P0] for Kalman filter (default: best from grid search)
    %   'window_size'    - Window for moving average (default: 4 weeks)
    %   'alpha'          - Smoothing factor for exponential (default: 0.3)
    %   'verbose'        - Display progress (default: true)
    %
    % OUTPUT:
    %   results - Struct containing:
    %     .method_results  - Results for each method
    %     .comparison      - Side-by-side metrics
    %     .rankings        - Method rankings by metric
    %     .best_method     - Overall best performer
    %
    % METHODS COMPARED:
    %   'kalman'        - Kalman filter (our approach)
    %   'moving_avg'    - Simple moving average of polls
    %   'exponential'   - Exponentially weighted moving average
    %   'latest_poll'   - Use most recent poll only
    %   'naive'         - Assume 50/50 probability always
    %
    % EXAMPLE:
    %   % Compare all methods
    %   results = compare_methods();
    %
    %   % Compare Kalman vs moving average only
    %   results = compare_methods('methods', {'kalman', 'moving_avg'});
    %
    % SEE ALSO: grid_search, sensitivity_analysis, run_backtest
    
    % Parse inputs
    p = inputParser;
    p.addParameter('methods', {'kalman', 'moving_avg', 'exponential', 'latest_poll', 'naive'});
    p.addParameter('kalman_params', []);
    p.addParameter('window_size', 4);
    p.addParameter('alpha', 0.3);
    p.addParameter('verbose', true);
    p.parse(varargin{:});
    
    % Extract parameters
    methods = p.Results.methods;
    kalman_params = p.Results.kalman_params;
    window_size = p.Results.window_size;
    alpha = p.Results.alpha;
    verbose = p.Results.verbose;
    
    % Load Kalman parameters if not specified
    if isempty(kalman_params)
        try
            grid_results = load('grid_search_results.mat');
            kalman_params = grid_results.best_params;
        catch
            kalman_params = [0.001, 0.05, 0.1];
        end
    end
    
    if verbose
        fprintf('\n=== METHOD COMPARISON BENCHMARK ===\n');
        fprintf('Methods to compare: %s\n', strjoin(methods, ', '));
        fprintf('===================================\n\n');
    end
    
    % Load polling data
    data_path = fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'processed');
    polls_file = fullfile(data_path, 'weekly_polls.mat');
    if ~exist(polls_file, 'file')
        error('Polling data not found: %s', polls_file);
    end
    polls = load(polls_file);
    
    % Initialize storage
    n_methods = length(methods);
    method_results = cell(n_methods, 1);
    
    % Run each method
    for i = 1:n_methods
        method = methods{i};
        
        if verbose
            fprintf('--- Running: %s ---\n', method);
        end
        
        try            switch lower(method)
                case 'kalman'
                    result = run_kalman_method(kalman_params, verbose);
                case 'moving_avg'
                    result = run_moving_average(polls, window_size, verbose);
                case 'exponential'
                    result = run_exponential_smoothing(polls, alpha, verbose);
                case 'latest_poll'
                    result = run_latest_poll(polls, verbose);
                case 'naive'
                    result = run_naive_baseline(polls, verbose);
                otherwise
                    warning('Unknown method: %s', method);
                    continue;
            end
            
            result.method_name = method;
            method_results{i} = result;
            
            if verbose
                fprintf('  Brier score: %.6f\n', result.brier_score);
                fprintf('  Final error: %.6f\n', result.final_error);
                fprintf('  RMSE: %.6f\n\n', result.rmse);
            end
            
        catch ME
            warning('Failed to run %s: %s', method, ME.message);
            method_results{i} = struct('method_name', method, 'failed', true);
        end
    end
    
    % Remove failed methods
    valid_results = method_results(~cellfun(@(x) isfield(x, 'failed'), method_results));
    n_valid = length(valid_results);
    
    % Create comparison table
    if n_valid > 0
        comparison = create_comparison_table(valid_results);
        
        % Rank methods by each metric
        rankings = rank_methods(comparison);
        
        % Determine best overall method (by Brier score)
        [~, best_idx] = min(comparison.brier_score);
        best_method = comparison.method{best_idx};
    else
        comparison = struct();
        rankings = struct();
        best_method = 'None';
    end
    
    % Package results
    results.method_results = valid_results;
    results.comparison = comparison;
    results.rankings = rankings;
    results.best_method = best_method;
    results.n_methods = n_valid;
    
    % Summary report
    if verbose && n_valid > 0
        fprintf('=== COMPARISON SUMMARY ===\n');
        fprintf('Methods compared: %d\n\n', n_valid);
        fprintf('Results by Brier Score:\n');
        for i = 1:n_valid
            fprintf('  %d. %-15s: %.6f\n', i, comparison.method{rankings.brier(i)}, ...
                    comparison.brier_score(rankings.brier(i)));
        end
        fprintf('\nResults by RMSE:\n');
        for i = 1:n_valid
            fprintf('  %d. %-15s: %.6f\n', i, comparison.method{rankings.rmse(i)}, ...
                    comparison.rmse(rankings.rmse(i)));
        end
        fprintf('\nResults by Final Error:\n');
        for i = 1:n_valid
            fprintf('  %d. %-15s: %.6f\n', i, comparison.method{rankings.final_error(i)}, ...
                    comparison.final_error(rankings.final_error(i)));
        end
        fprintf('\n** Best overall: %s **\n', best_method);
        fprintf('==========================\n\n');
    end
end

% ============================================================
% BASELINE METHOD IMPLEMENTATIONS
% ============================================================

function result = run_kalman_method(params, verbose)
    % Run Kalman filter with specified parameters
    if verbose
        fprintf('  Parameters: Q=%.5f, R=%.4f, P0=%.4f\n', params(1), params(2), params(3));
    end

    % Create params struct for run_backtest
    kf_params = struct();
    kf_params.Q = params(1);
    kf_params.R = params(2);
    kf_params.P0 = params(3);
    kf_params.x0 = 0.5;  % Default initial state

    backtest_results = run_backtest('params', kf_params, 'verbose', false, 'save_results', false);
    result = extract_metrics(backtest_results);
end

function result = run_moving_average(polls, window_size, verbose)
    % Simple moving average of recent polls
    if verbose
        fprintf('  Window size: %d weeks\n', window_size);
    end
    
    % Calculate moving average for each week
    n_weeks = length(polls.dem_avg);
    predictions = zeros(n_weeks, 1);
    
    for i = 1:n_weeks
        start_idx = max(1, i - window_size + 1);
        window_data = polls.dem_avg(start_idx:i);
        predictions(i) = mean(window_data);
    end
    
    % Convert to win probabilities
    win_probs = convert_polls_to_probs(predictions, polls.rep_avg);
    
    % Calculate metrics
    result = calculate_baseline_metrics(win_probs);
end

function result = run_exponential_smoothing(polls, alpha, verbose)
    % Exponentially weighted moving average
    if verbose
        fprintf('  Smoothing factor: %.2f\n', alpha);
    end
    
    n_weeks = length(polls.dem_avg);
    predictions = zeros(n_weeks, 1);
    predictions(1) = polls.dem_avg(1);
    
    for i = 2:n_weeks
        predictions(i) = alpha * polls.dem_avg(i) + (1 - alpha) * predictions(i-1);
    end
    
    % Convert to win probabilities
    win_probs = convert_polls_to_probs(predictions, polls.rep_avg);
    
    result = calculate_baseline_metrics(win_probs);
end

function result = run_latest_poll(polls, verbose)
    % Use only the most recent poll (no smoothing)
    if verbose
        fprintf('  Using latest poll only\n');
    end
    
    % Simply use current poll as prediction
    win_probs = convert_polls_to_probs(polls.dem_avg, polls.rep_avg);
    
    result = calculate_baseline_metrics(win_probs);
end

function result = run_naive_baseline(polls, verbose)
    % Naive baseline: always predict 50/50
    if verbose
        fprintf('  Constant 50%% probability\n');
    end

    % Determine number of weeks from polls data
    if isstruct(polls) && isfield(polls, 'dem_avg')
        n_weeks = length(polls.dem_avg);
    else
        n_weeks = 52;  % Default to 52 weeks
    end
    win_probs = 0.5 * ones(n_weeks, 1);

    result = calculate_baseline_metrics(win_probs);
end

% ============================================================
% HELPER FUNCTIONS
% ============================================================

function win_probs = convert_polls_to_probs(dem_pct, rep_pct)
    % Convert poll percentages to win probabilities using logistic function
    margin = (dem_pct - rep_pct) / 100;
    k = 15;  % Scaling parameter
    win_probs = 1 ./ (1 + exp(-k * margin));
end

function metrics = calculate_baseline_metrics(win_probs)
    % Calculate standard metrics for baseline methods
    
    % Actual outcome: Trump won (Dem win prob = 0)
    actual_win_prob = 0.0;
    
    % Brier score
    errors = win_probs - actual_win_prob;
    metrics.brier_score = mean(errors.^2);
    
    % RMSE
    metrics.rmse = sqrt(mean(errors.^2));
    
    % Final prediction error
    metrics.final_error = abs(win_probs(end) - actual_win_prob);
    metrics.final_prediction = win_probs(end);
end

function metrics = extract_metrics(backtest_results)
    % Extract standard metrics from backtest results
    metrics.brier_score = backtest_results.metrics.brier_score;
    metrics.final_prediction = backtest_results.predictions.win_prob(end);
    
    % Calculate RMSE
    actual_win_prob = 0.0;
    errors = backtest_results.predictions.win_prob - actual_win_prob;
    metrics.rmse = sqrt(mean(errors.^2));
    metrics.final_error = abs(metrics.final_prediction - actual_win_prob);
end

function comparison = create_comparison_table(results)
    % Create structured comparison table
    n = length(results);
    
    comparison.method = cell(n, 1);
    comparison.brier_score = zeros(n, 1);
    comparison.rmse = zeros(n, 1);
    comparison.final_error = zeros(n, 1);
    comparison.final_prediction = zeros(n, 1);
    
    for i = 1:n
        comparison.method{i} = results{i}.method_name;
        comparison.brier_score(i) = results{i}.brier_score;
        comparison.rmse(i) = results{i}.rmse;
        comparison.final_error(i) = results{i}.final_error;
        comparison.final_prediction(i) = results{i}.final_prediction;
    end
end

function rankings = rank_methods(comparison)
    % Rank methods by each metric (lower is better for all metrics)
    [~, rankings.brier] = sort(comparison.brier_score);
    [~, rankings.rmse] = sort(comparison.rmse);
    [~, rankings.final_error] = sort(comparison.final_error);
end
