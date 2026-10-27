function test_suite = test_hd_validate_parameters
% Unit tests for heat-diffusion/utils/validate_parameters.m
    try
        test_functions = localfunctions();
    catch
    end
    initTestSuite;
end

function p = base_1d()
    p = struct('alpha', 0.01, 'dt', 0.001, 't_final', 1.0, ...
               'T_boundary', 0, 'L', 1.0, 'nx', 50);
end

function p = base_2d()
    p = struct('alpha', 0.01, 'dt', 0.001, 't_final', 1.0, ...
               'T_boundary', 0, 'Lx', 1.0, 'Ly', 1.0, 'nx', 50, 'ny', 50);
end

function [ok, w] = run_validate(p, dim)
    % Suppress the ERROR: lines printed by validate_parameters
    [~, ok, w] = evalc_validate(p, dim);
end

function [out, ok, w] = evalc_validate(p, dim)
    ok = [];
    w = [];
    out = evalc('[ok, w] = validate_parameters(p, dim);');
end

function test_valid_1d_has_no_warnings
    [ok, w] = run_validate(base_1d(), '1d');
    assertTrue(ok);
    assertTrue(iscell(w));
    assertTrue(isempty(w));
end

function test_valid_2d_has_no_warnings
    [ok, w] = run_validate(base_2d(), '2d');
    assertTrue(ok);
    assertTrue(isempty(w));
end

function test_missing_alpha_is_invalid
    p = rmfield(base_1d(), 'alpha');
    assertFalse(run_validate(p, '1d'));
end

function test_non_positive_alpha_is_invalid
    p = base_1d();
    p.alpha = 0;
    assertFalse(run_validate(p, '1d'));
    p.alpha = -1;
    assertFalse(run_validate(p, '1d'));
end

function test_missing_or_non_positive_dt_is_invalid
    p = rmfield(base_1d(), 'dt');
    assertFalse(run_validate(p, '1d'));
    p = base_1d();
    p.dt = 0;
    assertFalse(run_validate(p, '1d'));
    p.dt = -0.001;
    assertFalse(run_validate(p, '1d'));
end

function test_missing_or_non_positive_t_final_is_invalid
    p = rmfield(base_1d(), 't_final');
    assertFalse(run_validate(p, '1d'));
    p = base_1d();
    p.t_final = 0;
    assertFalse(run_validate(p, '1d'));
end

function test_small_dt_warns_but_is_valid
    p = base_1d();
    p.dt = 1e-6;
    [ok, w] = run_validate(p, '1d');
    assertTrue(ok);
    assertEqual(numel(w), 1);
    assertFalse(isempty(strfind(w{1}, 'time step')));
end

function test_dt_at_threshold_does_not_warn
    p = base_1d();
    p.dt = 1e-5;
    [ok, w] = run_validate(p, '1d');
    assertTrue(ok);
    assertTrue(isempty(w));
end

function test_long_t_final_warns_but_is_valid
    p = base_1d();
    p.t_final = 10;
    [ok, w] = run_validate(p, '1d');
    assertTrue(ok);
    assertTrue(isempty(w));

    p.t_final = 10.5;
    [ok, w] = run_validate(p, '1d');
    assertTrue(ok);
    assertEqual(numel(w), 1);
    assertFalse(isempty(strfind(w{1}, 'Long simulation')));
end

function test_non_numeric_T_boundary_is_invalid
    p = base_1d();
    p.T_boundary = 'hot';
    assertFalse(run_validate(p, '1d'));
end

function test_T_boundary_is_optional
    p = rmfield(base_1d(), 'T_boundary');
    assertTrue(run_validate(p, '1d'));
end

function test_1d_requires_positive_L
    p = rmfield(base_1d(), 'L');
    assertFalse(run_validate(p, '1d'));
    p = base_1d();
    p.L = 0;
    assertFalse(run_validate(p, '1d'));
end

function test_1d_nx_minimum_is_10
    p = rmfield(base_1d(), 'nx');
    assertFalse(run_validate(p, '1d'));
    p = base_1d();
    p.nx = 9;
    assertFalse(run_validate(p, '1d'));
    p.nx = 10;
    assertTrue(run_validate(p, '1d'));
end

function test_1d_large_grid_warns
    % hd-vp-4: warning for large grids when nx > 200
    p = base_1d();
    p.nx = 300;
    [ok, w] = run_validate(p, '1d');
    assertTrue(ok);
    assertEqual(numel(w), 1);
    assertFalse(isempty(strfind(w{1}, 'Large grid')));
end

function test_1d_fine_resolution_warns
    p = base_1d();
    p.L = 1e-3;
    p.nx = 20;
    [ok, w] = run_validate(p, '1d');
    assertTrue(ok);
    assertEqual(numel(w), 1);
    assertFalse(isempty(strfind(w{1}, 'spatial resolution')));
end

function test_2d_requires_positive_lengths
    p = rmfield(base_2d(), 'Ly');
    assertFalse(run_validate(p, '2d'));
    p = base_2d();
    p.Lx = 0;
    assertFalse(run_validate(p, '2d'));
    p = base_2d();
    p.Ly = -1;
    assertFalse(run_validate(p, '2d'));
end

function test_2d_requires_nx_ny_at_least_10
    p = rmfield(base_2d(), 'ny');
    assertFalse(run_validate(p, '2d'));
    p = base_2d();
    p.ny = 9;
    assertFalse(run_validate(p, '2d'));
    p = base_2d();
    p.nx = 9;
    assertFalse(run_validate(p, '2d'));
    p = base_2d();
    p.nx = 10;
    p.ny = 10;
    assertTrue(run_validate(p, '2d'));
end

function test_2d_grid_over_200_warns
    p = base_2d();
    p.nx = 200;
    p.ny = 200;
    [ok, w] = run_validate(p, '2d');
    assertTrue(ok);
    assertTrue(isempty(w));

    p.nx = 201;
    [ok, w] = run_validate(p, '2d');
    assertTrue(ok);
    assertEqual(numel(w), 1);
end

function test_2d_total_points_over_50000_warns_too
    p = base_2d();
    p.nx = 224;
    p.ny = 224;   % 50176 points
    [ok, w] = run_validate(p, '2d');
    assertTrue(ok);
    assertEqual(numel(w), 2);
    assertFalse(isempty(strfind(w{2}, 'total points')));
end

function test_2d_ignores_1d_fields
    p = base_1d();   % has L and nx but no Lx/Ly/ny
    assertFalse(run_validate(p, '2d'));
end

function test_invalid_dimension_is_invalid
    assertFalse(run_validate(base_1d(), '3d'));
end

function test_warnings_accumulate
    p = base_1d();
    p.dt = 1e-6;
    p.t_final = 20;
    [ok, w] = run_validate(p, '1d');
    assertTrue(ok);
    assertEqual(numel(w), 2);
end
