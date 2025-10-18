% test_all_patterns_1d.m
% Comprehensive test for all 1D patterns to identify crashes

function test_all_patterns_1d()
    fprintf('\n========================================\n');
    fprintf('TESTING ALL 1D PATTERNS\n');
    fprintf('========================================\n\n');
    
    % Add paths
    script_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(script_dir, 'core'));
    addpath(fullfile(script_dir, 'display'));
    addpath(fullfile(script_dir, 'interaction'));
    addpath(fullfile(script_dir, 'patterns'));
    addpath(fullfile(script_dir, 'utils'));
    
    % Set up parameters
    params.alpha = 0.01;
    params.L = 1.0;
    params.T_boundary = 0.0;
    params.nx = 100;
    params.dt = 0.001;
    params.t_final = 0.1;  % Short for testing
    params.frame_skip = 10;
    params.colormap_choice = 'jet';
    params.fps_target = 30;
    
    % Test patterns
    patterns = {'gaussian', 'step', 'double_peak', 'sine', 'random'};
    
    for i = 1:length(patterns)
        pattern_name = patterns{i};
        fprintf('\n----------------------------------------\n');
        fprintf('Testing pattern: %s\n', pattern_name);
        fprintf('----------------------------------------\n');
        
        try
            % Generate initial condition
            fprintf('  1. Generating initial condition... ');
            u0 = get_pattern_1d(pattern_name, params.nx);
            fprintf('OK (size: %dx%d)\n', size(u0, 1), size(u0, 2));
            
            % Check dimensions
            fprintf('  2. Checking dimensions... ');
            if length(u0) ~= params.nx
                error('Size mismatch: expected %d, got %d', params.nx, length(u0));
            end
            fprintf('OK\n');
            
            % Validate parameters
            fprintf('  3. Validating parameters... ');
            [is_valid, warnings] = validate_parameters(params, '1d');
            if ~is_valid
                error('Invalid parameters');
            end
            fprintf('OK\n');
            
            % Run simulation
            fprintf('  4. Running simulation... ');
            [u_history, x, t] = heat_solver_1d(u0, params.alpha, params.L, ...
                                                params.T_boundary, params.nx, ...
                                                params.dt, params.t_final);
            fprintf('OK (steps: %d)\n', length(t));
            
            % Test animation setup (but don't run full animation)
            fprintf('  5. Testing visualization setup... ');
            fig = figure('Visible', 'off');
            plot(x, u_history(:, 1), 'b-', 'LineWidth', 2);
            close(fig);
            fprintf('OK\n');
            
            fprintf('  ✓ PATTERN "%s" PASSED ALL TESTS\n', pattern_name);
            
        catch err
            fprintf('  ✗ FAILED!\n');
            fprintf('  Error: %s\n', err.message);
            fprintf('  Location: %s (line %d)\n', err.stack(1).name, err.stack(1).line);
            
            % Show detailed error info
            fprintf('\n  DETAILED ERROR INFO:\n');
            disp(err);
            
            if exist('u0', 'var')
                fprintf('\n  u0 info:\n');
                fprintf('    Size: %dx%d\n', size(u0, 1), size(u0, 2));
                fprintf('    Min: %.4f, Max: %.4f\n', min(u0), max(u0));
            end
        end
    end
    
    fprintf('\n========================================\n');
    fprintf('TEST COMPLETE\n');
    fprintf('========================================\n\n');
end
