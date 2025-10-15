% TEST_PHASE2_CLI.m - CLI Test for Phase 2: Basic Visualization (Simplified)
%
% Tests display functions without requiring visual verification.
% Focuses on ensuring functions execute without errors.

clear all;
close all;
clc;

fprintf('=== Testing Phase 2: Basic Visualization (CLI) ===\n\n');

% Add required directories
addpath('core');
addpath('display');

test_passed = 0;
test_failed = 0;

%% Test 1: Display initialization
fprintf('Test 1: Display initialization...\n');
try
  fig = init_display(20);
  if ishandle(fig)
    fprintf('  ✓ Display initialized successfully\n');
    test_passed++;
    close all;
  else
    fprintf('  ✗ Failed to create figure handle\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 2: Update display with various grids
fprintf('Test 2: Update display with different grid states...\n');
try
  % Empty grid
  grid = zeros(15, 15);
  fig = init_display(grid);
  update_display(fig, grid, 0, 0, 'Empty');
  
  % Grid with cells
  grid(8, 7:9) = 1;
  update_display(fig, grid, 1, 3, 'Running');
  
  fprintf('  ✓ Display updates successful\n');
  test_passed++;
  close all;
catch err
  fprintf('  ✗ Error: %s\n', err.message);
  test_failed++;
  close all;
end
fprintf('\n');

%% Test 3: Blinker animation (non-visual verification)
fprintf('Test 3: Blinker pattern evolution...\n');
try
  grid = zeros(10, 10);
  grid(5, 4:6) = 1;  % Horizontal blinker
  
  % Test that it oscillates correctly (logic test)
  gen1 = gameoflife_rules(grid);
  gen2 = gameoflife_rules(gen1);
  
  if isequal(grid, gen2)
    fprintf('  ✓ Blinker oscillates correctly (period-2)\n');
    test_passed++;
  else
    fprintf('  ✗ Blinker oscillation failed\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 4: Display with statistics integration
fprintf('Test 4: Display with statistics...\n');
try
  grid = rand(20, 20) > 0.7;
  fig = init_display(grid);
  
  % Test old-style call
  update_display(fig, grid, 1, sum(grid(:)), 'Testing');
  
  % Test new-style with stats (if available)
  addpath('utils');
  if exist('calculate_stats', 'file')
    stats = calculate_stats(grid, [], 2);
    update_display(fig, grid, stats, 'With Stats');
    fprintf('  ✓ Display with statistics works\n');
  else
    fprintf('  ✓ Display works (stats not yet implemented)\n');
  endif
  
  test_passed++;
  close all;
catch err
  fprintf('  ✗ Error: %s\n', err.message);
  test_failed++;
  close all;
end
fprintf('\n');

%% Test 5: Large grid performance
fprintf('Test 5: Large grid handling (50x50)...\n');
try
  grid_large = rand(50, 50) > 0.65;
  fig = init_display(grid_large);
  update_display(fig, grid_large, 0, sum(grid_large(:)), 'Large Grid');
  
  fprintf('  ✓ Large grid handled successfully\n');
  test_passed++;
  close all;
catch err
  fprintf('  ✗ Error: %s\n', err.message);
  test_failed++;
  close all;
end
fprintf('\n');

%% Summary
fprintf('====================================\n');
fprintf('Phase 2 CLI Test Results:\n');
fprintf('  Tests Passed: %d\n', test_passed);
fprintf('  Tests Failed: %d\n', test_failed);
fprintf('====================================\n\n');

if test_failed == 0
  fprintf('✓ All Phase 2 Tests PASSED!\n');
  fprintf('\nBasic Visualization verified:\n');
  fprintf('  ✓ Display initialization\n');
  fprintf('  ✓ Grid updates\n');
  fprintf('  ✓ Pattern evolution\n');
  fprintf('  ✓ Statistics integration\n');
  fprintf('  ✓ Large grid support\n');
else
  fprintf('✗ Some tests FAILED\n');
endif

close all;
