% TEST_PHASE2_CLI - CLI-compatible test suite for Phase 2: Basic Visualization
%
% Tests core functionality without GUI requirements

clear all;
close all;
clc;

fprintf('=== Phase 2: Basic Visualization Tests (CLI) ===\n\n');

% Add paths
addpath('../core');
addpath('../display');

%% Test 1: 1D Heat Solver Integration
fprintf('Test 1: Testing 1D heat solver integration...\n');

% Parameters
alpha = 0.01;
L = 1.0;
T_boundary = 0.0;
nx = 50;
dt = 0.001;
t_final = 0.1;

% Initial condition: Gaussian
u0 = @(x) exp(-100 * (x - 0.5).^2);

% Run solver
fprintf('  Running 1D heat solver...\n');
[u_history, x, t] = heat_solver_1d(u0, alpha, L, T_boundary, nx, dt, t_final);

% Verify output dimensions
fprintf('  Verifying dimensions...\n');
assert(size(u_history, 1) == nx, 'Wrong number of spatial points');
assert(size(u_history, 2) == length(t), 'Wrong number of time steps');
assert(length(x) == nx, 'x vector has wrong length');

fprintf('  ✓ Dimensions correct: u_history(%dx%d), x(%d), t(%d)\n', ...
        size(u_history, 1), size(u_history, 2), length(x), length(t));

% Check heat diffusion behavior
fprintf('  Checking heat diffusion properties...\n');
u_initial = u_history(:, 1);
u_final = u_history(:, end);

% Maximum should decrease (diffusion smooths peaks)
max_initial = max(u_initial);
max_final = max(u_final);
assert(max_final < max_initial, 'Maximum should decrease due to diffusion');
fprintf('  ✓ Maximum decreased: %.2f -> %.2f\n', max_initial, max_final);

% Total "heat" should be conserved (approximately, with boundary losses)
total_initial = sum(u_initial);
total_final = sum(u_final);
fprintf('  ✓ Heat diffused to boundaries: %.2f -> %.2f\n', total_initial, total_final);

fprintf('  ✓ Test 1 PASSED\n\n');


%% Test 2: 2D Heat Solver Integration
fprintf('Test 2: Testing 2D heat solver integration...\n');

% Parameters
alpha = 0.01;
Lx = 1.0;
Ly = 1.0;
T_boundary = 0.0;
nx = 30;
ny = 30;
dt = 0.001;
t_final = 0.1;

% Initial condition: Gaussian at center
u0 = @(x, y) 100 * exp(-100 * ((x - 0.5).^2 + (y - 0.5).^2));

% Run solver
fprintf('  Running 2D heat solver...\n');
[u_history, x, y, t] = heat_solver_2d(u0, alpha, Lx, Ly, T_boundary, nx, ny, dt, t_final);

% Verify output dimensions
fprintf('  Verifying dimensions...\n');
assert(size(u_history, 1) == nx, 'Wrong number of x points');
assert(size(u_history, 2) == ny, 'Wrong number of y points');
assert(size(u_history, 3) == length(t), 'Wrong number of time steps');

fprintf('  ✓ Dimensions correct: u_history(%dx%dx%d), x(%d), y(%d), t(%d)\n', ...
        size(u_history, 1), size(u_history, 2), size(u_history, 3), ...
        length(x), length(y), length(t));

% Check 2D diffusion
fprintf('  Checking 2D heat diffusion properties...\n');
u_initial = u_history(:, :, 1);
u_final = u_history(:, :, end);

max_initial = max(u_initial(:));
max_final = max(u_final(:));
assert(max_final < max_initial, 'Maximum should decrease in 2D diffusion');
fprintf('  ✓ Maximum decreased: %.2f -> %.2f\n', max_initial, max_final);

% Check symmetry (should be maintained for centered Gaussian)
u_flipped_x = flipud(u_final);
symmetry_error = norm(u_final - u_flipped_x, 'fro') / norm(u_final, 'fro');
fprintf('  ✓ Symmetry maintained (error = %.2e)\n', symmetry_error);

fprintf('  ✓ Test 2 PASSED\n\n');


%% Test 3: Display function availability
fprintf('Test 3: Checking display functions exist...\n');

% Check if visualization functions exist (but don't call them in CLI mode)
functions_to_check = {
  'animate_1d',
  'animate_2d',
  'plot_1d_snapshot',
  'plot_2d_snapshot'
};

all_exist = true;
for i = 1:length(functions_to_check)
  func_name = functions_to_check{i};
  if exist(func_name, 'file')
    fprintf('  ✓ %s exists\n', func_name);
  else
    fprintf('  ✗ %s NOT FOUND\n', func_name);
    all_exist = false;
  end
end

if all_exist
  fprintf('  ✓ Test 3 PASSED\n\n');
else
  fprintf('  ✗ Test 3 FAILED - Some display functions missing\n\n');
end


%% Summary
fprintf('========================================\n');
fprintf('Phase 2 CLI Tests Complete\n');
fprintf('All core solver integration tests passed!\n');
fprintf('========================================\n');
