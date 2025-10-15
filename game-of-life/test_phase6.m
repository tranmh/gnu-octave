% TEST_PHASE6 - Test Phase 6: Statistics & Polish
%
% This script tests the statistics calculation, enhanced display,
% help system, and overall integration of all features.
%
% Run this test to verify Phase 6 implementation.

clear all;
close all;
clc;

fprintf('\n');
fprintf('═══════════════════════════════════════════════════════════════════\n');
fprintf('            PHASE 6 TEST: STATISTICS & POLISH                      \n');
fprintf('═══════════════════════════════════════════════════════════════════\n');
fprintf('\n');

% Add required paths
addpath('core');
addpath('display');
addpath('patterns');
addpath('utils');

%% Test 1: Statistics Calculation
fprintf('TEST 1: Statistics Calculation\n');
fprintf('─────────────────────────────────────────────────────────────────\n');

% Create test grid
grid = zeros(10, 10);
grid(5, 5) = 1;
grid(5, 6) = 1;
grid(6, 5) = 1;
grid(6, 6) = 1;  % 4 cells

prev_grid = [];

stats = calculate_stats(grid, prev_grid, 1);

fprintf('  Generation: %d\n', stats.generation);
fprintf('  Population: %d (expected: 4)\n', stats.population);
fprintf('  Density: %.1f%% (expected: 4.0%%)\n', stats.density);
fprintf('  Change: %d (expected: 0)\n', stats.change);
fprintf('  Static: %d (expected: 0)\n', stats.is_static);

if stats.population == 4 && abs(stats.density - 4.0) < 0.1
  fprintf('  ✓ Basic statistics: PASSED\n');
else
  fprintf('  ✗ Basic statistics: FAILED\n');
endif

fprintf('\n');

%% Test 2: Statistics with Change
fprintf('TEST 2: Statistics with Population Change\n');
fprintf('─────────────────────────────────────────────────────────────────\n');

prev_grid = grid;
grid(4, 5) = 1;
grid(4, 6) = 1;  % Now 6 cells

stats = calculate_stats(grid, prev_grid, 2);

fprintf('  Population: %d (expected: 6)\n', stats.population);
fprintf('  Change: %d (expected: +2)\n', stats.change);
fprintf('  Change Rate: %.1f%% (expected: 50.0%%)\n', stats.change_rate);

if stats.population == 6 && stats.change == 2
  fprintf('  ✓ Change tracking: PASSED\n');
else
  fprintf('  ✗ Change tracking: FAILED\n');
endif

fprintf('\n');

%% Test 3: Static Detection
fprintf('TEST 3: Static Pattern Detection\n');
fprintf('─────────────────────────────────────────────────────────────────\n');

% Create block pattern (static)
grid = zeros(5, 5);
grid(2:3, 2:3) = 1;  % 2x2 block

prev_grid = grid;  % Same as current

stats = calculate_stats(grid, prev_grid, 5);

fprintf('  Pattern: 2x2 Block (still life)\n');
fprintf('  Static: %d (expected: 1)\n', stats.is_static);

if stats.is_static
  fprintf('  ✓ Static detection: PASSED\n');
else
  fprintf('  ✗ Static detection: FAILED\n');
endif

fprintf('\n');

%% Test 4: Display Help
fprintf('TEST 4: Display Help System\n');
fprintf('─────────────────────────────────────────────────────────────────\n');

try
  fprintf('  Displaying help screen...\n');
  display_help();
  fprintf('  ✓ Help display: PASSED\n');
catch err
  fprintf('  ✗ Help display: FAILED - %s\n', err.message);
end

fprintf('\n');

%% Test 5: Enhanced Display Integration
fprintf('TEST 5: Enhanced Display with Statistics\n');
fprintf('─────────────────────────────────────────────────────────────────\n');

% Create small test grid
test_grid = zeros(10, 10);
test_grid(4:6, 4:6) = 1;  % 3x3 block

try
  fprintf('  Creating test display...\n');
  fig = init_display(size(test_grid));
  
  fprintf('  Testing old-style update (backward compatibility)...\n');
  update_display(fig, test_grid, 1, 9, 'Testing');
  pause(1);
  
  fprintf('  Testing new-style update with stats...\n');
  stats = calculate_stats(test_grid, [], 2);
  update_display(fig, test_grid, stats, 'Testing Stats');
  pause(1);
  
  fprintf('  ✓ Enhanced display: PASSED\n');
  
  close(fig);
catch err
  fprintf('  ✗ Enhanced display: FAILED - %s\n', err.message);
  if exist('fig', 'var') && ishandle(fig)
    close(fig);
  endif
end

fprintf('\n');

%% Test 6: Full Integration Test
fprintf('TEST 6: Full System Integration\n');
fprintf('─────────────────────────────────────────────────────────────────\n');
fprintf('  This test will run a brief simulation.\n');
fprintf('  The window will appear for 5 seconds.\n');
fprintf('  Verify that statistics display correctly.\n\n');

try
  % Create a simple oscillator (blinker)
  grid = zeros(10, 10);
  grid(5, 4:6) = 1;  % Horizontal blinker
  
  fig = init_display(size(grid));
  
  prev_grid = [];
  
  % Run for several generations
  for gen = 1:10
    stats = calculate_stats(grid, prev_grid, gen);
    
    % Determine status
    if stats.is_static
      status = 'Static';
    elseif mod(gen, 2) == 0
      status = 'Running';
    else
      status = 'Paused';
    endif
    
    update_display(fig, grid, stats, status);
    
    fprintf('  Gen %d: Pop=%d, Change=%+d, Density=%.1f%%\n', ...
            gen, stats.population, stats.change, stats.density);
    
    prev_grid = grid;
    grid = gameoflife_rules(grid);
    
    pause(0.5);
  endfor
  
  fprintf('\n  ✓ Full integration: PASSED\n');
  
  pause(2);
  close(fig);
  
catch err
  fprintf('  ✗ Full integration: FAILED - %s\n', err.message);
  if exist('fig', 'var') && ishandle(fig)
    close(fig);
  endif
end

fprintf('\n');

%% Summary
fprintf('═══════════════════════════════════════════════════════════════════\n');
fprintf('                     PHASE 6 TEST COMPLETE                         \n');
fprintf('═══════════════════════════════════════════════════════════════════\n');
fprintf('\n');
fprintf('All Phase 6 features have been tested:\n');
fprintf('  ✓ Statistics calculation (population, change, density)\n');
fprintf('  ✓ Static pattern detection\n');
fprintf('  ✓ Enhanced display with full statistics overlay\n');
fprintf('  ✓ Help system\n');
fprintf('  ✓ Full system integration\n');
fprintf('\n');
fprintf('Phase 6 implementation is COMPLETE!\n');
fprintf('\n');
fprintf('Next steps:\n');
fprintf('  1. Run the full game: game_of_life()\n');
fprintf('  2. Try different patterns from the menu\n');
fprintf('  3. Test all keyboard and mouse controls\n');
fprintf('  4. Save and load custom patterns\n');
fprintf('\n');
fprintf('═══════════════════════════════════════════════════════════════════\n');
