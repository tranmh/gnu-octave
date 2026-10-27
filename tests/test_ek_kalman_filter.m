function test_suite = test_ek_kalman_filter
% Unit tests for election-kalman-filter/core/kalman_filter.m
    try
        test_functions = localfunctions();
    catch
    end
    initTestSuite;
end

function p = default_params()
    % Same values as kalman_init() defaults (ek-5)
    p = struct('x_est', 0.5, 'P_est', 0.1, 'Q', 0.001, 'R', 0.05);
end

function r = run_kf(z, weeks, params, varargin)
    r = kalman_filter(z, weeks, params, 'verbose', false, varargin{:});
end

function test_kalman_init_defaults
    [~, params] = evalc('kalman_init()');
    assertEqual(params.x_est, 0.5);
    assertEqual(params.P_est, 0.1);
    assertEqual(params.Q, 0.001);
    assertEqual(params.R, 0.05);
end

function test_single_measurement_matches_hand_computation
    r = run_kf(0.6, 1, default_params());
    P_pred = 0.1 + 0.001;
    K = P_pred / (P_pred + 0.05);
    assertElementsAlmostEqual(r.x_pred, 0.5, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.P_pred, P_pred, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.K, K, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.innovation, 0.1, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.x_est, 0.5 + K * 0.1, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.P_est, (1 - K) * P_pred, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.final_estimate, r.x_est, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.final_std, sqrt(r.P_est), 'absolute', 1e-12);
end

function test_nan_measurement_uses_prediction
    % ek-7
    r = run_kf([0.6, NaN, NaN], [1, 2, 3], default_params());
    assertTrue(isnan(r.K(2)) && isnan(r.K(3)));
    assertTrue(isnan(r.innovation(2)) && isnan(r.innovation(3)));
    assertEqual(r.x_est(2), r.x_pred(2));
    assertEqual(r.P_est(2), r.P_pred(2));
    assertEqual(r.x_est(3), r.x_est(1));
    assertElementsAlmostEqual(r.P_est(3), r.P_est(1) + 2 * 0.001, 'absolute', 1e-12);
end

function test_all_missing_keeps_prior_and_grows_uncertainty
    r = run_kf(nan(1, 5), 1:5, default_params());
    assertElementsAlmostEqual(r.x_est, 0.5 * ones(5, 1), 'absolute', 1e-12);
    assertElementsAlmostEqual(r.P_est, 0.1 + 0.001 * (1:5)', 'absolute', 1e-12);
end

function test_converges_to_constant_measurement
    n = 50;
    r = run_kf(0.7 * ones(1, n), 1:n, default_params(), 'transition_week', 1000);
    assertElementsAlmostEqual(r.final_estimate, 0.7, 'absolute', 5e-3);
    % estimates move monotonically toward the measurement
    assertTrue(all(diff(r.x_est) >= -1e-12));
    assertTrue(all(r.x_est <= 0.7 + 1e-12));
end

function test_covariance_properties
    n = 60;
    z = 0.5 + 0.05 * sin((1:n) / 3);
    z(10:12) = NaN;
    q = 0.001; R = 0.05;
    r = run_kf(z, 1:n, default_params(), 'transition_week', 1000);
    assertTrue(all(r.P_est > 0));
    measured = ~isnan(z(:));
    assertTrue(all(r.P_est(measured) < r.P_pred(measured)));
    assertTrue(all(r.K(measured) > 0 & r.K(measured) < 1));
    % P_pred(t) = P_est(t-1) + Q (random walk)
    assertElementsAlmostEqual(r.P_pred(2:end), r.P_est(1:end-1) + q, 'absolute', 1e-12);
    % Steady-state Riccati solution: P^2 + Q P - Q R = 0
    P_ss = (-q + sqrt(q^2 + 4 * q * R)) / 2;
    assertElementsAlmostEqual(r.P_est(end), P_ss, 'relative', 1e-3);
end

function test_output_shapes_are_columns
    r = run_kf([0.4 0.5 0.6], [1 2 3], default_params());
    assertEqual(size(r.x_est), [3, 1]);
    assertEqual(size(r.measurements), [3, 1]);
    assertEqual(r.week_numbers, [1; 2; 3]);
end

function test_transition_resets_P_and_raises_Q_for_three_weeks
    % ek-8
    weeks = 30:45;
    z = 0.5 * ones(size(weeks));   % zero innovations, only covariance changes
    q = 0.001;
    r = run_kf(z, weeks, default_params());
    assertTrue(r.transition_handled);
    i38 = find(weeks == 38);
    assertElementsAlmostEqual(r.P_pred(i38), 0.15 + 5 * q, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.P_pred(i38 + 1), r.P_est(i38) + 5 * q, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.P_pred(i38 + 2), r.P_est(i38 + 1) + 5 * q, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.P_pred(i38 + 3), r.P_est(i38 + 2) + q, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.P_pred(i38 - 1), r.P_est(i38 - 2) + q, 'absolute', 1e-12);
end

function test_transition_applies_on_missing_measurement
    weeks = 36:40;
    z = [0.5 0.5 NaN 0.5 0.5];
    r = run_kf(z, weeks, default_params());
    assertTrue(r.transition_handled);
    assertElementsAlmostEqual(r.P_est(3), 0.15 + 5 * 0.001, 'absolute', 1e-12);
end

function test_no_transition_when_week_absent
    r = run_kf(0.5 * ones(1, 10), 1:10, default_params());
    assertFalse(r.transition_handled);
    r = run_kf(0.5 * ones(1, 3), [39 40 41], default_params());
    assertFalse(r.transition_handled);
end

function test_custom_transition_options
    r = run_kf([0.5 0.5], [5 6], default_params(), ...
               'transition_week', 5, 'Q_transition', 0.02, 'P_reset', 0.3);
    assertTrue(r.transition_handled);
    assertElementsAlmostEqual(r.P_pred(1), 0.3 + 0.02, 'absolute', 1e-12);
    assertElementsAlmostEqual(r.P_pred(2), r.P_est(1) + 0.02, 'absolute', 1e-12);
end

function test_length_mismatch_raises
    assertExceptionThrown(@() run_kf([0.5 0.5], 1, default_params()), ...
                          'kalman_filter:InputSizeMismatch');
end

function test_non_vector_measurements_raise
    assertExceptionThrown(@() run_kf(0.5 * ones(2, 2), 1:4, default_params()));
end

function test_invalid_option_raises
    assertExceptionThrown(@() run_kf(0.5, 1, default_params(), 'P_reset', -1));
end
