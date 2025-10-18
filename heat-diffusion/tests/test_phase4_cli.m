% TEST_PHASE4_CLI.M - CLI test suite for Pattern Library (Phase 4)
%
% Tests all pattern generation functions without interactive menu
% Validates pattern properties and parameter handling

fprintf('\n==============================================\n');
fprintf('   PHASE 4 TEST SUITE - Pattern Library (CLI)\n');
fprintf('==============================================\n\n');

% Add paths
addpath('../patterns');

% Test counters
tests_passed = 0;
tests_failed = 0;
test_num = 0;

%% Test 1: 1D Gaussian Pattern
test_num = test_num + 1;
fprintf('Test %d: 1D Gaussian pattern... ', test_num);
try
    u0 = get_pattern_1d('gaussian', 100);
    assert(length(u0) == 100, 'Wrong output size');
    assert(max(u0) > 0, 'Pattern should have positive values');
    assert(min(u0) >= 0, 'Pattern should be non-negative');
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
fprintf('Test %d: 1D Step pattern... ', test_num);
try
    u0 = get_pattern_1d('step', 100, 'center', 0.5);
    assert(length(u0) == 100, 'Wrong output size');
    left_half = u0(1:50);
    right_half = u0(51:100);
    assert(abs(mean(left_half) - mean(right_half)) > 50, 'Step should create distinct regions');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 3: 1D Double Peak
test_num = test_num + 1;
fprintf('Test %d: 1D Double peak... ', test_num);
try
    u0 = get_pattern_1d('double_peak', 100, 'center1', 0.3, 'center2', 0.7);
    assert(length(u0) == 100, 'Wrong output size');
    assert(u0(50) < max(u0(1:40)) && u0(50) < max(u0(60:100)), 'Should have two peaks');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 4: 1D Sine
test_num = test_num + 1;
fprintf('Test %d: 1D Sine... ', test_num);
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

%% Test 5: 1D Random
test_num = test_num + 1;
fprintf('Test %d: 1D Random... ', test_num);
try
    u0 = get_pattern_1d('random', 100, 'amplitude', 50);
    assert(length(u0) == 100, 'Wrong output size');
    assert(max(u0) <= 50, 'Should respect amplitude');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 6: 2D Gaussian
test_num = test_num + 1;
fprintf('Test %d: 2D Gaussian... ', test_num);
try
    u0 = get_pattern_2d('gaussian', 50, 50);
    assert(size(u0, 1) == 50 && size(u0, 2) == 50, 'Wrong output size');
    assert(max(u0(:)) > 0, 'Pattern should have positive values');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 7: 2D Corner Hot
test_num = test_num + 1;
fprintf('Test %d: 2D Corner Hot... ', test_num);
try
    u0 = get_pattern_2d('corner_hot', 50, 50);
    assert(size(u0, 1) == 50 && size(u0, 2) == 50, 'Wrong output size');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 8: 2D Center Hot
test_num = test_num + 1;
fprintf('Test %d: 2D Center Hot... ', test_num);
try
    u0 = get_pattern_2d('center_hot', 50, 50);
    assert(size(u0, 1) == 50 && size(u0, 2) == 50, 'Wrong output size');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 9: 2D Ring
test_num = test_num + 1;
fprintf('Test %d: 2D Ring... ', test_num);
try
    u0 = get_pattern_2d('ring', 50, 50, 'ring_radius', 0.3);
    assert(size(u0, 1) == 50 && size(u0, 2) == 50, 'Wrong output size');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Test 10: 2D Checkerboard
test_num = test_num + 1;
fprintf('Test %d: 2D Checkerboard... ', test_num);
try
    u0 = get_pattern_2d('checkerboard', 50, 50, 'num_checks', 4);
    assert(size(u0, 1) == 50 && size(u0, 2) == 50, 'Wrong output size');
    fprintf('PASSED\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

%% Summary
fprintf('\n==============================================\n');
fprintf('   TEST SUMMARY\n');
fprintf('==============================================\n');
fprintf('Tests passed: %d / %d\n', tests_passed, test_num);
fprintf('Tests failed: %d / %d\n', tests_failed, test_num);

if tests_failed == 0
    fprintf('\n✓ ALL TESTS PASSED\n\n');
else
    fprintf('\n✗ SOME TESTS FAILED\n\n');
end
