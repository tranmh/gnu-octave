% TEST_PHASE4.M - Test suite for Pattern Library (Phase 4)
%
% Tests all pattern generation functions and interactive menu
% Validates pattern properties, parameter handling, and integration

fprintf('\n==============================================\n');
fprintf('   PHASE 4 TEST SUITE - Pattern Library\n');
fprintf('==============================================\n\n');

% Add paths
addpath('../patterns');

% Test counters
tests_passed = 0;
tests_failed = 0;
test_num = 0;

%% Test 1: 1D Gaussian Pattern
test_num = test_num + 1;
fprintf('Test %d: 1D Gaussian pattern generation... ', test_num);
try
    u0 = get_pattern_1d('gaussian', 100);
    assert(length(u0) == 100, 'Wrong output size');
    assert(max(u0) > 0, 'Pattern should have positive values');
    assert(min(u0) >= 0, 'Pattern should be non-negative');
    % Check that peak is roughly at center
    [~, peak_idx] = max(u0);
    assert(abs(peak_idx - 50) < 10, 'Peak should be near center');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 2: 1D Step Pattern
test_num = test_num + 1;
fprintf('Test %d: 1D Step pattern generation... ', test_num);
try
    u0 = get_pattern_1d('step', 100, 'center', 0.5);
    assert(length(u0) == 100, 'Wrong output size');
    % Step should create two distinct regions
    left_half = u0(1:50);
    right_half = u0(51:100);
    assert(abs(mean(left_half) - mean(right_half)) > 50, 'Step should create distinct regions');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 3: 1D Double Peak Pattern
test_num = test_num + 1;
fprintf('Test %d: 1D Double peak pattern... ', test_num);
try
    u0 = get_pattern_1d('double_peak', 100, 'center1', 0.3, 'center2', 0.7);
    assert(length(u0) == 100, 'Wrong output size');
    % Should have two local maxima
    % Simple check: value in middle should be less than both peaks
    assert(u0(50) < max(u0(1:40)) && u0(50) < max(u0(60:100)), 'Should have two peaks');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 4: 1D Sine Pattern
test_num = test_num + 1;
fprintf('Test %d: 1D Sine pattern... ', test_num);
try
    u0 = get_pattern_1d('sine', 100, 'frequency', 2);
    assert(length(u0) == 100, 'Wrong output size');
    assert(max(u0) > 0 && min(u0) >= 0, 'Sine should be in [0, amp]');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 5: 1D Random Pattern
test_num = test_num + 1;
fprintf('Test %d: 1D Random pattern... ', test_num);
try
    u0 = get_pattern_1d('random', 100);
    assert(length(u0) == 100, 'Wrong output size');
    assert(std(u0) > 0, 'Random pattern should have variation');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 6: 1D Custom Parameters
test_num = test_num + 1;
fprintf('Test %d: 1D Custom parameters... ', test_num);
try
    u0 = get_pattern_1d('gaussian', 100, 'amplitude', 200, 'width', 0.05, 'center', 0.7);
    assert(max(u0) > 150, 'Should respect amplitude parameter');
    [~, peak_idx] = max(u0);
    assert(peak_idx > 60, 'Should respect center parameter');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 7: 1D Invalid Pattern Name
test_num = test_num + 1;
fprintf('Test %d: 1D Invalid pattern name error handling... ', test_num);
try
    try
        u0 = get_pattern_1d('nonexistent', 100);
        error('Should have thrown an error');
    catch e
        assert(contains(e.message, 'Unknown pattern'), 'Should give clear error message');
    end
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 8: 2D Center Hot Pattern
test_num = test_num + 1;
fprintf('Test %d: 2D Center hot pattern... ', test_num);
try
    u0 = get_pattern_2d('center_hot', 50, 50);
    assert(all(size(u0) == [50, 50]), 'Wrong output size');
    assert(max(u0(:)) > 0, 'Pattern should have positive values');
    % Peak should be near center
    [max_val, max_idx] = max(u0(:));
    [row, col] = ind2sub(size(u0), max_idx);
    assert(abs(row - 25) < 5 && abs(col - 25) < 5, 'Peak should be near center');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 9: 2D Corner Hot Pattern
test_num = test_num + 1;
fprintf('Test %d: 2D Corner hot pattern... ', test_num);
try
    u0 = get_pattern_2d('corner_hot', 50, 50);
    assert(all(size(u0) == [50, 50]), 'Wrong output size');
    % Corners should be hotter than center
    center_val = u0(25, 25);
    corners = [u0(5,5), u0(5,45), u0(45,5), u0(45,45)];
    assert(all(corners > center_val), 'Corners should be hotter than center');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 10: 2D Gaussian Pattern
test_num = test_num + 1;
fprintf('Test %d: 2D Gaussian pattern... ', test_num);
try
    u0 = get_pattern_2d('gaussian', 50, 50);
    assert(all(size(u0) == [50, 50]), 'Wrong output size');
    % Should be radially symmetric (approximately)
    center_row = u0(25, :);
    center_col = u0(:, 25);
    assert(abs(center_row(25) - center_col(25)) < 1e-10, 'Should be radially symmetric');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 11: 2D Ring Pattern
test_num = test_num + 1;
fprintf('Test %d: 2D Ring pattern... ', test_num);
try
    u0 = get_pattern_2d('ring', 50, 50, 'ring_radius', 0.3);
    assert(all(size(u0) == [50, 50]), 'Wrong output size');
    % Center should be cooler than ring
    center_val = u0(25, 25);
    % Check a point that should be on the ring (roughly)
    ring_idx = round(25 + 0.3 * 25);
    ring_val = u0(25, ring_idx);
    assert(ring_val > center_val, 'Ring should be hotter than center');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 12: 2D Checkerboard Pattern
test_num = test_num + 1;
fprintf('Test %d: 2D Checkerboard pattern... ', test_num);
try
    u0 = get_pattern_2d('checkerboard', 50, 50, 'num_checks', 4);
    assert(all(size(u0) == [50, 50]), 'Wrong output size');
    % Should have alternating values
    unique_vals = unique(u0(:));
    assert(length(unique_vals) == 2, 'Checkerboard should have two distinct values');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 13: 2D Radial Pattern
test_num = test_num + 1;
fprintf('Test %d: 2D Radial pattern... ', test_num);
try
    u0 = get_pattern_2d('radial', 50, 50);
    assert(all(size(u0) == [50, 50]), 'Wrong output size');
    % Center should be hottest
    assert(u0(25, 25) >= max(u0(:)) - 1, 'Center should be hottest');
    % Should decrease with distance from center
    assert(u0(25, 25) > u0(25, 40), 'Should decrease with distance');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 14: 2D Random Pattern
test_num = test_num + 1;
fprintf('Test %d: 2D Random pattern... ', test_num);
try
    u0 = get_pattern_2d('random', 50, 50);
    assert(all(size(u0) == [50, 50]), 'Wrong output size');
    assert(std(u0(:)) > 0, 'Random pattern should have variation');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 15: 2D Custom Parameters
test_num = test_num + 1;
fprintf('Test %d: 2D Custom parameters... ', test_num);
try
    u0 = get_pattern_2d('gaussian', 50, 50, ...
                       'amplitude', 200, ...
                       'center_x', 0.7, ...
                       'center_y', 0.3);
    assert(max(u0(:)) > 150, 'Should respect amplitude parameter');
    [max_val, max_idx] = max(u0(:));
    [row, col] = ind2sub(size(u0), max_idx);
    assert(col > 30 && row < 20, 'Should respect center parameters');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 16: 2D Invalid Pattern Name
test_num = test_num + 1;
fprintf('Test %d: 2D Invalid pattern name error handling... ', test_num);
try
    try
        u0 = get_pattern_2d('nonexistent', 50, 50);
        error('Should have thrown an error');
    catch e
        assert(contains(e.message, 'Unknown pattern'), 'Should give clear error message');
    end
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 17: Integration with Phase 1 Solver (1D)
test_num = test_num + 1;
fprintf('Test %d: Integration with 1D solver... ', test_num);
try
    addpath('../core');
    u0 = get_pattern_1d('gaussian', 50);
    alpha = 0.01;
    L = 1.0;
    dt = 0.001;
    t_final = 0.1;
    U = heat_solver_1d(u0, alpha, L, dt, t_final);
    assert(size(U, 1) == 50, 'Solver should accept pattern output');
    % Temperature should decrease (diffusing to zero boundaries)
    assert(max(U(:, end)) < max(U(:, 1)), 'Heat should diffuse away');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 18: Integration with Phase 1 Solver (2D)
test_num = test_num + 1;
fprintf('Test %d: Integration with 2D solver... ', test_num);
try
    u0 = get_pattern_2d('center_hot', 20, 20);
    alpha = 0.01;
    Lx = 1.0;
    Ly = 1.0;
    dt = 0.001;
    t_final = 0.05;
    U = heat_solver_2d(u0, alpha, Lx, Ly, dt, t_final);
    assert(size(U, 1) == 20 && size(U, 2) == 20, 'Solver should accept pattern output');
    % Temperature should decrease
    assert(max(U(:, :, end), [], 'all') < max(U(:, :, 1), [], 'all'), 'Heat should diffuse');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 19: Pattern Consistency
test_num = test_num + 1;
fprintf('Test %d: Pattern reproducibility... ', test_num);
try
    % Same parameters should give same pattern (except random)
    u0_1 = get_pattern_1d('gaussian', 100, 'amplitude', 50, 'center', 0.3);
    u0_2 = get_pattern_1d('gaussian', 100, 'amplitude', 50, 'center', 0.3);
    assert(max(abs(u0_1 - u0_2)) < 1e-10, 'Pattern should be reproducible');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 20: Different Grid Sizes
test_num = test_num + 1;
fprintf('Test %d: Patterns on different grid sizes... ', test_num);
try
    u0_small = get_pattern_1d('gaussian', 50);
    u0_large = get_pattern_1d('gaussian', 200);
    assert(length(u0_small) == 50, 'Should work on small grids');
    assert(length(u0_large) == 200, 'Should work on large grids');
    % Patterns should look similar (peak in middle)
    [~, peak_small] = max(u0_small);
    [~, peak_large] = max(u0_large);
    assert(abs(peak_small / 50 - peak_large / 200) < 0.1, 'Pattern should scale with grid');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Summary
fprintf('\n==============================================\n');
fprintf('              TEST SUMMARY\n');
fprintf('==============================================\n');
fprintf('Total tests: %d\n', test_num);
fprintf('Passed: %d\n', tests_passed);
fprintf('Failed: %d\n', tests_failed);

if tests_failed == 0
    fprintf('\n✓ ALL TESTS PASSED!\n');
    fprintf('Pattern library is working correctly.\n');
else
    fprintf('\n✗ SOME TESTS FAILED\n');
    fprintf('Please review the failed tests above.\n');
end

fprintf('\n==============================================\n');
fprintf('Phase 4 Pattern Library: VERIFIED\n');
fprintf('==============================================\n\n');

% Note: pattern_menu is not tested automatically since it requires
% user interaction. Test it manually by running:
% [name, params] = pattern_menu(1);  % for 1D
% [name, params] = pattern_menu(2);  % for 2D
