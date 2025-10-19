% TEST_KALMAN_CORE Unit tests for Kalman filter core functions
%
% Tests all core Kalman filter functions:
%   - kalman_init
%   - kalman_predict
%   - kalman_update
%   - kalman_filter
%   - adaptive_noise
%
% Run this script to verify Phase 2 implementation

% Author: Election Kalman Filter Project
% Date: October 2025

%% Add paths to core functions
addpath('../core');

fprintf('\n========================================\n');
fprintf('   KALMAN FILTER CORE - UNIT TESTS\n');
fprintf('========================================\n\n');

% Test counters
total_tests = 0;
passed_tests = 0;
failed_tests = 0;

%% Test 1: kalman_init - Default initialization
fprintf('Test 1: kalman_init with default parameters...\n');
total_tests = total_tests + 1;
try
    params = kalman_init();
    assert(params.x_est == 0.5, 'Initial state should be 0.5');
    assert(params.P_est == 0.1, 'Initial covariance should be 0.1');
    assert(params.Q == 0.001, 'Process noise should be 0.001');
    assert(params.R == 0.05, 'Measurement noise should be 0.05');
    assert(params.k_scale == 15, 'Polling scale should be 15');
    assert(isfield(params, 'history'), 'Should have history field');
    fprintf('  ✓ PASSED\n\n');
    passed_tests = passed_tests + 1;
catch err
    fprintf('  ✗ FAILED: %s\n\n', err.message);
    failed_tests = failed_tests + 1;
end

%% Test 2: kalman_init - Custom parameters
fprintf('Test 2: kalman_init with custom parameters...\n');
total_tests = total_tests + 1;
try
    params = kalman_init('x0', 0.6, 'P0', 0.15, 'Q', 0.002, 'R', 0.08);
    assert(params.x_est == 0.6, 'Custom initial state failed');
    assert(params.P_est == 0.15, 'Custom initial covariance failed');
    assert(params.Q == 0.002, 'Custom process noise failed');
    assert(params.R == 0.08, 'Custom measurement noise failed');
    fprintf('  ✓ PASSED\n\n');
    passed_tests = passed_tests + 1;
catch err
    fprintf('  ✗ FAILED: %s\n\n', err.message);
    failed_tests = failed_tests + 1;
end

%% Test 3: kalman_predict - Basic prediction
fprintf('Test 3: kalman_predict basic functionality...\n');
total_tests = total_tests + 1;
try
    x_est = 0.52;
    P_est = 0.08;
    Q = 0.001;
    [x_pred, P_pred] = kalman_predict(x_est, P_est, Q);
    
    % Random walk model: x_pred = x_est
    assert(abs(x_pred - x_est) < 1e-10, 'Predicted state should equal current state');
    % Covariance increases: P_pred = P_est + Q
    assert(abs(P_pred - (P_est + Q)) < 1e-10, 'Predicted covariance incorrect');
    assert(P_pred > P_est, 'Uncertainty should increase during prediction');
    fprintf('  ✓ PASSED\n\n');
    passed_tests = passed_tests + 1;
catch err
    fprintf('  ✗ FAILED: %s\n\n', err.message);
    failed_tests = failed_tests + 1;
end

%% Test 4: kalman_update - Basic update
fprintf('Test 4: kalman_update basic functionality...\n');
total_tests = total_tests + 1;
try
    x_pred = 0.50;
    P_pred = 0.10;
    z = 0.55;
    R = 0.05;
    [x_est, P_est, K, innovation] = kalman_update(x_pred, P_pred, z, R);
    
    % Kalman gain should be in [0, 1]
    assert(K >= 0 && K <= 1, 'Kalman gain outside valid range');
    % Innovation should match measurement residual
    assert(abs(innovation - (z - x_pred)) < 1e-10, 'Innovation calculation incorrect');
    % Uncertainty should decrease
    assert(P_est < P_pred, 'Uncertainty should decrease during update');
    % State should move toward measurement
    assert((x_est - x_pred) * (z - x_pred) > 0, 'State should move toward measurement');
    fprintf('  ✓ PASSED\n\n');
    passed_tests = passed_tests + 1;
catch err
    fprintf('  ✗ FAILED: %s\n\n', err.message);
    failed_tests = failed_tests + 1;
end

%% Test 5: kalman_update - Kalman gain properties
fprintf('Test 5: Kalman gain properties...\n');
total_tests = total_tests + 1;
try
    P_pred = 0.10;
    z = 0.55;
    x_pred = 0.50;
    
    % High measurement noise → low gain
    [~, ~, K_high_R, ~] = kalman_update(x_pred, P_pred, z, 1.0);
    % Low measurement noise → high gain
    [~, ~, K_low_R, ~] = kalman_update(x_pred, P_pred, z, 0.01);
    
    assert(K_low_R > K_high_R, 'Lower R should give higher Kalman gain');
    fprintf('  ✓ PASSED\n\n');
    passed_tests = passed_tests + 1;
catch err
    fprintf('  ✗ FAILED: %s\n\n', err.message);
    failed_tests = failed_tests + 1;
end

%% Test 6: kalman_filter - Synthetic data (constant measurement)
fprintf('Test 6: kalman_filter with constant measurements...\n');
total_tests = total_tests + 1;
try
    params = kalman_init('x0', 0.5, 'P0', 0.1, 'Q', 0.001, 'R', 0.05);
    measurements = 0.6 * ones(20, 1);  % Constant 60% probability
    week_numbers = (1:20)';
    
    results = kalman_filter(measurements, week_numbers, params, 'verbose', false);
    
    % State should converge toward measurement
    assert(abs(results.x_est(end) - 0.6) < 0.05, 'Should converge to measurement value');
    % Uncertainty should decrease over time
    assert(results.P_est(end) < results.P_est(1), 'Uncertainty should decrease');
    % Final estimate should be stable
    final_range = results.x_est(end-2:end);
    assert(std(final_range) < 0.01, 'Final estimates should be stable');
    
    fprintf('  ✓ PASSED\n\n');
    passed_tests = passed_tests + 1;
catch err
    fprintf('  ✗ FAILED: %s\n\n', err.message);
    failed_tests = failed_tests + 1;
end

%% Test 7: kalman_filter - Missing data handling
fprintf('Test 7: kalman_filter with missing data...\n');
total_tests = total_tests + 1;
try
    params = kalman_init();
    measurements = [0.50, 0.52, NaN, NaN, 0.54, 0.55]';
    week_numbers = (1:6)';
    
    results = kalman_filter(measurements, week_numbers, params, 'verbose', false);
    
    % Should handle NaN values
    assert(all(~isnan(results.x_est)), 'State estimates should not be NaN');
    % Kalman gain should be NaN for missing data
    assert(isnan(results.K(3)) && isnan(results.K(4)), 'K should be NaN for missing data');
    % Uncertainty should increase during missing data
    assert(results.P_est(4) > results.P_est(2), 'Uncertainty should increase with no measurements');
    
    fprintf('  ✓ PASSED\n\n');
    passed_tests = passed_tests + 1;
catch err
    fprintf('  ✗ FAILED: %s\n\n', err.message);
    failed_tests = failed_tests + 1;
end

%% Test 8: kalman_filter - Transition period handling
fprintf('Test 8: kalman_filter transition period handling...\n');
total_tests = total_tests + 1;
try
    params = kalman_init('Q', 0.001);
    % Create data with transition at week 38
    measurements = [0.48 * ones(37, 1); 0.52 * ones(15, 1)];
    week_numbers = (1:52)';
    
    results = kalman_filter(measurements, week_numbers, params, ...
        'verbose', false, 'transition_week', 38);
    
    % Should handle transition
    assert(results.transition_handled, 'Transition should be handled');
    % Uncertainty should increase at transition
    P_before = results.P_est(37);
    P_after = results.P_est(39);
    % Note: Due to transition handling, P might reset
    assert(results.P_pred(38) > P_before, 'Uncertainty should spike at transition');
    
    fprintf('  ✓ PASSED\n\n');
    passed_tests = passed_tests + 1;
catch err
    fprintf('  ✗ FAILED: %s\n\n', err.message);
    failed_tests = failed_tests + 1;
end

%% Test 9: adaptive_noise - Innovation-based estimation
fprintf('Test 9: adaptive_noise estimation...\n');
total_tests = total_tests + 1;
try
    % Run filter with known parameters
    params = kalman_init('Q', 0.002, 'R', 0.06);
    measurements = 0.5 + 0.1 * randn(30, 1);  % Noisy measurements around 0.5
    measurements = max(0, min(1, measurements));  % Clip to [0, 1]
    week_numbers = (1:30)';
    
    results = kalman_filter(measurements, week_numbers, params, 'verbose', false);
    [Q_est, R_est, diagnostics] = adaptive_noise(results, 'verbose', false);
    
    % Estimates should be positive
    assert(Q_est > 0, 'Estimated Q should be positive');
    assert(R_est > 0, 'Estimated R should be positive');
    % Should have diagnostics
    assert(isfield(diagnostics, 'innovation_variance'), 'Should have diagnostics');
    
    fprintf('  ✓ PASSED\n\n');
    passed_tests = passed_tests + 1;
catch err
    fprintf('  ✗ FAILED: %s\n\n', err.message);
    failed_tests = failed_tests + 1;
end

%% Test 10: Boundary conditions - State limits
fprintf('Test 10: Boundary conditions for state...\n');
total_tests = total_tests + 1;
try
    params = kalman_init('x0', 0.95);
    % Measurement above 1.0 (should be clipped)
    [x_pred, P_pred] = kalman_predict(0.95, 0.1, 0.01);
    [x_est, P_est, K, innov] = kalman_update(x_pred, P_pred, 1.0, 0.05);
    
    assert(x_est >= 0 && x_est <= 1, 'State should stay in [0, 1]');
    
    % Test lower bound
    params2 = kalman_init('x0', 0.05);
    [x_pred2, P_pred2] = kalman_predict(0.05, 0.1, 0.01);
    [x_est2, P_est2, K2, innov2] = kalman_update(x_pred2, P_pred2, 0.0, 0.05);
    
    assert(x_est2 >= 0 && x_est2 <= 1, 'State should stay in [0, 1]');
    
    fprintf('  ✓ PASSED\n\n');
    passed_tests = passed_tests + 1;
catch err
    fprintf('  ✗ FAILED: %s\n\n', err.message);
    failed_tests = failed_tests + 1;
end

%% Test 11: Covariance properties
fprintf('Test 11: Covariance properties...\n');
total_tests = total_tests + 1;
try
    % Covariance should always be positive
    params = kalman_init('P0', 0.1, 'Q', 0.001, 'R', 0.05);
    measurements = 0.5 + 0.05 * randn(20, 1);
    measurements = max(0, min(1, measurements));
    week_numbers = (1:20)';
    
    results = kalman_filter(measurements, week_numbers, params, 'verbose', false);
    
    assert(all(results.P_est > 0), 'All covariances should be positive');
    assert(all(results.P_pred > 0), 'All predicted covariances should be positive');
    
    fprintf('  ✓ PASSED\n\n');
    passed_tests = passed_tests + 1;
catch err
    fprintf('  ✗ FAILED: %s\n\n', err.message);
    failed_tests = failed_tests + 1;
end

%% Test 12: Integration test - Complete workflow
fprintf('Test 12: Complete filter workflow integration...\n');
total_tests = total_tests + 1;
try
    % Initialize filter
    params = kalman_init('x0', 0.5, 'P0', 0.1, 'Q', 0.001, 'R', 0.05);
    
    % Create realistic synthetic data
    true_prob = 0.48 + 0.04 * (1:52)' / 52;  % Gradual trend
    measurements = true_prob + 0.03 * randn(52, 1);  % Add noise
    measurements(10:12) = NaN;  % Some missing data
    measurements = max(0, min(1, measurements));  % Clip
    week_numbers = (1:52)';
    
    % Run filter
    results = kalman_filter(measurements, week_numbers, params, ...
        'verbose', false, 'transition_week', 38);
    
    % Estimate noise parameters
    [Q_est, R_est] = adaptive_noise(results, 'verbose', false);
    
    % Comprehensive checks
    assert(length(results.x_est) == 52, 'Should have 52 estimates');
    assert(results.final_estimate >= 0 && results.final_estimate <= 1, 'Final estimate valid');
    assert(results.final_std > 0, 'Final std should be positive');
    assert(Q_est > 0 && R_est > 0, 'Noise estimates should be positive');
    
    fprintf('  ✓ PASSED\n\n');
    passed_tests = passed_tests + 1;
catch err
    fprintf('  ✗ FAILED: %s\n\n', err.message);
    failed_tests = failed_tests + 1;
end

%% Summary
fprintf('========================================\n');
fprintf('   TEST SUMMARY\n');
fprintf('========================================\n');
fprintf('Total tests:  %d\n', total_tests);
fprintf('Passed:       %d (✓)\n', passed_tests);
fprintf('Failed:       %d (✗)\n', failed_tests);
fprintf('Success rate: %.1f%%\n', 100 * passed_tests / total_tests);
fprintf('========================================\n\n');

if failed_tests == 0
    fprintf('🎉 ALL TESTS PASSED! Phase 2 implementation verified.\n\n');
else
    fprintf('⚠️  Some tests failed. Please review the implementation.\n\n');
end
