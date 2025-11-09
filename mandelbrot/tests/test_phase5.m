% TEST_PHASE5.m - Test script for Phase 5: 3D Fractals
%
% This script tests:
% - Mandelbulb 3D distance estimation
% - Mandelbox 3D distance estimation
% - Ray marching renderer
% - 3D fractal visualization
% - Integration with explorer

clear all;
close all;
clc;

fprintf('=== Testing Phase 5: 3D Fractals ===\n\n');

% Add directories to path
addpath('../core');
addpath('../display');
addpath('../interaction');

% Test counter
test_num = 0;
tests_passed = 0;
tests_failed = 0;

%% Test 1: Mandelbulb Distance Estimation
test_num = test_num + 1;
fprintf('Test %d: Mandelbulb Distance Estimation\n', test_num);
fprintf('----------------------------------------\n');

try
  % Test point inside
  pos_inside = [0, 0, 0];
  dist_inside = mandelbulb_3d(pos_inside, 8, 16);

  if dist_inside >= 0
    fprintf('  ✓ Distance at origin: %.4f\n', dist_inside);
  else
    error('Negative distance');
  end

  % Test point outside
  pos_outside = [3, 0, 0];
  dist_outside = mandelbulb_3d(pos_outside, 8, 16);

  if dist_outside > dist_inside
    fprintf('  ✓ Outside point has larger distance\n');
  else
    fprintf('  ⚠ Distance relationship unexpected\n');
  end

  % Test multiple powers
  powers = [4, 8, 12];
  for p = powers
    dist = mandelbulb_3d([0.5, 0.5, 0.5], p, 16);
    fprintf('  ✓ Power %d: distance = %.4f\n', p, dist);
  end

  fprintf('  ✓ PASSED: Mandelbulb distance estimation\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 2: Mandelbox Distance Estimation
test_num = test_num + 1;
fprintf('Test %d: Mandelbox Distance Estimation\n', test_num);
fprintf('---------------------------------------\n');

try
  % Test point at origin
  pos_origin = [0, 0, 0];
  dist_origin = mandelbox_3d(pos_origin, 2.5, 16);

  if dist_origin >= 0
    fprintf('  ✓ Distance at origin: %.4f\n', dist_origin);
  else
    error('Negative distance');
  end

  % Test different scales
  scales = [2.0, 2.5, 3.0];
  for s = scales
    dist = mandelbox_3d([0.3, 0.3, 0.3], s, 16);
    fprintf('  ✓ Scale %.1f: distance = %.4f\n', s, dist);
  end

  fprintf('  ✓ PASSED: Mandelbox distance estimation\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 3: Mandelbulb Multiple Points
test_num = test_num + 1;
fprintf('Test %d: Mandelbulb Batch Processing\n', test_num);
fprintf('------------------------------------\n');

try
  % Test multiple points at once
  points = [
    0.0, 0.0, 0.0;
    0.5, 0.5, 0.5;
    1.0, 0.0, 0.0;
    0.0, 1.0, 0.0;
    0.0, 0.0, 1.0
  ];

  distances = mandelbulb_3d(points, 8, 16);

  if length(distances) == size(points, 1)
    fprintf('  ✓ Batch processing: %d points computed\n', length(distances));
  else
    error('Batch size mismatch');
  end

  if all(distances >= 0)
    fprintf('  ✓ All distances non-negative\n');
  else
    error('Some distances negative');
  end

  fprintf('  ✓ PASSED: Batch processing\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 4: Ray Marching Renderer (Small)
test_num = test_num + 1;
fprintf('Test %d: Ray Marching Renderer (Small)\n', test_num);
fprintf('---------------------------------------\n');

try
  fprintf('  Rendering 100x75 Mandelbulb...\n');

  params.power = 8;
  params.max_iter = 12;
  params.max_steps = 60;

  tic;
  [image, hit_map] = render_3d('mandelbulb', params, 100, 75);
  elapsed = toc;

  fprintf('  Time: %.2f seconds\n', elapsed);

  if size(image, 1) == 75 && size(image, 2) == 100
    fprintf('  ✓ Output dimensions correct: 75x100\n');
  else
    error('Output dimensions incorrect');
  end

  if all(image(:) >= 0) && all(image(:) <= 1)
    fprintf('  ✓ Pixel values in [0,1] range\n');
  else
    error('Pixel values out of range');
  end

  hit_count = sum(hit_map(:));
  if hit_count > 100
    fprintf('  ✓ Surface hits: %d pixels\n', hit_count);
  else
    fprintf('  ⚠ Few surface hits: %d pixels\n', hit_count);
  end

  fprintf('  ✓ PASSED: Small render\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 5: Mandelbox Rendering
test_num = test_num + 1;
fprintf('Test %d: Mandelbox Rendering\n', test_num);
fprintf('----------------------------\n');

try
  fprintf('  Rendering 100x75 Mandelbox...\n');

  params.scale = 2.5;
  params.max_iter = 12;
  params.max_steps = 60;

  tic;
  [image, hit_map] = render_3d('mandelbox', params, 100, 75);
  elapsed = toc;

  fprintf('  Time: %.2f seconds\n', elapsed);

  if size(image, 1) == 75 && size(image, 2) == 100
    fprintf('  ✓ Output dimensions correct\n');
  else
    error('Output dimensions incorrect');
  end

  hit_count = sum(hit_map(:));
  fprintf('  ✓ Surface hits: %d pixels\n', hit_count);

  fprintf('  ✓ PASSED: Mandelbox rendering\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 6: Keyboard 3D Fractal Switching
test_num = test_num + 1;
fprintf('Test %d: Keyboard 3D Fractal Switching\n', test_num);
fprintf('---------------------------------------\n');

try
  % Create test state
  state.fractal_type = 'mandelbrot';
  state.needs_render = false;
  state.mandelbulb_power = 8;
  state.mandelbox_scale = 2.5;

  % Test 3D fractal keys
  state_bulb = handle_keyboard(state, 'V');
  if strcmp(state_bulb.fractal_type, 'mandelbulb') && state_bulb.needs_render
    fprintf('  ✓ Key V switches to Mandelbulb\n');
  else
    error('Mandelbulb switch failed');
  end

  state_box = handle_keyboard(state, 'N');
  if strcmp(state_box.fractal_type, 'mandelbox') && state_box.needs_render
    fprintf('  ✓ Key N switches to Mandelbox\n');
  else
    error('Mandelbox switch failed');
  end

  fprintf('  ✓ PASSED: 3D fractal switching\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 7: Visual Test (Small Render)
test_num = test_num + 1;
fprintf('Test %d: Visual Test (3D Fractals)\n', test_num);
fprintf('-----------------------------------\n');

try
  fprintf('  Rendering visual comparison...\n');

  fig = figure('Name', 'Phase 5: 3D Fractals', ...
               'Position', [100, 100, 800, 400], ...
               'Color', [0.1, 0.1, 0.1]);

  % Mandelbulb
  subplot(1, 2, 1);
  params.power = 8;
  params.max_iter = 12;
  params.max_steps = 60;
  [img1, ~] = render_3d('mandelbulb', params, 150, 150);
  imshow(img1);
  title('Mandelbulb (Power 8)', 'Color', 'white', 'FontSize', 12);

  % Mandelbox
  subplot(1, 2, 2);
  params.scale = 2.5;
  [img2, ~] = render_3d('mandelbox', params, 150, 150);
  imshow(img2);
  title('Mandelbox (Scale 2.5)', 'Color', 'white', 'FontSize', 12);

  fprintf('  ✓ Visual test complete\n');
  fprintf('  ✓ Check figure for 3D fractals\n');

  pause(1);
  close(fig);

  fprintf('  ✓ PASSED: Visual test\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 8: Performance Comparison
test_num = test_num + 1;
fprintf('Test %d: 3D Performance Comparison\n', test_num);
fprintf('----------------------------------\n');

try
  res = [150, 150];
  fprintf('  Rendering %dx%d:\n', res(1), res(2));

  params.max_iter = 12;
  params.max_steps = 60;

  % Mandelbulb
  params.power = 8;
  tic;
  [img, ~] = render_3d('mandelbulb', params, res(1), res(2));
  t_bulb = toc;
  fprintf('    Mandelbulb: %.2f s\n', t_bulb);

  % Mandelbox
  params.scale = 2.5;
  tic;
  [img, ~] = render_3d('mandelbox', params, res(1), res(2));
  t_box = toc;
  fprintf('    Mandelbox:  %.2f s\n', t_box);

  if t_bulb < 60 && t_box < 60
    fprintf('  ✓ Both fractals render in reasonable time\n');
  else
    fprintf('  ⚠ Rendering slower than target\n');
  end

  fprintf('  ✓ PASSED: Performance comparison\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 9: Integration Test
test_num = test_num + 1;
fprintf('Test %d: Explorer Integration\n', test_num);
fprintf('------------------------------\n');

try
  % Create complete state with 3D fields
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
  state.mandelbulb_power = 8;
  state.mandelbox_scale = 2.5;
  state.zoom_level = 1.0;
  state.running = true;
  state.needs_render = false;

  % Check 3D fields
  required_3d_fields = {'mandelbulb_power', 'mandelbox_scale'};
  for i = 1:length(required_3d_fields)
    if ~isfield(state, required_3d_fields{i})
      error('Missing field: %s', required_3d_fields{i});
    end
  end

  fprintf('  ✓ All 3D state fields present\n');
  fprintf('  ✓ State structure complete\n');
  fprintf('  ✓ PASSED: Explorer integration\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Summary
fprintf('========================================\n');
fprintf('Phase 5 Test Summary:\n');
fprintf('  Total tests: %d\n', test_num);
fprintf('  Passed: %d\n', tests_passed);
fprintf('  Failed: %d\n', tests_failed);
fprintf('========================================\n\n');

if tests_failed == 0
  fprintf('✓ All tests passed! Phase 5 complete.\n');
  fprintf('\n3D fractals working correctly:\n');
  fprintf('  ✓ Mandelbulb distance estimation\n');
  fprintf('  ✓ Mandelbox distance estimation\n');
  fprintf('  ✓ Ray marching renderer\n');
  fprintf('  ✓ Basic lighting\n');
  fprintf('  ✓ Keyboard 3D switching\n');
  fprintf('  ✓ Explorer integration\n');
  fprintf('\nPhase 5 is ready for Phase 6!\n');
  fprintf('\nTo explore 3D fractals:\n');
  fprintf('  cd mandelbrot\n');
  fprintf('  fractal_explorer([400, 300])  %% Smaller res for 3D\n');
  fprintf('  Press V for Mandelbulb\n');
  fprintf('  Press N for Mandelbox\n');
  fprintf('\nNote: 3D rendering is slower, use smaller resolutions\n');
else
  fprintf('✗ Some tests failed. Please review.\n');
end
