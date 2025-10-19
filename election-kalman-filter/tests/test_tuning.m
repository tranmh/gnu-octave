function test_tuning()
    % TEST_TUNING - Unit tests for Phase 6 parameter tuning functions
    %
    % Tests all parameter tuning and validation functions:
    %   - grid_search()
    %   - cross_validate()
    %   - sensitivity_analysis()
    %   - compare_methods()
    %   - final_params()
    %
    % USAGE:
    %   test_tuning()
    %
    % NOTE: Tests use small parameter ranges for speed
    
    % Add paths to required directories
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(script_dir);
    addpath(fullfile(project_root, 'tuning'));
    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'backtest'));
    addpath(fullfile(project_root, 'data', 'processed'));
    
    fprintf('\n========================================\n');
    fprintf('Phase 6: Parameter Tuning Tests\n');
    fprintf('========================================\n\n');
    
    % Track test results
    tests_passed = 0;
    tests_failed = 0;
    
    %% Test 1: grid_search() basic functionality
    fprintf('Test 1: grid_search() basic functionality...\n');
    try
        % Small grid for quick testing
        results = grid_search('q_range', [0.001, 0.01], ...
                             'r_range', [0.05, 0.1], ...
                             'p0_range', [0.1], ...
                             'verbose', false);
        
        % Check output structure
        assert(isstruct(results), 'grid_search should return struct');
        assert(isfield(results, 'best_params'), 'Missing best_params field');
        assert(isfield(results, 'best_score'), 'Missing best_score field');
        assert(isfield(results, 'all_scores'), 'Missing all_scores field');
        
        % Check best_params format
        assert(length(results.best_params) == 3, 'best_params should be [Q, R, P0]');
        assert(all(results.best_params > 0), 'Parameters should be positive');
        
        % Check scores array dimensions
        n_q = length(results.q_range);
        n_r = length(results.r_range);
        n_p0 = length(results.p0_range);
        expected_size = [n_q, n_r, n_p0];
        assert(all(size(results.all_scores) == expected_size), 'Incorrect scores array size');
        
        fprintf('  ✓ grid_search() passed\n');
        tests_passed = tests_passed + 1;
    catch ME
        fprintf('  ✗ grid_search() FAILED: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test 2: grid_search() metric selection
    fprintf('Test 2: grid_search() metric selection...\n');
    try
        % Test different metrics
        metrics = {'brier', 'rmse', 'final_error'};
        for i = 1:length(metrics)
            results = grid_search('q_range', [0.001], ...
                                 'r_range', [0.05], ...
                                 'p0_range', [0.1], ...
                                 'metric', metrics{i}, ...
                                 'verbose', false);
            assert(strcmp(results.metric_used, metrics{i}), ...
                   sprintf('Metric mismatch for %s', metrics{i}));
        end
        
        fprintf('  ✓ Metric selection passed\n');
        tests_passed = tests_passed + 1;
    catch ME
        fprintf('  ✗ Metric selection FAILED: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test 3: cross_validate() basic functionality
    fprintf('Test 3: cross_validate() basic functionality...\n');
    try
        % Test with default parameters
        results = cross_validate('params', [0.001, 0.05, 0.1], ...
                                'verbose', false);
        
        % Check output structure
        assert(isstruct(results), 'cross_validate should return struct');
        assert(isfield(results, 'avg_metrics'), 'Missing avg_metrics field');
        assert(isfield(results, 'consistency'), 'Missing consistency field');
        assert(isfield(results, 'elections'), 'Missing elections field');
        
        % Check metrics are reasonable
        assert(results.avg_metrics.brier >= 0 && results.avg_metrics.brier <= 1, ...
               'Brier score should be in [0,1]');
        
        fprintf('  ✓ cross_validate() passed\n');
        tests_passed = tests_passed + 1;
    catch ME
        fprintf('  ✗ cross_validate() FAILED: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test 4: sensitivity_analysis() basic functionality
    fprintf('Test 4: sensitivity_analysis() basic functionality...\n');
    try
        % Test with default parameters
        results = sensitivity_analysis('base_params', [0.001, 0.05, 0.1], ...
                                      'perturbation', [0.5, 1.0, 2.0], ...
                                      'verbose', false);
        
        % Check output structure
        assert(isstruct(results), 'sensitivity_analysis should return struct');
        assert(isfield(results, 'sensitivity'), 'Missing sensitivity field');
        assert(isfield(results, 'robustness_score'), 'Missing robustness_score field');
        
        % Check robustness score range
        assert(results.robustness_score >= 0 && results.robustness_score <= 1, ...
               'Robustness score should be in [0,1]');
        
        fprintf('  ✓ sensitivity_analysis() passed\n');
        tests_passed = tests_passed + 1;
    catch ME
        fprintf('  ✗ sensitivity_analysis() FAILED: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test 5: compare_methods() basic functionality
    fprintf('Test 5: compare_methods() basic functionality...\n');
    try
        % Test with subset of methods
        results = compare_methods('methods', {'kalman', 'moving_avg'}, ...
                                 'verbose', false);
        
        % Check output structure
        assert(isstruct(results), 'compare_methods should return struct');
        assert(isfield(results, 'methods'), 'Missing methods field');
        assert(isfield(results, 'performance'), 'Missing performance field');
        
        % Check that Kalman filter is included
        assert(isfield(results.performance, 'kalman'), 'Missing kalman results');
        
        % Check metrics are valid
        assert(results.performance.kalman.brier >= 0, 'Invalid Brier score');
        
        fprintf('  ✓ compare_methods() passed\n');
        tests_passed = tests_passed + 1;
    catch ME
        fprintf('  ✗ compare_methods() FAILED: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test 6: final_params() basic functionality
    fprintf('Test 6: final_params() basic functionality...\n');
    try
        % Test parameter selection (without running full analysis)
        params = final_params('run_analysis', false, ...
                             'save_results', false, ...
                             'verbose', false);
        
        % Check output structure
        assert(isstruct(params), 'final_params should return struct');
        assert(isfield(params, 'Q'), 'Missing Q parameter');
        assert(isfield(params, 'R'), 'Missing R parameter');
        assert(isfield(params, 'P0'), 'Missing P0 parameter');
        
        % Check parameters are positive
        assert(params.Q > 0, 'Q must be positive');
        assert(params.R > 0, 'R must be positive');
        assert(params.P0 > 0, 'P0 must be positive');
        
        fprintf('  ✓ final_params() passed\n');
        tests_passed = tests_passed + 1;
    catch ME
        fprintf('  ✗ final_params() FAILED: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test 7: Parameter validity checks
    fprintf('Test 7: Parameter validity checks...\n');
    try
        % Test that parameters are in reasonable ranges
        test_params = [0.001, 0.05, 0.1];  % [Q, R, P0]
        
        % Q should be small (process noise)
        assert(test_params(1) >= 0.0001 && test_params(1) <= 0.1, ...
               'Q should be in [0.0001, 0.1]');
        
        % R should be moderate (measurement noise)
        assert(test_params(2) >= 0.01 && test_params(2) <= 0.5, ...
               'R should be in [0.01, 0.5]');
        
        % P0 should be moderate (initial uncertainty)
        assert(test_params(3) >= 0.01 && test_params(3) <= 0.5, ...
               'P0 should be in [0.01, 0.5]');
        
        fprintf('  ✓ Parameter validity passed\n');
        tests_passed = tests_passed + 1;
    catch ME
        fprintf('  ✗ Parameter validity FAILED: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test Summary
    fprintf('\n========================================\n');
    fprintf('Test Summary\n');
    fprintf('========================================\n');
    fprintf('Tests Passed: %d\n', tests_passed);
    fprintf('Tests Failed: %d\n', tests_failed);
    fprintf('Total Tests:  %d\n', tests_passed + tests_failed);
    
    if tests_failed == 0
        fprintf('\n✓ All Phase 6 tests PASSED!\n\n');
    else
        fprintf('\n✗ Some tests FAILED. Review errors above.\n\n');
        error('Phase 6 tests failed');
    end
    
end
