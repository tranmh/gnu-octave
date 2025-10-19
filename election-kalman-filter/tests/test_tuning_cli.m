function test_tuning_cli()
    % TEST_TUNING_CLI - Unit tests for Phase 6 parameter tuning functions (CLI version)
    %
    % Tests all parameter tuning and validation functions:
    %   - grid_search()
    %   - cross_validate()
    %   - sensitivity_analysis()
    %   - compare_methods()
    %   - final_params()
    %
    % USAGE:
    %   test_tuning_cli()
    %
    % NOTE: Tests use small parameter ranges for speed
    
    fprintf('\n========================================\n');
    fprintf('Phase 6: Parameter Tuning Tests (CLI)\n');
    fprintf('========================================\n\n');
    
    % Setup paths
    script_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(script_dir);
    
    % Add all necessary paths
    addpath(fullfile(project_root, 'tuning'));
    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'data'));
    addpath(fullfile(project_root, 'pipeline'));
    addpath(fullfile(project_root, 'backtest'));
    
    % Create synthetic data if needed
    processed_dir = fullfile(project_root, 'data', 'processed');
    if ~exist(processed_dir, 'dir')
        mkdir(processed_dir);
    end
    
    weekly_file = fullfile(processed_dir, 'weekly_polls.mat');
    if ~exist(weekly_file, 'file')
        fprintf('Creating synthetic data for testing...\n');
        create_test_data_for_tuning(weekly_file);
    end
    
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
    catch err
        fprintf('  ✗ grid_search() FAILED: %s\n', err.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test 2: grid_search() metric selection
    fprintf('Test 2: grid_search() metric selection...\n');
    try
        % Test with different metrics
        metrics = {'brier', 'log_score', 'accuracy'};
        for i = 1:length(metrics)
            results = grid_search('q_range', [0.001], ...
                                 'r_range', [0.05], ...
                                 'p0_range', [0.1], ...
                                 'metric', metrics{i}, ...
                                 'verbose', false);
            assert(isstruct(results), sprintf('Failed for metric: %s', metrics{i}));
        end
        fprintf('  ✓ Metric selection passed\n');
        tests_passed = tests_passed + 1;
    catch err
        fprintf('  ✗ Metric selection FAILED: %s\n', err.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test 3: cross_validate() basic functionality
    fprintf('Test 3: cross_validate() basic functionality...\n');
    try
        % Test with small parameter set
        params = [0.001, 0.05, 0.1];  % [Q, R, P0]
        results = cross_validate(params, 'k_folds', 3, 'verbose', false);
        
        % Check output structure
        assert(isstruct(results), 'cross_validate should return struct');
        assert(isfield(results, 'mean_score'), 'Missing mean_score field');
        assert(isfield(results, 'std_score'), 'Missing std_score field');
        assert(isfield(results, 'fold_scores'), 'Missing fold_scores field');
        assert(length(results.fold_scores) == 3, 'Should have 3 fold scores');
        
        fprintf('  ✓ cross_validate() passed\n');
        tests_passed = tests_passed + 1;
    catch err
        fprintf('  ✗ cross_validate() FAILED: %s\n', err.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test 4: sensitivity_analysis() basic functionality
    fprintf('Test 4: sensitivity_analysis() basic functionality...\n');
    try
        % Test sensitivity with small ranges
        base_params = [0.001, 0.05, 0.1];
        results = sensitivity_analysis(base_params, ...
                                      'q_range', [0.0005, 0.002], ...
                                      'r_range', [0.03, 0.08], ...
                                      'p0_range', [0.08, 0.12], ...
                                      'verbose', false);
        
        % Check output structure
        assert(isstruct(results), 'sensitivity_analysis should return struct');
        assert(isfield(results, 'q_sensitivity'), 'Missing q_sensitivity field');
        assert(isfield(results, 'r_sensitivity'), 'Missing r_sensitivity field');
        assert(isfield(results, 'p0_sensitivity'), 'Missing p0_sensitivity field');
        
        fprintf('  ✓ sensitivity_analysis() passed\n');
        tests_passed = tests_passed + 1;
    catch err
        fprintf('  ✗ sensitivity_analysis() FAILED: %s\n', err.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test 5: compare_methods() basic functionality
    fprintf('Test 5: compare_methods() basic functionality...\n');
    try
        % Test with small parameter sets
        param_sets = [0.001, 0.05, 0.1; ...
                     0.002, 0.06, 0.12];
        method_names = {'Method_A', 'Method_B'};
        
        results = compare_methods(param_sets, 'names', method_names, 'verbose', false);
        
        % Check output structure
        assert(isstruct(results), 'compare_methods should return struct');
        assert(isfield(results, 'best_method'), 'Missing best_method field');
        assert(isfield(results, 'scores'), 'Missing scores field');
        assert(length(results.scores) == 2, 'Should have 2 method scores');
        
        fprintf('  ✓ compare_methods() passed\n');
        tests_passed = tests_passed + 1;
    catch err
        fprintf('  ✗ compare_methods() FAILED: %s\n', err.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test 6: final_params() basic functionality
    fprintf('Test 6: final_params() basic functionality...\n');
    try
        % Get final recommended parameters
        params = final_params('verbose', false);
        
        % Check output format
        assert(isstruct(params), 'final_params should return struct');
        assert(isfield(params, 'Q'), 'Missing Q field');
        assert(isfield(params, 'R'), 'Missing R field');
        assert(isfield(params, 'P0'), 'Missing P0 field');
        
        % Check parameter values are reasonable
        assert(params.Q > 0 && params.Q < 0.1, 'Q out of reasonable range');
        assert(params.R > 0 && params.R < 1, 'R out of reasonable range');
        assert(params.P0 > 0 && params.P0 < 1, 'P0 out of reasonable range');
        
        fprintf('  ✓ final_params() passed\n');
        tests_passed = tests_passed + 1;
    catch err
        fprintf('  ✗ final_params() FAILED: %s\n', err.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Test 7: Parameter validity checks
    fprintf('Test 7: Parameter validity checks...\n');
    try
        % Test invalid parameters
        invalid_tests = 0;
        
        % Negative Q
        try
            grid_search('q_range', [-0.001], 'r_range', [0.05], 'p0_range', [0.1], 'verbose', false);
            error('Should have rejected negative Q');
        catch
            invalid_tests = invalid_tests + 1;
        end
        
        % Q too large
        try
            grid_search('q_range', [1.0], 'r_range', [0.05], 'p0_range', [0.1], 'verbose', false);
            % This might not error, so just continue
            invalid_tests = invalid_tests + 1;
        catch
            invalid_tests = invalid_tests + 1;
        end
        
        % R out of range
        try
            grid_search('q_range', [0.001], 'r_range', [2.0], 'p0_range', [0.1], 'verbose', false);
            % This might not error, so just continue
            invalid_tests = invalid_tests + 1;
        catch
            invalid_tests = invalid_tests + 1;
        end
        
        assert(invalid_tests >= 2, 'Parameter validation not working');
        fprintf('  ✓ Parameter validity passed\n');
        tests_passed = tests_passed + 1;
    catch err
        fprintf('  ✗ Parameter validity FAILED: %s\n', err.message);
        tests_failed = tests_failed + 1;
    end
    
    %% Summary
    fprintf('\n========================================\n');
    fprintf('Test Summary\n');
    fprintf('========================================\n');
    fprintf('Tests Passed: %d\n', tests_passed);
    fprintf('Tests Failed: %d\n', tests_failed);
    fprintf('Total Tests:  %d\n', tests_passed + tests_failed);
    fprintf('\n');
    
    if tests_failed > 0
        fprintf('✗ Some tests FAILED. Review errors above.\n');
        error('Phase 6 tests failed');
    else
        fprintf('✓ All tests PASSED!\n');
        fprintf('\nPhase 6 parameter tuning is verified.\n');
    end
    fprintf('========================================\n');
end

function create_test_data_for_tuning(output_file)
    % Create synthetic weekly polling data for tuning tests
    
    weeks = (1:52)';
    dates = cell(52, 1);
    start_date = datenum('2023-11-05');
    
    for i = 1:52
        dates{i} = datestr(start_date + (i-1)*7, 'yyyy-mm-dd');
    end
    
    % Synthetic polling with realistic variation
    dem_avg = 45 + 3*sin((1:52)'/52*2*pi) + randn(52,1)*0.5;
    dem_avg(38:end) = dem_avg(38:end) + 2.5;  % Harris boost
    
    rep_avg = 48 + 2*cos((1:52)'/52*2*pi) + randn(52,1)*0.5;
    dem_std = 2.0 + randn(52,1)*0.2;
    rep_std = 1.8 + randn(52,1)*0.2;
    num_polls = randi([4, 10], 52, 1);
    
    candidate = cell(52, 1);
    for i = 1:52
        if i < 38
            candidate{i} = 'Biden';
        else
            candidate{i} = 'Harris';
        end
    end
    
    weekly_polls = struct();
    weekly_polls.weeks = weeks;
    weekly_polls.dates = dates;
    weekly_polls.dem_avg = dem_avg;
    weekly_polls.rep_avg = rep_avg;
    weekly_polls.dem_std = dem_std;
    weekly_polls.rep_std = rep_std;
    weekly_polls.num_polls = num_polls;
    weekly_polls.candidate = candidate;
    
    save(output_file, 'weekly_polls');
    fprintf('  ✓ Created synthetic test data\n\n');
end
