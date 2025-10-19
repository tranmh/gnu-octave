function ci_results = confidence_intervals(predictions, confidence_levels)
    % CONFIDENCE_INTERVALS Compute confidence intervals for predictions
    %
    % Usage:
    %   ci_results = confidence_intervals(predictions)
    %   ci_results = confidence_intervals(predictions, confidence_levels)
    %
    % Inputs:
    %   predictions       - Struct with fields:
    %                       .win_prob: [nx1] predicted win probabilities
    %                       .win_prob_std: [nx1] prediction uncertainties
    %                       .weeks: [nx1] week numbers (optional)
    %   confidence_levels - Array of confidence levels (default: [0.68, 0.95, 0.99])
    %                       Values should be between 0 and 1
    %
    % Outputs:
    %   ci_results - Struct containing:
    %                .confidence_levels: Input confidence levels
    %                .z_scores: Corresponding z-scores for normal distribution
    %                .intervals: Cell array of [nx2] matrices [lower, upper]
    %                .final_intervals: Final week intervals for each level
    %                .coverage_widths: Average interval widths for each level
    %                .weeks: Week numbers (if available)
    %
    % Notes:
    %   - Assumes predictions follow normal distribution
    %   - Intervals are clipped to [0, 1] range
    %   - Common confidence levels:
    %     * 68% (1 sigma): z = 1.00
    %     * 95% (2 sigma): z = 1.96
    %     * 99% (3 sigma): z = 2.58
    %
    % Example:
    %   predictions.win_prob = [0.48; 0.49; 0.51];
    %   predictions.win_prob_std = [0.10; 0.09; 0.08];
    %   ci = confidence_intervals(predictions, [0.68, 0.95]);
    
    % Default confidence levels
    if nargin < 2
        confidence_levels = [0.68, 0.95, 0.99];
    end
    
    % Validate inputs
    if ~isstruct(predictions) || ~isfield(predictions, 'win_prob')
        error('Predictions must be a struct with field win_prob');
    end
    if ~isfield(predictions, 'win_prob_std')
        error('Predictions must include win_prob_std for confidence intervals');
    end
    
    % Validate confidence levels
    if any(confidence_levels <= 0 | confidence_levels >= 1)
        error('Confidence levels must be between 0 and 1');
    end
    
    % Extract predictions
    win_prob = predictions.win_prob(:);
    win_prob_std = predictions.win_prob_std(:);
    n_weeks = length(win_prob);
    
    % Compute z-scores for each confidence level
    % For normal distribution: P(-z < X < z) = confidence_level
    % z = norminv((1 + confidence_level) / 2)
    z_scores = zeros(size(confidence_levels));
    for i = 1:length(confidence_levels)
        % Using inverse normal CDF
        alpha = (1 - confidence_levels(i)) / 2;
        z_scores(i) = -norminv(alpha);
    end
    
    % Initialize output
    ci_results.confidence_levels = confidence_levels(:)';
    ci_results.z_scores = z_scores(:)';
    ci_results.intervals = cell(1, length(confidence_levels));
    ci_results.final_intervals = zeros(length(confidence_levels), 2);
    ci_results.coverage_widths = zeros(size(confidence_levels));
    
    % Compute intervals for each confidence level
    for i = 1:length(confidence_levels)
        z = z_scores(i);
        
        % Lower and upper bounds
        lower = win_prob - z * win_prob_std;
        upper = win_prob + z * win_prob_std;
        
        % Clip to [0, 1] range
        lower = max(0, min(1, lower));
        upper = max(0, min(1, upper));
        
        % Store intervals
        ci_results.intervals{i} = [lower, upper];
        
        % Final interval
        ci_results.final_intervals(i, :) = [lower(end), upper(end)];
        
        % Average coverage width
        ci_results.coverage_widths(i) = mean(upper - lower);
    end
    
    % Add week numbers if available
    if isfield(predictions, 'weeks')
        ci_results.weeks = predictions.weeks(:);
    else
        ci_results.weeks = (1:n_weeks)';
    end
    
    % Add dates if available
    if isfield(predictions, 'dates')
        ci_results.dates = predictions.dates;
    end
    
    % Store underlying predictions
    ci_results.win_prob = win_prob;
    ci_results.win_prob_std = win_prob_std;
    
    % Display summary
    fprintf('\n=== CONFIDENCE INTERVALS SUMMARY ===\n');
    for i = 1:length(confidence_levels)
        fprintf('%d%% CI: [%.4f, %.4f] (width: %.4f)\n', ...
                round(confidence_levels(i) * 100), ...
                ci_results.final_intervals(i, 1), ...
                ci_results.final_intervals(i, 2), ...
                ci_results.coverage_widths(i));
    end
    fprintf('Final Prediction: %.4f ± %.4f\n', win_prob(end), win_prob_std(end));
    fprintf('====================================\n\n');
end
