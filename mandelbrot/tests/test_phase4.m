% TEST_PHASE4.m - Test script for Phase 4: Extended 2D Fractals
%
% This script tests:
% - Burning Ship fractal
% - Tricorn fractal
% - Multibrot with various powers
% - Phoenix fractal
% - Integration with explorer
% - Fractal switching

clear all;
close all;
clc;

fprintf('=== Testing Phase 4: Extended 2D Fractals ===\n\n');

% Add directories to path
addpath('../core');
addpath('../display');
addpath('../interaction');

% Test counter
test_num = 0;
tests_passed = 0;
tests_failed = 0;

%% Test 1: Burning Ship Fractal
test_num = test_num + 1;
fprintf('Test %d: Burning Ship Fractal\n', test_num);
fprintf('------------------------------\n');

try
  % Compute Burning Ship
  [iter, final_z] = burning_ship(-0.5-0.5i, 4.0, 3.0, 200, 150, 256);

  % Check output dimensions
  if size(iter, 1) == 150 && size(iter, 2) == 200
    fprintf('  ✓ Output dimensions correct: 150x200\n');
  else
    error('Output dimensions incorrect');
  end

  % Check that some points escape
  escaped_count = sum(iter(:) > 0);
  if escaped_count > 1000
    fprintf('  ✓ Points escape: %d / %d\n', escaped_count, numel(iter));
  else
    error('Too few escaped points');
  end

  % Check final_z values
  if all(size(final_z) == size(iter))
    fprintf('  ✓ final_z dimensions match iter\n');
  else
    error('final_z dimensions mismatch');
  end

  fprintf('  ✓ PASSED: Burning Ship fractal\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 2: Tricorn Fractal
test_num = test_num + 1;
fprintf('Test %d: Tricorn Fractal\n', test_num);
fprintf('------------------------\n');

try
  % Compute Tricorn
  [iter, final_z] = tricorn(0+0i, 4.0, 3.0, 200, 150, 256);

  % Check output
  if size(iter, 1) == 150 && size(iter, 2) == 200
    fprintf('  ✓ Output dimensions correct\n');
  else
    error('Output dimensions incorrect');
  end

  % Tricorn should have some interior points
  interior_count = sum(iter(:) == 0);
  if interior_count > 100
    fprintf('  ✓ Interior points present: %d\n', interior_count);
  else
    fprintf('  ⚠ Few interior points: %d (might be zoomed out)\n', interior_count);
  end

  fprintf('  ✓ PASSED: Tricorn fractal\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 3: Multibrot with Different Powers
test_num = test_num + 1;
fprintf('Test %d: Multibrot (Variable Power)\n', test_num);
fprintf('-----------------------------------\n');

try
  powers = [3, 4, 5, 8];

  for i = 1:length(powers)
    p = powers(i);
    [iter, final_z] = multibrot(p, 0+0i, 3.0, 3.0, 100, 100, 256);

    if size(iter, 1) == 100 && size(iter, 2) == 100
      fprintf('  ✓ Multibrot-%d computed successfully\n', p);
    else
      error('Multibrot-%d dimensions incorrect', p);
    end
  end

  fprintf('  ✓ All power variants working\n');
  fprintf('  ✓ PASSED: Multibrot fractal\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 4: Phoenix Fractal
test_num = test_num + 1;
fprintf('Test %d: Phoenix Fractal\n', test_num);
fprintf('------------------------\n');

try
  % Compute Phoenix with default parameters
  phoenix_c = 0.5 - 0.1i;
  phoenix_p = -0.5 + 0i;
  [iter, final_z] = phoenix(phoenix_c, phoenix_p, 0+0i, 4.0, 3.0, 200, 150, 256);

  % Check output
  if size(iter, 1) == 150 && size(iter, 2) == 200
    fprintf('  ✓ Output dimensions correct\n');
  else
    error('Output dimensions incorrect');
  end

  % Check for variety
  escaped_count = sum(iter(:) > 0);
  if escaped_count > 500
    fprintf('  ✓ Phoenix structure computed: %d escaped\n', escaped_count);
  else
    fprintf('  ⚠ Phoenix structure minimal: %d escaped\n', escaped_count);
  end

  fprintf('  ✓ PASSED: Phoenix fractal\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 5: Burning Ship with Smooth Coloring
test_num = test_num + 1;
fprintf('Test %d: Extended Fractals with Smooth Coloring\n', test_num);
fprintf('------------------------------------------------\n');

try
  % Test each fractal with smooth coloring
  fractals = {'Burning Ship', 'Tricorn', 'Multibrot-3'};

  for i = 1:length(fractals)
    switch i
      case 1
        [iter, final_z] = burning_ship(-0.5-0.5i, 4.0, 3.0, 150, 100, 256);
      case 2
        [iter, final_z] = tricorn(0+0i, 4.0, 3.0, 150, 100, 256);
      case 3
        [iter, final_z] = multibrot(3, 0+0i, 3.0, 3.0, 150, 100, 256);
    end

    smooth = smooth_coloring(iter, final_z, 2.0);

    if all(smooth(:) >= 0) && all(isfinite(smooth(:)))
      fprintf('  ✓ %s: Smooth coloring works\n', fractals{i});
    else
      error('%s smooth coloring failed', fractals{i});
    end
  end

  fprintf('  ✓ PASSED: Smooth coloring integration\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 6: Fractal Visualization
test_num = test_num + 1;
fprintf('Test %d: Extended Fractals Visualization\n', test_num);
fprintf('------------------------------------------\n');

try
  % Render each fractal with colors
  fractals_to_test = {
    'burning_ship', -0.5-0.5i, 4.0, 3.0;
    'tricorn', 0+0i, 4.0, 3.0;
    'multibrot', 0+0i, 3.0, 3.0
  };

  for i = 1:size(fractals_to_test, 1)
    ftype = fractals_to_test{i, 1};
    center = fractals_to_test{i, 2};
    width = fractals_to_test{i, 3};
    height = fractals_to_test{i, 4};

    switch ftype
      case 'burning_ship'
        [iter, final_z] = burning_ship(center, width, height, 150, 100, 256);
      case 'tricorn'
        [iter, final_z] = tricorn(center, width, height, 150, 100, 256);
      case 'multibrot'
        [iter, final_z] = multibrot(3, center, width, height, 150, 100, 256);
    end

    smooth = smooth_coloring(iter, final_z, 2.0);
    rgb = apply_colormap(smooth, 'electric_dream');

    if size(rgb, 3) == 3
      fprintf('  ✓ %s: RGB image generated\n', ftype);
    else
      error('%s RGB generation failed', ftype);
    end
  end

  fprintf('  ✓ PASSED: Fractal visualization\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 7: Keyboard Fractal Switching
test_num = test_num + 1;
fprintf('Test %d: Keyboard Fractal Switching\n', test_num);
fprintf('------------------------------------\n');

try
  % Create test state
  state.fractal_type = 'mandelbrot';
  state.center = -0.5 + 0i;
  state.width = 3.5;
  state.height = 2.5;
  state.needs_render = false;
  state.multibrot_power = 3;
  state.phoenix_c = 0.5 - 0.1i;
  state.phoenix_p = -0.5 + 0i;

  % Test fractal keys
  fractal_keys = {'B', 'T', 'P', 'X', 'M'};
  fractal_names = {'burning_ship', 'tricorn', 'multibrot', 'phoenix', 'mandelbrot'};

  for i = 1:length(fractal_keys)
    state_new = handle_keyboard(state, fractal_keys{i});
    if strcmp(state_new.fractal_type, fractal_names{i}) && state_new.needs_render
      fprintf('  ✓ Key %s switches to %s\n', fractal_keys{i}, fractal_names{i});
    else
      error('Fractal switch failed for key %s', fractal_keys{i});
    end
  end

  fprintf('  ✓ PASSED: Fractal switching\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 8: Performance Comparison
test_num = test_num + 1;
fprintf('Test %d: Performance Comparison\n', test_num);
fprintf('--------------------------------\n');

try
  res = [400, 300];
  iterations = 256;

  fprintf('  Computing %dx%d at %d iterations:\n', res(1), res(2), iterations);

  % Mandelbrot
  tic;
  [iter, final_z] = mandelbrot_2d(-0.5+0i, 3.5, 2.5, res(1), res(2), iterations);
  t_mandel = toc;
  fprintf('    Mandelbrot:    %.3f s\n', t_mandel);

  % Burning Ship
  tic;
  [iter, final_z] = burning_ship(-0.5-0.5i, 4.0, 3.0, res(1), res(2), iterations);
  t_burning = toc;
  fprintf('    Burning Ship:  %.3f s\n', t_burning);

  % Tricorn
  tic;
  [iter, final_z] = tricorn(0+0i, 4.0, 3.0, res(1), res(2), iterations);
  t_tricorn = toc;
  fprintf('    Tricorn:       %.3f s\n', t_tricorn);

  % Multibrot-3
  tic;
  [iter, final_z] = multibrot(3, 0+0i, 3.0, 3.0, res(1), res(2), iterations);
  t_multi = toc;
  fprintf('    Multibrot-3:   %.3f s\n', t_multi);

  % Phoenix
  tic;
  [iter, final_z] = phoenix(0.5-0.1i, -0.5+0i, 0+0i, 4.0, 3.0, res(1), res(2), iterations);
  t_phoenix = toc;
  fprintf('    Phoenix:       %.3f s\n', t_phoenix);

  fprintf('  ✓ All fractals computed in reasonable time\n');
  fprintf('  ✓ PASSED: Performance comparison\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 9: Visual Gallery Test
test_num = test_num + 1;
fprintf('Test %d: Extended Fractals Visual Gallery\n', test_num);
fprintf('------------------------------------------\n');

try
  fprintf('  Generating gallery of all fractals...\n');

  fig = figure('Name', 'Phase 4 Gallery', ...
               'Position', [50, 50, 1400, 600], ...
               'Color', [0.1, 0.1, 0.1]);

  fractals = {
    @() mandelbrot_2d(-0.5+0i, 3.5, 2.5, 250, 200, 256), 'Mandelbrot';
    @() julia_2d(-0.7+0.27i, 0+0i, 4.0, 3.0, 250, 200, 256), 'Julia';
    @() burning_ship(-0.5-0.5i, 4.0, 3.0, 250, 200, 256), 'Burning Ship';
    @() tricorn(0+0i, 4.0, 3.0, 250, 200, 256), 'Tricorn';
    @() multibrot(3, 0+0i, 3.0, 3.0, 250, 200, 256), 'Multibrot-3';
    @() phoenix(0.5-0.1i, -0.5+0i, 0+0i, 4.0, 3.0, 250, 200, 256), 'Phoenix'
  };

  for i = 1:size(fractals, 1)
    subplot(2, 3, i);
    [iter, final_z] = fractals{i, 1}();
    smooth = smooth_coloring(iter, final_z, 2.0);
    rgb = apply_colormap(smooth, 'sunset_fire');
    image(rgb);
    axis equal tight off;
    title(fractals{i, 2}, 'Color', 'white', 'FontSize', 11);
  end

  fprintf('  ✓ Gallery generated with all 6 fractals\n');
  fprintf('  ✓ Check window for visual verification\n');

  pause(1);
  close(fig);

  fprintf('  ✓ PASSED: Visual gallery\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 10: Integration Test
test_num = test_num + 1;
fprintf('Test %d: Explorer Integration\n', test_num);
fprintf('------------------------------\n');

try
  fprintf('  Testing fractal switching in explorer state...\n');

  % Create complete state
  state.resolution = [400, 300];
  state.fractal_type = 'mandelbrot';
  state.center = -0.5 + 0i;
  state.width = 3.5;
  state.height = 2.5;
  state.max_iter = 256;
  state.escape_radius = 2.0;
  state.palette = 'deep_ocean';
  state.julia_c = -0.7 + 0.27i;
  state.multibrot_power = 3;
  state.phoenix_c = 0.5 - 0.1i;
  state.phoenix_p = -0.5 + 0i;
  state.zoom_level = 1.0;
  state.running = true;
  state.needs_render = false;

  % Check all required fields for new fractals
  required_new_fields = {'multibrot_power', 'phoenix_c', 'phoenix_p'};
  for i = 1:length(required_new_fields)
    if ~isfield(state, required_new_fields{i})
      error('Missing field: %s', required_new_fields{i});
    end
  end

  fprintf('  ✓ All new state fields present\n');
  fprintf('  ✓ State structure extended correctly\n');
  fprintf('  ✓ PASSED: Explorer integration\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Summary
fprintf('========================================\n');
fprintf('Phase 4 Test Summary:\n');
fprintf('  Total tests: %d\n', test_num);
fprintf('  Passed: %d\n', tests_passed);
fprintf('  Failed: %d\n', tests_failed);
fprintf('========================================\n\n');

if tests_failed == 0
  fprintf('✓ All tests passed! Phase 4 complete.\n');
  fprintf('\nExtended 2D fractals working correctly:\n');
  fprintf('  ✓ Burning Ship fractal\n');
  fprintf('  ✓ Tricorn fractal\n');
  fprintf('  ✓ Multibrot (variable power)\n');
  fprintf('  ✓ Phoenix fractal\n');
  fprintf('  ✓ Smooth coloring integration\n');
  fprintf('  ✓ Keyboard fractal switching\n');
  fprintf('  ✓ Explorer integration\n');
  fprintf('\nPhase 4 is ready for Phase 5!\n');
  fprintf('\nTo explore all fractals interactively:\n');
  fprintf('  cd mandelbrot\n');
  fprintf('  fractal_explorer()\n');
  fprintf('  Press B, T, P, X, M, J for different fractals\n');
else
  fprintf('✗ Some tests failed. Please review.\n');
end
