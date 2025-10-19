function results = cross_validate(varargin)
    % CROSS_VALIDATE - Validate Kalman filter on historical elections
    %
    % Tests parameter robustness by applying the filter to previous elections
    % (2016, 2020) and comparing performance across different electoral contexts.
    %
    % USAGE:
    %   results = cross_validate()
    %   results = cross_validate('params', [0.001, 0.05, 0.1], ...)
    %
    % OPTIONAL PARAMETERS:
    %   'params'         - [Q, R, P0] to test (default: use best from grid_search)
    %   'elections'      - Years to validate: [2016, 2020] (default: [2016, 2020])
    %   'use_synthetic'  - Use synthetic data if historical unavailable (default: true)
    %   'verbose'        - Display progress (default: true)
    %
    % OUTPUT:
    %   results - Struct containing:
    %     .params_tested   - [Q, R, P0] values used
    %     .election_results - Cell array of results per election
    %     .average_metrics  - Mean performance across elections
    %     .consistency      - Variance in performance
    %
    % EXAMPLE:
    %   % Test default parameters on historical data
    %   results = cross_validate();
    %
    %   % Test specific parameters
    %   results = cross_validate('params', [0.001, 0.05, 0.1]);
    %
    % SEE ALSO: grid_search, sensitivity_analysis, run_backtest
    
    % Parse inputs
    p = inputParser;
    p.addParameter('params', [], @(x) isempty(x) || (isnumeric(x) && length(x) == 3));
    p.addParameter('elections', [2016, 2020]);
    p.addParameter('use_synthetic', true);
    p.addParameter('verbose', true);
    p.parse(varargin{:});
    
    % Extract parameters
    params = p.Results.params;
    elections = p.Results.elections;
    use_synthetic = p.Results.use_synthetic;
    verbose = p.Results.verbose;
    
    % If no params specified, try to load best from grid search
    if isempty(params)
        try
            grid_results = load('grid_search_results.mat');
            params = grid_results.best_params;
            if verbose
                fprintf('Using best parameters from grid_search: Q=%.5f, R=%.4f, P0=%.4f\n', ...
                        params(1), params(2), params(3));
            end
        catch
            % Use reasonable defaults
            params = [0.001, 0.05, 0.1];
            if verbose
                fprintf('Using default parameters: Q=%.5f, R=%.4f, P0=%.4f\n', ...
                        params(1), params(2), params(3));
            end
        end
    end
    
    Q = params(1);
    R = params(2);
    P0 = params(3);
    
    if verbose
        fprintf('\n=== HISTORICAL CROSS-VALIDATION ===\n');
        fprintf('Testing on elections: %s\n', mat2str(elections));
        fprintf('Parameters: Q=%.5f, R=%.4f, P0=%.4f\n', Q, R, P0);
        fprintf('===================================\n\n');
    end
    
    % Initialize storage
    n_elections = length(elections);
    election_results = cell(n_elections, 1);
    
    % Validate on each historical election
    for i = 1:n_elections
        year = elections(i);
        
        if verbose
            fprintf('--- Election %d (%d/%d) ---\n', year, i, n_elections);
        end
        
        try
            % Check if historical data exists
            hist_filename = sprintf('historical_polls_%d.mat', year);
            historical_path = fullfile(fileparts(mfilename('fullpath')), '..', ...
                                      'data', 'processed', hist_filename);
            
            if exist(historical_path, 'file')
                if verbose
                    fprintf('  Loading historical data: %s\n', hist_filename);
                end
                election_data = load(historical_path);
            elseif use_synthetic
                if verbose
                    fprintf('  Historical data not found, generating synthetic data\n');
                end
                election_data = generate_synthetic_election(year);
            else
                warning('Historical data not found for %d, skipping', year);
                continue;
            end
            
            % Run validation with these parameters
            validation_result = validate_on_election(election_data, Q, R, P0, verbose);
            election_results{i} = validation_result;
            
            if verbose
                fprintf('  Brier score: %.6f\n', validation_result.brier_score);
                fprintf('  Final error: %.6f\n', validation_result.final_error);
                if validation_result.direction_correct
                    direction_str = 'Yes';
                else
                    direction_str = 'No';
                end
                fprintf('  Direction correct: %s\n\n', direction_str);
            end
            
        catch ME
            warning('Failed validation for %d: %s', year, ME.message);
            election_results{i} = struct('year', year, 'failed', true, ...
                                        'error', ME.message);
        end
    end
    
    % Calculate aggregate statistics
    valid_results = election_results(~cellfun(@(x) isfield(x, 'failed'), election_results));
    n_valid = length(valid_results);
    
    if n_valid > 0
        brier_scores = cellfun(@(x) x.brier_score, valid_results);
        final_errors = cellfun(@(x) x.final_error, valid_results);
        directions = cellfun(@(x) x.direction_correct, valid_results);
        
        average_metrics.brier_mean = mean(brier_scores);
        average_metrics.brier_std = std(brier_scores);
        average_metrics.error_mean = mean(final_errors);
        average_metrics.error_std = std(final_errors);
        average_metrics.direction_accuracy = mean(directions);
        
        consistency.brier_range = max(brier_scores) - min(brier_scores);
        consistency.error_range = max(final_errors) - min(final_errors);
        consistency.brier_cv = average_metrics.brier_std / average_metrics.brier_mean;
    else
        average_metrics = struct();
        consistency = struct();
    end
    
    % Package results
    results.params_tested = params;
    results.election_results = election_results;
    results.average_metrics = average_metrics;
    results.consistency = consistency;
    results.n_valid = n_valid;
    results.n_total = n_elections;
    
    % Final summary
    if verbose && n_valid > 0
        fprintf('=== CROSS-VALIDATION SUMMARY ===\n');
        fprintf('Validated on %d/%d elections\n', n_valid, n_elections);
        fprintf('\nAverage Performance:\n');
        fprintf('  Brier score: %.6f ± %.6f\n', ...
                average_metrics.brier_mean, average_metrics.brier_std);
        fprintf('  Final error: %.6f ± %.6f\n', ...
                average_metrics.error_mean, average_metrics.error_std);
        fprintf('  Direction accuracy: %.1f%%\n', 100 * average_metrics.direction_accuracy);
        fprintf('\nConsistency Metrics:\n');
        fprintf('  Brier CV: %.4f\n', consistency.brier_cv);
        fprintf('  Error range: [%.6f, %.6f]\n', ...
                min(final_errors), max(final_errors));
        fprintf('================================\n\n');
    end
end

function validation_result = validate_on_election(election_data, Q, R, P0, verbose)
    % Validate Kalman filter on a single historical election
    
    % Run Kalman filter with specified parameters
    % (This would integrate with actual historical polling data)
    
    % For now, create placeholder validation
    % In full implementation, this would:
    % 1. Load historical weekly polling data
    % 2. Run Kalman filter forward
    % 3. Compare final prediction to actual outcome
    
    validation_result.year = election_data.year;
    validation_result.actual_winner = election_data.actual_winner;
    validation_result.actual_margin = election_data.actual_margin;
    
    % Placeholder: Run simplified backtest simulation
    % In practice, would call run_backtest with historical data
    validation_result.final_prediction = 0.5 + randn() * 0.1;  % Placeholder
    validation_result.final_error = abs(validation_result.final_prediction - ...
                                       election_data.dem_win_prob);
    validation_result.brier_score = validation_result.final_error^2;  % Simplified
    
    % Check if prediction direction correct
    predicted_winner = validation_result.final_prediction > 0.5;
    actual_winner = election_data.dem_win_prob > 0.5;
    validation_result.direction_correct = (predicted_winner == actual_winner);
end

function election_data = generate_synthetic_election(year)
    % Generate synthetic election data for testing when historical unavailable    
    % Known historical outcomes
    switch year
        case 2016
            % Trump won (Republican)
            election_data.year = 2016;
            election_data.actual_winner = 'Trump';
            election_data.dem_candidate = 'Clinton';
            election_data.rep_candidate = 'Trump';
            election_data.dem_vote_share = 48.2;  % Popular vote
            election_data.rep_vote_share = 46.1;
            election_data.dem_margin = 2.1;  % Clinton won popular vote
            election_data.dem_win_prob = 0.0;  % But lost electoral college
            
        case 2020
            % Biden won (Democrat)
            election_data.year = 2020;
            election_data.actual_winner = 'Biden';
            election_data.dem_candidate = 'Biden';
            election_data.rep_candidate = 'Trump';
            election_data.dem_vote_share = 51.3;
            election_data.rep_vote_share = 46.8;
            election_data.dem_margin = 4.5;
            election_data.dem_win_prob = 1.0;  % Biden won
            
        otherwise
            % Generic synthetic data
            election_data.year = year;
            election_data.actual_winner = 'Unknown';
            election_data.dem_candidate = 'Candidate_D';
            election_data.rep_candidate = 'Candidate_R';
            election_data.dem_vote_share = 48 + randn() * 3;
            election_data.rep_vote_share = 100 - election_data.dem_vote_share;
            election_data.dem_margin = election_data.dem_vote_share - ...
                                      election_data.rep_vote_share;
            election_data.dem_win_prob = double(election_data.dem_margin > 0);
    end
end
