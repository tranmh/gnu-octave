function test_suite = test_heat_solver_2d_factorisation
  % TEST_HEAT_SOLVER_2D_FACTORISATION - A_left is constant, so a time step
  % must not cost as much as factorising it again (A_left \ rhs).
  try
    test_functions = localfunctions();
  catch
  end
  initTestSuite;
end

function test_step_cost_is_below_one_factorise_and_solve
  addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'core'));

  nx = 120;
  ny = 120;
  alpha = 0.001;
  dt = 0.001;
  u0 = @(x, y) 100 * exp(-100 * ((x - 0.5).^2 + (y - 0.5).^2));

  % Per-step cost of the solver: difference of two runs (setup cancels)
  t_short = time_solver(u0, alpha, nx, ny, dt, 0.02);   % 21 steps
  t_long = time_solver(u0, alpha, nx, ny, dt, 0.06);    % 61 steps
  per_step = (t_long - t_short) / 40;

  % Reference: one factorise-and-solve of the same A_left
  h = 1 / (nx + 1);
  r = alpha * dt / h^2;
  N = nx * ny;
  A_left = speye(N) - (r / 2) * build_laplacian_matrix('2d', nx, ny);
  rhs = rand(N, 1);
  t_solve = inf;
  for k = 1:5
    tic;
    v = A_left \ rhs; %#ok<NASGU>
    t_solve = min(t_solve, toc);
  end

  assertTrue(per_step < 0.5 * t_solve, sprintf( ...
    'per-step %.3g s is not well below one A_left\\rhs (%.3g s): A_left is re-factorised every step', ...
    per_step, t_solve));
end

function t = time_solver(u0, alpha, nx, ny, dt, t_final)
  t = inf;
  for k = 1:3
    tic;
    heat_solver_2d(u0, alpha, 1, 1, 0, nx, ny, dt, t_final);
    t = min(t, toc);
  end
end
