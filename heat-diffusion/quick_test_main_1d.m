% quick_test_main_1d.m
% Quick automated test of main_1d with each pattern

function quick_test_main_1d()
    fprintf('\n========================================\n');
    fprintf('QUICK TEST: main_1d.m with all patterns\n');
    fprintf('========================================\n\n');
    
    % Add paths
    script_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(script_dir, 'core'));
    addpath(fullfile(script_dir, 'display'));
    addpath(fullfile(script_dir, 'interaction'));
    addpath(fullfile(script_dir, 'patterns'));
    addpath(fullfile(script_dir, 'utils'));
    
    % Set up parameters (same as main_1d)
    params.alpha = 0.01;
    params.L = 1.0;
    params.T_boundary = 0.0;
    params.nx = 100;
    params.dt = 0.001;
    params.t_final = 0.05;  % Shorter for quick test
    params.frame_skip = 10;
    params.colormap_choice = 'jet';
    params.fps_target = 30;
    
    % Test each pattern
    patterns = {'gaussian', 'step', 'double_peak', 'sine', 'random'};
    
    for i = 1:length(patterns)
        pattern_name = patterns{i};
        fprintf('Testing: %s... ', pattern_name);
        
        try
            % Get pattern
            u0 = get_pattern_1d(pattern_name, params.nx);
            
            % Validate
            [is_valid, ~] = validate_parameters(params, '1d');
            if ~is_valid
                error('Invalid parameters');
            end
            
            % Solve
            [u_history, x, t] = heat_solver_1d(u0, params.alpha, params.L, ...
                                                params.T_boundary, params.nx, ...
                                                params.dt, params.t_final);
            
            % Quick visualization test
            fig = figure('Visible', 'off');
            plot(x, u_history(:, 1), 'b-', 'LineWidth', 2);
            xlabel('Position [m]');
            ylabel('Temperature [°C]');
            title(sprintf('%s - Initial Condition', pattern_name));
            close(fig);
            
            fprintf('✓ PASS\n');
            
        catch err
            fprintf('✗ FAIL: %s\n', err.message);
        end
    end
    
    fprintf('\n========================================\n');
    fprintf('Quick test complete!\n');
    fprintf('========================================\n\n');
end
