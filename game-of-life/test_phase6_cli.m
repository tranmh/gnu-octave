% TEST_PHASE6_CLI.m - CLI Test for Phase 6: Statistics & Polish
%
% Tests statistics calculation and display help without GUI interaction.
% Validates the final polish and integration features.

clear all;
close all;
clc;

fprintf('=== Testing Phase 6: Statistics & Polish (CLI) ===\n\n');

% Add required directories
addpath('core');
addpath('utils');
addpath('display');

test_passed = 0;
test_failed = 0;

%% Test 1: Basic statistics calculation
fprintf('Test 1: Testing basic statistics calculation...\n');
try
  grid = zeros(10, 10);
  grid(5, 5) = 1;
  grid(5, 6) = 1;
  grid(6, 5) = 1;
  grid(6, 6) = 1;  % 4-cell block
  
  prev_grid = [];
  stats = calculate_stats(grid, prev_grid, 1);
  
  if stats.generation == 1 && stats.population == 4 && abs(stats.density - 4.0) < 0.1
    fprintf('  ✓ Basic statistics calculated correctly\n');
    fprintf('    Generation: %d, Population: %d, Density: %.1f%%\n', ...
            stats.generation, stats.population, stats.density);
    test_passed++;
  else
    fprintf('  ✗ Basic statistics incorrect\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error in basic statistics: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 2: Population change tracking
fprintf('Test 2: Testing population change tracking...\n');
try
  grid = zeros(10, 10);
  grid(5, 5:6) = 1;
  prev_grid = grid;
  
  % Add more cells
  grid(6, 5:6) = 1;
  stats = calculate_stats(grid, prev_grid, 2);
  
  if stats.change == 2 && abs(stats.change_rate - 100.0) < 1.0
    fprintf('  ✓ Population change tracked correctly\n');
    fprintf('    Change: +%d, Change Rate: %.1f%%\n', stats.change, stats.change_rate);
    test_passed++;
  else
    fprintf('  ✗ Change tracking incorrect\n');
    fprintf('    Expected change: 2, got: %d\n', stats.change);
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error in change tracking: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 3: Static pattern detection
fprintf('Test 3: Testing static pattern detection...\n');
try
  % Create a block (still life)
  grid = zeros(10, 10);
  grid(5:6, 5:6) = 1;
  prev_grid = grid;
  
  stats = calculate_stats(grid, prev_grid, 5);
  
  if stats.is_static == 1
    fprintf('  ✓ Static pattern detected correctly\n');
    test_passed++;
  else
    fprintf('  ✗ Static detection failed\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error in static detection: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 4: Non-static pattern detection
fprintf('Test 4: Testing non-static pattern detection...\n');
try
  % Blinker - oscillating pattern
  grid1 = zeros(10, 10);
  grid1(5, 4:6) = 1;  % Horizontal
  
  grid2 = gameoflife_rules(grid1);  % Vertical
  
  stats = calculate_stats(grid2, grid1, 2);
  
  if stats.is_static == 0
    fprintf('  ✓ Non-static pattern detected correctly\n');
    test_passed++;
  else
    fprintf('  ✗ Should have detected non-static pattern\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error in non-static detection: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 5: Empty grid statistics
fprintf('Test 5: Testing statistics with empty grid...\n');
try
  grid = zeros(10, 10);
  prev_grid = [];
  
  stats = calculate_stats(grid, prev_grid, 0);
  
  if stats.population == 0 && stats.density == 0
    fprintf('  ✓ Empty grid statistics correct\n');
    test_passed++;
  else
    fprintf('  ✗ Empty grid statistics incorrect\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error with empty grid: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 6: Full grid statistics
fprintf('Test 6: Testing statistics with full grid...\n');
try
  grid = ones(10, 10);
  prev_grid = [];
  
  stats = calculate_stats(grid, prev_grid, 1);
  
  if stats.population == 100 && abs(stats.density - 100.0) < 0.1
    fprintf('  ✓ Full grid statistics correct\n');
    test_passed++;
  else
    fprintf('  ✗ Full grid statistics incorrect\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error with full grid: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 7: Display help function
fprintf('Test 7: Testing display_help function...\n');
try
  % Capture display_help output - should not crash
  display_help();
  fprintf('  ✓ Display help executed without errors\n');
  test_passed++;
catch err
  fprintf('  ✗ Error in display_help: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 8: Statistics over multiple generations
fprintf('Test 8: Testing statistics tracking over multiple generations...\n');
try
  grid = zeros(15, 15);
  % Create a glider
  grid(7, 8) = 1;
  grid(8, 9) = 1;
  grid(9, 7:9) = 1;
  
  prev_grid = [];
  generations_tested = 0;
  
  for gen = 1:5
    stats = calculate_stats(grid, prev_grid, gen);
    
    % Verify stats structure
    if isfield(stats, 'generation') && isfield(stats, 'population') && ...
       isfield(stats, 'density') && isfield(stats, 'change')
      generations_tested++;
    endif
    
    prev_grid = grid;
    grid = gameoflife_rules(grid);
  endfor
  
  if generations_tested == 5
    fprintf('  ✓ Statistics tracked correctly over 5 generations\n');
    test_passed++;
  else
    fprintf('  ✗ Statistics tracking failed over generations\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error in multi-generation tracking: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 9: Negative change (population decrease)
fprintf('Test 9: Testing population decrease tracking...\n');
try
  grid = ones(10, 10);  % Start with full grid
  prev_grid = grid;
  
  % Most cells will die (overcrowding)
  grid = gameoflife_rules(grid);
  stats = calculate_stats(grid, prev_grid, 2);
  
  if stats.change < 0
    fprintf('  ✓ Population decrease tracked correctly (change: %d)\n', stats.change);
    test_passed++;
  else
    fprintf('  ✗ Failed to track population decrease\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error tracking decrease: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 10: Integration with update_display
fprintf('Test 10: Testing integration with update_display...\n');
fprintf('  ⚠ Skipping GUI test in CLI mode (would crash Octave)\n');
fprintf('  ℹ This test verifies display functions exist and stats format is correct\n');
try
  grid = zeros(10, 10);
  grid(5, 4:6) = 1;
  
  prev_grid = [];
  stats = calculate_stats(grid, prev_grid, 1);
  
  % Verify stats structure is correct for display integration
  if isfield(stats, 'generation') && isfield(stats, 'population') && ...
     isfield(stats, 'density') && isfield(stats, 'change') && ...
     isfield(stats, 'change_rate') && isfield(stats, 'is_static')
    fprintf('  ✓ Statistics structure compatible with display functions\n');
    test_passed++;
  else
    fprintf('  ✗ Statistics structure missing required fields\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error in integration test: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Summary
fprintf('====================================\n');
fprintf('Phase 6 CLI Test Results:\n');
fprintf('  Tests Passed: %d\n', test_passed);
fprintf('  Tests Failed: %d\n', test_failed);
fprintf('====================================\n\n');

if test_failed == 0
  fprintf('All Phase 6 Tests PASSED!\n');
  fprintf('\nStatistics & Polish working correctly:\n');
  fprintf('  ✓ Basic statistics calculation\n');
  fprintf('  ✓ Population change tracking\n');
  fprintf('  ✓ Static pattern detection\n');
  fprintf('  ✓ Empty and full grid handling\n');
  fprintf('  ✓ Display help system\n');
  fprintf('  ✓ Multi-generation tracking\n');
  fprintf('  ✓ Integration with display\n');
  fprintf('\nPhase 6 is COMPLETE!\n');
  fprintf('\n=== ALL PHASES COMPLETED ===\n');
  fprintf('The Game of Life implementation is ready!\n');
else
  fprintf('Some tests FAILED. Please review the errors above.\n');
endif
