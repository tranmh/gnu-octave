% test_phase5.m
% Comprehensive test suite for Phase 5: Polish & Testing
%
% Tests:
%   1. Parameter validation (valid and invalid inputs)
%   2. Stability calculations (1D and 2D)
%   3. Main scripts (integration test)
%   4. Conservation properties
%   5. Convergence verification
%   6. Performance benchmarks
%
% USAGE:
%   Run from heat-diffusion directory:
%   >> cd('C:/Users/tranm/work/gnu-octave/heat-diffusion')
%   >> test_phase5

function test_phase5()
    
    fprintf('\n========================================\n');
    fprintf('PHASE 5 COMPREHENSIVE TEST SUITE\n');
    fprintf('========================================\n\n');
    
    % Add paths
    setup_paths();
    
    % Track test results
    tests_passed = 0;
    tests_failed = 0;
    
    % ====================================================================
    % TEST 1: Parameter Validation
    % ====================================================================
    
    fprintf('TEST 1: Parameter Validation\n');
    fprintf('------------------------------\n');
    
    try
        % Test 1a: Valid 1D parameters
        params_1d = struct('alpha', 0.01, 'L', 1.0, 'nx', 100, ...
                           'dt', 0.001, 't_final', 1.0, 'T_boundary', 0.0);
        [valid, warns] = validate_parameters(params_1d, '1d');
        assert(valid == true, 'Valid 1D parameters rejected');
        fprintf('  ✓ Valid 1D parameters accepted\n');
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    try
        % Test 1b: Valid 2D parameters
        params_2d = struct('alpha', 0.01, 'Lx', 1.0, 'Ly', 1.0, ...
                           'nx', 50, 'ny', 50, 'dt', 0.001, ...
                           't_final', 1.0, 'T_boundary', 0.0);
        [valid, warns] = validate_parameters(params_2d, '2d');
        assert(valid == true, 'Valid 2D parameters rejected');
        fprintf('  ✓ Valid 2D parameters accepted\n');
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    try
        % Test 1c: Invalid alpha (negative)
        params_bad = params_1d;
        params_bad.alpha = -0.01;
        [valid, warns] = validate_parameters(params_bad, '1d');
        assert(valid == false, 'Negative alpha not rejected');
        fprintf('  ✓ Negative alpha correctly rejected\n');
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    try
        % Test 1d: Too few grid points
        params_bad = params_1d;
        params_bad.nx = 5;
        [valid, warns] = validate_parameters(params_bad, '1d');
        assert(valid == false, 'Too few grid points not rejected');
        fprintf('  ✓ Insufficient grid resolution rejected\n');
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    fprintf('\n');
    
    % ====================================================================
    % TEST 2: Stability Calculations
    % ====================================================================
    
    fprintf('TEST 2: Stability Calculations\n');
    fprintf('--------------------------------\n');
    
    try
        % Test 2a: 1D stability with low CFL
        params_1d.dt = 0.0001;  % Small time step
        stability = calculate_stability(params_1d, '1d');
        assert(stability.cfl < 1.0, 'CFL calculation error');
        assert(isfield(stability, 'dt_optimal'), 'Missing dt_optimal');
        fprintf('  ✓ 1D stability calculated (CFL = %.4f)\n', stability.cfl);
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    try
        % Test 2b: 2D stability
        stability = calculate_stability(params_2d, '2d');
        assert(isfield(stability, 'cfl'), 'Missing CFL number');
        assert(isfield(stability, 'status'), 'Missing stability status');
        fprintf('  ✓ 2D stability calculated (CFL = %.4f)\n', stability.cfl);
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    try
        % Test 2c: High CFL number warning
        params_high_cfl = params_1d;
        params_high_cfl.dt = 0.1;  % Large time step
        stability = calculate_stability(params_high_cfl, '1d');
        assert(stability.cfl > 5.0, 'High CFL not detected');
        assert(isfield(stability, 'recommendation'), 'No recommendation for high CFL');
        fprintf('  ✓ High CFL warning generated correctly\n');
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    fprintf('\n');
    
    % ====================================================================
    % TEST 3: Conservation Properties
    % ====================================================================
    
    fprintf('TEST 3: Conservation Properties\n');
    fprintf('---------------------------------\n');
    
    try
        % Test 3a: 1D heat conservation (insulated boundaries would conserve)
        % With Dirichlet BC, heat should decay to boundary values
        params_test = struct('alpha', 0.01, 'L', 1.0, 'nx', 50, ...
                             'dt', 0.001, 't_final', 0.1, 'T_boundary', 0.0);
        
        % Create initial Gaussian
        u0 = get_pattern_1d('gaussian', params_test.nx, params_test.L);
        initial_energy = sum(u0);
        
        % Solve
        [u_hist, x, t] = heat_solver_1d(u0, params_test);
        final_energy = sum(u_hist(:, end));
        
        % Energy should decrease (heat flows out through boundaries)
        assert(final_energy < initial_energy, 'Heat not dissipating');
        fprintf('  ✓ 1D heat dissipation verified (%.2f%% decrease)\n', ...
                100 * (1 - final_energy/initial_energy));
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    try
        % Test 3b: 2D heat conservation
        params_test_2d = struct('alpha', 0.01, 'Lx', 1.0, 'Ly', 1.0, ...
                                'nx', 30, 'ny', 30, 'dt', 0.001, ...
                                't_final', 0.05, 'T_boundary', 0.0);
        
        u0 = get_pattern_2d('center_hot', params_test_2d.nx, params_test_2d.ny, ...
                            params_test_2d.Lx, params_test_2d.Ly);
        initial_energy = sum(u0(:));
        
        [u_hist, x, y, t] = heat_solver_2d(u0, params_test_2d);
        final_energy = sum(u_hist(:, :, end), 'all');
        
        assert(final_energy < initial_energy, '2D heat not dissipating');
        fprintf('  ✓ 2D heat dissipation verified (%.2f%% decrease)\n', ...
                100 * (1 - final_energy/initial_energy));
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    fprintf('\n');
    
    % ====================================================================
    % TEST 4: Maximum Principle
    % ====================================================================
    
    fprintf('TEST 4: Maximum Principle\n');
    fprintf('--------------------------\n');
    
    try
        % Test 4a: No new extrema should be created
        % Maximum temperature should not exceed initial maximum
        params_test = struct('alpha', 0.01, 'L', 1.0, 'nx', 50, ...
                             'dt', 0.001, 't_final', 0.1, 'T_boundary', 0.0);
        
        u0 = get_pattern_1d('gaussian', params_test.nx, params_test.L);
        max_initial = max(u0);
        
        [u_hist, x, t] = heat_solver_1d(u0, params_test);
        max_final = max(u_hist(:));
        
        assert(max_final <= max_initial * 1.001, 'Maximum principle violated');
        fprintf('  ✓ Maximum principle verified (max: %.4f → %.4f)\n', ...
                max_initial, max_final);
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    fprintf('\n');
    
    % ====================================================================
    % TEST 5: Convergence with Grid Refinement
    % ====================================================================
    
    fprintf('TEST 5: Grid Convergence\n');
    fprintf('-------------------------\n');
    
    try
        % Test 5a: Solution should converge with finer grids
        params_coarse = struct('alpha', 0.01, 'L', 1.0, 'nx', 20, ...
                               'dt', 0.001, 't_final', 0.05, 'T_boundary', 0.0);
        params_fine = params_coarse;
        params_fine.nx = 40;
        
        u0_coarse = get_pattern_1d('gaussian', params_coarse.nx, params_coarse.L);
        u0_fine = get_pattern_1d('gaussian', params_fine.nx, params_fine.L);
        
        [u_coarse, ~, ~] = heat_solver_1d(u0_coarse, params_coarse);
        [u_fine, ~, ~] = heat_solver_1d(u0_fine, params_fine);
        
        % Compare center values at final time
        center_coarse = u_coarse(round(end/2), end);
        center_fine = u_fine(round(end/2), end);
        rel_diff = abs(center_coarse - center_fine) / max(abs(center_fine), 1e-10);
        
        assert(rel_diff < 0.1, 'Solutions diverging with refinement');
        fprintf('  ✓ Grid convergence verified (relative diff: %.2f%%)\n', rel_diff * 100);
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    fprintf('\n');
    
    % ====================================================================
    % TEST 6: Performance Benchmarks
    % ====================================================================
    
    fprintf('TEST 6: Performance Benchmarks\n');
    fprintf('--------------------------------\n');
    
    try
        % Test 6a: 1D performance
        params_perf = struct('alpha', 0.01, 'L', 1.0, 'nx', 100, ...
                             'dt', 0.001, 't_final', 0.1, 'T_boundary', 0.0);
        u0 = get_pattern_1d('gaussian', params_perf.nx, params_perf.L);
        
        tic;
        [u_hist, x, t] = heat_solver_1d(u0, params_perf);
        time_1d = toc;
        
        fprintf('  ✓ 1D solver (nx=%d, %d steps): %.3f seconds\n', ...
                params_perf.nx, length(t), time_1d);
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    try
        % Test 6b: 2D performance
        params_perf_2d = struct('alpha', 0.01, 'Lx', 1.0, 'Ly', 1.0, ...
                                'nx', 40, 'ny', 40, 'dt', 0.001, ...
                                't_final', 0.05, 'T_boundary', 0.0);
        u0 = get_pattern_2d('center_hot', params_perf_2d.nx, params_perf_2d.ny, ...
                            params_perf_2d.Lx, params_perf_2d.Ly);
        
        tic;
        [u_hist, x, y, t] = heat_solver_2d(u0, params_perf_2d);
        time_2d = toc;
        
        fprintf('  ✓ 2D solver (%dx%d, %d steps): %.3f seconds\n', ...
                params_perf_2d.nx, params_perf_2d.ny, length(t), time_2d);
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    fprintf('\n');
    
    % ====================================================================
    % TEST 7: Pattern Library Integration
    % ====================================================================
    
    fprintf('TEST 7: Pattern Library Integration\n');
    fprintf('-------------------------------------\n');
    
    try
        % Test all 1D patterns
        patterns_1d = {'gaussian', 'step', 'double_peak', 'sine', 'random'};
        for i = 1:length(patterns_1d)
            u0 = get_pattern_1d(patterns_1d{i}, 50, 1.0);
            assert(length(u0) == 50, sprintf('Wrong size for pattern %s', patterns_1d{i}));
        end
        fprintf('  ✓ All 1D patterns generate correctly\n');
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    try
        % Test all 2D patterns
        patterns_2d = {'center_hot', 'corner_hot', 'gaussian', 'ring', ...
                       'checkerboard', 'radial', 'random'};
        for i = 1:length(patterns_2d)
            u0 = get_pattern_2d(patterns_2d{i}, 30, 30, 1.0, 1.0);
            assert(all(size(u0) == [30, 30]), ...
                   sprintf('Wrong size for pattern %s', patterns_2d{i}));
        end
        fprintf('  ✓ All 2D patterns generate correctly\n');
        tests_passed = tests_passed + 1;
    catch e
        fprintf('  ✗ FAILED: %s\n', e.message);
        tests_failed = tests_failed + 1;
    end
    
    fprintf('\n');
    
    % ====================================================================
    % FINAL SUMMARY
    % ====================================================================
    
    fprintf('\n========================================\n');
    fprintf('TEST SUMMARY\n');
    fprintf('========================================\n');
    fprintf('Tests passed: %d\n', tests_passed);
    fprintf('Tests failed: %d\n', tests_failed);
    fprintf('Total tests:  %d\n', tests_passed + tests_failed);
    
    if tests_failed == 0
        fprintf('\n✓ ALL TESTS PASSED!\n');
        fprintf('Phase 5 implementation is complete and verified.\n');
    else
        fprintf('\n✗ Some tests failed. Please review.\n');
    end
    
    fprintf('========================================\n\n');
    
end

% ====================================================================
% HELPER FUNCTION: Setup Paths
% ====================================================================

function setup_paths()
    % Add all required directories to the path
    script_dir = fileparts(mfilename('fullpath'));
    project_dir = fileparts(script_dir);  % Go up one level
    
    addpath(fullfile(project_dir, 'core'));
    addpath(fullfile(project_dir, 'display'));
    addpath(fullfile(project_dir, 'interaction'));
    addpath(fullfile(project_dir, 'patterns'));
    addpath(fullfile(project_dir, 'utils'));
end
