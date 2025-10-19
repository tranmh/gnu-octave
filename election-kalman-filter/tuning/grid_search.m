function results = grid_search(varargin)
    % GRID_SEARCH - Optimize Kalman filter parameters via grid search
    %
    % Performs exhaustive grid search over process noise (Q) and measurement
    % noise (R) parameters to find optimal Kalman filter configuration.
    %
    % USAGE:
    %   results = grid_search()
    %   results = grid_search('q_range', [0.0001, 0.001, 0.01], ...)
    %
    % OPTIONAL PARAMETERS:
    %   'q_range'        - Array of Q values to test (default: [0.0001, 0.0005, 0.001, 0.005, 0.01, 0.05])
    %   'r_range'        - Array of R values to test (default: [0.01, 0.02, 0.05, 0.1, 0.2])
    %   'p0_range'       - Array of P(0) values (default: [0.05, 0.1, 0.2])
    %   'metric'         - Optimization metric: 'brier', 'rmse', 'final_error' (default: 'brier')
    %   'verbose'        - Display progress (default: true)
    %   'parallel'       - Use parallel processing if available (default: false)
    %
    % OUTPUT:
    %   results - Struct containing:
    %     .best_params     - Optimal [Q, R, P0] values
    %     .best_score      - Best metric value achieved
    %     .all_scores      - 3D array of all scores [Q×R×P0]
    %     .q_range         - Q values tested
    %     .r_range         - R values tested
    %     .p0_range        - P0 values tested
    %     .grid_stats      - Statistics across grid
    %     .metric_used     - Which metric was optimized
    %
    % EXAMPLE:
    %   % Quick search with coarse grid
    %   results = grid_search('q_range', [0.001, 0.01], 'r_range', [0.05, 0.1]);
    %
    %   % Fine-grained search optimizing for RMSE
    %   results = grid_search('metric', 'rmse', 'verbose', true);
    %
    % SEE ALSO: run_backtest, sensitivity_analysis, final_params
    
    % Parse input arguments
    p = inputParser;
    p.addParameter('q_range', [0.0001, 0.0005, 0.001, 0.005, 0.01, 0.05]);
    p.addParameter('r_range', [0.01, 0.02, 0.05, 0.1, 0.2]);
    p.addParameter('p0_range', [0.05, 0.1, 0.2]);
    p.addParameter('metric', 'brier', @(x) any(strcmpi(x, {'brier', 'rmse', 'final_error'})));
    p.addParameter('verbose', true);
    p.addParameter('parallel', false);
    p.parse(varargin{:});
    
    % Extract parameters
    q_range = p.Results.q_range;
    r_range = p.Results.r_range;
    p0_range = p.Results.p0_range;
    metric = lower(p.Results.metric);
    verbose = p.Results.verbose;
    use_parallel = p.Results.parallel;
    
    % Grid dimensions
    nQ = length(q_range);
    nR = length(r_range);
    nP0 = length(p0_range);
    total_combos = nQ * nR * nP0;
    
    if verbose
        fprintf('\n=== KALMAN FILTER PARAMETER GRID SEARCH ===\n');
        fprintf('Grid dimensions: %d Q × %d R × %d P0 = %d combinations\n', ...
                nQ, nR, nP0, total_combos);
        fprintf('Optimization metric: %s\n', upper(metric));
        fprintf('Q range: [%.5f, %.5f]\n', min(q_range), max(q_range));
        fprintf('R range: [%.4f, %.4f]\n', min(r_range), max(r_range));
        fprintf('P0 range: [%.4f, %.4f]\n', min(p0_range), max(p0_range));
        fprintf('==========================================\n\n');
    end
    
    % Initialize results storage
    all_scores = zeros(nQ, nR, nP0);
    best_score = inf;
    best_params = [NaN, NaN, NaN];
    
    % Progress tracking
    combo_count = 0;
    start_time = tic;    
    % Grid search over all parameter combinations
    for iQ = 1:nQ
        for iR = 1:nR
            for iP0 = 1:nP0
                combo_count = combo_count + 1;
                
                % Current parameter set
                Q = q_range(iQ);
                R = r_range(iR);
                P0 = p0_range(iP0);
                
                % Run backtest with these parameters
                try
                    backtest_results = run_backtest_with_params(Q, R, P0);
                    
                    % Calculate score based on selected metric
                    switch metric
                        case 'brier'
                            score = backtest_results.metrics.brier_score;
                        case 'rmse'
                            score = calculate_rmse(backtest_results);
                        case 'final_error'
                            % Actual outcome: Trump won (Dem win prob = 0)
                            actual_win_prob = 0.0;
                            score = abs(backtest_results.predictions.win_prob(end) - actual_win_prob);
                    end
                    
                    all_scores(iQ, iR, iP0) = score;
                    
                    % Update best parameters
                    if score < best_score
                        best_score = score;
                        best_params = [Q, R, P0];
                    end
                    
                catch ME
                    warning('Failed for Q=%.5f, R=%.4f, P0=%.4f: %s', ...
                            Q, R, P0, ME.message);
                    all_scores(iQ, iR, iP0) = inf;
                end
                
                % Progress report
                if verbose && mod(combo_count, max(1, floor(total_combos/10))) == 0
                    elapsed = toc(start_time);
                    pct = 100 * combo_count / total_combos;
                    eta = elapsed * (total_combos - combo_count) / combo_count;
                    fprintf('Progress: %5.1f%% (%d/%d) | Elapsed: %4.1fs | ETA: %4.1fs | Best %s: %.6f\n', ...
                            pct, combo_count, total_combos, elapsed, eta, ...
                            upper(metric), best_score);
                end
            end
        end
    end
    
    % Calculate grid statistics
    valid_scores = all_scores(all_scores < inf);
    grid_stats.mean = mean(valid_scores);
    grid_stats.median = median(valid_scores);
    grid_stats.std = std(valid_scores);
    grid_stats.min = min(valid_scores);
    grid_stats.max = max(valid_scores);
    grid_stats.range = grid_stats.max - grid_stats.min;
    grid_stats.n_valid = length(valid_scores);
    grid_stats.n_failed = sum(all_scores(:) == inf);
    
    % Package results
    results.best_params = best_params;
    results.best_score = best_score;
    results.all_scores = all_scores;
    results.q_range = q_range;
    results.r_range = r_range;
    results.p0_range = p0_range;
    results.grid_stats = grid_stats;
    results.metric_used = metric;
    results.total_time = toc(start_time);
    
    % Final report
    if verbose
        fprintf('\n=== GRID SEARCH COMPLETE ===\n');
        fprintf('Total time: %.1f seconds\n', results.total_time);
        fprintf('Valid combinations: %d/%d\n', grid_stats.n_valid, total_combos);
        fprintf('\n--- OPTIMAL PARAMETERS ---\n');        fprintf('  Q (process noise):     %.6f\n', best_params(1));
        fprintf('  R (measurement noise): %.6f\n', best_params(2));
        fprintf('  P0 (initial unc.):     %.6f\n', best_params(3));
        fprintf('  Best %s score:         %.6f\n', upper(metric), best_score);
        fprintf('\n--- GRID STATISTICS ---\n');
        fprintf('  Mean score:   %.6f\n', grid_stats.mean);
        fprintf('  Median score: %.6f\n', grid_stats.median);
        fprintf('  Std dev:      %.6f\n', grid_stats.std);
        fprintf('  Range:        [%.6f, %.6f]\n', grid_stats.min, grid_stats.max);
        fprintf('===========================\n\n');
    end
end

function backtest_results = run_backtest_with_params(Q, R, P0)
    % Run backtest with specified Kalman filter parameters
    %
    % This is a wrapper that temporarily sets parameters and runs backtest
    
    % Load data
    data_path = fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'processed');
    polls_file = fullfile(data_path, 'weekly_polls.mat');
    
    if ~exist(polls_file, 'file')
        error('Weekly polls data not found: %s', polls_file);
    end
    
    polls = load(polls_file);
    
    % Create params struct for run_backtest
    params = struct();
    params.Q = Q;
    params.R = R;
    params.P0 = P0;
    params.x0 = 0.5;  % Default initial state
    
    % Run backtest with custom parameters
    backtest_results = run_backtest('params', params, 'verbose', false, 'save_results', false);
end

function rmse = calculate_rmse(backtest_results)
    % Calculate root mean squared error between predictions and actual outcome
    %
    % Uses final actual outcome (Trump win = 0, Harris win = 1 for Dem prob)
    % and compares against all weekly predictions
    
    % Actual outcome (Trump won, so Dem win probability = 0)
    actual_win_prob = 0.0;
    
    % Predicted win probabilities over time
    predicted_probs = backtest_results.predictions.win_prob;
    
    % Calculate RMSE
    errors = predicted_probs - actual_win_prob;
    rmse = sqrt(mean(errors.^2));
end
