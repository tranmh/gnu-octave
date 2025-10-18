% test_main_2d_automated.m
% Automated test of main_2d.m with all patterns
% This script simulates user input for each pattern

function test_main_2d_automated()
    clear all;
    close all;
    clc;
    
    fprintf('\n=================================================\n');
    fprintf('  AUTOMATED TESTING OF MAIN_2D\n');
    fprintf('=================================================\n\n');
    
    % Add paths
    setup_paths();
    
    % Test each pattern by number
    patterns = {'center_hot', 'corner_hot', 'gaussian', 'ring', ...
                'checkerboard', 'radial', 'random'};
    
    for i = 1:length(patterns)
        fprintf('\n=================================================\n');
        fprintf('Testing pattern %d/%d: %s\n', i, length(patterns), patterns{i});
        fprintf('=================================================\n\n');
        
        try
            % Call test with pattern number
            test_single_pattern(i, patterns{i});
            fprintf('✓ Pattern %s tested successfully!\n', patterns{i});
        catch err
            fprintf('✗ ERROR with pattern %s: %s\n', patterns{i}, err.message);
        end
        
        % Close figures after each test
        close all;
        pause(0.5);
    end
    
    fprintf('\n=================================================\n');
    fprintf('All automated tests complete!\n');
    fprintf('=================================================\n\n');
end

function test_single_pattern(pattern_num, pattern_name)
    % Simulation parameters
    params.alpha = 0.01;
    params.Lx = 1.0;
    params.Ly = 1.0;
    params.T_boundary = 0.0;
    params.nx = 30;  % Smaller for quick testing
    params.ny = 30;
    params.dt = 0.001;
    params.t_final = 0.05;  % Very short simulation
    params.frame_skip = 5;
    params.colormap_choice = 'jet';
    params.fps_target = 30;
    params.view_mode = 'heatmap';
    
    % Generate pattern directly
    fprintf('Generating %s pattern...\n', pattern_name);
    u0 = get_pattern_2d(pattern_name, params.nx, params.ny);
    
    fprintf('  Pattern stats:\n');
    fprintf('    Size: %d x %d\n', size(u0, 1), size(u0, 2));
    fprintf('    Min: %.2f, Max: %.2f, Mean: %.2f\n', ...
            min(u0(:)), max(u0(:)), mean(u0(:)));
    
    % Run simulation
    fprintf('Running simulation...\n');
    [u_history, x, y, t] = heat_solver_2d(u0, params.alpha, params.Lx, params.Ly, ...
                                           params.T_boundary, params.nx, params.ny, ...
                                           params.dt, params.t_final);
    
    fprintf('  Simulation complete: %d time steps\n', length(t));
    
    % Quick visualization
    fprintf('Creating visualization...\n');
    fig = figure('Name', sprintf('Test: %s', pattern_name), ...
                'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);
    
    subplot(1, 3, 1);
    imagesc(x, y, u0);
    colorbar;
    title('Initial');
    axis equal tight;
    colormap(jet);
    
    mid_idx = ceil(length(t) / 2);
    subplot(1, 3, 2);
    imagesc(x, y, u_history(:,:,mid_idx));
    colorbar;
    title(sprintf('t=%.3fs', t(mid_idx)));
    axis equal tight;
    colormap(jet);
    
    subplot(1, 3, 3);
    imagesc(x, y, u_history(:,:,end));
    colorbar;
    title(sprintf('Final t=%.3fs', t(end)));
    axis equal tight;
    colormap(jet);
    
    drawnow;
end

function setup_paths()
    script_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(script_dir, 'core'));
    addpath(fullfile(script_dir, 'display'));
    addpath(fullfile(script_dir, 'interaction'));
    addpath(fullfile(script_dir, 'patterns'));
    addpath(fullfile(script_dir, 'utils'));
end
