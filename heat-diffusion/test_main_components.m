% Automated test for main_2d with pattern selection
addpath('patterns');
addpath('core');
addpath('display');
addpath('interaction');

fprintf('Testing main_2d with center_hot pattern...\n');

% Simulate the main_2d workflow with automated pattern selection
% Set up parameters
params = struct();
params.Lx = 1.0;
params.Ly = 1.0;
params.nx = 50;
params.ny = 50;
params.alpha = 0.01;
params.t_final = 1.0;
params.dt = 0.001;

% Get the pattern directly
try
    u0 = get_pattern_2d('center_hot', params.nx, params.ny);
    fprintf('✓ Pattern generation successful\n');
    fprintf('  Pattern size: %d x %d\n', size(u0, 1), size(u0, 2));
    fprintf('  Min temp: %.2f\n', min(u0(:)));
    fprintf('  Max temp: %.2f\n', max(u0(:)));
catch e
    fprintf('✗ Pattern generation failed: %s\n', e.message);
    return;
end

% Test solver initialization
try
    [A_x, A_y] = setup_crank_nicolson_2d(params.nx, params.ny, params.alpha, params.dt, params.Lx, params.Ly);
    fprintf('✓ Solver setup successful\n');
catch e
    fprintf('✗ Solver setup failed: %s\n', e.message);
    return;
end

% Test one time step
try
    u_new = crank_nicolson_step_2d(u0, A_x, A_y, params.nx, params.ny);
    fprintf('✓ Time step computation successful\n');
    fprintf('  New min temp: %.2f\n', min(u_new(:)));
    fprintf('  New max temp: %.2f\n', max(u_new(:)));
catch e
    fprintf('✗ Time step failed: %s\n', e.message);
    return;
end

fprintf('\n✓ All components working correctly!\n');
fprintf('You can now run main_2d and it should work.\n');
