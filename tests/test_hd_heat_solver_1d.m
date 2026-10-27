function test_suite = test_hd_heat_solver_1d
% Unit tests for heat-diffusion/core/heat_solver_1d.m
    try
        test_functions = localfunctions();
    catch
    end
    initTestSuite;
end

function assert_error_contains(f, fragment)
    try
        f();
    catch err
        assertFalse(isempty(strfind(err.message, fragment)), ...
                    sprintf('unexpected error message: %s', err.message));
        return;
    end
    error('expected an error containing "%s"', fragment);
end

function test_grid_and_time_shapes
    % nx=9, L=1 -> dx = 0.1, interior points 0.1..0.9
    [u, x, t] = heat_solver_1d(zeros(9, 1), 0.01, 1.0, 0, 9, 0.25, 1.0);
    assertEqual(size(u), [9, 5]);
    assertEqual(size(x), [9, 1]);
    assertEqual(size(t), [5, 1]);
    assertElementsAlmostEqual(x, (0.1:0.1:0.9)', 'absolute', 1e-12);
    assertElementsAlmostEqual(t, [0; 0.25; 0.5; 0.75; 1.0], 'absolute', 1e-12);
end

function test_nt_rounds_up_when_dt_does_not_divide
    [u, ~, t] = heat_solver_1d(zeros(5, 1), 0.01, 1.0, 0, 5, 0.3, 1.0);
    % nt = ceil(1/0.3) + 1 = 5, t spans exactly 0..t_final
    assertEqual(numel(t), 5);
    assertEqual(size(u, 2), 5);
    assertElementsAlmostEqual(t(end), 1.0, 'absolute', 1e-12);
    assertElementsAlmostEqual(t(1), 0, 'absolute', 1e-12);
end

function test_first_column_is_initial_vector
    u0 = (1:9)';
    u = heat_solver_1d(u0, 0.01, 1.0, 0, 9, 0.25, 1.0);
    assertEqual(u(:, 1), u0);
end

function test_row_vector_initial_condition_is_accepted
    u0 = 1:9;
    u = heat_solver_1d(u0, 0.01, 1.0, 0, 9, 0.25, 1.0);
    assertEqual(u(:, 1), u0(:));
end

function test_function_handle_initial_condition_evaluated_at_x
    f = @(x) 3 * x + 1;
    [u, x] = heat_solver_1d(f, 0.01, 2.0, 0, 7, 0.1, 0.5);
    assertElementsAlmostEqual(u(:, 1), f(x), 'absolute', 1e-12);
    % dx = L/(nx+1) = 0.25
    assertElementsAlmostEqual(x, (0.25:0.25:1.75)', 'absolute', 1e-12);
end

function test_uniform_boundary_temperature_is_steady_state
    u = heat_solver_1d(50 * ones(20, 1), 0.5, 1.0, 50, 20, 0.001, 0.1);
    assertElementsAlmostEqual(u, 50 * ones(size(u)), 'absolute', 1e-9);
end

function test_zero_initial_heats_toward_boundary_temperature
    u = heat_solver_1d(zeros(19, 1), 1.0, 1.0, 100, 19, 0.001, 2.0);
    assertTrue(all(u(:) >= -1e-9));
    assertTrue(all(u(:) <= 100 + 1e-9));
    assertElementsAlmostEqual(u(:, end), 100 * ones(19, 1), 'absolute', 1e-3);
end

function test_matches_discrete_sine_mode_decay
    % u0 = sin(pi x) with zero boundaries decays like exp(-alpha pi^2 t)
    nx = 49; L = 1.0; alpha = 0.01; dt = 0.01; t_final = 1.0;
    [u, x, t] = heat_solver_1d(@(x) sin(pi * x), alpha, L, 0, nx, dt, t_final);
    expected = sin(pi * x) * exp(-alpha * pi^2 * t');
    assertElementsAlmostEqual(u, expected, 'absolute', 1e-3);
end

function test_maximum_principle_and_decay_with_zero_boundary
    u0 = @(x) 100 * exp(-100 * (x - 0.5).^2);
    [u, ~, ~] = heat_solver_1d(u0, 0.01, 1.0, 0, 49, 0.01, 1.0);
    assertTrue(max(u(:)) <= max(u(:, 1)) + 1e-9);
    assertTrue(min(u(:)) >= -1e-9);
    peaks = max(u, [], 1);
    assertTrue(all(diff(peaks) <= 1e-12));
    total = sum(u, 1);
    assertTrue(total(end) < total(1));
end

function test_long_run_decays_to_zero
    u = heat_solver_1d(@(x) 10 * ones(size(x)), 1.0, 1.0, 0, 9, 0.004, 2.0);
    assertTrue(max(abs(u(:, end))) < 1e-3);
end

function test_symmetric_initial_stays_symmetric
    u = heat_solver_1d(@(x) x .* (1 - x), 0.05, 1.0, 0, 21, 0.01, 0.5);
    assertElementsAlmostEqual(u, flipud(u), 'absolute', 1e-10);
end

function test_large_r_issues_accuracy_warning
    lastwarn('');
    heat_solver_1d(zeros(9, 1), 1.0, 1.0, 0, 9, 0.1, 0.2);  % r = 10
    msg = lastwarn();
    assertFalse(isempty(strfind(msg, 'r =')));
end

function test_requires_seven_arguments
    assert_error_contains(@() heat_solver_1d(zeros(9, 1), 0.01, 1.0, 0, 9, 0.1), ...
                          'Requires 7 input arguments');
end

function test_rejects_non_positive_alpha
    assert_error_contains(@() heat_solver_1d(zeros(9, 1), 0, 1.0, 0, 9, 0.1, 1), 'alpha');
    assert_error_contains(@() heat_solver_1d(zeros(9, 1), -1, 1.0, 0, 9, 0.1, 1), 'alpha');
end

function test_rejects_non_positive_L
    assert_error_contains(@() heat_solver_1d(zeros(9, 1), 0.01, 0, 0, 9, 0.1, 1), 'L must be positive');
end

function test_rejects_non_numeric_boundary
    assert_error_contains(@() heat_solver_1d(zeros(9, 1), 0.01, 1, 'x', 9, 0.1, 1), 'T_boundary');
end

function test_rejects_bad_nx
    assert_error_contains(@() heat_solver_1d(zeros(9, 1), 0.01, 1, 0, 1, 0.1, 1), 'nx');
    assert_error_contains(@() heat_solver_1d(zeros(9, 1), 0.01, 1, 0, 2.5, 0.1, 1), 'nx');
end

function test_rejects_non_positive_dt_and_t_final
    assert_error_contains(@() heat_solver_1d(zeros(9, 1), 0.01, 1, 0, 9, 0, 1), 'dt');
    assert_error_contains(@() heat_solver_1d(zeros(9, 1), 0.01, 1, 0, 9, 0.1, 0), 't_final');
end

function test_rejects_wrong_length_initial_vector
    assert_error_contains(@() heat_solver_1d(zeros(8, 1), 0.01, 1, 0, 9, 0.1, 1), 'u0');
    assert_error_contains(@() heat_solver_1d(zeros(3, 3), 0.01, 1, 0, 9, 0.1, 1), 'u0');
end
