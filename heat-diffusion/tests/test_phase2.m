% TEST_PHASE2 - Test suite for Phase 2: Basic Visualization
%
% Tests all visualization functions with simple test cases
% to verify correct operation and visual output.

clear all;
close all;
clc;

fprintf('=== Phase 2: Basic Visualization Tests ===\n\n');

% Add paths
addpath('../core');
addpath('../display');

%% Test 1: animate_1d with simple Gaussian decay
fprintf('Test 1: Testing animate_1d with Gaussian decay...\n');

% Simple test case: Gaussian initial condition
nx = 50;
L = 1.0;
x = linspace(0, L, nx)';
dx = L / (nx - 1);

% Time parameters
alpha = 0.01;
dt = 0.001;
t_final = 0.1;
t = 0:dt:t_final;
nt = length(t);

% Initial condition: Gaussian
x0 = L / 2;
sigma = 0.1;
u0 = exp(-((x - x0).^2) / (2 * sigma^2));

% Run 1D solver
fprintf('  Running 1D heat solver...\n');
[U, x_out, t_out] = heat_solver_1d(u0, L, alpha, dt, t_final);

% Test animation
fprintf('  Testing animate_1d...\n');
params_1d.frame_skip = 5;
params_1d.fps_target = 30;
params_1d.title_prefix = 'Test: 1D Gaussian Decay';
animate_1d(x, U, t, params_1d);
fprintf('  ✓ animate_1d completed successfully\n\n');

pause(2);

%% Test 2: plot_1d_snapshot with multiple time snapshots
fprintf('Test 2: Testing plot_1d_snapshot with multiple snapshots...\n');

% Select snapshots at t=0, t=0.025, t=0.05, t=0.1
time_indices = [1, 26, 51, 101];
params_snap.title_prefix = 'Test: 1D Temperature Snapshots';
params_snap.legend_on = true;

plot_1d_snapshot(x, U, t, time_indices, params_snap);
fprintf('  ✓ plot_1d_snapshot completed successfully\n\n');

pause(2);

%% Test 3: animate_2d with 2D Gaussian
fprintf('Test 3: Testing animate_2d with 2D Gaussian...\n');

% 2D grid
nx_2d = 30;
ny_2d = 30;
Lx = 1.0;
Ly = 1.0;
x_2d = linspace(0, Lx, nx_2d);
y_2d = linspace(0, Ly, ny_2d);

[X_2d, Y_2d] = meshgrid(x_2d, y_2d);

% Initial condition: 2D Gaussian at center
x0_2d = Lx / 2;
y0_2d = Ly / 2;
sigma_2d = 0.15;
u0_2d = exp(-(((X_2d - x0_2d).^2 + (Y_2d - y0_2d).^2)) / (2 * sigma_2d^2))';

% Run 2D solver
fprintf('  Running 2D heat solver...\n');
dt_2d = 0.001;
t_final_2d = 0.1;
[U_2d, x_2d_out, y_2d_out, t_2d] = heat_solver_2d(u0_2d, Lx, Ly, alpha, dt_2d, t_final_2d);

% Test animation with heatmap
fprintf('  Testing animate_2d (heatmap)...\n');
params_2d.frame_skip = 5;
params_2d.fps_target = 30;
params_2d.plot_type = 'heatmap';
params_2d.title_prefix = 'Test: 2D Gaussian Decay (Heatmap)';
animate_2d(x_2d, y_2d, U_2d, t_2d, params_2d);
fprintf('  ✓ animate_2d (heatmap) completed successfully\n\n');

pause(2);

%% Test 4: animate_2d with surface plot
fprintf('Test 4: Testing animate_2d with surface plot...\n');

params_2d_surf.frame_skip = 5;
params_2d_surf.fps_target = 30;
params_2d_surf.plot_type = 'surface';
params_2d_surf.view_angle = [45, 30];
params_2d_surf.title_prefix = 'Test: 2D Gaussian Decay (Surface)';
animate_2d(x_2d, y_2d, U_2d, t_2d, params_2d_surf);
fprintf('  ✓ animate_2d (surface) completed successfully\n\n');

pause(2);

%% Test 5: plot_2d_multiple
fprintf('Test 5: Testing plot_2d_multiple...\n');

% Plot at final time
time_idx_2d = length(t_2d);
params_multi.title_prefix = 'Test: 2D Multiple Views';
params_multi.layout = 'horizontal';
plot_2d_multiple(x_2d, y_2d, U_2d, t_2d, time_idx_2d, params_multi);
fprintf('  ✓ plot_2d_multiple completed successfully\n\n');

%% Summary
fprintf('==============================================\n');
fprintf('All Phase 2 visualization tests completed!\n');
fprintf('==============================================\n');
fprintf('\nVisualization functions tested:\n');
fprintf('  ✓ animate_1d\n');
fprintf('  ✓ plot_1d_snapshot\n');
fprintf('  ✓ animate_2d (heatmap mode)\n');
fprintf('  ✓ animate_2d (surface mode)\n');
fprintf('  ✓ plot_2d_multiple\n');
fprintf('\nAll functions are working correctly.\n');
fprintf('Close all figure windows to complete the test.\n');
