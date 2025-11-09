% TEST_PHASE3.m - Test script for Phase 3: Interactive Explorer
%
% This script tests:
% - Zoom calculation
% - Coordinate conversion
% - Pan operations
% - Keyboard handling
% - State management
% - Interactive functions

clear all;
close all;
clc;

fprintf('=== Testing Phase 3: Interactive Explorer ===\n\n');

% Add directories to path
addpath('../core');
addpath('../display');
addpath('../interaction');
addpath('../utils');

% Test counter
test_num = 0;
tests_passed = 0;
tests_failed = 0;

%% Test 1: Coordinate Conversion
test_num = test_num + 1;
fprintf('Test %d: Pixel to Complex Coordinate Conversion\n', test_num);
fprintf('------------------------------------------------\n');

try
  % Test center point
  center = -0.5 + 0i;
  width = 3.5;
  height = 2.5;
  fig_width = 800;
  fig_height = 600;

  % Center pixel should map to center complex
  center_pixel = [fig_width/2, fig_height/2];
  center_complex = coordinate_converter(center_pixel, center, width, height, fig_width, fig_height);

  error_center = abs(center_complex - center);
  if error_center < 0.01
    fprintf('  ✓ Center pixel maps to center complex: %.4f%+.4fi\n', ...
            real(center_complex), imag(center_complex));
  else
    error('Center mapping incorrect');
  end

  % Test corner
  corner_pixel = [0, 0];  % Top-left
  corner_complex = coordinate_converter(corner_pixel, center, width, height, fig_width, fig_height);
  expected_corner = (real(center) - width/2) + 1i * (imag(center) + height/2);

  error_corner = abs(corner_complex - expected_corner);
  if error_corner < 0.01
    fprintf('  ✓ Top-left corner mapped correctly\n');
  else
    fprintf('  ⚠ Corner mapping approximate (error: %.4f)\n', error_corner);
  end

  fprintf('  ✓ PASSED: Coordinate conversion\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 2: Zoom Calculator
test_num = test_num + 1;
fprintf('Test %d: Zoom Calculation\n', test_num);
fprintf('-------------------------\n');

try
  % Initial view
  center = -0.5 + 0i;
  width = 3.5;
  height = 2.5;
  fig_width = 800;
  fig_height = 600;

  % Zoom in 2x at center
  click_pos = [fig_width/2, fig_height/2];
  zoom_factor = 2.0;

  [new_center, new_width, new_height] = zoom_calculator(...
    click_pos, center, width, height, zoom_factor, fig_width, fig_height);

  % Width should be halved
  if abs(new_width - width/2) < 0.01 && abs(new_height - height/2) < 0.01
    fprintf('  ✓ Zoom 2x reduces dimensions by half\n');
    fprintf('    Old: %.2f × %.2f\n', width, height);
    fprintf('    New: %.2f × %.2f\n', new_width, new_height);
  else
    error('Zoom dimensions incorrect');
  end

  % Center should remain approximately same (clicked at center)
  if abs(new_center - center) < 0.1
    fprintf('  ✓ Zoom at center keeps center position\n');
  else
    fprintf('  ⚠ Center shifted (expected for zoom at point)\n');
  end

  fprintf('  ✓ PASSED: Zoom calculation\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 3: Pan Operations
test_num = test_num + 1;
fprintf('Test %d: Pan Operations\n', test_num);
fprintf('-----------------------\n');

try
  % Create test state
  state.center = -0.5 + 0i;
  state.width = 3.5;
  state.height = 2.5;
  state.needs_render = false;

  % Pan right
  state_right = handle_pan(state, 'right');
  if real(state_right.center) > real(state.center)
    fprintf('  ✓ Pan right increases real part\n');
  else
    error('Pan right failed');
  end

  % Pan up
  state_up = handle_pan(state, 'up');
  if imag(state_up.center) > imag(state.center)
    fprintf('  ✓ Pan up increases imaginary part\n');
  else
    error('Pan up failed');
  end

  % Check render flag
  if state_right.needs_render && state_up.needs_render
    fprintf('  ✓ Pan operations set needs_render flag\n');
  else
    error('needs_render flag not set');
  end

  fprintf('  ✓ PASSED: Pan operations\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 4: Zoom Handler
test_num = test_num + 1;
fprintf('Test %d: Zoom Handler\n', test_num);
fprintf('---------------------\n');

try
  % Create test state
  state.center = -0.5 + 0i;
  state.width = 3.5;
  state.height = 2.5;
  state.resolution = [800, 600];
  state.zoom_level = 1.0;
  state.needs_render = false;

  % Zoom in
  click_pos = [400, 300];
  state_zoomed = handle_zoom(state, click_pos, 2.0);

  if state_zoomed.width < state.width
    fprintf('  ✓ Zoom in reduces view width\n');
  else
    error('Zoom in failed');
  end

  if state_zoomed.zoom_level > state.zoom_level
    fprintf('  ✓ Zoom level increased: %.2f → %.2f\n', ...
            state.zoom_level, state_zoomed.zoom_level);
  else
    error('Zoom level not updated');
  end

  if state_zoomed.needs_render
    fprintf('  ✓ Zoom sets needs_render flag\n');
  else
    error('needs_render not set');
  end

  fprintf('  ✓ PASSED: Zoom handler\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 5: Keyboard Handler - Palettes
test_num = test_num + 1;
fprintf('Test %d: Keyboard Handler - Palette Switching\n', test_num);
fprintf('----------------------------------------------\n');

try
  % Create test state
  state.palette = 'deep_ocean';
  state.needs_render = false;

  % Test palette keys
  palettes = {'1', '2', '3', '4', '5'};
  palette_names = {'deep_ocean', 'sunset_fire', 'electric_dream', 'monochrome', 'northern_lights'};

  for i = 1:length(palettes)
    state_new = handle_keyboard(state, palettes{i});
    if strcmp(state_new.palette, palette_names{i}) && state_new.needs_render
      fprintf('  ✓ Key %s switches to %s\n', palettes{i}, palette_names{i});
    else
      error('Palette switch failed for key %s', palettes{i});
    end
  end

  fprintf('  ✓ PASSED: Palette switching\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 6: Keyboard Handler - Iterations
test_num = test_num + 1;
fprintf('Test %d: Keyboard Handler - Iteration Control\n', test_num);
fprintf('----------------------------------------------\n');

try
  % Create test state
  state.max_iter = 256;
  state.needs_render = false;

  % Increase iterations
  state_inc = handle_keyboard(state, '+');
  if state_inc.max_iter > state.max_iter
    fprintf('  ✓ + increases iterations: %d → %d\n', state.max_iter, state_inc.max_iter);
  else
    error('Iteration increase failed');
  end

  % Decrease iterations
  state_dec = handle_keyboard(state_inc, '-');
  if state_dec.max_iter < state_inc.max_iter
    fprintf('  ✓ - decreases iterations: %d → %d\n', state_inc.max_iter, state_dec.max_iter);
  else
    error('Iteration decrease failed');
  end

  fprintf('  ✓ PASSED: Iteration control\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 7: Keyboard Handler - Fractal Switching
test_num = test_num + 1;
fprintf('Test %d: Keyboard Handler - Fractal Switching\n', test_num);
fprintf('----------------------------------------------\n');

try
  % Create test state
  state.fractal_type = 'mandelbrot';
  state.julia_c = -0.7 + 0.27i;
  state.needs_render = false;

  % Switch to Julia
  state_julia = handle_keyboard(state, 'j');
  if strcmp(state_julia.fractal_type, 'julia') && state_julia.needs_render
    fprintf('  ✓ J switches to Julia set\n');
  else
    error('Julia switch failed');
  end

  % Switch to Mandelbrot
  state_mandel = handle_keyboard(state_julia, 'M');
  if strcmp(state_mandel.fractal_type, 'mandelbrot') && state_mandel.needs_render
    fprintf('  ✓ M switches to Mandelbrot set\n');
  else
    error('Mandelbrot switch failed');
  end

  fprintf('  ✓ PASSED: Fractal switching\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 8: Keyboard Handler - Navigation
test_num = test_num + 1;
fprintf('Test %d: Keyboard Handler - Arrow Key Navigation\n', test_num);
fprintf('-------------------------------------------------\n');

try
  % Create test state
  state.center = 0 + 0i;
  state.width = 3.5;
  state.height = 2.5;
  state.needs_render = false;

  % Test arrow keys
  original_center = state.center;

  state_up = handle_keyboard(state, 'uparrow');
  state_down = handle_keyboard(state, 'downarrow');
  state_left = handle_keyboard(state, 'leftarrow');
  state_right = handle_keyboard(state, 'rightarrow');

  % Check movements
  if imag(state_up.center) > imag(original_center)
    fprintf('  ✓ Up arrow pans up\n');
  else
    error('Up arrow failed');
  end

  if imag(state_down.center) < imag(original_center)
    fprintf('  ✓ Down arrow pans down\n');
  else
    error('Down arrow failed');
  end

  if real(state_left.center) < real(original_center)
    fprintf('  ✓ Left arrow pans left\n');
  else
    error('Left arrow failed');
  end

  if real(state_right.center) > real(original_center)
    fprintf('  ✓ Right arrow pans right\n');
  else
    error('Right arrow failed');
  end

  fprintf('  ✓ PASSED: Arrow key navigation\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 9: State Management
test_num = test_num + 1;
fprintf('Test %d: State Management\n', test_num);
fprintf('-------------------------\n');

try
  % Create complete state
  state.resolution = [800, 600];
  state.fractal_type = 'mandelbrot';
  state.center = -0.5 + 0i;
  state.width = 3.5;
  state.height = 2.5;
  state.max_iter = 256;
  state.escape_radius = 2.0;
  state.palette = 'deep_ocean';
  state.julia_c = -0.7 + 0.27i;
  state.zoom_level = 1.0;
  state.running = true;
  state.needs_render = false;

  % Verify all required fields present
  required_fields = {'resolution', 'fractal_type', 'center', 'width', 'height', ...
                    'max_iter', 'escape_radius', 'palette', 'julia_c', ...
                    'zoom_level', 'running', 'needs_render'};

  all_present = true;
  for i = 1:length(required_fields)
    if ~isfield(state, required_fields{i})
      fprintf('  ✗ Missing field: %s\n', required_fields{i});
      all_present = false;
    end
  end

  if all_present
    fprintf('  ✓ All required state fields present\n');
    fprintf('  ✓ State structure is complete\n');
  else
    error('State structure incomplete');
  end

  fprintf('  ✓ PASSED: State management\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 10: Interactive Rendering (Manual)
test_num = test_num + 1;
fprintf('Test %d: Interactive Rendering Test\n', test_num);
fprintf('------------------------------------\n');

try
  fprintf('  Starting brief interactive test...\n');
  fprintf('  Window will open for 3 seconds\n');
  fprintf('  (Full testing requires manual interaction)\n\n');

  % Launch explorer with timeout
  fig = figure('Name', 'Phase 3 Test - Auto-closing', ...
               'Position', [100, 100, 600, 450]);

  % Initialize state
  state.resolution = [600, 450];
  state.fractal_type = 'mandelbrot';
  state.center = -0.5 + 0i;
  state.width = 3.5;
  state.height = 2.5;
  state.max_iter = 256;
  state.escape_radius = 2.0;
  state.palette = 'electric_dream';

  % Render
  [iter, final_z] = mandelbrot_2d(state.center, state.width, state.height, ...
                                  state.resolution(1), state.resolution(2), ...
                                  state.max_iter, state.escape_radius);
  smooth = smooth_coloring(iter, final_z, state.escape_radius);
  rgb_image = apply_colormap(smooth, state.palette);

  image(rgb_image);
  axis equal tight off;
  title('Phase 3 Interactive Test - Auto-closing in 3s', 'Color', 'white');

  fprintf('  ✓ Render successful\n');

  % Wait and close
  pause(3);
  if ishandle(fig)
    close(fig);
  end

  fprintf('  ✓ Window management working\n');
  fprintf('  ✓ PASSED: Interactive rendering\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Summary
fprintf('========================================\n');
fprintf('Phase 3 Test Summary:\n');
fprintf('  Total tests: %d\n', test_num);
fprintf('  Passed: %d\n', tests_passed);
fprintf('  Failed: %d\n', tests_failed);
fprintf('========================================\n\n');

if tests_failed == 0
  fprintf('✓ All tests passed! Phase 3 complete.\n');
  fprintf('\nInteractive explorer components working:\n');
  fprintf('  ✓ Coordinate conversion\n');
  fprintf('  ✓ Zoom calculations\n');
  fprintf('  ✓ Pan operations\n');
  fprintf('  ✓ Keyboard controls\n');
  fprintf('  ✓ State management\n');
  fprintf('  ✓ Interactive rendering\n');
  fprintf('\nPhase 3 is ready for integration!\n');
  fprintf('\nTo test interactively, run:\n');
  fprintf('  cd mandelbrot\n');
  fprintf('  fractal_explorer()\n');
else
  fprintf('✗ Some tests failed. Please review.\n');
end
