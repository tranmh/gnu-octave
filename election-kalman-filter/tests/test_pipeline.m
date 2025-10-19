% TEST_PIPELINE - Test Phase 3: Weekly Update System
%
% This script tests the weekly processing pipeline components

fprintf('\n====================================\n');
fprintf('Testing Phase 3: Weekly Update System\n');
fprintf('====================================\n\n');

% Add paths
script_dir = fileparts(mfilename('fullpath'));
project_dir = fileparts(script_dir);
addpath(fullfile(project_dir, 'pipeline'));
addpath(fullfile(project_dir, 'core'));

%% Test 1: polls_to_probability
fprintf('Test 1: polls_to_probability\n');
fprintf('----------------------------\n');

% Test case: Biden leading by 2 points
[p1, u1] = polls_to_probability(48.5, 46.5, 2.0, 1.8);
fprintf('Biden 48.5%%, Trump 46.5%% → Win prob: %.3f, Uncertainty: %.4f\n', p1, u1);
assert(p1 > 0.5 && p1 < 1.0, 'Win probability should favor Biden');
assert(u1 > 0, 'Uncertainty should be positive');

% Test case: Trump leading by 3 points  
[p2, u2] = polls_to_probability(46.0, 49.0, 2.5, 2.0);
fprintf('Biden 46.0%%, Trump 49.0%% → Win prob: %.3f, Uncertainty: %.4f\n', p2, u2);
assert(p2 < 0.5, 'Win probability should favor Trump');

% Test case: Tie
[p3, u3] = polls_to_probability(47.5, 47.5, 2.0, 2.0);
fprintf('Tie 47.5%% vs 47.5%% → Win prob: %.3f, Uncertainty: %.4f\n', p3, u3);
assert(abs(p3 - 0.5) < 0.01, 'Tie should give ~50%% probability');

fprintf('✓ polls_to_probability tests passed\n\n');

%% Test 2: multi_poll_aggregator
fprintf('Test 2: multi_poll_aggregator\n');
fprintf('------------------------------\n');

% Create test weekly data entry
test_week.dem_avg = 47.5;
test_week.rep_avg = 48.2;
test_week.dem_std = 2.1;
test_week.rep_std = 1.9;
test_week.num_polls = 5;

agg = multi_poll_aggregator(test_week);

fprintf('Input: 5 polls, Dem %.1f%% ± %.1f%%, Rep %.1f%% ± %.1f%%\n', ...
        test_week.dem_avg, test_week.dem_std, test_week.rep_avg, test_week.rep_std);
fprintf('Output: Dem %.2f%% ± %.2f%%, Rep %.2f%% ± %.2f%%\n', ...
        agg.dem_pct, agg.dem_std, agg.rep_pct, agg.rep_std);
fprintf('Confidence factor: %.3f\n', agg.confidence);

assert(agg.dem_pct == test_week.dem_avg, 'Mean should be preserved');
assert(agg.confidence > 0.5, 'Confidence should be high with 5 polls');
assert(agg.num_polls == 5, 'Number of polls should match');

% Test with no polls
test_week_empty.dem_avg = NaN;
test_week_empty.rep_avg = NaN;
test_week_empty.dem_std = NaN;
test_week_empty.rep_std = NaN;
test_week_empty.num_polls = 0;

agg_empty = multi_poll_aggregator(test_week_empty);
fprintf('No polls → Confidence: %.3f\n', agg_empty.confidence);
assert(agg_empty.confidence == 0, 'Confidence should be zero with no polls');
assert(isnan(agg_empty.dem_pct), 'Should return NaN with no polls');

fprintf('✓ multi_poll_aggregator tests passed\n\n');

%% Test 3: transition_handler
fprintf('Test 3: transition_handler\n');
fprintf('--------------------------\n');

Q_base = 0.001;
P_current = 0.05;

% Test week before transition (week 37)
[Q37, P37, is_trans37] = transition_handler(37, Q_base, P_current);
fprintf('Week 37 (before): Q=%.5f, P=%.4f, is_transition=%d\n', Q37, P37, is_trans37);
assert(Q37 == Q_base, 'Q should be unchanged before transition');
assert(is_trans37 == false, 'Should not be in transition');

% Test transition week (week 38)
[Q38, P38, is_trans38] = transition_handler(38, Q_base, P_current);
fprintf('Week 38 (transition): Q=%.5f, P=%.4f, is_transition=%d\n', Q38, P38, is_trans38);
assert(Q38 > Q_base, 'Q should increase during transition');
assert(P38 > P_current, 'P should reset to higher value');
assert(is_trans38 == true, 'Should be in transition');

% Test week after transition period (week 41)
[Q41, P41, is_trans41] = transition_handler(41, Q_base, P_current);
fprintf('Week 41 (after): Q=%.5f, P=%.4f, is_transition=%d\n', Q41, P41, is_trans41);
assert(Q41 == Q_base, 'Q should return to base after transition');
assert(is_trans41 == false, 'Should not be in transition');

fprintf('✓ transition_handler tests passed\n\n');

%% Test 4: Integration test with Phase 2 (Kalman core)
fprintf('Test 4: Integration with Kalman core\n');
fprintf('-------------------------------------\n');

% Initialize Kalman filter
x0 = 0.5;
P0 = 0.1;
Q = 0.001;
R = 0.05;

% Simulate a few weeks of data
x = x0;
P = P0;

for week = 1:5
    % Prediction
    [x_pred, P_pred] = kalman_predict(x, P, Q);
    
    % Simulate observation (random walk)
    z = x_pred + randn() * 0.02;
    z = max(0.01, min(0.99, z));  % Keep in valid range
    
    % Update
    [x, P, K, innov] = kalman_update(x_pred, P_pred, z, R);
    
    fprintf('Week %d: z=%.3f, x_pred=%.3f, x_est=%.3f, K=%.3f\n', ...
            week, z, x_pred, x, K);
    
    assert(x >= 0 && x <= 1, 'State must be in [0,1]');
    assert(P > 0, 'Uncertainty must be positive');
    assert(K >= 0 && K <= 1, 'Kalman gain must be in [0,1]');
end

fprintf('✓ Integration tests passed\n\n');

%% Summary
fprintf('====================================\n');
fprintf('All Phase 3 pipeline tests PASSED ✓\n');
fprintf('====================================\n\n');

fprintf('Pipeline components verified:\n');
fprintf('  1. polls_to_probability     - Converts polls to win probability\n');
fprintf('  2. multi_poll_aggregator    - Aggregates multiple polls\n');
fprintf('  3. transition_handler       - Handles Biden→Harris transition\n');
fprintf('  4. Integration with Phase 2 - Works with Kalman filter core\n\n');

fprintf('Next step: Run full pipeline with weekly_processor.m\n');
fprintf('Note: Requires weekly_polls.csv from Phase 1\n\n');
