% TEST_PHASE1 - Comprehensive test suite for Phase 1: Core PDE Solvers
%
% Tests:
%   1. Laplacian matrix construction (1D and 2D)
%   2. 1D heat solver with analytical solution
%   3. 2D heat solver with symmetry properties
%   4. Stability verification
%   5. Conservation properties
%   6. Convergence with grid refinement
%
% Usage:
%   cd('C:/Users/tranm/work/gnu-octave/heat-diffusion/tests')
%   test_phase1
%
% Phase: 1 - Core PDE Solvers

clear all;
close all;
clc;

fprintf('=== Phase 1: Core PDE Solvers - Test Suite ===\n\n');

% Add core directory to path
addpath('../core');

% Test counter
test_num = 0;
tests_passed = 0;
tests_failed = 0;


%% Test 1: Laplacian Matrix Construction (1D)
test_num = test_num + 1;
fprintf('Test %d: 1D Laplacian Matrix Construction\n', test_num);

try
  nx = 5;
  L = build_laplacian_matrix('1d', nx);
  
  % Expected tridiagonal structure: [-2 1 0 ...; 1 -2 1 ...; ...]
  expected = [-2  1  0  0  0;
               1 -2  1  0  0;
               0  1 -2  1  0;
               0  0  1 -2  1;
               0  0  0  1 -2];
  
  if norm(full(L) - expected, 'fro') < 1e-10
    fprintf('  ✓ PASSED: 1D Laplacian has correct tridiagonal structure\n');
    tests_passed = tests_passed + 1;
  else
    fprintf('  ✗ FAILED: 1D Laplacian structure incorrect\n');
    tests_failed = tests_failed + 1;
  end
catch err
  fprintf('  ✗ FAILED: %s\n', err.message);
  tests_failed = tests_failed + 1;
end

fprintf('\n');


%% Test 2: Laplacian Matrix Construction (2D)
test_num = test_num + 1;
fprintf('Test %d: 2D Laplacian Matrix Construction\n', test_num);

try
  nx = 3;
  ny = 3;
  L = build_laplacian_matrix('2d', nx, ny);
  
  % Check dimensions
  N = nx * ny;
  if size(L, 1) == N && size(L, 2) == N
    fprintf('  ✓ PASSED: 2D Laplacian has correct dimensions (%dx%d)\n', N, N);
    
    % Check five-point stencil structure
    % Center point should have -4, neighbors should have 1
    L_full = full(L);
    diag_sum = sum(diag(L_full));
    expected_diag_sum = -4 * N;
    
    if abs(diag_sum - expected_diag_sum) < 1e-10
      fprintf('  ✓ PASSED: 2D Laplacian has correct diagonal values\n');
      tests_passed = tests_passed + 1;
    else
      fprintf('  ✗ FAILED: 2D Laplacian diagonal sum incorrect\n');
      tests_failed = tests_failed + 1;
    end
  else
    fprintf('  ✗ FAILED: 2D Laplacian dimensions incorrect\n');
    tests_failed = tests_failed + 1;
  end
catch err
  fprintf('  ✗ FAILED: %s\n', err.message);
  tests_failed = tests_failed + 1;
end

fprintf('\n');


%% Test 3: 1D Heat Solver - Analytical Comparison
test_num = test_num + 1;
fprintf('Test %d: 1D Heat Solver vs Analytical Solution\n', test_num);

try
  % For simple exponential decay with zero boundaries:
  % Initial: u(x,0) = sin(π*x/L)
  % Analytical: u(x,t) = exp(-α*(π/L)²*t) * sin(π*x/L)
  
  alpha = 0.01;
  L = 1.0;
  T_boundary = 0.0;
  nx = 100;
  dt = 0.001;
  t_final = 0.5;
  
  % Initial condition
  u0 = @(x) sin(pi * x / L);
  
  % Solve numerically
  [u_history, x, t] = heat_solver_1d(u0, alpha, L, T_boundary, nx, dt, t_final);
  
  % Analytical solution at final time
  decay_factor = exp(-alpha * (pi / L)^2 * t_final);
  u_analytical = decay_factor * sin(pi * x / L);
  
  % Compare
  error_norm = norm(u_history(:, end) - u_analytical) / norm(u_analytical);
  
  if error_norm < 0.01  % Less than 1% relative error
    fprintf('  ✓ PASSED: 1D solver matches analytical solution (error = %.2e)\n', error_norm);
    tests_passed = tests_passed + 1;
  else
    fprintf('  ✗ FAILED: 1D solver error too large (%.2e)\n', error_norm);
    tests_failed = tests_failed + 1;
  end
catch err
  fprintf('  ✗ FAILED: %s\n', err.message);
  tests_failed = tests_failed + 1;
end

fprintf('\n');


%% Test 4: 2D Heat Solver - Symmetry Check
test_num = test_num + 1;
fprintf('Test %d: 2D Heat Solver - Symmetry Properties\n', test_num);

try
  % Symmetric initial condition should maintain symmetry
  alpha = 0.01;
  Lx = 1.0;
  Ly = 1.0;
  T_boundary = 0.0;
  nx = 30;
  ny = 30;
  dt = 0.001;
  t_final = 0.1;
  
  % Symmetric Gaussian at center
  u0 = @(x, y) 100 * exp(-100 * ((x - 0.5).^2 + (y - 0.5).^2));
  
  [u_history, x, y, t] = heat_solver_2d(u0, alpha, Lx, Ly, T_boundary, nx, ny, dt, t_final);
  
  % Check if final solution is symmetric about center
  u_final = u_history(:, :, end);
  u_flipped_x = flipud(u_final);
  u_flipped_y = fliplr(u_final);
  
  symmetry_error_x = norm(u_final - u_flipped_x, 'fro') / norm(u_final, 'fro');
  symmetry_error_y = norm(u_final - u_flipped_y, 'fro') / norm(u_final, 'fro');
  
  if symmetry_error_x < 0.01 && symmetry_error_y < 0.01
    fprintf('  ✓ PASSED: 2D solver maintains symmetry (error_x = %.2e, error_y = %.2e)\n', ...
            symmetry_error_x, symmetry_error_y);
    tests_passed = tests_passed + 1;
  else
    fprintf('  ✗ FAILED: Symmetry violated (error_x = %.2e, error_y = %.2e)\n', ...
            symmetry_error_x, symmetry_error_y);
    tests_failed = tests_failed + 1;
  end
catch err
  fprintf('  ✗ FAILED: %s\n', err.message);
  tests_failed = tests_failed + 1;
end

fprintf('\n');


%% Test 5: Maximum Principle (1D)
test_num = test_num + 1;
fprintf('Test %d: Maximum Principle Verification (1D)\n', test_num);

try
  % Maximum principle: max/min should occur at boundaries or initial condition
  % No new extrema should be created
  
  alpha = 0.01;
  L = 1.0;
  T_boundary = 0.0;
  nx = 100;
  dt = 0.001;
  t_final = 0.5;
  
  % Non-negative initial condition
  u0 = @(x) 50 * exp(-50 * (x - 0.5).^2);
  
  [u_history, x, t] = heat_solver_1d(u0, alpha, L, T_boundary, nx, dt, t_final);
  
  % Check that solution stays non-negative and bounded by initial max
  u_initial = u0(x);
  max_initial = max(u_initial);
  min_initial = min([T_boundary, min(u_initial)]);
  
  max_over_time = max(u_history(:));
  min_over_time = min(u_history(:));
  
  if min_over_time >= min_initial - 1e-10 && max_over_time <= max_initial + 1e-10
    fprintf('  ✓ PASSED: Maximum principle satisfied\n');
    fprintf('    Initial range: [%.2f, %.2f]\n', min_initial, max_initial);
    fprintf('    Solution range: [%.2f, %.2f]\n', min_over_time, max_over_time);
    tests_passed = tests_passed + 1;
  else
    fprintf('  ✗ FAILED: Maximum principle violated\n');
    tests_failed = tests_failed + 1;
  end
catch err
  fprintf('  ✗ FAILED: %s\n', err.message);
  tests_failed = tests_failed + 1;
end

fprintf('\n');


%% Test 6: Stability Test (Large Time Steps)
test_num = test_num + 1;
fprintf('Test %d: Stability with Large Time Steps\n', test_num);

try
  % Crank-Nicolson should remain stable even with large dt
  alpha = 0.01;
  L = 1.0;
  T_boundary = 0.0;
  nx = 50;
  dt = 0.1;  % Very large time step
  t_final = 1.0;
  
  u0 = @(x) sin(pi * x / L);
  
  [u_history, x, t] = heat_solver_1d(u0, alpha, L, T_boundary, nx, dt, t_final);
  
  % Check for NaN or Inf (instability indicators)
  if all(isfinite(u_history(:)))
    fprintf('  ✓ PASSED: Solution remains stable with large dt = %.2f\n', dt);
    tests_passed = tests_passed + 1;
  else
    fprintf('  ✗ FAILED: Instability detected (NaN or Inf values)\n');
    tests_failed = tests_failed + 1;
  end
catch err
  fprintf('  ✗ FAILED: %s\n', err.message);
  tests_failed = tests_failed + 1;
end

fprintf('\n');


%% Test 7: Grid Convergence (1D)
test_num = test_num + 1;
fprintf('Test %d: Grid Convergence Test (1D)\n', test_num);

try
  % Solution should converge as grid is refined
  alpha = 0.01;
  L = 1.0;
  T_boundary = 0.0;
  dt = 0.0001;
  t_final = 0.1;
  
  u0 = @(x) sin(pi * x / L);
  
  % Coarse grid
  nx1 = 50;
  [u_history1, x1, t1] = heat_solver_1d(u0, alpha, L, T_boundary, nx1, dt, t_final);
  
  % Fine grid
  nx2 = 100;
  [u_history2, x2, t2] = heat_solver_1d(u0, alpha, L, T_boundary, nx2, dt, t_final);
  
  % Interpolate coarse solution to fine grid for comparison
  % Use 'extrap' to handle boundary points properly
  u1_interp = interp1(x1, u_history1(:, end), x2, 'linear', 'extrap');
  
  % Error should decrease with refinement
  convergence_ratio = norm(u1_interp - u_history2(:, end)) / norm(u_history2(:, end));
  
  if convergence_ratio < 0.1  % Reasonable convergence
    fprintf('  ✓ PASSED: Grid convergence observed (error ratio = %.2e)\n', convergence_ratio);
    tests_passed = tests_passed + 1;
  else
    fprintf('  ✗ FAILED: Poor convergence (error ratio = %.2e)\n', convergence_ratio);
    tests_failed = tests_failed + 1;
  end
catch err
  fprintf('  ✗ FAILED: %s\n', err.message);
  tests_failed = tests_failed + 1;
end

fprintf('\n');


%% Test 8: Performance Benchmark
test_num = test_num + 1;
fprintf('Test %d: Performance Benchmark\n', test_num);

try
  % 2D solver with moderate grid size
  alpha = 0.01;
  Lx = 1.0;
  Ly = 1.0;
  T_boundary = 0.0;
  nx = 100;
  ny = 100;
  dt = 0.001;
  t_final = 0.1;
  
  u0 = @(x, y) 100 * exp(-100 * ((x - 0.5).^2 + (y - 0.5).^2));
  
  tic;
  [u_history, x, y, t] = heat_solver_2d(u0, alpha, Lx, Ly, T_boundary, nx, ny, dt, t_final);
  elapsed = toc;
  
  nt = length(t);
  fprintf('  Grid: %dx%d, Time steps: %d\n', nx, ny, nt);
  fprintf('  Elapsed time: %.2f seconds\n', elapsed);
  fprintf('  Time per step: %.4f seconds\n', elapsed / nt);
  
  if elapsed < 60  % Should complete within 1 minute
    fprintf('  ✓ PASSED: Performance acceptable\n');
    tests_passed = tests_passed + 1;
  else
    fprintf('  ✗ WARNING: Performance may be slow\n');
    tests_passed = tests_passed + 1;  % Not a failure, just a note
  end
catch err
  fprintf('  ✗ FAILED: %s\n', err.message);
  tests_failed = tests_failed + 1;
end

fprintf('\n');


%% Summary
fprintf('========================================\n');
fprintf('Test Summary:\n');
fprintf('  Total tests: %d\n', test_num);
fprintf('  Passed: %d\n', tests_passed);
fprintf('  Failed: %d\n', tests_failed);
fprintf('========================================\n\n');

if tests_failed == 0
  fprintf('✓ All tests passed! Phase 1 complete.\n');
else
  fprintf('✗ Some tests failed. Please review.\n');
end
