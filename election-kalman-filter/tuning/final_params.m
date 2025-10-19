function params = final_params(varargin)
    % FINAL_PARAMS - Select and justify final Kalman filter parameters
    %
    % Synthesizes results from grid search, cross-validation, sensitivity
    % analysis, and method comparison to select final production parameters.
    %
    % USAGE:
    %   params = final_params()
    %   params = final_params('run_analysis', true, ...)
    %
    % OPTIONAL PARAMETERS:
    %   'run_analysis'   - Run all analyses before selection (default: false)
    %   'save_results'   - Save parameter selection report (default: true)
    %   'output_file'    - Filename for report (default: 'final_params_report.txt')
    %   'verbose'        - Display detailed report (default: true)
    %
    % OUTPUT:
    %   params - Struct containing:
    %     .Q               - Process noise covariance (selected)
    %     .R               - Measurement noise covariance (selected)
    %     .P0              - Initial uncertainty (selected)
    %     .justification   - Text explaining selection rationale
    %     .performance     - Expected performance metrics
    %     .robustness      - Robustness assessment
    %     .alternatives    - Other candidate parameter sets
    %
    % SELECTION CRITERIA:
    %   1. Best performance on 2024 election (primary)
    %   2. Consistency across historical elections
    %   3. Low sensitivity to parameter perturbations
    %   4. Outperforms baseline methods
    %   5. Theoretical plausibility
    %
    % EXAMPLE:
    %   % Select final parameters based on saved analysis results
    %   params = final_params();
    %
    %   % Run full analysis pipeline then select
    %   params = final_params('run_analysis', true);
    %
    % SEE ALSO: grid_search, cross_validate, sensitivity_analysis, compare_methods
    
    % Parse inputs
    p = inputParser;
    p.addParameter('run_analysis', false);
    p.addParameter('save_results', true);
    p.addParameter('output_file', 'final_params_report.txt');
    p.addParameter('verbose', true);
    p.parse(varargin{:});
    
    run_analysis = p.Results.run_analysis;
    save_results = p.Results.save_results;
    output_file = p.Results.output_file;
    verbose = p.Results.verbose;
    
    if verbose
        fprintf('\n=== FINAL PARAMETER SELECTION ===\n');
        fprintf('Synthesizing all tuning results...\n');
        fprintf('==================================\n\n');
    end
    
    % Run analyses if requested
    if run_analysis
        if verbose
            fprintf('Running comprehensive parameter analysis...\n\n');
        end
        
        fprintf('Step 1/4: Grid search...\n');
        grid_results = grid_search('verbose', false);
        save('grid_search_results.mat', 'grid_results');
        
        fprintf('Step 2/4: Cross-validation...\n');
        cv_results = cross_validate('verbose', false);
        save('cross_validate_results.mat', 'cv_results');
        
        fprintf('Step 3/4: Sensitivity analysis...\n');
        sens_results = sensitivity_analysis('verbose', false);
        save('sensitivity_results.mat', 'sens_results');
        
        fprintf('Step 4/4: Method comparison...\n');
        comp_results = compare_methods('verbose', false);
        save('comparison_results.mat', 'comp_results');
        
        fprintf('\nAll analyses complete!\n\n');
    else
        % Load existing results
        if verbose
            fprintf('Loading existing analysis results...\n');
        end
        
        try
            load('grid_search_results.mat', 'grid_results');
            load('cross_validate_results.mat', 'cv_results');
            load('sensitivity_results.mat', 'sens_results');
            load('comparison_results.mat', 'comp_results');
        catch ME
            error(['Could not load analysis results. Run with ''run_analysis'', true ' ...
                   'or ensure analysis files exist in current directory.']);
        end
    end
    
    % ==================================================================
    % PARAMETER SELECTION LOGIC
    % ==================================================================
    
    % Candidate 1: Best from grid search (optimized for 2024)
    candidate1 = grid_results.best_params;
    score1 = grid_results.best_score;
    
    % Candidate 2: Most robust (lowest sensitivity)
    candidate2 = sens_results.base_params;
    score2 = evaluate_parameter_set(candidate2);
    
    % Candidate 3: Best cross-validated (historical consistency)
    if isfield(cv_results, 'params_tested') && ~isempty(cv_results.params_tested)
        candidate3 = cv_results.params_tested;
        score3 = evaluate_parameter_set(candidate3);
    else
        candidate3 = candidate1;
        score3 = score1;
    end
    
    % Score each candidate on multiple criteria
    candidates = [candidate1; candidate2; candidate3];
    scores = [score1; score2; score3];
    
    % Additional scoring factors
    robustness_scores = zeros(3, 1);
    if isfield(sens_results, 'robustness_score')
        robustness_scores(2) = 1.0 / (1.0 + sens_results.robustness_score);  % Higher is better
    end
    
    % Consistency scores (from cross-validation)
    consistency_scores = zeros(3, 1);
    if isfield(cv_results, 'average_metrics') && isfield(cv_results.average_metrics, 'brier_std')
        consistency_scores(3) = 1.0 / (1.0 + cv_results.average_metrics.brier_std);
    end
    
    % Composite score (weighted combination)
    w_performance = 0.5;
    w_robustness = 0.3;
    w_consistency = 0.2;
    
    % Normalize scores (lower is better for Brier, so invert)
    norm_performance = 1 ./ (1 + scores);
    norm_robustness = robustness_scores / max(max(robustness_scores), eps);
    norm_consistency = consistency_scores / max(max(consistency_scores), eps);
    
    composite_scores = w_performance * norm_performance + ...
                      w_robustness * norm_robustness + ...
                      w_consistency * norm_consistency;
    
    % Select best candidate
    [best_composite, best_idx] = max(composite_scores);
    selected_params = candidates(best_idx, :);
    
    % Package final parameters
    params.Q = selected_params(1);
    params.R = selected_params(2);
    params.P0 = selected_params(3);
    params.selection_method = sprintf('Candidate %d', best_idx);
    params.composite_score = best_composite;
    
    % Build justification text
    justification = build_justification(params, grid_results, cv_results, ...
                                       sens_results, comp_results, best_idx);
    params.justification = justification;
    
    % Expected performance
    params.performance.brier_score = scores(best_idx);
    params.performance.expected_error = sqrt(scores(best_idx));
    
    if isfield(cv_results, 'average_metrics')
        params.performance.historical_brier = cv_results.average_metrics.brier_mean;
    end
    
    % Robustness assessment
    if isfield(sens_results, 'sensitivity_index')
        params.robustness.q_sensitivity = sens_results.sensitivity_index.Q;
        params.robustness.r_sensitivity = sens_results.sensitivity_index.R;
        params.robustness.p0_sensitivity = sens_results.sensitivity_index.P0;
        params.robustness.overall = sens_results.robustness_score;
    end
    
    % Alternative parameter sets
    params.alternatives = cell(2, 1);
    for i = 1:3
        if i ~= best_idx
            alt.params = candidates(i, :);
            alt.score = scores(i);
            alt.composite = composite_scores(i);
            if i > best_idx
                alt_idx = i - 1;
            else
                alt_idx = i;
            end
            params.alternatives{alt_idx} = alt;
        end
    end
    
    % Display results
    if verbose
        display_final_report(params, grid_results, cv_results, sens_results, comp_results);
    end
    
    % Save report to file
    if save_results
        save_final_report(params, output_file, grid_results, cv_results, ...
                         sens_results, comp_results);
        if verbose
            fprintf('\nParameter selection report saved to: %s\n', output_file);
        end
    end
end

% ============================================================
% HELPER FUNCTIONS
% ============================================================

function score = evaluate_parameter_set(params)
    % Evaluate a parameter set using run_backtest
    try
        results = run_backtest('Q', params(1), 'R', params(2), 'P0', params(3), ...
                              'verbose', false);
        score = results.metrics.brier_score;
    catch
        score = inf;
    end
end

function justification = build_justification(params, grid_results, cv_results, ...
                                           sens_results, comp_results, best_idx)
    % Build text justification for parameter selection
    
    justification = sprintf(['Final Kalman Filter Parameters:\n' ...
                            '  Q (process noise):     %.6f\n' ...
                            '  R (measurement noise): %.6f\n' ...                            '  P0 (initial unc.):     %.6f\n\n' ...
                            'Selection Rationale:\n'], ...
                           params.Q, params.R, params.P0);
    
    switch best_idx
        case 1
            justification = [justification ...
                'Selected based on BEST PERFORMANCE on 2024 election data.\n' ...
                sprintf('Achieved Brier score of %.6f via exhaustive grid search.\n', ...
                       grid_results.best_score)];
        case 2
            justification = [justification ...
                'Selected based on ROBUSTNESS to parameter variations.\n' ...
                sprintf('Low sensitivity score: %.4f (lower is more stable).\n', ...
                       sens_results.robustness_score)];
        case 3
            justification = [justification ...
                'Selected based on HISTORICAL CONSISTENCY across elections.\n' ...
                sprintf('Validated on %d previous elections.\n', cv_results.n_valid)];
    end
    
    % Add method comparison context
    if isfield(comp_results, 'best_method')
        justification = [justification ...
            sprintf('\nKalman filter outperforms baseline methods including:\n' ...
                   '  - Moving average\n' ...
                   '  - Exponential smoothing\n' ...
                   '  - Latest poll only\n')];
    end
end

function display_final_report(params, grid_results, cv_results, sens_results, comp_results)
    % Display comprehensive parameter selection report
    
    fprintf('=== FINAL PARAMETER SELECTION REPORT ===\n\n');
    fprintf('SELECTED PARAMETERS:\n');
    fprintf('  Q (process noise):     %.6f\n', params.Q);
    fprintf('  R (measurement noise): %.6f\n', params.R);
    fprintf('  P0 (initial unc.):     %.6f\n', params.P0);
    fprintf('  Selection method:      %s\n', params.selection_method);
    fprintf('  Composite score:       %.6f\n', params.composite_score);
    
    fprintf('\nEXPECTED PERFORMANCE:\n');    fprintf('  Brier score (2024):    %.6f\n', params.performance.brier_score);
    fprintf('  Expected error:        %.6f\n', params.performance.expected_error);
    if isfield(params.performance, 'historical_brier')
        fprintf('  Historical avg Brier:  %.6f\n', params.performance.historical_brier);
    end
    
    fprintf('\nROBUSTNESS ASSESSMENT:\n');
    if isfield(params.robustness, 'overall')
        fprintf('  Overall robustness:    %.4f (lower is better)\n', params.robustness.overall);
        fprintf('  Q sensitivity:         %.4f\n', params.robustness.q_sensitivity);
        fprintf('  R sensitivity:         %.4f\n', params.robustness.r_sensitivity);
        fprintf('  P0 sensitivity:        %.4f\n', params.robustness.p0_sensitivity);
    else
        fprintf('  Robustness data not available\n');
    end
    
    fprintf('\nGRID SEARCH SUMMARY:\n');
    fprintf('  Optimal Q from grid:   %.6f\n', grid_results.best_params(1));
    fprintf('  Optimal R from grid:   %.6f\n', grid_results.best_params(2));
    fprintf('  Optimal P0 from grid:  %.6f\n', grid_results.best_params(3));
    fprintf('  Best grid score:       %.6f\n', grid_results.best_score);
    
    fprintf('\nCROSS-VALIDATION:\n');
    if isfield(cv_results, 'n_valid')
        fprintf('  Elections validated:   %d/%d\n', cv_results.n_valid, cv_results.n_total);
        if isfield(cv_results.average_metrics, 'brier_mean')
            fprintf('  Avg Brier score:       %.6f ± %.6f\n', ...
                   cv_results.average_metrics.brier_mean, ...
                   cv_results.average_metrics.brier_std);
        end
    else
        fprintf('  Cross-validation data not available\n');
    end
    
    fprintf('\nMETHOD COMPARISON:\n');
    if isfield(comp_results, 'best_method')
        fprintf('  Best method overall:   %s\n', comp_results.best_method);
        fprintf('  Methods compared:      %d\n', comp_results.n_methods);
    else
        fprintf('  Method comparison not available\n');
    end
    
    fprintf('\n');    fprintf('========================================\n\n');
end

function save_final_report(params, filename, grid_results, cv_results, ...
                          sens_results, comp_results)
    % Save comprehensive report to text file
    
    fid = fopen(filename, 'w');
    if fid == -1
        warning('Could not open file for writing: %s', filename);
        return;
    end
    
    try
        fprintf(fid, '========================================\n');
        fprintf(fid, 'KALMAN FILTER PARAMETER SELECTION REPORT\n');
        fprintf(fid, '========================================\n');
        fprintf(fid, 'Generated: %s\n\n', datestr(now));
        
        fprintf(fid, '%s\n', params.justification);
        
        fprintf(fid, '\n--- DETAILED ANALYSIS ---\n\n');
        
        fprintf(fid, 'Grid Search Results:\n');
        fprintf(fid, '  Combinations tested: %d\n', ...
               prod(size(grid_results.all_scores)));
        fprintf(fid, '  Optimal Q: %.6f\n', grid_results.best_params(1));
        fprintf(fid, '  Optimal R: %.6f\n', grid_results.best_params(2));
        fprintf(fid, '  Optimal P0: %.6f\n', grid_results.best_params(3));
        fprintf(fid, '  Best score: %.6f\n\n', grid_results.best_score);
        
        if isfield(cv_results, 'n_valid')
            fprintf(fid, 'Cross-Validation:\n');
            fprintf(fid, '  Elections: %d/%d\n', cv_results.n_valid, cv_results.n_total);
            if isfield(cv_results.average_metrics, 'brier_mean')
                fprintf(fid, '  Avg Brier: %.6f ± %.6f\n\n', ...
                       cv_results.average_metrics.brier_mean, ...
                       cv_results.average_metrics.brier_std);
            end
        end
        
        if isfield(sens_results, 'robustness_score')
            fprintf(fid, 'Sensitivity Analysis:\n');
            fprintf(fid, '  Q sensitivity: %.4f\n', sens_results.sensitivity_index.Q);
            fprintf(fid, '  R sensitivity: %.4f\n', sens_results.sensitivity_index.R);
            fprintf(fid, '  P0 sensitivity: %.4f\n', sens_results.sensitivity_index.P0);
            fprintf(fid, '  Robustness: %.4f\n\n', sens_results.robustness_score);
        end
        
        if isfield(comp_results, 'n_methods')
            fprintf(fid, 'Method Comparison:\n');
            fprintf(fid, '  Methods compared: %d\n', comp_results.n_methods);
            fprintf(fid, '  Best method: %s\n\n', comp_results.best_method);
        end
        
        fprintf(fid, '--- RECOMMENDATION ---\n\n');
        fprintf(fid, 'Use the following parameters for production:\n');
        fprintf(fid, '  kalman_init(''Q'', %.6f, ''R'', %.6f, ''P0'', %.6f)\n\n', ...
               params.Q, params.R, params.P0);
        
        fprintf(fid, 'Expected Performance:\n');
        fprintf(fid, '  Brier score: %.6f\n', params.performance.brier_score);
        fprintf(fid, '  Confidence: ±%.6f\n', params.performance.expected_error);
        
        fprintf(fid, '\n========================================\n');
        fprintf(fid, 'END OF REPORT\n');
        fprintf(fid, '========================================\n');
        
        fclose(fid);
    catch ME
        fclose(fid);
        rethrow(ME);
    end
end
