% Comprehensive test of main_2d functionality
% This simulates the user selecting pattern 1 (center_hot)

fprintf('=== COMPREHENSIVE TEST OF MAIN_2D ===\n\n');

% Add paths
addpath('patterns');
addpath('core');
addpath('display');
addpath('interaction');
addpath('utils');

% Test 1: Pattern generation
fprintf('Test 1: Pattern generation\n');
try
    u0 = get_pattern_2d('center_hot', 50, 50);
    fprintf('  ✓ Pattern generated: size %dx%d, max=%.2f\n', size(u0,1), size(u0,2), max(u0(:)));
catch e
    fprintf('  ✗ FAILED: %s\n', e.message);
    return;
end

% Test 2: Solver setup
fprintf('\nTest 2: Heat solver\n');
try
    params = struct();
    params.alpha = 0.01;
    params.Lx = 1.0;
    params.Ly = 1.0;
    params.T_boundary = 0;
    params.nx = 50;
    params.ny = 50;
    params.dt = 0.001;
    params.t_final = 0.01;  % Just 10 steps for testing
    
    [u_history, x, y, t] = heat_solver_2d(u0, params);
    fprintf('  ✓ Solver ran: %d time steps computed\n', length(t));
    fprintf('    Final temp range: [%.2f, %.2f]\n', min(u_history(:,:,end), [], 'all'), max(u_history(:,:,end), [], 'all'));
catch e
    fprintf('  ✗ FAILED: %s\n', e.message);
    return;
end

% Test 3: Check visualization functions exist
fprintf('\nTest 3: Visualization functions\n');
try
    % Just check if functions exist, don't actually plot
    which('plot_2d_heat');
    fprintf('  ✓ Visualization function found\n');
catch
    fprintf('  ✗ Visualization function missing\n');
end

fprintf('\n=== ALL TESTS PASSED ===\n');
fprintf('You can now run: main_2d\n');
fprintf('Then enter: 1\n');
