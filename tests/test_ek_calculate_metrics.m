function test_suite = test_ek_calculate_metrics
% Unit tests for election-kalman-filter/backtest/calculate_metrics.m
    try
        test_functions = localfunctions();
    catch
    end
    initTestSuite;
end

function m = metrics_quiet(pred, actual)
    [~, m] = evalc('calculate_metrics(pred, actual)');
end

function pred = three_week_predictions()
    pred = struct();
    pred.win_prob = [0.4; 0.6; 0.3];
    pred.win_prob_std = [0.1; 0.1; 0.1];
    pred.weeks = [1; 2; 3];
    pred.dates = {'2024-10-20'; '2024-10-27'; '2024-11-03'};
end

function test_republican_win_hand_computed_scores
    m = metrics_quiet(three_week_predictions(), struct('winner', 'Trump'));
    tol = 1e-12;
    assertElementsAlmostEqual(m.final_prediction, 0.3, 'absolute', tol);
    assertElementsAlmostEqual(m.final_error, 0.3, 'absolute', tol);
    assertElementsAlmostEqual(m.brier_score, (0.16 + 0.36 + 0.09) / 3, 'absolute', tol);
    assertElementsAlmostEqual(m.final_brier_score, 0.09, 'absolute', tol);
    assertElementsAlmostEqual(m.log_score, mean(-log([0.6, 0.4, 0.7])), 'absolute', tol);
    assertElementsAlmostEqual(m.final_log_score, -log(0.7), 'absolute', tol);
    assertElementsAlmostEqual(m.rmse, sqrt(0.61 / 3), 'absolute', tol);
    assertElementsAlmostEqual(m.mae, 1.3 / 3, 'absolute', tol);
    assertElementsAlmostEqual(m.prediction_volatility, std([0.2, -0.3]), 'absolute', tol);
    assertElementsAlmostEqual(m.max_prediction_change, 0.3, 'absolute', tol);
    assertElementsAlmostEqual(m.prediction_trend, -0.1, 'absolute', tol);
    assertElementsAlmostEqual(m.prediction_confidence, 0.2, 'absolute', tol);
    assertEqual(m.n_predictions, 3);
    assertElementsAlmostEqual(m.prediction_mean, 1.3 / 3, 'absolute', tol);
    assertElementsAlmostEqual(m.prediction_median, 0.4, 'absolute', tol);
    assertTrue(m.correct_winner_prediction);
    assertEqual(m.grade, 'Fair');
end

function test_confidence_interval_from_std
    m = metrics_quiet(three_week_predictions(), struct('winner', 'Trump'));
    assertElementsAlmostEqual(m.final_confidence_interval, [0.3 - 0.196, 0.3 + 0.196], ...
                              'absolute', 1e-12);
    assertFalse(m.outcome_in_final_ci);
    assertElementsAlmostEqual(m.avg_ci_width, 0.392, 'absolute', 1e-12);
    assertElementsAlmostEqual(m.final_ci_width, 0.392, 'absolute', 1e-12);
end

function test_confidence_interval_clipped_to_unit_range
    pred = struct('win_prob', [0.1; 0.9], 'win_prob_std', [0.5; 0.5]);
    m = metrics_quiet(pred, struct('winner', 'Harris'));
    assertEqual(m.final_confidence_interval, [0, 1]);
    assertTrue(m.outcome_in_final_ci);
    assertElementsAlmostEqual(m.avg_ci_width, 1.0, 'absolute', 1e-12);
end

function test_without_std_ci_fields_are_nan
    pred = struct('win_prob', [0.4; 0.45]);
    m = metrics_quiet(pred, struct('winner', 'Trump'));
    assertTrue(all(isnan(m.final_confidence_interval)));
    assertTrue(isnan(m.outcome_in_final_ci));
    assertTrue(isnan(m.avg_ci_width));
    assertTrue(isnan(m.final_ci_width));
    assertTrue(isnan(m.vote_share_error));
    assertFalse(isfield(m, 'weeks'));
end

function test_democratic_winner_excellent_grade
    pred = struct('win_prob', [0.9; 0.95]);
    m = metrics_quiet(pred, struct('winner', 'Harris'));
    assertElementsAlmostEqual(m.brier_score, (0.01 + 0.0025) / 2, 'absolute', 1e-12);
    assertElementsAlmostEqual(m.final_error, 0.05, 'absolute', 1e-12);
    assertTrue(m.correct_winner_prediction);
    assertEqual(m.grade, 'Excellent');
end

function test_biden_counts_as_democratic_winner_case_insensitive
    m = metrics_quiet(struct('win_prob', 0.8), struct('winner', 'biden'));
    assertElementsAlmostEqual(m.final_error, 0.2, 'absolute', 1e-12);
    assertTrue(m.correct_winner_prediction);
end

function test_good_grade_band
    pred = struct('win_prob', [0.65; 0.65]);
    m = metrics_quiet(pred, struct('winner', 'Harris'));
    assertElementsAlmostEqual(m.brier_score, 0.1225, 'absolute', 1e-12);
    assertEqual(m.grade, 'Good');
end

function test_wrong_winner_is_poor
    pred = struct('win_prob', [0.6; 0.7]);
    m = metrics_quiet(pred, struct('winner', 'Trump'));
    assertFalse(m.correct_winner_prediction);
    assertEqual(m.grade, 'Poor');
end

function test_exactly_half_predicts_republican
    m = metrics_quiet(struct('win_prob', 0.5), struct('winner', 'Trump'));
    assertTrue(m.correct_winner_prediction);
end

function test_single_prediction_has_zero_volatility
    m = metrics_quiet(struct('win_prob', 0.4), struct('winner', 'Trump'));
    assertEqual(m.prediction_volatility, 0);
    assertEqual(m.max_prediction_change, 0);
    assertEqual(m.prediction_trend, 0);
    assertEqual(m.n_predictions, 1);
end

function test_log_score_is_capped_for_certain_wrong_prediction
    m = metrics_quiet(struct('win_prob', 1.0), struct('winner', 'Trump'));
    assertElementsAlmostEqual(m.log_score, -log(1e-10), 'absolute', 1e-9);
    assertElementsAlmostEqual(m.brier_score, 1, 'absolute', 1e-12);
end

function test_vote_share_error
    actual = struct('winner', 'Trump', 'dem_vote_share', 48.3);
    m = metrics_quiet(three_week_predictions(), actual);
    assertElementsAlmostEqual(m.vote_share_error, abs(0.3 - 0.483), 'absolute', 1e-12);
end

function test_row_vector_input_and_passthrough_fields
    pred = three_week_predictions();
    pred.win_prob = pred.win_prob';
    m = metrics_quiet(pred, struct('winner', 'Trump'));
    assertEqual(m.weekly_predictions, [0.4; 0.6; 0.3]);
    assertEqual(m.weeks, [1; 2; 3]);
    assertEqual(m.dates, pred.dates);
end

function test_invalid_predictions_raise
    assertExceptionThrown(@() calculate_metrics([0.5 0.6], struct('winner', 'Trump')));
    assertExceptionThrown(@() calculate_metrics(struct('p', 0.5), struct('winner', 'Trump')));
end

function test_invalid_outcome_raises
    pred = struct('win_prob', 0.5);
    assertExceptionThrown(@() calculate_metrics(pred, 'Trump'));
    assertExceptionThrown(@() calculate_metrics(pred, struct('dem_vote_share', 48)));
end

function test_unknown_winner_raises
    try
        calculate_metrics(struct('win_prob', 0.5), struct('winner', 'Nobody'));
    catch err
        assertFalse(isempty(strfind(err.message, 'Unknown winner')));
        return;
    end
    error('expected an error for an unknown winner');
end
