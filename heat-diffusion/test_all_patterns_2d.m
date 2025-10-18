% test_all_patterns_2d.m
% Comprehensive test script for all 2D initial condition patterns
%
% This script tests each pattern individually with proper error handling
% and visual verification.

function test_all_patterns_2d()
    clear all;
    close all;
    clc;
    
    fprintf('\n=================================================\n');
    fprintf('  TESTING ALL 2D PATTERNS\n');
    fprintf('=================================================\n\n');
    
    % Add paths
    setup_paths();
    
    % Test parameters - small grid for quick testing
    params.alpha = 0.01;
    params.Lx = 1.0;
    params.Ly = 1.0;
    params.T_boundary = 0.0;
    params.nx = 40;
    params.ny = 40;
    params.dt = 0.001;
    params.t_final = 0.1;  % Short simulation
    params.frame_skip = 5;
    params.colormap_choice = 'jet';
    params.fps_target = 30;
    params.view_mode = 'heatmap';
    
    % All available patterns
    patterns = {'center_hot', 'corner_hot', 'gaussian', 'ring', ...
                'checkerboard', 'radial', 'random'};
    
    % Test each pattern
    for i = 1:length(patterns)
        pattern_name = patterns{i};
        fprintf('\n-------------------------------------------------\n');
        fprintf('Testing pattern %d/%d: %s\n', i, length(patterns), pattern_name);
        fprintf('-------------------------------------------------\n');
        
        try
            % Generate initial condition
            fprintf('  Generating initial condition...\n');
            u0 = get_pattern_2d(pattern_name, params.nx, params.ny);
            
            % Validate initial condition
            fprintf('  Validating pattern...\n');
            fprintf('    Size: %d x %d\n', size(u0, 1), size(u0, 2));
            fprintf('    Min value: %.2f\n', min(u0(:)));
            fprintf('    Max value: %.2f\n', max(u0(:)));
            fprintf('    Mean value: %.2f\n', mean(u0(:)));
            
            % Check for issues
            if any(isnan(u0(:)))
                error('Pattern contains NaN values!');
            end
            if any(isinf(u0(:)))
                error('Pattern contains Inf values!');
            end
            
            % Run short simulation
            fprintf('  Running simulation...\n');
            tic;
            [u_history, x, y, t] = heat_solver_2d(u0, params.alpha, ...
                                                   params.Lx, params.Ly, ...
                                                   params.T_boundary, ...
                                                   params.nx, params.ny, ...
                                                   params.dt, params.t_final);
            elapsed = toc;
            
            fprintf('    Simulation time: %.2f seconds\n', elapsed);
            fprintf('    Time steps: %d\n', length(t));
            
            % Validate output
            fprintf('  Validating results...\n');
            fprintf('    History size: %d x %d x %d\n', size(u_history, 1), ...
                    size(u_history, 2), size(u_history, 3));
            
            if any(isnan(u_history(:)))
                error('Simulation produced NaN values!');
            end
            if any(isinf(u_history(:)))
                error('Simulation produced Inf values!');
            end
            
            % Create visualization
            fprintf('  Creating visualization...\n');
            fig = figure('Name', sprintf('Pattern: %s', pattern_name), ...
                        'NumberTitle', 'off', ...
                        'Position', [50 + (i-1)*50, 50 + (i-1)*50, 800, 600]);
            
            % Plot initial and final states
            subplot(2, 2, 1);
            imagesc(x, y, u0);
            colorbar;
            title(sprintf('Initial: %s', strrep(pattern_name, '_', ' ')));
            xlabel('x [m]');
            ylabel('y [m]');
            axis equal tight;
            colormap(jet);
            
            subplot(2, 2, 2);
            imagesc(x, y, u_history(:,:,end));
            colorbar;
            title(sprintf('Final (t=%.2f s)', t(end)));
            xlabel('x [m]');
            ylabel('y [m]');
            axis equal tight;
            colormap(jet);
            
            % Plot middle state
            mid_idx = ceil(length(t) / 2);
            subplot(2, 2, 3);
            imagesc(x, y, u_history(:,:,mid_idx));
            colorbar;
            title(sprintf('Middle (t=%.3f s)', t(mid_idx)));
            xlabel('x [m]');
            ylabel('y [m]');
            axis equal tight;
            colormap(jet);
            
            % Plot temperature evolution at center
            subplot(2, 2, 4);
            cx = ceil(params.nx / 2);
            cy = ceil(params.ny / 2);
            temp_center = squeeze(u_history(cy, cx, :));
            plot(t, temp_center, 'b-', 'LineWidth', 2);
            grid on;
            title('Temperature at Center');
            xlabel('Time [s]');
            ylabel('Temperature [°C]');
            
            fprintf('  ✓ Pattern tested successfully!\n');
            
        catch err
            fprintf('  ✗ ERROR: %s\n', err.message);
            fprintf('  Stack trace:\n');
            for j = 1:length(err.stack)
                fprintf('    %s (line %d)\n', err.stack(j).name, err.stack(j).line);
            end
        end
    end
    
    fprintf('\n=================================================\n');
    fprintf('All pattern tests complete!\n');
    fprintf('=================================================\n\n');
    
end

% Setup paths helper function
function setup_paths()
    script_dir = fileparts(mfilename('fullpath'));
    
    addpath(fullfile(script_dir, 'core'));
    addpath(fullfile(script_dir, 'display'));
    addpath(fullfile(script_dir, 'interaction'));
    addpath(fullfile(script_dir, 'patterns'));
    addpath(fullfile(script_dir, 'utils'));
end
