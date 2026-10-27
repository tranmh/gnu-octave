function test_suite = test_ek_weekly_processor
% Unit tests for election-kalman-filter/pipeline/weekly_processor.m
% A fixture weekly CSV is passed via 'data_file'; save_results is off so the
% repository results/ folder is not written.
    try
        test_functions = localfunctions();
    catch
    end
    initTestSuite;
end

function [f, c] = fixture_file()
    d = tempname();
    mkdir(d);
    f = fullfile(d, 'weekly.csv');
    rows = {'week_number,week_start,week_end,dem_avg,rep_avg,dem_std,rep_std,num_polls,dem_candidate', ...
            '1,2023-11-05,2023-11-11,45.00,49.00,2.00,2.00,4,Biden', ...
            '2,2023-11-12,2023-11-18,NaN,NaN,NaN,NaN,0,Biden', ...
            '37,2024-07-14,2024-07-20,44.00,47.00,1.50,1.50,3,Biden', ...
            '38,2024-07-21,2024-07-27,46.00,46.00,2.00,2.00,5,Harris', ...
            '39,2024-07-28,2024-08-03,NaN,NaN,NaN,NaN,0,Harris', ...
            '41,2024-08-11,2024-08-17,47.00,46.00,1.00,1.00,6,Harris'};
    fid = fopen(f, 'w');
    fprintf(fid, '%s\n', rows{:});
    fclose(fid);
    c = onCleanup(@() remove_dir(d));
end

function remove_dir(d)
    confirm_recursive_rmdir(false, 'local');
    rmdir(d, 's');
end

function r = run_wp(f, varargin)
    [~, r] = evalc('weekly_processor(''data_file'', f, ''save_results'', false, ''verbose'', false, varargin{:})');
end

function [z, R] = expected_obs(dem, rep, s, n)
    % multi_poll_aggregator + polls_to_probability, written out by hand
    conf = 1 / (1 + exp(-(n - 3)));
    s = max(0.5, min(s * max(sqrt(conf), 0.5), 5));
    m = (dem - rep) / 100;
    z = 1 / (1 + exp(-15 * m));
    deriv = 15 * exp(-15 * m) / (1 + exp(-15 * m))^2;
    R = (deriv * sqrt(2) * s / 100)^2 + 0.05^2;
    R = max(0.001, min(R, 0.25)) / sqrt(n);
end

function test_one_result_per_row
    [f, c] = fixture_file();
    r = run_wp(f);
    assertEqual(numel(r.details), 6);
    assertEqual(r.week_numbers, [1; 2; 37; 38; 39; 41]);
    assertEqual(r.dates{1}, '2023-11-05');
    assertEqual(size(r.win_prob_history), [6, 1]);
    assertElementsAlmostEqual(r.uncertainty_history, sqrt([r.details.P_est]'), 'absolute', 1e-12);
end

function test_first_week_update_matches_hand_computation
    [f, c] = fixture_file();
    r = run_wp(f);
    w1 = r.details(1);
    [z, R] = expected_obs(45, 49, 2, 4);
    P_pred = 0.1 + 0.001;
    K = P_pred / (P_pred + R);
    assertElementsAlmostEqual(w1.poll_obs, z, 'absolute', 1e-9);
    assertElementsAlmostEqual(w1.R_used, R, 'absolute', 1e-12);
    assertElementsAlmostEqual(w1.x_pred, 0.5, 'absolute', 1e-12);
    assertElementsAlmostEqual(w1.P_pred, P_pred, 'absolute', 1e-12);
    assertElementsAlmostEqual(w1.K, K, 'absolute', 1e-9);
    assertElementsAlmostEqual(w1.x_est, 0.5 + K * (z - 0.5), 'absolute', 1e-9);
    assertElementsAlmostEqual(w1.P_est, (1 - K) * P_pred, 'absolute', 1e-9);
    assertEqual(w1.Q_used, 0.001);
end

function test_week_without_polls_keeps_prediction
    [f, c] = fixture_file();
    r = run_wp(f);
    w2 = r.details(2);
    assertTrue(isnan(w2.poll_obs));
    assertEqual(w2.K, 0);
    assertEqual(w2.innovation, 0);
    assertEqual(w2.x_est, w2.x_pred);
    assertEqual(w2.P_est, w2.P_pred);
    assertEqual(w2.R_used, 0.05);
    assertElementsAlmostEqual(w2.P_pred, r.details(1).P_est + 0.001, 'absolute', 1e-12);
end

function test_transition_week_raises_Q_and_resets_P
    [f, c] = fixture_file();
    r = run_wp(f);
    w38 = r.details(4);
    assertEqual(w38.dem_candidate, 'Harris');
    assertElementsAlmostEqual(w38.Q_used, 0.005, 'absolute', 1e-12);
    assertElementsAlmostEqual(w38.P_est, 0.15, 'absolute', 1e-12);
    w39 = r.details(5);
    assertTrue(w39.Q_used > 0.001 && w39.Q_used < 0.005);
    w41 = r.details(6);
    assertElementsAlmostEqual(w41.Q_used, 0.001, 'absolute', 1e-12);
end

function test_estimates_stay_probabilities
    [f, c] = fixture_file();
    r = run_wp(f);
    assertTrue(all(r.win_prob_history >= 0 & r.win_prob_history <= 1));
    assertTrue(all([r.details.P_est] > 0));
end

function test_params_struct_overrides_individual_values
    [f, c] = fixture_file();
    params = struct('Q', 0.002, 'R', 0.04, 'x0', 0.3, 'P0', 0.2);
    r = run_wp(f, 'params', params, 'Q', 0.5);
    w1 = r.details(1);
    assertElementsAlmostEqual(w1.x_pred, 0.3, 'absolute', 1e-12);
    assertElementsAlmostEqual(w1.P_pred, 0.2 + 0.002, 'absolute', 1e-12);
    assertEqual(r.details(2).R_used, 0.04);
end

function test_individual_parameters
    [f, c] = fixture_file();
    r = run_wp(f, 'x0', 0.6, 'P0', 0.05, 'Q', 0.003, 'R_base', 0.07);
    assertElementsAlmostEqual(r.details(1).x_pred, 0.6, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.details(1).P_pred, 0.053, 'absolute', 1e-12);
    assertEqual(r.details(2).R_used, 0.07);
end

function test_missing_data_file_raises
    try
        run_wp(fullfile(tempdir(), 'aqaa_no_such_weekly_file.csv'));
    catch err
        assertFalse(isempty(strfind(err.message, 'Data file not found')));
        return;
    end
    error('expected an error for a missing data file');
end

function test_invalid_option_type_raises
    [f, c] = fixture_file();
    assertExceptionThrown(@() run_wp(f, 'Q', 'big'));
end
