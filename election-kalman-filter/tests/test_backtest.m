% TEST_BACKTEST_FRAMEWORK - Unit tests for Phase 4: Backtesting Framework
%
% Tests:
%   1. calculate_metrics with synthetic data
%   2. confidence_intervals computation
%   3. compare_sources with multiple predictions
%   4. Full backtest pipeline (if data available)

fprintf('\n=== TESTING PHASE 4: BACKTESTING FRAMEWORK ===\n\n');

% Add paths
script_dir = fileparts(mfilename('fullpath'));
project_root = fileparts(script_dir);
addpath(fullfile(project_root, 'backtest'));
addpath(fullfile(project_root, 'core'));

test_count = 0;
pass_count = 0;

%% Test 1: calculate_metrics basic functionality
fprintf('Test 1: calculate_metrics with synthetic data\n');
test_count = test_count + 1;

try
    % Create synthetic predictions
    predictions.win_prob = [0.48; 0.49; 0.51; 0.52];
    predictions.win_prob_std = [0.10; 0.09; 0.08; 0.07];
    predictions.weeks = [1; 2; 3; 4];
    predictions.dates = {'2024-01-01'; '2024-01-08'; '2024-01-15'; '2024-01-22'};
    
    % Actual outcome (Trump won)
    actual.winner = 'Trump';
    actual.dem_vote_share = 48.3;
    actual.rep_vote_share = 50.1;
    
    % Calculate metrics
    metrics = calculate_metrics(predictions, actual);
    
    % Validate structure
    assert(isstruct(metrics), 'Metrics should be a struct');
    assert(isfield(metrics, 'final_prediction'), 'Missing final_prediction field');
    assert(isfield(metrics, 'brier_score'), 'Missing brier_score field');
    assert(isfield(metrics, 'correct_winner_prediction'), 'Missing correct_winner_prediction');
    
    % Validate values
    assert(metrics.final_prediction >= 0 && metrics.final_prediction <= 1, ...
           'Final prediction out of [0,1] range');
    assert(metrics.brier_score >= 0 && metrics.brier_score <= 1, ...
           'Brier score out of [0,1] range');
    
    fprintf('  ✓ Metrics structure valid\n');
    fprintf('  ✓ Final prediction: %.4f\n', metrics.final_prediction);
    fprintf('  ✓ Brier score: %.4f\n', metrics.brier_score);
    fprintf('  ✓ Correct winner: %s\n', mat2str(metrics.correct_winner_prediction));
    
    pass_count = pass_count + 1;
    fprintf('  PASSED\n\n');
    
catch err
    fprintf('  FAILED: %s\n\n', err.message);
end

%% Test 2: confidence_intervals computation
fprintf('Test 2: confidence_intervals computation\n');
test_count = test_count + 1;

try
    % Create predictions with uncertainty
    predictions.win_prob = [0.50; 0.51; 0.52];
    predictions.win_prob_std = [0.10; 0.09; 0.08];
    predictions.weeks = [1; 2; 3];
    
    % Compute confidence intervals
    ci_results = confidence_intervals(predictions, [0.68, 0.95, 0.99]);
    
    % Validate structure
    assert(isstruct(ci_results), 'CI results should be a struct');
    assert(isfield(ci_results, 'intervals'), 'Missing intervals field');
    assert(isfield(ci_results, 'final_intervals'), 'Missing final_intervals field');
    assert(length(ci_results.confidence_levels) == 3, 'Should have 3 confidence levels');
    
    % Validate intervals
    for i = 1:3
        interval = ci_results.intervals{i};
        assert(all(interval(:,1) <= interval(:,2)), 'Lower bound > upper bound');
        assert(all(interval(:,1) >= 0 && interval(:,1) <= 1), 'Bounds out of range');
        assert(all(interval(:,2) >= 0 && interval(:,2) <= 1), 'Bounds out of range');
    end
    
    % Check that wider CI is indeed wider
    assert(ci_results.coverage_widths(3) > ci_results.coverage_widths(2), ...
           '99% CI should be wider than 95% CI');
    assert(ci_results.coverage_widths(2) > ci_results.coverage_widths(1), ...
           '95% CI should be wider than 68% CI');
    
    fprintf('  ✓ Confidence intervals computed correctly\n');
    fprintf('  ✓ 68%% CI width: %.4f\n', ci_results.coverage_widths(1));
    fprintf('  ✓ 95%% CI width: %.4f\n', ci_results.coverage_widths(2));
    fprintf('  ✓ 99%% CI width: %.4f\n', ci_results.coverage_widths(3));
    
    pass_count = pass_count + 1;
    fprintf('  PASSED\n\n');
    
catch err
    fprintf('  FAILED: %s\n\n', err.message);
end

%% Test 3: compare_sources with multiple predictions
fprintf('Test 3: compare_sources functionality\n');
test_count = test_count + 1;

try
    % Create two different prediction sources
    pred1.win_prob = [0.48; 0.49; 0.50];
    pred1.win_prob_std = [0.10; 0.09; 0.08];
    
    pred2.win_prob = [0.51; 0.52; 0.53];
    pred2.win_prob_std = [0.12; 0.11; 0.10];
    
    predictions_cell = {pred1, pred2};
    source_names = {'FiveThirtyEight', 'RealClearPolitics'};
    
    % Actual outcome
    actual.winner = 'Trump';
    actual.dem_vote_share = 48.3;
    
    % Compare sources
    comparison = compare_sources(predictions_cell, source_names, actual);
    
    % Validate structure
    assert(isstruct(comparison), 'Comparison should be a struct');
    assert(comparison.n_sources == 2, 'Should have 2 sources');
    assert(isfield(comparison, 'best_source'), 'Missing best_source field');
    assert(isfield(comparison, 'ensemble_prediction'), 'Missing ensemble');
    assert(isfield(comparison, 'rankings'), 'Missing rankings');
    
    % Validate ensemble
    assert(isstruct(comparison.ensemble_prediction), 'Ensemble should be struct');
    assert(length(comparison.ensemble_prediction.win_prob) == 3, 'Ensemble length mismatch');
    
    fprintf('  ✓ Source comparison successful\n');
    fprintf('  ✓ Best source: %s\n', comparison.best_source);
    fprintf('  ✓ Ensemble Brier score: %.4f\n', comparison.ensemble_metrics.brier_score);
    
    pass_count = pass_count + 1;
    fprintf('  PASSED\n\n');
    
catch err
    fprintf('  FAILED: %s\n\n', err.message);
end

%% Test 4: Error handling
fprintf('Test 4: Error handling\n');
test_count = test_count + 1;

try
    % Test with invalid inputs
    caught_error = false;
    try
        calculate_metrics([], struct('winner', 'Trump'));
    catch
        caught_error = true;
    end
    assert(caught_error, 'Should catch invalid predictions');
    
    caught_error = false;
    try
        confidence_intervals(struct('win_prob', [0.5]), [1.5]);
    catch
        caught_error = true;
    end
    assert(caught_error, 'Should catch invalid confidence level');
    
    fprintf('  ✓ Error handling works correctly\n');
    pass_count = pass_count + 1;
    fprintf('  PASSED\n\n');
    
catch err
    fprintf('  FAILED: %s\n\n', err.message);
end

%% Summary
fprintf('\n=== TEST SUMMARY ===\n');
fprintf('Tests passed: %d/%d\n', pass_count, test_count);
if pass_count == test_count
    fprintf('✓ All tests PASSED!\n');
    fprintf('\nPhase 4 implementation is ready.\n');
else
    fprintf('✗ Some tests FAILED\n');
    fprintf('\nPlease review failed tests before proceeding.\n');
end
fprintf('====================\n\n');
