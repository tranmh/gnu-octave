#!/usr/bin/env octave
% run_all_tests.m
% Master test script - runs all tests for heat diffusion project
% Can be run from command line or Octave prompt

function run_all_tests()
    fprintf('\n');
    fprintf('╔═══════════════════════════════════════════════════════╗\n');
    fprintf('║     HEAT DIFFUSION - COMPREHENSIVE TEST SUITE        ║\n');
    fprintf('╚═══════════════════════════════════════════════════════╝\n');
    fprintf('\n');
    
    % Setup paths
    script_dir = fileparts(mfilename('fullpath'));
    cd(script_dir);
    
    % Add all required paths
    addpath(fullfile(script_dir, 'core'));
    addpath(fullfile(script_dir, 'display'));
    addpath(fullfile(script_dir, 'interaction'));
    addpath(fullfile(script_dir, 'patterns'));
    addpath(fullfile(script_dir, 'utils'));
    addpath(fullfile(script_dir, 'tests'));
    
    test_results = struct();
    test_count = 0;
    
    % ===================================================================
    % TEST 1: Quick Fix Verification
    % ===================================================================
    test_count = test_count + 1;
    fprintf('\n');
    fprintf('─────────────────────────────────────────────────────────\n');
    fprintf('TEST %d: Quick Fix Verification\n', test_count);
    fprintf('─────────────────────────────────────────────────────────\n');
    
    try
        quick_test_fixes();
        test_results(test_count).name = 'Quick Fix Verification';
        test_results(test_count).status = 'PASS';
        test_results(test_count).time = toc;
    catch err
        test_results(test_count).name = 'Quick Fix Verification';
        test_results(test_count).status = 'FAIL';
        test_results(test_count).error = err.message;
        fprintf('❌ FAILED: %s\n', err.message);
    end
    
    % ===================================================================
    % TEST 2: Automated Pattern Tests (1D)
    % ===================================================================
    test_count = test_count + 1;
    fprintf('\n');
    fprintf('─────────────────────────────────────────────────────────\n');
    fprintf('TEST %d: All 1D Patterns\n', test_count);
    fprintf('─────────────────────────────────────────────────────────\n');
    
    try
        tic;
        test_main_1d_automated();
        test_results(test_count).name = 'All 1D Patterns';
        test_results(test_count).status = 'PASS';
        test_results(test_count).time = toc;
    catch err
        test_results(test_count).name = 'All 1D Patterns';
        test_results(test_count).status = 'FAIL';
        test_results(test_count).error = err.message;
        fprintf('❌ FAILED: %s\n', err.message);
    end
    
    % ===================================================================
    % TEST 3: Core Solvers
    % ===================================================================
    test_count = test_count + 1;
    fprintf('\n');
    fprintf('─────────────────────────────────────────────────────────\n');
    fprintf('TEST %d: Core PDE Solvers\n', test_count);
    fprintf('─────────────────────────────────────────────────────────\n');
    
    try
        tic;
        % Test 1D solver
        fprintf('  Testing heat_solver_1d...');
        u0 = ones(50, 1) * 100;
        [u, x, t] = heat_solver_1d(u0, 0.01, 1.0, 0, 50, 0.001, 0.01);
        assert(size(u, 1) == 50);
        fprintf(' ✓\n');
        
        % Test 2D solver  
        fprintf('  Testing heat_solver_2d...');
        u0 = ones(20, 20) * 100;
        [u, x, y, t] = heat_solver_2d(u0, 0.01, 1.0, 1.0, 0, 20, 20, 0.001, 0.01);
        assert(size(u, 1) == 20 && size(u, 2) == 20);
        fprintf(' ✓\n');
        
        test_results(test_count).name = 'Core PDE Solvers';
        test_results(test_count).status = 'PASS';
        test_results(test_count).time = toc;
    catch err
        test_results(test_count).name = 'Core PDE Solvers';
        test_results(test_count).status = 'FAIL';
        test_results(test_count).error = err.message;
        fprintf(' ✗\n❌ FAILED: %s\n', err.message);
    end
    
    % ===================================================================
    % TEST 4: Pattern Generation
    % ===================================================================
    test_count = test_count + 1;
    fprintf('\n');
    fprintf('─────────────────────────────────────────────────────────\n');
    fprintf('TEST %d: Pattern Generation\n', test_count);
    fprintf('─────────────────────────────────────────────────────────\n');
    
    try
        tic;
        patterns_1d = {'gaussian', 'step', 'double_peak', 'sine', 'random'};
        patterns_2d = {'center_hot', 'corner_hot', 'gaussian', 'ring', ...
                      'checkerboard', 'radial', 'random'};
        
        fprintf('  Testing 1D patterns...');
        for i = 1:length(patterns_1d)
            u0 = get_pattern_1d(patterns_1d{i}, 50);
            assert(length(u0) == 50);
        end
        fprintf(' ✓\n');
        
        fprintf('  Testing 2D patterns...');
        for i = 1:length(patterns_2d)
            u0 = get_pattern_2d(patterns_2d{i}, 20, 20);
            assert(size(u0, 1) == 20 && size(u0, 2) == 20);
        end
        fprintf(' ✓\n');
        
        test_results(test_count).name = 'Pattern Generation';
        test_results(test_count).status = 'PASS';
        test_results(test_count).time = toc;
    catch err
        test_results(test_count).name = 'Pattern Generation';
        test_results(test_count).status = 'FAIL';
        test_results(test_count).error = err.message;
        fprintf(' ✗\n❌ FAILED: %s\n', err.message);
    end
    
    % ===================================================================
    % TEST 5: Utility Functions
    % ===================================================================
    test_count = test_count + 1;
    fprintf('\n');
    fprintf('─────────────────────────────────────────────────────────\n');
    fprintf('TEST %d: Utility Functions\n', test_count);
    fprintf('─────────────────────────────────────────────────────────\n');
    
    try
        tic;
        % Test parameter validation
        fprintf('  Testing validate_parameters...');
        params = struct('alpha', 0.01, 'L', 1.0, 'T_boundary', 0, ...
                       'nx', 50, 'dt', 0.001, 't_final', 1.0);
        [valid, warns] = validate_parameters(params, '1d');
        assert(valid == true);
        fprintf(' ✓\n');
        
        % Test stability calculation
        fprintf('  Testing calculate_stability...');
        stability = calculate_stability(params, '1d');
        assert(isfield(stability, 'cfl'));
        assert(isfield(stability, 'status'));
        fprintf(' ✓\n');
        
        test_results(test_count).name = 'Utility Functions';
        test_results(test_count).status = 'PASS';
        test_results(test_count).time = toc;
    catch err
        test_results(test_count).name = 'Utility Functions';
        test_results(test_count).status = 'FAIL';
        test_results(test_count).error = err.message;
        fprintf(' ✗\n❌ FAILED: %s\n', err.message);
    end
    
    % ===================================================================
    % FINAL SUMMARY
    % ===================================================================
    fprintf('\n\n');
    fprintf('╔═══════════════════════════════════════════════════════╗\n');
    fprintf('║                   TEST SUMMARY                        ║\n');
    fprintf('╚═══════════════════════════════════════════════════════╝\n');
    fprintf('\n');
    
    % Calculate statistics
    num_pass = sum(strcmp({test_results.status}, 'PASS'));
    num_fail = sum(strcmp({test_results.status}, 'FAIL'));
    total = length(test_results);
    
    fprintf('Total Tests:     %d\n', total);
    fprintf('Passed:          %d (%.1f%%)\n', num_pass, 100*num_pass/total);
    fprintf('Failed:          %d (%.1f%%)\n', num_fail, 100*num_fail/total);
    fprintf('\n');
    
    % Detailed results
    fprintf('Detailed Results:\n');
    fprintf('─────────────────────────────────────────────────────────\n');
    for i = 1:length(test_results)
        status_icon = '✅';
        time_str = '';
        if strcmp(test_results(i).status, 'FAIL')
            status_icon = '❌';
        elseif isfield(test_results(i), 'time')
            time_str = sprintf(' (%.2fs)', test_results(i).time);
        end
        
        fprintf('%s %-30s : %s%s\n', status_icon, test_results(i).name, ...
                test_results(i).status, time_str);
        
        if strcmp(test_results(i).status, 'FAIL') && isfield(test_results(i), 'error')
            fprintf('   └─ %s\n', test_results(i).error);
        end
    end
    
    fprintf('\n');
    fprintf('═══════════════════════════════════════════════════════\n');
    
    if num_fail == 0
        fprintf('  🎉 ALL TESTS PASSED! 🎉\n');
        fprintf('  The heat diffusion simulator is working correctly.\n');
        fprintf('  Ready to run main_1d and main_2d!\n');
    else
        fprintf('  ⚠️  SOME TESTS FAILED\n');
        fprintf('  Please review the errors above.\n');
        fprintf('  Check FIX_REPORT_MAIN_CRASHES.md for solutions.\n');
    end
    
    fprintf('═══════════════════════════════════════════════════════\n');
    fprintf('\n');
    
    % Close any open figures
    close all;
end

% Run tests if script is executed directly
if ~exist('is_octave_function_call', 'var')
    run_all_tests();
end
