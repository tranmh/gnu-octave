function metrics = calculate_metrics(predictions, actual_outcome)
    % CALCULATE_METRICS Compute accuracy metrics for election predictions
    %
    % Usage:
    %   metrics = calculate_metrics(predictions, actual_outcome)
    %
    % Inputs:
    %   predictions    - Struct with fields:
    %                    .win_prob: [nx1] predicted win probabilities
    %                    .win_prob_std: [nx1] prediction uncertainties
    %                    .weeks: [nx1] week numbers
    %                    .dates: {nx1} date strings
    %   actual_outcome - Struct with fields:
    %                    .winner: 'Trump' or 'Harris'
    %                    .dem_vote_share: Democratic vote percentage
    %                    .rep_vote_share: Republican vote percentage
    %                    .dem_margin: Democratic margin (can be negative)
    %
    % Outputs:
    %   metrics - Struct containing:
    %             .final_prediction: Final win probability
    %             .final_error: Absolute error of final prediction
    %             .brier_score: Brier score (0 = perfect, 1 = worst)
    %             .log_score: Logarithmic score (higher is better)
    %             .rmse: Root mean squared error over all weeks
    %             .mae: Mean absolute error over all weeks
    %             .calibration: Calibration error
    %             .final_confidence_interval: [lower, upper]
    %             .prediction_consistency: Measure of prediction stability
    %
    % Notes:
    %   - Brier score: mean((prediction - outcome)^2), optimal = 0
    %   - Log score: -log(probability assigned to actual outcome)
    %   - Calibration: difference between predicted and empirical probabilities
    %
    % Example:
    %   predictions.win_prob = [0.48; 0.47; 0.49; 0.51];
    %   predictions.win_prob_std = [0.10; 0.09; 0.08; 0.07];
    %   actual.winner = 'Trump';
    %   actual.dem_vote_share = 48.3;
    %   metrics = calculate_metrics(predictions, actual);
    
    % Validate inputs
    if ~isstruct(predictions) || ~isfield(predictions, 'win_prob')
        error('Predictions must be a struct with field win_prob');
    end
    if ~isstruct(actual_outcome) || ~isfield(actual_outcome, 'winner')
        error('Actual outcome must be a struct with field winner');
    end
    
    % Extract predictions
    win_prob = predictions.win_prob(:);
    n_weeks = length(win_prob);
    
    % Determine actual outcome (0 or 1)
    % 1 = Democrat won, 0 = Republican won
    if strcmpi(actual_outcome.winner, 'Harris') || strcmpi(actual_outcome.winner, 'Biden')
        actual_binary = 1;  % Democrat won
    elseif strcmpi(actual_outcome.winner, 'Trump')
        actual_binary = 0;  % Republican won
    else
        error('Unknown winner: %s', actual_outcome.winner);
    end
    
    % ===== FINAL PREDICTION METRICS =====
    metrics.final_prediction = win_prob(end);
    metrics.final_error = abs(metrics.final_prediction - actual_binary);
    
    % ===== BRIER SCORE =====
    % Brier score: mean squared error of probabilistic predictions
    % For binary outcome: BS = (p - outcome)^2
    % Optimal score: 0 (perfect prediction)
    % Worst score: 1 (always predict opposite of outcome)
    brier_scores = (win_prob - actual_binary).^2;
    metrics.brier_score = mean(brier_scores);
    metrics.final_brier_score = brier_scores(end);
    
    % ===== LOGARITHMIC SCORE =====
    % Log score: -log(probability assigned to actual outcome)
    % Lower is better (less negative)
    % Penalizes confident wrong predictions heavily
    epsilon = 1e-10;  % Avoid log(0)
    if actual_binary == 1
        prob_correct = max(win_prob, epsilon);
    else
        prob_correct = max(1 - win_prob, epsilon);
    end
    log_scores = -log(prob_correct);
    metrics.log_score = mean(log_scores);
    metrics.final_log_score = log_scores(end);
    
    % ===== ROOT MEAN SQUARED ERROR =====
    % RMSE over all weekly predictions
    metrics.rmse = sqrt(mean((win_prob - actual_binary).^2));
    
    % ===== MEAN ABSOLUTE ERROR =====
    % MAE over all weekly predictions
    metrics.mae = mean(abs(win_prob - actual_binary));
    
    % ===== PREDICTION CONSISTENCY =====
    % Measure how stable predictions were
    % Lower is better (more consistent)
    if n_weeks > 1
        prediction_changes = diff(win_prob);
        metrics.prediction_volatility = std(prediction_changes);
        metrics.max_prediction_change = max(abs(prediction_changes));
        metrics.prediction_trend = win_prob(end) - win_prob(1);
    else
        metrics.prediction_volatility = 0;
        metrics.max_prediction_change = 0;
        metrics.prediction_trend = 0;
    end
    
    % ===== CONFIDENCE INTERVALS =====
    if isfield(predictions, 'win_prob_std')
        win_prob_std = predictions.win_prob_std(:);
        
        % 95% confidence intervals
        z_95 = 1.96;
        lower_bound = win_prob - z_95 * win_prob_std;
        upper_bound = win_prob + z_95 * win_prob_std;
        
        % Ensure bounds are in [0, 1]
        lower_bound = max(0, min(1, lower_bound));
        upper_bound = max(0, min(1, upper_bound));
        
        metrics.final_confidence_interval = [lower_bound(end), upper_bound(end)];
        
        % Check if actual outcome falls within 95% CI
        metrics.outcome_in_final_ci = (actual_binary >= lower_bound(end)) && ...
                                       (actual_binary <= upper_bound(end));
        
        % Average confidence interval width
        metrics.avg_ci_width = mean(upper_bound - lower_bound);
        metrics.final_ci_width = upper_bound(end) - lower_bound(end);
        
    else
        metrics.final_confidence_interval = [NaN, NaN];
        metrics.outcome_in_final_ci = NaN;
        metrics.avg_ci_width = NaN;
        metrics.final_ci_width = NaN;
    end
    
    % ===== CALIBRATION =====
    % Divide predictions into bins and check empirical vs predicted probabilities
    % For a single election, perfect calibration check isn't possible
    % Instead, we measure how far the final prediction was from 0.5 (uncertainty)
    metrics.prediction_confidence = abs(metrics.final_prediction - 0.5);
    
    % ===== DIRECTIONAL ACCURACY =====
    % Did we predict the correct winner?
    predicted_winner_dem = metrics.final_prediction > 0.5;
    actual_winner_dem = actual_binary == 1;
    metrics.correct_winner_prediction = (predicted_winner_dem == actual_winner_dem);
    
    % ===== VOTE SHARE COMPARISON =====
    if isfield(actual_outcome, 'dem_vote_share')
        % Compare predicted probability to actual vote share
        actual_dem_share = actual_outcome.dem_vote_share / 100;
        metrics.vote_share_error = abs(metrics.final_prediction - actual_dem_share);
    else
        metrics.vote_share_error = NaN;
    end
    
    % ===== SUMMARY STATISTICS =====
    metrics.n_predictions = n_weeks;
    metrics.prediction_mean = mean(win_prob);
    metrics.prediction_median = median(win_prob);
    metrics.prediction_std = std(win_prob);
    
    % ===== WEEKLY EVOLUTION =====
    metrics.weekly_predictions = win_prob;
    if isfield(predictions, 'weeks')
        metrics.weeks = predictions.weeks;
    end
    if isfield(predictions, 'dates')
        metrics.dates = predictions.dates;
    end
    
    % ===== PERFORMANCE GRADE =====
    % Simple grading system
    if metrics.correct_winner_prediction && metrics.brier_score < 0.1
        metrics.grade = 'Excellent';
    elseif metrics.correct_winner_prediction && metrics.brier_score < 0.15
        metrics.grade = 'Good';
    elseif metrics.correct_winner_prediction
        metrics.grade = 'Fair';
    else
        metrics.grade = 'Poor';
    end
    
    % Display summary
    fprintf('\n=== BACKTESTING METRICS SUMMARY ===\n');
    fprintf('Final Prediction: %.4f (Democratic win probability)\n', metrics.final_prediction);
    fprintf('Actual Winner: %s\n', actual_outcome.winner);
    fprintf('Correct Winner: %s\n', mat2str(metrics.correct_winner_prediction));
    fprintf('Final Error: %.4f\n', metrics.final_error);
    fprintf('Brier Score: %.4f (optimal = 0)\n', metrics.brier_score);
    fprintf('Log Score: %.4f (lower is better)\n', metrics.log_score);
    fprintf('Performance Grade: %s\n', metrics.grade);
    fprintf('===================================\n\n');
end
