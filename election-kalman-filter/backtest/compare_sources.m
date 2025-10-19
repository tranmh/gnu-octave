function comparison = compare_sources(predictions_cell, source_names, actual_outcome)
    % COMPARE_SOURCES Compare predictions from multiple polling sources
    %
    % Usage:
    %   comparison = compare_sources(predictions_cell, source_names, actual_outcome)
    %
    % Inputs:
    %   predictions_cell - Cell array of prediction structs, each with:
    %                      .win_prob: [nx1] predicted win probabilities
    %                      .win_prob_std: [nx1] prediction uncertainties
    %   source_names     - Cell array of source names (same length as predictions_cell)
    %   actual_outcome   - Struct with fields:
    %                      .winner: 'Trump' or 'Harris'
    %                      .dem_vote_share: Democratic vote percentage
    %
    % Outputs:
    %   comparison - Struct containing:
    %                .source_names: Input source names
    %                .n_sources: Number of sources
    %                .metrics: [n_sources x 1] struct array of metrics
    %                .rankings: Struct with rankings by different criteria
    %                .best_source: Name of best performing source
    %                .ensemble_prediction: Combined prediction from all sources
    %
    % Notes:
    %   - Each source is evaluated independently using calculate_metrics
    %   - Sources are ranked by Brier score (lower is better)
    %   - Ensemble combines predictions using simple averaging
    %
    % Example:
    %   pred1.win_prob = [0.48; 0.49];
    %   pred2.win_prob = [0.51; 0.52];
    %   actual.winner = 'Trump';
    %   comparison = compare_sources({pred1, pred2}, {'Source1', 'Source2'}, actual);
    
    % Validate inputs
    if ~iscell(predictions_cell)
        error('predictions_cell must be a cell array');
    end
    if ~iscell(source_names)
        error('source_names must be a cell array');
    end
    if length(predictions_cell) ~= length(source_names)
        error('predictions_cell and source_names must have same length');
    end
    if ~isstruct(actual_outcome)
        error('actual_outcome must be a struct');
    end
    
    n_sources = length(predictions_cell);
    comparison.source_names = source_names;
    comparison.n_sources = n_sources;
    
    % ===== CALCULATE METRICS FOR EACH SOURCE =====
    fprintf('\n=== COMPARING %d POLLING SOURCES ===\n', n_sources);
    
    metrics_array = struct();
    for i = 1:n_sources
        fprintf('\nEvaluating: %s\n', source_names{i});
        fprintf('----------------------------------------\n');
        
        % Calculate metrics for this source
        metrics_array(i).source = source_names{i};
        metrics_array(i).results = calculate_metrics(predictions_cell{i}, actual_outcome);
    end
    
    comparison.metrics = metrics_array;
    
    % ===== RANK SOURCES BY DIFFERENT CRITERIA =====
    
    % Extract key metrics for ranking
    brier_scores = zeros(n_sources, 1);
    final_errors = zeros(n_sources, 1);
    log_scores = zeros(n_sources, 1);
    correct_winners = zeros(n_sources, 1);
    
    for i = 1:n_sources
        brier_scores(i) = metrics_array(i).results.brier_score;
        final_errors(i) = metrics_array(i).results.final_error;
        log_scores(i) = metrics_array(i).results.log_score;
        correct_winners(i) = double(metrics_array(i).results.correct_winner_prediction);
    end
    
    % Rank by Brier score (lower is better)
    [sorted_brier, idx_brier] = sort(brier_scores);
    comparison.rankings.by_brier_score = source_names(idx_brier);
    comparison.rankings.brier_scores = sorted_brier;
    
    % Rank by final error (lower is better)
    [sorted_error, idx_error] = sort(final_errors);
    comparison.rankings.by_final_error = source_names(idx_error);
    comparison.rankings.final_errors = sorted_error;
    
    % Rank by log score (lower is better)
    [sorted_log, idx_log] = sort(log_scores);
    comparison.rankings.by_log_score = source_names(idx_log);
    comparison.rankings.log_scores = sorted_log;
    
    % ===== IDENTIFY BEST SOURCE =====
    % Best source is the one with lowest Brier score
    comparison.best_source = source_names{idx_brier(1)};
    comparison.best_brier_score = sorted_brier(1);
    
    % ===== CREATE ENSEMBLE PREDICTION =====
    % Simple averaging of all sources
    fprintf('\n=== CREATING ENSEMBLE PREDICTION ===\n');
    
    % Find minimum length among all predictions
    min_length = inf;
    for i = 1:n_sources
        min_length = min(min_length, length(predictions_cell{i}.win_prob));
    end
    
    % Average predictions (truncate to min_length)
    ensemble_win_prob = zeros(min_length, 1);
    ensemble_std = zeros(min_length, 1);
    
    for i = 1:n_sources
        pred = predictions_cell{i}.win_prob;
        ensemble_win_prob = ensemble_win_prob + pred(1:min_length);
        
        if isfield(predictions_cell{i}, 'win_prob_std')
            std_val = predictions_cell{i}.win_prob_std;
            % Combine uncertainties (assuming independence)
            ensemble_std = ensemble_std + std_val(1:min_length).^2;
        end
    end
    
    ensemble_win_prob = ensemble_win_prob / n_sources;
    ensemble_std = sqrt(ensemble_std) / n_sources;  % Average of variances
    
    % Create ensemble prediction struct
    ensemble.win_prob = ensemble_win_prob;
    ensemble.win_prob_std = ensemble_std;
    if isfield(predictions_cell{1}, 'weeks')
        ensemble.weeks = predictions_cell{1}.weeks(1:min_length);
    end
    if isfield(predictions_cell{1}, 'dates')
        ensemble.dates = predictions_cell{1}.dates(1:min_length);
    end
    
    % Evaluate ensemble
    ensemble_metrics = calculate_metrics(ensemble, actual_outcome);
    comparison.ensemble_prediction = ensemble;
    comparison.ensemble_metrics = ensemble_metrics;
    
    % ===== COMPARATIVE STATISTICS =====
    comparison.stats.mean_brier_score = mean(brier_scores);
    comparison.stats.std_brier_score = std(brier_scores);
    comparison.stats.mean_final_error = mean(final_errors);
    comparison.stats.std_final_error = std(final_errors);
    comparison.stats.correct_winner_rate = mean(correct_winners);
    
    % ===== DISPLAY COMPARISON SUMMARY =====
    fprintf('\n=== SOURCE COMPARISON SUMMARY ===\n');
    fprintf('%-20s %12s %12s %12s %10s\n', ...
            'Source', 'Brier Score', 'Final Error', 'Log Score', 'Winner OK');
    fprintf('%-20s %12s %12s %12s %10s\n', ...
            repmat('-', 1, 20), repmat('-', 1, 12), repmat('-', 1, 12), ...
            repmat('-', 1, 12), repmat('-', 1, 10));
    
    for i = 1:n_sources
        fprintf('%-20s %12.4f %12.4f %12.4f %10s\n', ...
                source_names{i}, ...
                brier_scores(i), ...
                final_errors(i), ...
                log_scores(i), ...
                mat2str(correct_winners(i) == 1));
    end
    
    fprintf('%-20s %12s %12s %12s %10s\n', ...
            repmat('-', 1, 20), repmat('-', 1, 12), repmat('-', 1, 12), ...
            repmat('-', 1, 12), repmat('-', 1, 10));
    fprintf('%-20s %12.4f %12.4f %12.4f %10s\n', ...
            'ENSEMBLE', ...
            ensemble_metrics.brier_score, ...
            ensemble_metrics.final_error, ...
            ensemble_metrics.log_score, ...
            mat2str(ensemble_metrics.correct_winner_prediction));
    
    fprintf('\nBest Source (by Brier score): %s (%.4f)\n', ...
            comparison.best_source, comparison.best_brier_score);
    fprintf('Ensemble Performance: %.4f Brier score\n', ensemble_metrics.brier_score);
    fprintf('=================================\n\n');
end
