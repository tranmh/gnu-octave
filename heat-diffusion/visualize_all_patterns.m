% visualize_all_patterns.m
% Create a comprehensive visual comparison of all 2D patterns
% Shows initial conditions and their evolution over time

function visualize_all_patterns()
    clear all;
    close all;
    clc;
    
    fprintf('\n=================================================\n');
    fprintf('  VISUALIZING ALL 2D PATTERNS\n');
    fprintf('=================================================\n\n');
    
    % Add paths
    setup_paths();
    
    % Parameters
    nx = 40;
    ny = 40;
    
    % All patterns
    patterns = {'center_hot', 'corner_hot', 'gaussian', 'ring', ...
                'checkerboard', 'radial', 'random'};
    
    % Create figure for initial conditions
    fig1 = figure('Name', 'All Initial Conditions', 'NumberTitle', 'off', ...
                  'Position', [50, 50, 1400, 800]);
    
    fprintf('Generating all initial conditions...\n');
    
    % Generate and plot all initial conditions
    for i = 1:length(patterns)
        pattern_name = patterns{i};
        fprintf('  %d. %s\n', i, pattern_name);
        
        % Generate pattern
        u0 = get_pattern_2d(pattern_name, nx, ny);
        
        % Plot
        subplot(2, 4, i);
        imagesc(u0);
        colorbar;
        title(strrep(pattern_name, '_', ' '), 'FontSize', 12, 'FontWeight', 'bold');
        axis equal tight;
        colormap(jet);
        
        % Add statistics as text
        min_val = min(u0(:));
        max_val = max(u0(:));
        mean_val = mean(u0(:));
        
        text(2, ny-2, sprintf('min: %.1f\nmax: %.1f\nmean: %.1f', ...
                              min_val, max_val, mean_val), ...
             'Color', 'white', 'FontSize', 8, 'FontWeight', 'bold', ...
             'BackgroundColor', [0 0 0 0.5], 'VerticalAlignment', 'top');
    end
    
    fprintf('\n');
    fprintf('Figure created: All Initial Conditions\n');
    fprintf('Close the figure when done viewing.\n\n');
    
    % Wait for user
    fprintf('Press Enter to continue to evolution comparison...\n');
    pause;
    
    % Now create evolution comparison for a subset of interesting patterns
    interesting_patterns = {'center_hot', 'ring', 'checkerboard'};
    
    fprintf('\nGenerating evolution comparison for selected patterns...\n');
    
    % Simulation parameters
    params.alpha = 0.01;
    params.Lx = 1.0;
    params.Ly = 1.0;
    params.T_boundary = 0.0;
    params.nx = 40;
    params.ny = 40;
    params.dt = 0.001;
    params.t_final = 0.2;
    
    % Create evolution figure
    fig2 = figure('Name', 'Pattern Evolution Over Time', 'NumberTitle', 'off', ...
                  'Position', [100, 100, 1400, 600]);
    
    for i = 1:length(interesting_patterns)
        pattern_name = interesting_patterns{i};
        fprintf('  Simulating %s...\n', pattern_name);
        
        % Generate initial condition
        u0 = get_pattern_2d(pattern_name, params.nx, params.ny);
        
        % Run simulation
        [u_history, x, y, t] = heat_solver_2d(u0, params.alpha, ...
                                               params.Lx, params.Ly, ...
                                               params.T_boundary, ...
                                               params.nx, params.ny, ...
                                               params.dt, params.t_final);
        
        % Plot snapshots: t=0, t=T/4, t=T/2, t=T
        times = [1, ceil(length(t)/4), ceil(length(t)/2), length(t)];
        
        for j = 1:4
            subplot(3, 4, (i-1)*4 + j);
            imagesc(x, y, u_history(:,:,times(j)));
            colorbar;
            title(sprintf('%s\nt=%.3fs', strrep(pattern_name, '_', ' '), t(times(j))), ...
                  'FontSize', 10);
            axis equal tight;
            colormap(jet);
            xlabel('x [m]');
            ylabel('y [m]');
        end
    end
    
    fprintf('\nAll visualizations complete!\n');
    fprintf('=================================================\n\n');
end

function setup_paths()
    script_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(script_dir, 'core'));
    addpath(fullfile(script_dir, 'display'));
    addpath(fullfile(script_dir, 'patterns'));
    addpath(fullfile(script_dir, 'utils'));
end
