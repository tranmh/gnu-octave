% main_1d.m
% Main entry point for 1D Heat Diffusion Simulation
% 
% This script provides an interactive interface for running 1D heat diffusion
% simulations with various initial conditions and real-time visualization.
%
% USAGE:
%   Simply run: main_1d
%   Then select a pattern from the menu and watch the heat diffuse!
%
% CONTROLS (during simulation):
%   SPACE - Pause/Resume
%   UP    - Increase speed (reduce delay)
%   DOWN  - Decrease speed (increase delay)
%   R     - Reset to initial condition
%   Q     - Quit simulation
%   H     - Show help
%
% MATHEMATICAL FOUNDATION:
%   Solves the 1D heat equation: ∂u/∂t = α ∇²u
%   Using the Crank-Nicolson method (unconditionally stable)
%   With Dirichlet boundary conditions (fixed temperatures at ends)

function main_1d()
    % Clear workspace and figures
    clear all;
    close all;
    clc;
    
    fprintf('\n=================================================\n');
    fprintf('  1D HEAT DIFFUSION SIMULATOR\n');
    fprintf('  Using Crank-Nicolson Method\n');
    fprintf('=================================================\n\n');
    
    % Add paths to required directories
    setup_paths();
    
    % ====================================================================
    % SIMULATION PARAMETERS
    % ====================================================================
    
    % Physical parameters
    params.alpha = 0.01;        % Thermal diffusivity [m²/s]
    params.L = 1.0;             % Domain length [m]
    params.T_boundary = 0.0;    % Boundary temperature [°C]
    
    % Numerical parameters
    params.nx = 100;            % Number of spatial points
    params.dt = 0.001;          % Time step [s]
    params.t_final = 1.0;       % Final simulation time [s]
    
    % Visualization parameters
    params.frame_skip = 10;     % Show every Nth time step
    params.colormap_choice = 'jet';
    params.fps_target = 30;
    
    % Display current configuration
    fprintf('CONFIGURATION:\n');
    fprintf('  Domain: [0, %.2f] m\n', params.L);
    fprintf('  Grid points: %d\n', params.nx);
    fprintf('  Time step: %.4f s\n', params.dt);
    fprintf('  Final time: %.2f s\n', params.t_final);
    fprintf('  Thermal diffusivity: %.4f m²/s\n', params.alpha);
    fprintf('\n');
    
    % ====================================================================
    % VALIDATE PARAMETERS
    % ====================================================================
    
    [is_valid, warnings] = validate_parameters(params, '1d');
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
    
    stability = calculate_stability(params, '1d');
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
    
    % Available patterns for 1D
    patterns_1d = {'gaussian', 'step', 'double_peak', 'sine', 'random'};
    
    fprintf('Available patterns:\n');
    for i = 1:length(patterns_1d)
        fprintf('  %d. %s\n', i, patterns_1d{i});
    end
    fprintf('\n');
    
    % Get user choice
    choice = input('Enter pattern number (or press Enter for menu): ');
    
    if isempty(choice)
        % Use interactive pattern menu
        [pattern_name, u0] = pattern_menu('1d', params);
    else
        % Direct pattern selection
        if choice < 1 || choice > length(patterns_1d)
            error('Invalid pattern choice');
        end
        pattern_name = patterns_1d{choice};
        u0 = get_pattern_1d(pattern_name, params.nx);
    end
    
    fprintf('Selected pattern: %s\n\n', pattern_name);
    
    % ====================================================================
    % RUN SIMULATION
    % ====================================================================
    
    fprintf('Starting simulation...\n');
    fprintf('Press H during simulation to see controls\n\n');
    
    % Solve the heat equation
    [u_history, x, t] = heat_solver_1d(u0, params);
    
    fprintf('Simulation complete!\n');
    fprintf('  Total time steps: %d\n', length(t));
    fprintf('  Spatial points: %d\n', length(x));
    fprintf('\n');
    
    % ====================================================================
    % VISUALIZATION
    % ====================================================================
    
    fprintf('Starting animation...\n');
    fprintf('Use controls to interact with the simulation\n\n');
    
    % Set up interactive controls and run animation
    fig = figure('Name', '1D Heat Diffusion', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 900, 600]);
    
    % Animate with interactive controls
    animate_1d(u_history, x, t, params, fig);
    
    fprintf('\n=================================================\n');
    fprintf('Simulation complete. Thank you for using the\n');
    fprintf('1D Heat Diffusion Simulator!\n');
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
