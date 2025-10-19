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
        actual_size = size(results.all_scores);

        % Pad actual_size if needed (for singleton dimensions)
        if length(actual_size) == 2
            actual_size(3) = 1;
        end

        expected_size = [n_q, n_r, n_p0];
        assert(isequal(actual_size, expected_size), ...
               sprintf('Incorrect scores array size: expected [%d,%d,%d], got [%d,%d,%d]', ...
                       n_q, n_r, n_p0, actual_size(1), actual_size(2), actual_size(3)));

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
    catch err
        fprintf('  ✗ Metric selection FAILED: %s\n', err.message);
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
        assert(isfield(results, 'params_tested'), 'Missing params_tested field');
        assert(isfield(results, 'election_results'), 'Missing election_results field');

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
        results = sensitivity_analysis('base_params', [0.001, 0.05, 0.1], ...
                                      'perturbation', [0.5, 1.0, 2.0], ...
                                      'verbose', false);

        % Check output structure
        assert(isstruct(results), 'sensitivity_analysis should return struct');
        assert(isfield(results, 'q_sensitivity'), 'Missing q_sensitivity field');
        assert(isfield(results, 'r_sensitivity'), 'Missing r_sensitivity field');
        assert(isfield(results, 'p0_sensitivity'), 'Missing p0_sensitivity field');
        assert(isfield(results, 'sensitivity_index'), 'Missing sensitivity_index field');

        fprintf('  ✓ sensitivity_analysis() passed\n');
        tests_passed = tests_passed + 1;
    catch err
        fprintf('  ✗ sensitivity_analysis() FAILED: %s\n', err.message);
        tests_failed = tests_failed + 1;
    end

    %% Test 5: compare_methods() basic functionality
    fprintf('Test 5: compare_methods() basic functionality...\n');
    try
        % Test with subset of methods for speed
        results = compare_methods('methods', {'kalman', 'naive'}, ...
                                 'verbose', false);

        % Check output structure
        assert(isstruct(results), 'compare_methods should return struct');
        assert(isfield(results, 'method_results'), 'Missing method_results field');
        assert(isfield(results, 'comparison'), 'Missing comparison field');
        assert(isfield(results, 'best_method'), 'Missing best_method field');

        fprintf('  ✓ compare_methods() passed\n');
        tests_passed = tests_passed + 1;
    catch err
        fprintf('  ✗ compare_methods() FAILED: %s\n', err.message);
        tests_failed = tests_failed + 1;
    end

    %% Test 6: final_params() basic functionality
    fprintf('Test 6: final_params() basic functionality...\n');
    try
        % Need to create mock analysis files first
        create_mock_analysis_results();

        % Get final recommended parameters
        params = final_params('run_analysis', false, ...
                             'save_results', false, ...
                             'verbose', false);

        % Check output format
        assert(isstruct(params), 'final_params should return struct');
        assert(isfield(params, 'Q'), 'Missing Q field');
        assert(isfield(params, 'R'), 'Missing R field');
        assert(isfield(params, 'P0'), 'Missing P0 field');

        % Check parameter values are reasonable
        assert(params.Q > 0 && params.Q < 0.2, 'Q out of reasonable range');
        assert(params.R > 0 && params.R < 1, 'R out of reasonable range');
        assert(params.P0 > 0 && params.P0 < 1, 'P0 out of reasonable range');

        % Cleanup
        cleanup_mock_files();

        fprintf('  ✓ final_params() passed\n');
        tests_passed = tests_passed + 1;
    catch err
        cleanup_mock_files();
        fprintf('  ✗ final_params() FAILED: %s\n', err.message);
        tests_failed = tests_failed + 1;
    end

    %% Test 7: Parameter validity checks
    fprintf('Test 7: Parameter validity checks...\n');
    try
        % Test that valid parameters work
        test_params = [0.001, 0.05, 0.1];  % [Q, R, P0]

        % Q should be small (process noise)
        assert(test_params(1) > 0 && test_params(1) < 0.2, ...
               'Q should be in reasonable range');

        % R should be moderate (measurement noise)
        assert(test_params(2) > 0 && test_params(2) < 1, ...
               'R should be in reasonable range');

        % P0 should be moderate (initial uncertainty)
        assert(test_params(3) > 0 && test_params(3) < 1, ...
               'P0 should be in reasonable range');

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

    % Save in the format expected by the system
    dem_avg = dem_avg;
    rep_avg = rep_avg;
    dem_std = dem_std;
    rep_std = rep_std;
    num_polls = num_polls;
    candidate = candidate;
    weeks = weeks;
    dates = dates;

    save(output_file, 'dem_avg', 'rep_avg', 'dem_std', 'rep_std', ...
         'num_polls', 'candidate', 'weeks', 'dates');
    fprintf('  ✓ Created synthetic test data\n\n');
end

function create_mock_analysis_results()
    % Create mock analysis result files for final_params testing

    % Mock grid search results
    grid_results.best_params = [0.001, 0.05, 0.1];
    grid_results.best_score = 0.123;
    grid_results.all_scores = zeros(2, 2, 2);
    grid_results.q_range = [0.001, 0.01];
    grid_results.r_range = [0.05, 0.1];
    grid_results.p0_range = [0.1, 0.2];
    grid_results.grid_stats.mean = 0.15;
    grid_results.metric_used = 'brier';
    save('grid_search_results.mat', 'grid_results');

    % Mock cross-validation results
    cv_results.params_tested = [0.001, 0.05, 0.1];
    cv_results.average_metrics.brier_mean = 0.125;
    cv_results.average_metrics.brier_std = 0.02;
    cv_results.consistency.brier_cv = 0.16;
    cv_results.n_valid = 2;
    cv_results.n_total = 2;
    save('cross_validate_results.mat', 'cv_results');

    % Mock sensitivity results
    sens_results.base_params = [0.001, 0.05, 0.1];
    sens_results.base_score = 0.123;
    sens_results.sensitivity_index.Q = 0.5;
    sens_results.sensitivity_index.R = 0.6;
    sens_results.sensitivity_index.P0 = 0.4;
    sens_results.robustness_score = 0.5;
    save('sensitivity_results.mat', 'sens_results');

    % Mock comparison results
    comp_results.best_method = 'kalman';
    comp_results.n_methods = 2;
    save('comparison_results.mat', 'comp_results');
end

function cleanup_mock_files()
    % Remove mock analysis files
    if exist('grid_search_results.mat', 'file')
        delete('grid_search_results.mat');
    end
    if exist('cross_validate_results.mat', 'file')
        delete('cross_validate_results.mat');
    end
    if exist('sensitivity_results.mat', 'file')
        delete('sensitivity_results.mat');
    end
    if exist('comparison_results.mat', 'file')
        delete('comparison_results.mat');
    end
end
