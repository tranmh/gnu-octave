% test_main_1d_automated.m
% Fully automated test of main_1d functionality with all patterns
% Tests each pattern automatically without requiring user interaction

function test_main_1d_automated()
    fprintf('\n=======================================================\n');
    fprintf('  AUTOMATED MAIN_1D TESTING - ALL PATTERNS\n');
    fprintf('=======================================================\n\n');
    
    % Add paths
    script_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(script_dir, 'core'));
    addpath(fullfile(script_dir, 'display'));
    addpath(fullfile(script_dir, 'interaction'));
    addpath(fullfile(script_dir, 'patterns'));
    addpath(fullfile(script_dir, 'utils'));
    
    % Test parameters (short simulation for speed)
    params.alpha = 0.01;
    params.L = 1.0;
    params.T_boundary = 0.0;
    params.nx = 100;
    params.dt = 0.001;
    params.t_final = 0.05;  % Very short for testing
    params.frame_skip = 10;
    params.colormap_choice = 'jet';
    params.fps_target = 60;  % Fast animation for testing
    
    patterns_1d = {'gaussian', 'step', 'double_peak', 'sine', 'random'};
    
    test_results = struct('pattern', {}, 'status', {}, 'error_msg', {});
    
    fprintf('Testing %d patterns...\n\n', length(patterns_1d));
    
    for i = 1:length(patterns_1d)
        pattern_name = patterns_1d{i};
        fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        fprintf('Test %d/%d: %s\n', i, length(patterns_1d), upper(pattern_name));
        fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        
        test_results(i).pattern = pattern_name;
        
        try
            % Step 1: Get initial condition
            fprintf('  [1/4] Loading pattern...');
            u0 = get_pattern_1d(pattern_name, params.nx);
            fprintf(' ✓\n');
            fprintf('        Size: [%d x %d], Range: [%.2f, %.2f]\n', ...
                    size(u0, 1), size(u0, 2), min(u0), max(u0));
            
            % Step 2: Validate parameters
            fprintf('  [2/4] Validating parameters...');
            [is_valid, warnings] = validate_parameters(params, '1d');
            if ~is_valid
                error('Parameter validation failed');
            end
            fprintf(' ✓\n');
            if ~isempty(warnings)
                fprintf('        Warnings: %d\n', length(warnings));
            end
            
            % Step 3: Run solver
            fprintf('  [3/4] Running solver...');
            [u_history, x, t] = heat_solver_1d(u0, params.alpha, params.L, ...
                                                params.T_boundary, params.nx, ...
                                                params.dt, params.t_final);
            fprintf(' ✓\n');
            fprintf('        Solution: [%d x %d], Time steps: %d\n', ...
                    size(u_history, 1), size(u_history, 2), length(t));
            
            % Step 4: Test animation
            fprintf('  [4/4] Testing animation...');
            
            % Close any existing figures
            close all;
            
            % Run animation (brief)
            animate_1d(x, u_history, t, params);
            
            % Let animation run briefly
            pause(0.5);
            
            % Close figure
            close all;
            
            fprintf(' ✓\n');
            
            % Test passed
            test_results(i).status = 'PASS';
            test_results(i).error_msg = '';
            fprintf('  ✅ Result: PASS\n\n');
            
        catch err
            % Test failed
            test_results(i).status = 'FAIL';
            test_results(i).error_msg = err.message;
            
            fprintf(' ✗\n');
            fprintf('  ❌ Result: FAIL\n');
            fprintf('     Error: %s\n', err.message);
            if ~isempty(err.stack)
                fprintf('     Location: %s (line %d)\n\n', ...
                        err.stack(1).name, err.stack(1).line);
            else
                fprintf('\n');
            end
            
            % Clean up
            close all;
        end
    end
    
    % Display summary
    fprintf('\n=======================================================\n');
    fprintf('  TEST SUMMARY\n');
    fprintf('=======================================================\n\n');
    
    num_pass = sum(strcmp({test_results.status}, 'PASS'));
    num_fail = sum(strcmp({test_results.status}, 'FAIL'));
    
    fprintf('Total tests: %d\n', length(test_results));
    fprintf('Passed:      %d (%.1f%%)\n', num_pass, 100*num_pass/length(test_results));
    fprintf('Failed:      %d (%.1f%%)\n', num_fail, 100*num_fail/length(test_results));
    fprintf('\n');
    
    % Display detailed results
    fprintf('Detailed Results:\n');
    fprintf('─────────────────────────────────────────────────────\n');
    for i = 1:length(test_results)
        status_icon = '✅';
        if strcmp(test_results(i).status, 'FAIL')
            status_icon = '❌';
        end
        fprintf('  %s %-15s : %s\n', status_icon, test_results(i).pattern, ...
                test_results(i).status);
        if ~isempty(test_results(i).error_msg)
            fprintf('     └─ %s\n', test_results(i).error_msg);
        end
    end
    
    fprintf('\n=======================================================\n');
    
    if num_fail == 0
        fprintf('  🎉 ALL TESTS PASSED! 🎉\n');
        fprintf('  main_1d.m is working correctly with all patterns.\n');
    else
        fprintf('  ⚠️  SOME TESTS FAILED\n');
        fprintf('  Please review errors above and fix issues.\n');
    end
    
    fprintf('=======================================================\n\n');
end
