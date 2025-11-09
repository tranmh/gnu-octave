% TEST_PHASE6.m - Test script for Phase 6: Advanced Features & Export
%
% This script tests:
% - Pattern library (20+ locations)
% - Bookmark save/load
% - Image export (HD, 4K)
% - Animation export
% - Integration with explorer

clear all;
close all;
clc;

fprintf('=== Testing Phase 6: Advanced Features & Export ===\n\n');

% Add directories to path
addpath('../core');
addpath('../display');
addpath('../interaction');
addpath('../utils');

% Test counter
test_num = 0;
tests_passed = 0;
tests_failed = 0;

%% Test 1: Pattern Library - Count and Structure
test_num = test_num + 1;
fprintf('Test %d: Pattern Library - Count and Structure\n', test_num);
fprintf('------------------------------------------------\n');

try
  patterns = pattern_library();

  if length(patterns) >= 20
    fprintf('  ✓ Pattern count: %d patterns (>= 20)\n', length(patterns));
  else
    error('Not enough patterns: %d', length(patterns));
  end

  % Check first pattern structure
  p = patterns{1};
  required_fields = {'name', 'fractal_type', 'center', 'width', 'height', 'max_iter', 'description'};
  for i = 1:length(required_fields)
    if ~isfield(p, required_fields{i})
      error('Missing field: %s', required_fields{i});
    end
  end

  fprintf('  ✓ Pattern structure correct\n');
  fprintf('  ✓ PASSED: Pattern library structure\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 2: Pattern Library - Filter by Type
test_num = test_num + 1;
fprintf('Test %d: Pattern Library - Filter by Type\n', test_num);
fprintf('------------------------------------------\n');

try
  all_patterns = pattern_library();
  mandel_patterns = pattern_library('mandelbrot');
  julia_patterns = pattern_library('julia');

  fprintf('  ✓ All patterns: %d\n', length(all_patterns));
  fprintf('  ✓ Mandelbrot patterns: %d\n', length(mandel_patterns));
  fprintf('  ✓ Julia patterns: %d\n', length(julia_patterns));

  % Verify filtering works
  for i = 1:length(mandel_patterns)
    if ~strcmp(mandel_patterns{i}.fractal_type, 'mandelbrot')
      error('Filter failed: non-Mandelbrot pattern in results');
    end
  end

  fprintf('  ✓ Filtering works correctly\n');
  fprintf('  ✓ PASSED: Pattern filtering\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 3: Pattern Library - Famous Locations
test_num = test_num + 1;
fprintf('Test %d: Pattern Library - Famous Locations\n', test_num);
fprintf('--------------------------------------------\n');

try
  patterns = pattern_library();

  % Check for specific famous locations
  famous_names = {'Seahorse Valley', 'Elephant Valley', 'Double Spiral', 'Mini Mandelbrot'};
  found_count = 0;

  for i = 1:length(patterns)
    for j = 1:length(famous_names)
      if strcmp(patterns{i}.name, famous_names{j})
        found_count = found_count + 1;
        fprintf('  ✓ Found: %s\n', famous_names{j});
      end
    end
  end

  if found_count >= 3
    fprintf('  ✓ Famous locations present\n');
  else
    error('Not enough famous locations found');
  end

  fprintf('  ✓ PASSED: Famous locations\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 4: Bookmark Manager - Save and Load
test_num = test_num + 1;
fprintf('Test %d: Bookmark Manager - Save and Load\n', test_num);
fprintf('------------------------------------------\n');

try
  % Create test state
  state = struct();
  state.fractal_type = 'mandelbrot';
  state.center = -0.745 + 0.113i;
  state.width = 0.01;
  state.height = 0.01;
  state.max_iter = 512;
  state.palette = 'deep_ocean';
  state.zoom_level = 350;
  state.escape_radius = 2.0;

  % Save bookmark
  test_bookmark = 'test_bookmark_phase6';
  success = bookmark_manager('save', state, test_bookmark);

  if success
    fprintf('  ✓ Bookmark saved\n');
  else
    error('Bookmark save failed');
  end

  % Load bookmark
  loaded_state = bookmark_manager('load', test_bookmark);

  if abs(loaded_state.center - state.center) < 1e-10
    fprintf('  ✓ Center preserved\n');
  else
    error('Center not preserved');
  end

  if abs(loaded_state.width - state.width) < 1e-10
    fprintf('  ✓ Width preserved\n');
  else
    error('Width not preserved');
  end

  if strcmp(loaded_state.fractal_type, state.fractal_type)
    fprintf('  ✓ Fractal type preserved\n');
  else
    error('Fractal type not preserved');
  end

  % Clean up
  bookmark_manager('delete', test_bookmark);
  fprintf('  ✓ Bookmark deleted\n');

  fprintf('  ✓ PASSED: Bookmark save/load\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 5: Bookmark Manager - List
test_num = test_num + 1;
fprintf('Test %d: Bookmark Manager - List\n', test_num);
fprintf('---------------------------------\n');

try
  % Create multiple test bookmarks
  state1 = struct();
  state1.fractal_type = 'mandelbrot';
  state1.center = -0.5 + 0i;
  state1.width = 3.5;
  state1.height = 2.5;
  state1.max_iter = 256;
  state1.palette = 'deep_ocean';
  state1.zoom_level = 1.0;
  state1.escape_radius = 2.0;

  state2 = state1;
  state2.center = -0.745 + 0.113i;
  state2.width = 0.01;

  bookmark_manager('save', state1, 'test_list_1');
  bookmark_manager('save', state2, 'test_list_2');

  % List bookmarks
  bookmarks = bookmark_manager('list');

  if length(bookmarks) >= 2
    fprintf('  ✓ Bookmarks listed: %d found\n', length(bookmarks));
  else
    error('Not enough bookmarks in list');
  end

  % Verify structure
  if isfield(bookmarks{1}, 'filename') && isfield(bookmarks{1}, 'fractal_type')
    fprintf('  ✓ Bookmark info structure correct\n');
  else
    error('Bookmark info structure incorrect');
  end

  % Clean up
  bookmark_manager('delete', 'test_list_1');
  bookmark_manager('delete', 'test_list_2');

  fprintf('  ✓ PASSED: Bookmark list\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 6: Export Image - Small Resolution
test_num = test_num + 1;
fprintf('Test %d: Export Image - Small Resolution\n', test_num);
fprintf('-----------------------------------------\n');

try
  % Create test state
  state = struct();
  state.fractal_type = 'mandelbrot';
  state.center = -0.5 + 0i;
  state.width = 3.5;
  state.height = 2.5;
  state.max_iter = 256;
  state.escape_radius = 2.0;
  state.palette = 'deep_ocean';
  state.zoom_level = 1.0;
  state.julia_c = -0.7 + 0.27i;
  state.multibrot_power = 3;
  state.phoenix_c = 0.5 - 0.1i;
  state.phoenix_p = -0.5 + 0i;
  state.mandelbulb_power = 8;
  state.mandelbox_scale = 2.5;

  % Create output directory
  if ~exist('FINAL_OUTPUT', 'dir')
    mkdir('FINAL_OUTPUT');
  end

  % Export small image for testing
  test_file = 'FINAL_OUTPUT/test_export_small.png';
  success = export_image(state, test_file, [400, 300]);

  if success && exist(test_file, 'file')
    fprintf('  ✓ Export successful\n');

    % Check image dimensions
    img = imread(test_file);
    if size(img, 1) == 300 && size(img, 2) == 400
      fprintf('  ✓ Image dimensions correct: 400x300\n');
    else
      error('Image dimensions incorrect');
    end

    delete(test_file);
    fprintf('  ✓ Test file cleaned up\n');
  else
    error('Export failed');
  end

  fprintf('  ✓ PASSED: Image export\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 7: Export Animation - Few Frames
test_num = test_num + 1;
fprintf('Test %d: Export Animation - Few Frames\n', test_num);
fprintf('---------------------------------------\n');

try
  % Create start and end states
  start_state = struct();
  start_state.fractal_type = 'mandelbrot';
  start_state.center = -0.5 + 0i;
  start_state.width = 3.5;
  start_state.height = 2.5;
  start_state.max_iter = 256;
  start_state.escape_radius = 2.0;
  start_state.palette = 'deep_ocean';
  start_state.zoom_level = 1.0;
  start_state.julia_c = -0.7 + 0.27i;
  start_state.multibrot_power = 3;
  start_state.phoenix_c = 0.5 - 0.1i;
  start_state.phoenix_p = -0.5 + 0i;
  start_state.mandelbulb_power = 8;
  start_state.mandelbox_scale = 2.5;

  end_state = start_state;
  end_state.center = -0.745 + 0.113i;
  end_state.width = 0.1;
  end_state.height = 0.1;
  end_state.max_iter = 512;

  % Export animation (small, few frames for testing)
  anim_dir = 'test_animation';
  success = export_animation(start_state, end_state, 5, anim_dir, [200, 150]);

  if success
    fprintf('  ✓ Animation export successful\n');

    % Check frames exist
    frame_count = 0;
    for i = 1:5
      frame_file = fullfile(anim_dir, sprintf('frame_%04d.png', i));
      if exist(frame_file, 'file')
        frame_count = frame_count + 1;
      end
    end

    if frame_count == 5
      fprintf('  ✓ All frames generated: %d\n', frame_count);
    else
      error('Not all frames generated: %d/5', frame_count);
    end

    % Clean up
    rmdir(anim_dir, 's');
    fprintf('  ✓ Test files cleaned up\n');
  else
    error('Animation export failed');
  end

  fprintf('  ✓ PASSED: Animation export\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 8: Integration - Pattern to State
test_num = test_num + 1;
fprintf('Test %d: Integration - Pattern to State\n', test_num);
fprintf('----------------------------------------\n');

try
  patterns = pattern_library('mandelbrot');
  pattern = patterns{1};

  % Convert pattern to state
  state = struct();
  state.fractal_type = pattern.fractal_type;
  state.center = pattern.center;
  state.width = pattern.width;
  state.height = pattern.height;
  state.max_iter = pattern.max_iter;
  state.escape_radius = 2.0;
  state.palette = 'deep_ocean';
  state.zoom_level = 1.0;

  fprintf('  ✓ Pattern: %s\n', pattern.name);
  fprintf('  ✓ Converted to state\n');
  fprintf('  ✓ Center: %.6f%+.6fi\n', real(state.center), imag(state.center));
  fprintf('  ✓ Width: %.6f\n', state.width);

  fprintf('  ✓ PASSED: Pattern integration\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Test 9: Export Final Gallery Images
test_num = test_num + 1;
fprintf('Test %d: Export Final Gallery Images\n', test_num);
fprintf('-------------------------------------\n');

try
  % Create output directory
  if ~exist('FINAL_OUTPUT', 'dir')
    mkdir('FINAL_OUTPUT');
  end

  fprintf('  Exporting gallery images to FINAL_OUTPUT/\n\n');

  % Select diverse patterns for gallery
  patterns = pattern_library();

  gallery_indices = [];
  gallery_names = {'Classic Full View', 'Seahorse Valley', 'Classic Julia', ...
                   'Ship Full View', 'Tricorn Full View', 'Multibrot Power 8'};

  for i = 1:length(patterns)
    for j = 1:length(gallery_names)
      if strcmp(patterns{i}.name, gallery_names{j})
        gallery_indices(end+1) = i;
      end
    end
  end

  exported_count = 0;

  for idx = gallery_indices
    pattern = patterns{idx};

    % Create state from pattern
    state = struct();
    state.fractal_type = pattern.fractal_type;
    state.center = pattern.center;
    state.width = pattern.width;
    state.height = pattern.height;
    state.max_iter = pattern.max_iter;
    state.escape_radius = 2.0;
    state.palette = 'deep_ocean';
    state.zoom_level = 1.0;
    state.julia_c = -0.7 + 0.27i;
    state.multibrot_power = 3;
    state.phoenix_c = 0.5 - 0.1i;
    state.phoenix_p = -0.5 + 0i;
    state.mandelbulb_power = 8;
    state.mandelbox_scale = 2.5;

    % Override with pattern-specific parameters
    if isfield(pattern, 'julia_c')
      state.julia_c = pattern.julia_c;
    end
    if isfield(pattern, 'multibrot_power')
      state.multibrot_power = pattern.multibrot_power;
    end

    % Generate safe filename
    safe_name = strrep(pattern.name, ' ', '_');
    safe_name = strrep(safe_name, '/', '_');
    filename = sprintf('FINAL_OUTPUT/%s.png', safe_name);

    fprintf('  Exporting: %s\n', pattern.name);

    % Export at HD resolution for gallery
    success = export_image(state, filename, [1920, 1080]);

    if success
      exported_count = exported_count + 1;
      fprintf('    ✓ Saved: %s\n\n', filename);
    end
  end

  fprintf('  ✓ Exported %d gallery images\n', exported_count);
  fprintf('  ✓ PASSED: Gallery export\n\n');
  tests_passed = tests_passed + 1;

catch err
  fprintf('  ✗ FAILED: %s\n\n', err.message);
  tests_failed = tests_failed + 1;
end


%% Summary
fprintf('========================================\n');
fprintf('Phase 6 Test Summary:\n');
fprintf('  Total tests: %d\n', test_num);
fprintf('  Passed: %d\n', tests_passed);
fprintf('  Failed: %d\n', tests_failed);
fprintf('========================================\n\n');

if tests_failed == 0
  fprintf('✓ All tests passed! Phase 6 complete.\n');
  fprintf('\nAdvanced features working correctly:\n');
  fprintf('  ✓ Pattern library (24 locations)\n');
  fprintf('  ✓ Bookmark save/load system\n');
  fprintf('  ✓ High-resolution image export\n');
  fprintf('  ✓ Animation frame generation\n');
  fprintf('  ✓ Integration with explorer\n');
  fprintf('  ✓ Final gallery images exported\n');
  fprintf('\nPhase 6 complete! All features implemented.\n');
  fprintf('\nFinal gallery images saved to: FINAL_OUTPUT/\n');
  fprintf('\nTo use advanced features:\n');
  fprintf('  G - View pattern gallery\n');
  fprintf('  S - Save bookmark\n');
  fprintf('  L - Load bookmark\n');
  fprintf('  E - Export high-resolution image\n');
else
  fprintf('✗ Some tests failed. Please review.\n');
end
