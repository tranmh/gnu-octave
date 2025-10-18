% TEST_PHASE4_CLI_SIMPLE.M - Minimal CLI test for Pattern Library

fprintf('Starting Phase 4 simple test...\n');

% Add paths
addpath('../patterns');

fprintf('Test 1: Calling get_pattern_1d with gaussian...\n');
u0 = get_pattern_1d('gaussian', 100);
fprintf('Got result, size = %d\n', length(u0));
fprintf('Max value = %.2f\n', max(u0));
fprintf('✓ Test 1 PASSED\n\n');

fprintf('Test 2: Calling get_pattern_2d with gaussian...\n');
u0_2d = get_pattern_2d('gaussian', 50, 50);
fprintf('Got result, size = %dx%d\n', size(u0_2d, 1), size(u0_2d, 2));
fprintf('Max value = %.2f\n', max(u0_2d(:)));
fprintf('✓ Test 2 PASSED\n\n');

fprintf('All simple tests complete!\n');
