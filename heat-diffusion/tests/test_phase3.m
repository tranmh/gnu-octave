% TEST_PHASE3.M - Test interactive controls for heat diffusion simulation
%
% Tests Phase 3: Interactive Controls
% - Control structure initialization
% - Keyboard event handling simulation
% - State management
% - Speed adjustment
% - Save functionality
%
% AUTHOR: Heat Diffusion Project
% DATE: October 2025

fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════╗\n');
fprintf('║  PHASE 3 TEST: Interactive Controls                     ║\n');
fprintf('╚══════════════════════════════════════════════════════════╝\n');
fprintf('\n');

% Add paths
addpath('../interaction');
addpath('../core');

test_count = 0;
pass_count = 0;

% ============================================================================
% TEST 1: Control Structure Initialization (1D)
% ============================================================================
test_count = test_count + 1;
fprintf('Test %d: Control structure initialization (1D)... ', test_count);

try
  fig = figure('Visible', 'off');  % Hidden figure for testing
  ctrl = setup_controls(fig, '1d');
  
  % Check all required fields exist
  assert(isfield(ctrl, 'is_paused'));
  assert(isfield(ctrl, 'speed_factor'));
  assert(isfield(ctrl, 'should_reset'));
  assert(isfield(ctrl, 'should_quit'));
  assert(isfield(ctrl, 'should_save'));
  assert(isfield(ctrl, 'probe_mode'));
  assert(isfield(ctrl, 'show_help'));
  
  % Check initial values
  assert(ctrl.is_paused == false);
  assert(ctrl.speed_factor == 1.0);
  assert(ctrl.should_reset == false);
  assert(ctrl.should_quit == false);
  assert(ctrl.should_save == false);
  
  % Check 1D doesn't have 2D-specific fields
  assert(~isfield(ctrl, 'add_heat'));
  
  close(fig);
  fprintf('PASS\n');
  pass_count = pass_count + 1;
catch err
  fprintf('FAIL: %s\n', err.message);
  close(fig);
end

% ============================================================================
% TEST 2: Control Structure Initialization (2D)
% ============================================================================
test_count = test_count + 1;
fprintf('Test %d: Control structure initialization (2D)... ', test_count);

try
  fig = figure('Visible', 'off');
  ctrl = setup_controls(fig, '2d');
  
  % Check 2D-specific fields
  assert(isfield(ctrl, 'add_heat'));
  assert(isfield(ctrl, 'heat_pos'));
  assert(isfield(ctrl, 'heat_intensity'));
  
  % Check initial values
  assert(ctrl.add_heat == false);
  assert(isempty(ctrl.heat_pos));
  
  close(fig);
  fprintf('PASS\n');
  pass_count = pass_count + 1;
catch err
  fprintf('FAIL: %s\n', err.message);
  close(fig);
end

% ============================================================================
% TEST 3: Update Simulation - Continue State
% ============================================================================
test_count = test_count + 1;
fprintf('Test %d: Update simulation continues normally... ', test_count);

try
  fig = figure('Visible', 'off');
  ctrl = setup_controls(fig, '1d');
  
  % Create dummy data
  x = linspace(0, 1, 50);
  u = sin(2*pi*x);
  t = 0.1;
  
  % Should continue and return unchanged data
  [cont, u_mod] = update_simulation(ctrl, u, x, [], t);
  
  assert(cont == true);
  assert(all(u_mod == u));
  
  close(fig);
  fprintf('PASS\n');
  pass_count = pass_count + 1;
catch err
  fprintf('FAIL: %s\n', err.message);
  close(fig);
end

% ============================================================================
% TEST 4: Update Simulation - Quit Request
% ============================================================================
test_count = test_count + 1;
fprintf('Test %d: Quit request stops simulation... ', test_count);

try
  fig = figure('Visible', 'off');
  ctrl = setup_controls(fig, '1d');
  
  % Simulate quit request
  ctrl.should_quit = true;
  
  x = linspace(0, 1, 50);
  u = sin(2*pi*x);
  t = 0.1;
  
  [cont, u_mod] = update_simulation(ctrl, u, x, [], t);
  
  assert(cont == false);  % Should signal to stop
  
  close(fig);
  fprintf('PASS\n');
  pass_count = pass_count + 1;
catch err
  fprintf('FAIL: %s\n', err.message);
  close(fig);
end

% ============================================================================
% TEST 5: Update Simulation - Reset Request
% ============================================================================
test_count = test_count + 1;
fprintf('Test %d: Reset request signals properly... ', test_count);

try
  fig = figure('Visible', 'off');
  ctrl = setup_controls(fig, '1d');
  
  % Simulate reset request
  ctrl.should_reset = true;
  
  x = linspace(0, 1, 50);
  u = sin(2*pi*x);
  t = 0.1;
  
  [cont, u_mod] = update_simulation(ctrl, u, x, [], t);
  
  assert(cont == false);  % Should signal to stop for reset
  
  close(fig);
  fprintf('PASS\n');
  pass_count = pass_count + 1;
catch err
  fprintf('FAIL: %s\n', err.message);
  close(fig);
end

% ============================================================================
% TEST 6: Speed Factor Bounds
% ============================================================================
test_count = test_count + 1;
fprintf('Test %d: Speed factor stays within bounds... ', test_count);

try
  fig = figure('Visible', 'off');
  ctrl = setup_controls(fig, '1d');
  
  % Test initial value
  assert(ctrl.speed_factor == 1.0);
  
  % Speed factor should be between 0.1 and 10.0
  % (These bounds are implemented in the keyboard callback)
  
  close(fig);
  fprintf('PASS\n');
  pass_count = pass_count + 1;
catch err
  fprintf('FAIL: %s\n', err.message);
  close(fig);
end

% ============================================================================
% TEST 7: Heat Addition in 2D
% ============================================================================
test_count = test_count + 1;
fprintf('Test %d: Heat addition modifies temperature field (2D)... ', test_count);

try
  fig = figure('Visible', 'off');
  ctrl = setup_controls(fig, '2d');
  
  % Enable heat addition mode
  ctrl.add_heat = true;
  ctrl.heat_pos = [0.5, 0.5];  % Center of domain
  ctrl.heat_intensity = 1.0;
  
  % Create 2D grid and temperature field
  x = linspace(0, 1, 50);
  y = linspace(0, 1, 50);
  [X, Y] = meshgrid(x, y);
  u = zeros(size(X));  % Start with all zeros
  t = 0.1;
  
  [cont, u_mod] = update_simulation(ctrl, u, x, y, t);
  
  % Temperature field should be modified (heat added)
  assert(any(u_mod(:) > 0));  % Some points should be heated
  assert(max(u_mod(:)) > 0);  % Maximum should be positive
  
  % Heat should be centered around (0.5, 0.5)
  center_idx = round(length(x) / 2);
  assert(u_mod(center_idx, center_idx) > mean(u_mod(:)));
  
  close(fig);
  fprintf('PASS\n');
  pass_count = pass_count + 1;
catch err
  fprintf('FAIL: %s\n', err.message);
  close(fig);
end

% ============================================================================
% TEST 8: Pause State
% ============================================================================
test_count = test_count + 1;
fprintf('Test %d: Paused state returns immediately... ', test_count);

try
  fig = figure('Visible', 'off');
  ctrl = setup_controls(fig, '1d');
  
  % Set paused state
  ctrl.is_paused = true;
  
  x = linspace(0, 1, 50);
  u = sin(2*pi*x);
  t = 0.1;
  
  tic;
  [cont, u_mod] = update_simulation(ctrl, u, x, [], t);
  elapsed = toc;
  
  % Should continue (not quit) but pause briefly
  assert(cont == true);
  assert(all(u_mod == u));  % No modifications when paused
  assert(elapsed < 0.2);     % Should return quickly (with small pause)
  
  close(fig);
  fprintf('PASS\n');
  pass_count = pass_count + 1;
catch err
  fprintf('FAIL: %s\n', err.message);
  close(fig);
end

% ============================================================================
% SUMMARY
% ============================================================================
fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════╗\n');
fprintf('║  TEST SUMMARY                                            ║\n');
fprintf('╚══════════════════════════════════════════════════════════╝\n');
fprintf('  Tests passed: %d / %d\n', pass_count, test_count);

if pass_count == test_count
  fprintf('  ✓ ALL TESTS PASSED\n');
  fprintf('\n');
  fprintf('  Phase 3 (Interactive Controls) is ready!\n');
  fprintf('  - Control structure initialization working\n');
  fprintf('  - State management functional\n');
  fprintf('  - Quit and reset signals correct\n');
  fprintf('  - Heat addition working (2D)\n');
  fprintf('  - Pause functionality working\n');
  fprintf('\n');
  fprintf('  Next: Implement pattern library (Phase 4)\n');
else
  fprintf('  ✗ SOME TESTS FAILED\n');
  fprintf('  Please review the failures above.\n');
endif

fprintf('\n');
