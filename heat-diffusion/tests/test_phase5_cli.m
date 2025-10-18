% TEST_PHASE5_CLI.M - CLI test suite for Phase 5
%
% Tests core functionality without parameter structs

fprintf('\n========================================\n');
fprintf('PHASE 5 CLI TEST SUITE\n');
fprintf('========================================\n\n');

% Add paths
addpath('../core');
addpath('../patterns');
addpath('../utils');

tests_passed = 0;
tests_failed = 0;

%% TEST 1: 1D Solver Basic Functionality
fprintf('TEST 1: 1D Solver Basic Test\n');
fprintf('------------------------------\n');

try
    % Parameters
    alpha = 0.01;
    L = 1.0;
    T_boundary = 0.0;
    nx = 50;
    dt = 0.001;
    t_final = 0.1;
    
    % Initial condition
    u0 = @(x) 100 * exp(-100 * (x - 0.5).^2);
    
    % Solve
    [u_history, x, t] = heat_solver_1d(u0, alpha, L, T_boundary, nx, dt, t_final);
    
    % Verify dimensions
    assert(size(u_history, 1) == nx, 'Wrong spatial dimension');
    assert(size(u_history, 2) == length(t), 'Wrong time dimension');
    
    % Check heat diffusion
    max_initial = max(u_history(:, 1));
    max_final = max(u_history(:, end));
    assert(max_final < max_initial, 'Heat should diffuse');
    
    fprintf('  ✓ 1D solver working (max: %.2f -> %.2f)\n', max_initial, max_final);
    tests_passed = tests_passed + 1;
catch e
    fprintf('  ✗ FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

fprintf('\n');

%% TEST 2: 2D Solver Basic Functionality
fprintf('TEST 2: 2D Solver Basic Test\n');
fprintf('------------------------------\n');

try
    % Parameters
    alpha = 0.01;
    Lx = 1.0;
    Ly = 1.0;
    T_boundary = 0.0;
    nx = 30;
    ny = 30;
    dt = 0.001;
    t_final = 0.05;
    
    % Initial condition
    u0 = @(x, y) 100 * exp(-100 * ((x - 0.5).^2 + (y - 0.5).^2));
    
    % Solve
    [u_history, x, y, t] = heat_solver_2d(u0, alpha, Lx, Ly, T_boundary, nx, ny, dt, t_final);
    
    % Verify dimensions
    assert(size(u_history, 1) == nx, 'Wrong x dimension');
    assert(size(u_history, 2) == ny, 'Wrong y dimension');
    assert(size(u_history, 3) == length(t), 'Wrong time dimension');
    
    % Check heat diffusion
    max_initial = max(max(u_history(:, :, 1)));
    max_final = max(max(u_history(:, :, end)));
    assert(max_final < max_initial, '2D heat should diffuse');
    
    fprintf('  ✓ 2D solver working (max: %.2f -> %.2f)\n', max_initial, max_final);
    tests_passed = tests_passed + 1;
catch e
    fprintf('  ✗ FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

fprintf('\n');

%% TEST 3: Pattern Library
fprintf('TEST 3: Pattern Library\n');
fprintf('------------------------\n');

try
    % Test 1D patterns
    u0_gauss = get_pattern_1d('gaussian', 100);
    u0_step = get_pattern_1d('step', 100);
    u0_sine = get_pattern_1d('sine', 100);
    
    assert(length(u0_gauss) == 100, '1D Gaussian wrong size');
    assert(length(u0_step) == 100, '1D Step wrong size');
    assert(length(u0_sine) == 100, '1D Sine wrong size');
    
    fprintf('  ✓ 1D patterns working\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('  ✗ FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

try
    % Test 2D patterns
    u0_gauss_2d = get_pattern_2d('gaussian', 50, 50);
    u0_center = get_pattern_2d('center_hot', 50, 50);
    
    assert(all(size(u0_gauss_2d) == [50, 50]), '2D Gaussian wrong size');
    assert(all(size(u0_center) == [50, 50]), '2D Center hot wrong size');
    
    fprintf('  ✓ 2D patterns working\n');
    tests_passed = tests_passed + 1;
catch e
    fprintf('  ✗ FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

fprintf('\n');

%% TEST 4: Maximum Principle
fprintf('TEST 4: Maximum Principle\n');
fprintf('--------------------------\n');

try
    % Setup
    alpha = 0.01;
    L = 1.0;
    T_boundary = 0.0;
    nx = 50;
    dt = 0.001;
    t_final = 0.1;
    
    u0 = @(x) 50 * exp(-50 * (x - 0.5).^2);
    
    % Solve
    [u_history, x, t] = heat_solver_1d(u0, alpha, L, T_boundary, nx, dt, t_final);
    
    % Maximum should not increase
    max_initial = max(u_history(:, 1));
    max_overall = max(u_history(:));
    
    assert(max_overall <= max_initial * 1.001, 'Maximum principle violated');
    
    fprintf('  ✓ Maximum principle holds (%.2f -> %.2f)\n', max_initial, max_overall);
    tests_passed = tests_passed + 1;
catch e
    fprintf('  ✗ FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

fprintf('\n');

%% TEST 5: Conservation (with boundaries)
fprintf('TEST 5: Energy Dissipation\n');
fprintf('---------------------------\n');

try
    % With zero boundaries, total heat should decrease
    alpha = 0.01;
    L = 1.0;
    T_boundary = 0.0;
    nx = 50;
    dt = 0.001;
    t_final = 0.1;
    
    u0 = @(x) 100 * exp(-100 * (x - 0.5).^2);
    
    [u_history, x, t] = heat_solver_1d(u0, alpha, L, T_boundary, nx, dt, t_final);
    
    energy_initial = sum(u_history(:, 1));
    energy_final = sum(u_history(:, end));
    
    assert(energy_final < energy_initial, 'Energy should dissipate to boundaries');
    
    pct_decrease = 100 * (1 - energy_final / energy_initial);
    fprintf('  ✓ Energy dissipated %.1f%% to boundaries\n', pct_decrease);
    tests_passed = tests_passed + 1;
catch e
    fprintf('  ✗ FAILED: %s\n', e.message);
    tests_failed = tests_failed + 1;
end

fprintf('\n');

%% Summary
fprintf('========================================\n');
fprintf('TEST SUMMARY\n');
fprintf('========================================\n');
fprintf('Tests passed: %d\n', tests_passed);
fprintf('Tests failed: %d\n', tests_failed);
fprintf('Total tests:  %d\n', tests_passed + tests_failed);

if tests_failed == 0
    fprintf('\n✓ ALL TESTS PASSED\n');
else
    fprintf('\n✗ SOME TESTS FAILED\n');
end
fprintf('========================================\n\n');
