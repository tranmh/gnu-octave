% main_2d.m
% Main entry point for 2D Heat Diffusion Simulation
% 
% This script provides an interactive interface for running 2D heat diffusion
% simulations with various initial conditions and real-time visualization.
%
% USAGE:
%   Simply run: main_2d
%   Then select a pattern from the menu and watch the heat diffuse!
%
% CONTROLS (during simulation):
%   SPACE - Pause/Resume
%   UP    - Increase speed (reduce delay)
%   DOWN  - Decrease speed (increase delay)
%   R     - Reset to initial condition
%   Q     - Quit simulation
%   H     - Show help
%   V     - Change view mode (surface/heatmap/contour)
%
% MATHEMATICAL FOUNDATION:
%   Solves the 2D heat equation: ∂u/∂t = α ∇²u
%   Using the Crank-Nicolson method (unconditionally stable)
%   With Dirichlet boundary conditions (fixed temperatures at boundaries)

function main_2d()
    % Clear workspace and figures
    clear all;
    close all;
    clc;
    
    fprintf('\n=================================================\n');
    fprintf('  2D HEAT DIFFUSION SIMULATOR\n');
    fprintf('  Using Crank-Nicolson Method\n');
    fprintf('=================================================\n\n');
    
    % Add paths to required directories
    setup_paths();
    
    % ====================================================================
    % SIMULATION PARAMETERS
    % ====================================================================
    
    % Physical parameters
    params.alpha = 0.01;        % Thermal diffusivity [m²/s]
    params.Lx = 1.0;            % Domain length in x [m]
    params.Ly = 1.0;            % Domain length in y [m]
    params.T_boundary = 0.0;    % Boundary temperature [°C]
    
    % Numerical parameters
    params.nx = 50;             % Grid points in x
    params.ny = 50;             % Grid points in y
    params.dt = 0.001;          % Time step [s]
    params.t_final = 1.0;       % Final simulation time [s]
    
    % Visualization parameters
    params.frame_skip = 10;     % Show every Nth time step
    params.colormap_choice = 'jet';
    params.fps_target = 30;
    params.view_mode = 'surface';  % Default view: 'surface', 'heatmap', or 'contour'
    
    % Display current configuration
    fprintf('CONFIGURATION:\n');
    fprintf('  Domain: [0, %.2f] × [0, %.2f] m\n', params.Lx, params.Ly);
    fprintf('  Grid: %d × %d points\n', params.nx, params.ny);
    fprintf('  Time step: %.4f s\n', params.dt);
    fprintf('  Final time: %.2f s\n', params.t_final);
    fprintf('  Thermal diffusivity: %.4f m²/s\n', params.alpha);
    fprintf('\n');
    
    % ====================================================================
    % VALIDATE PARAMETERS
    % ====================================================================
    
    [is_valid, warnings] = validate_parameters(params, '2d');
    if ~is_valid
        error('Invalid parameters. Please check configuration.');
    end
    
    % Display any warnings
    if ~isempty(warnings)
        for i = 1:length(warnings)
            fprintf('WARNING: %s\n', warnings{i});
        end
        fprintf('\n');
    end
    
    % ====================================================================
    % CALCULATE STABILITY METRICS
    % ====================================================================
    
    stability = calculate_stability(params, '2d');
    fprintf('STABILITY ANALYSIS:\n');
    fprintf('  CFL number: %.4f\n', stability.cfl);
    fprintf('  Stability: %s\n', stability.status);
    fprintf('  Accuracy: %s\n', stability.accuracy);
    if isfield(stability, 'recommendation')
        fprintf('  Recommendation: %s\n', stability.recommendation);
    end
    fprintf('\n');
    
    % ====================================================================
    % PATTERN SELECTION
    % ====================================================================
    
    fprintf('Select an initial condition pattern:\n\n');
    
    % Available patterns for 2D
    patterns_2d = {'center_hot', 'corner_hot', 'gaussian', 'ring', ...
                   'checkerboard', 'radial', 'random'};
    
    fprintf('Available patterns:\n');
    for i = 1:length(patterns_2d)
        fprintf('  %d. %s\n', i, patterns_2d{i});
    end
    fprintf('\n');
    
    % Get user choice
    choice = input('Enter pattern number (or press Enter for menu): ');
    
    if isempty(choice)
        % Use interactive pattern menu
        [pattern_name, u0] = pattern_menu('2d', params);
    else
        % Direct pattern selection
        if choice < 1 || choice > length(patterns_2d)
            error('Invalid pattern choice');
        end
        pattern_name = patterns_2d{choice};
        u0 = get_pattern_2d(pattern_name, params.nx, params.ny);
    end
    
    fprintf('Selected pattern: %s\n\n', pattern_name);
    
    % ====================================================================
    % RUN SIMULATION
    % ====================================================================
    
    fprintf('Starting simulation...\n');
    fprintf('This may take a moment for larger grids...\n');
    fprintf('Press H during simulation to see controls\n\n');
    
    % Solve the heat equation
    tic;
    [u_history, x, y, t] = heat_solver_2d(u0, params.alpha, params.Lx, params.Ly, ...
                                           params.T_boundary, params.nx, params.ny, ...
                                           params.dt, params.t_final);
    elapsed = toc;
    
    fprintf('Simulation complete!\n');
    fprintf('  Total time steps: %d\n', length(t));
    fprintf('  Grid size: %d × %d\n', length(x), length(y));
    fprintf('  Computation time: %.2f seconds\n', elapsed);
    fprintf('\n');
    
    % ====================================================================
    % VISUALIZATION
    % ====================================================================
    
    fprintf('Starting animation...\n');
    fprintf('Use controls to interact with the simulation\n');
    fprintf('Press V to cycle through different view modes\n\n');
    
    % Set up figure
    fig = figure('Name', '2D Heat Diffusion', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1000, 700]);
    
    % Animate with interactive controls
    animate_2d(u_history, x, y, t, params, fig);
    
    fprintf('\n=================================================\n');
    fprintf('Simulation complete. Thank you for using the\n');
    fprintf('2D Heat Diffusion Simulator!\n');
    fprintf('=================================================\n\n');
end

% ====================================================================
% HELPER FUNCTION: Setup Paths
% ====================================================================

function setup_paths()
    % Add all required directories to the path
    script_dir = fileparts(mfilename('fullpath'));
    
    addpath(fullfile(script_dir, 'core'));
    addpath(fullfile(script_dir, 'display'));
    addpath(fullfile(script_dir, 'interaction'));
    addpath(fullfile(script_dir, 'patterns'));
    addpath(fullfile(script_dir, 'utils'));
    addpath(fullfile(script_dir, 'tests'));
end
