function results = sensitivity_analysis(varargin)
    % SENSITIVITY_ANALYSIS - Analyze parameter sensitivity and robustness
    %
    % Examines how Kalman filter performance varies with perturbations in
    % Q, R, and P0 parameters. Helps understand parameter importance and
    % robustness to misspecification.
    %
    % USAGE:
    %   results = sensitivity_analysis()
    %   results = sensitivity_analysis('base_params', [0.001, 0.05, 0.1], ...)
    %
    % OPTIONAL PARAMETERS:
    %   'base_params'    - Baseline [Q, R, P0] (default: best from grid search)
    %   'perturbation'   - Perturbation levels (default: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
    %   'metric'         - Performance metric (default: 'brier')
    %   'verbose'        - Display progress (default: true)
    %
    % OUTPUT:
    %   results - Struct containing:
    %     .base_params       - Baseline parameter values
    %     .base_score        - Performance at baseline
    %     .q_sensitivity     - Scores vs Q perturbations
    %     .r_sensitivity     - Scores vs R perturbations
    %     .p0_sensitivity    - Scores vs P0 perturbations
    %     .sensitivity_index - Normalized sensitivity measures
    %     .robustness_score  - Overall robustness metric
    %
    % EXAMPLE:
    %   % Analyze sensitivity around optimal parameters
    %   results = sensitivity_analysis();
    %
    %   % Custom perturbation range
    %   results = sensitivity_analysis('perturbation', [0.25, 0.5, 1.0, 2.0, 4.0]);
    %
    % SEE ALSO: grid_search, cross_validate, final_params
    
    % Parse inputs
    p = inputParser;
    p.addParameter('base_params', []);
    p.addParameter('perturbation', [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]);
    p.addParameter('metric', 'brier');
    p.addParameter('verbose', true);
    p.parse(varargin{:});
    
    % Extract parameters
    base_params = p.Results.base_params;
    perturbation = p.Results.perturbation;
    metric = p.Results.metric;
    verbose = p.Results.verbose;
    
    % Load base parameters if not specified
    if isempty(base_params)
        try
            grid_results = load('grid_search_results.mat');
            base_params = grid_results.best_params;
        catch
            base_params = [0.001, 0.05, 0.1];  % Defaults
        end
    end
    
    Q_base = base_params(1);
    R_base = base_params(2);
    P0_base = base_params(3);
    
    if verbose
        fprintf('\n=== PARAMETER SENSITIVITY ANALYSIS ===\n');
        fprintf('Base parameters: Q=%.5f, R=%.4f, P0=%.4f\n', ...
                Q_base, R_base, P0_base);
        fprintf('Perturbation factors: %s\n', mat2str(perturbation));
        fprintf('======================================\n\n');
    end
    
    n_perturb = length(perturbation);
    
    % Evaluate base performance
    if verbose
        fprintf('Evaluating baseline performance...\n');
    end
    base_score = evaluate_params(Q_base, R_base, P0_base, metric);
    
    % Q sensitivity (vary Q, hold R and P0 constant)
    if verbose
        fprintf('\nAnalyzing Q (process noise) sensitivity...\n');
    end
    q_scores = zeros(n_perturb, 1);
    for i = 1:n_perturb
        Q_test = Q_base * perturbation(i);
        q_scores(i) = evaluate_params(Q_test, R_base, P0_base, metric);
        if verbose
            fprintf('  Q = %.5f (×%.2f): %s = %.6f\n', ...
                    Q_test, perturbation(i), upper(metric), q_scores(i));
        end
    end
    
    % R sensitivity (vary R, hold Q and P0 constant)
    if verbose
        fprintf('\nAnalyzing R (measurement noise) sensitivity...\n');
    end
    r_scores = zeros(n_perturb, 1);
    for i = 1:n_perturb
        R_test = R_base * perturbation(i);
        r_scores(i) = evaluate_params(Q_base, R_test, P0_base, metric);
        if verbose
            fprintf('  R = %.4f (×%.2f): %s = %.6f\n', ...
                    R_test, perturbation(i), upper(metric), r_scores(i));
        end
    end
    
    % P0 sensitivity (vary P0, hold Q and R constant)
    if verbose
        fprintf('\nAnalyzing P0 (initial uncertainty) sensitivity...\n');
    end
    p0_scores = zeros(n_perturb, 1);
    for i = 1:n_perturb
        P0_test = P0_base * perturbation(i);
        p0_scores(i) = evaluate_params(Q_base, R_base, P0_test, metric);
        if verbose
            fprintf('  P0 = %.4f (×%.2f): %s = %.6f\n', ...
                    P0_test, perturbation(i), upper(metric), p0_scores(i));
        end
    end
    
    % Calculate sensitivity indices
    % Normalized change in performance per unit perturbation
    baseline_idx = find(perturbation == 1.0);
    if isempty(baseline_idx)
        baseline_idx = round(n_perturb / 2);  % Use middle value
    end
    
    sensitivity_index.Q = calculate_sensitivity_index(q_scores, perturbation, baseline_idx);
    sensitivity_index.R = calculate_sensitivity_index(r_scores, perturbation, baseline_idx);
    sensitivity_index.P0 = calculate_sensitivity_index(p0_scores, perturbation, baseline_idx);
    
    % Overall robustness score (lower is more robust)
    robustness_score = (sensitivity_index.Q + sensitivity_index.R + sensitivity_index.P0) / 3;
    
    % Package results
    results.base_params = base_params;
    results.base_score = base_score;
    results.perturbation_factors = perturbation;
    results.q_sensitivity = struct('perturbations', perturbation, 'scores', q_scores);
    results.r_sensitivity = struct('perturbations', perturbation, 'scores', r_scores);
    results.p0_sensitivity = struct('perturbations', perturbation, 'scores', p0_scores);
    results.sensitivity_index = sensitivity_index;
    results.robustness_score = robustness_score;
    results.metric_used = metric;
    
    % Summary report
    if verbose
        fprintf('\n=== SENSITIVITY SUMMARY ===\n');
        fprintf('Baseline score: %.6f\n', base_score);
        fprintf('\nSensitivity Indices (higher = more sensitive):\n');
        fprintf('  Q sensitivity:  %.4f\n', sensitivity_index.Q);
        fprintf('  R sensitivity:  %.4f\n', sensitivity_index.R);
        fprintf('  P0 sensitivity: %.4f\n', sensitivity_index.P0);
        fprintf('\nRobustness score: %.4f (lower is more robust)\n', robustness_score);
        
        % Interpretation
        [most_sensitive_val, most_sensitive_idx] = max([sensitivity_index.Q, ...
                                                        sensitivity_index.R, ...
                                                        sensitivity_index.P0]);
        param_names = {'Q (process noise)', 'R (measurement noise)', 'P0 (initial unc.)'};
        fprintf('\nMost sensitive parameter: %s (index: %.4f)\n', ...
                param_names{most_sensitive_idx}, most_sensitive_val);
        fprintf('===========================\n\n');
    end
end

function score = evaluate_params(Q, R, P0, metric)
    % Evaluate Kalman filter performance with given parameters
    
    try
        % Create params struct for run_backtest
        params = struct();
        params.Q = Q;
        params.R = R;
        params.P0 = P0;
        params.x0 = 0.5;  % Default initial state
        
        backtest_results = run_backtest('params', params, 'verbose', false, 'save_results', false);
        
        switch metric
            case 'brier'
                score = backtest_results.metrics.brier_score;
            case 'rmse'
                actual_win_prob = 0.0;  % Trump won                predicted_probs = backtest_results.predictions.win_prob;
                errors = predicted_probs - actual_win_prob;
                score = sqrt(mean(errors.^2));
            case 'final_error'
                actual_win_prob = 0.0;
                score = abs(backtest_results.predictions.win_prob(end) - actual_win_prob);
            otherwise
                error('Unknown metric: %s', metric);
        end
    catch ME
        warning('Failed to evaluate Q=%.5f, R=%.4f, P0=%.4f: %s', ...
                Q, R, P0, ME.message);
        score = inf;
    end
end

function sensitivity = calculate_sensitivity_index(scores, perturbations, baseline_idx)
    % Calculate normalized sensitivity measure
    %
    % Sensitivity = average absolute percent change in score per unit perturbation
    
    baseline_score = scores(baseline_idx);
    baseline_perturb = perturbations(baseline_idx);
    
    % Calculate percent changes
    pct_changes = abs((scores - baseline_score) / baseline_score) * 100;
    perturb_changes = abs(perturbations - baseline_perturb);
    
    % Exclude baseline point
    valid_idx = perturb_changes > 0;
    
    if sum(valid_idx) > 0
        % Average percent change per unit perturbation change
        normalized_sensitivity = pct_changes(valid_idx) ./ perturb_changes(valid_idx);
        sensitivity = mean(normalized_sensitivity);
    else
        sensitivity = 0;
    end
end
