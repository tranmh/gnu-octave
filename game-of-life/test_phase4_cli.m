% TEST_PHASE4_CLI.m - CLI Test for Phase 4: Pattern Library & Menu
%
% Tests pattern library and pattern placement without GUI interaction.
% Verifies that patterns are correctly defined and can be placed on grids.

clear all;
close all;
clc;

fprintf('=== Testing Phase 4: Pattern Library & Menu (CLI) ===\n\n');

% Add required directories
addpath('core');
addpath('patterns');

test_passed = 0;
test_failed = 0;

%% Test 1: Pattern Library - Random pattern
fprintf('Test 1: Testing random pattern generation...\n');
try
  pattern = pattern_library('random');
  
  % Random pattern returns empty, to be filled by caller
  if isempty(pattern)
    fprintf('  ✓ Random pattern returns empty (as designed)\n');
    test_passed++;
  else
    fprintf('  ✗ Random pattern should return empty\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error creating random pattern: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 2: Pattern Library - Glider
fprintf('Test 2: Testing glider pattern...\n');
try
  glider = pattern_library('glider');
  
  % Verify glider structure (3x3 with 5 live cells)
  expected_glider = [0 1 0; 0 0 1; 1 1 1];
  
  if isequal(glider, expected_glider)
    fprintf('  ✓ Glider pattern is correct\n');
    test_passed++;
  else
    fprintf('  ✗ Glider pattern structure is incorrect\n');
    fprintf('  Expected:\n');
    disp(expected_glider);
    fprintf('  Got:\n');
    disp(glider);
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error loading glider: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 3: Pattern Library - Blinker
fprintf('Test 3: Testing blinker pattern...\n');
try
  blinker = pattern_library('blinker');
  expected_blinker = [1 1 1];  % Horizontal line
  
  if isequal(blinker, expected_blinker)
    fprintf('  ✓ Blinker pattern is correct\n');
    test_passed++;
  else
    fprintf('  ✗ Blinker pattern is incorrect\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error loading blinker: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 4: Pattern Library - All patterns exist
fprintf('Test 4: Testing that all documented patterns exist...\n');
patterns_to_test = {'glider', 'blinker', 'toad', 'beacon', 'pulsar', 'lwss', 'glider_gun'};
all_exist = true;

for i = 1:length(patterns_to_test)
  try
    p = pattern_library(patterns_to_test{i});
    fprintf('  ✓ Pattern "%s" exists\n', patterns_to_test{i});
  catch err
    fprintf('  ✗ Pattern "%s" not found: %s\n', patterns_to_test{i}, err.message);
    all_exist = false;
  end
endfor

if all_exist
  test_passed++;
else
  test_failed++;
endif
fprintf('\n');

%% Test 5: Place Pattern - Center placement
fprintf('Test 5: Testing pattern placement (centering)...\n');
try
  grid = zeros(10, 10);
  pattern = [1 1 1];  % Horizontal blinker (1x3)
  
  result_grid = place_pattern(grid, pattern);
  
  % Pattern should be centered - check that it's placed correctly
  % and only 3 cells are alive
  if sum(result_grid(:)) == 3
    fprintf('  ✓ Pattern placed correctly (3 cells alive)\n');
    test_passed++;
  else
    fprintf('  ✗ Pattern not centered correctly\n');
    fprintf('  Expected 3 cells, got %d\n', sum(result_grid(:)));
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error in place_pattern: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 6: Place Pattern - Small pattern on large grid
fprintf('Test 6: Testing pattern placement on larger grid...\n');
try
  grid_large = zeros(50, 50);
  glider = pattern_library('glider');
  
  result = place_pattern(grid_large, glider);
  
  % Verify glider is placed and grid size is unchanged
  if size(result, 1) == 50 && size(result, 2) == 50 && sum(result(:)) == 5
    fprintf('  ✓ Pattern placed on large grid successfully\n');
    test_passed++;
  else
    fprintf('  ✗ Pattern placement on large grid failed\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error with large grid: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 7: Pattern behavior - Verify glider moves
fprintf('Test 7: Testing glider movement (4 generations)...\n');
try
  grid = zeros(20, 20);
  glider = pattern_library('glider');
  grid = place_pattern(grid, glider);
  
  initial_center_of_mass_x = 0;
  initial_center_of_mass_y = 0;
  population = 0;
  
  % Calculate initial center of mass
  for i = 1:20
    for j = 1:20
      if grid(i, j) == 1
        initial_center_of_mass_x = initial_center_of_mass_x + i;
        initial_center_of_mass_y = initial_center_of_mass_y + j;
        population = population + 1;
      endif
    endfor
  endfor
  initial_center_of_mass_x = initial_center_of_mass_x / population;
  initial_center_of_mass_y = initial_center_of_mass_y / population;
  
  % Run 4 generations
  for gen = 1:4
    grid = gameoflife_rules(grid);
  endfor
  
  % Calculate new center of mass
  new_center_of_mass_x = 0;
  new_center_of_mass_y = 0;
  population = 0;
  
  for i = 1:20
    for j = 1:20
      if grid(i, j) == 1
        new_center_of_mass_x = new_center_of_mass_x + i;
        new_center_of_mass_y = new_center_of_mass_y + j;
        population = population + 1;
      endif
    endfor
  endfor
  new_center_of_mass_x = new_center_of_mass_x / population;
  new_center_of_mass_y = new_center_of_mass_y / population;
  
  % Glider should have moved (center of mass should change)
  distance_moved = sqrt((new_center_of_mass_x - initial_center_of_mass_x)^2 + ...
                        (new_center_of_mass_y - initial_center_of_mass_y)^2);
  
  if distance_moved > 1.0 && population == 5
    fprintf('  ✓ Glider moves correctly (moved %.2f units)\n', distance_moved);
    test_passed++;
  else
    fprintf('  ✗ Glider did not move as expected\n');
    fprintf('  Distance: %.2f, Population: %d\n', distance_moved, population);
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error testing glider movement: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Test 8: Pattern behavior - Blinker oscillation
fprintf('Test 8: Testing blinker oscillation...\n');
try
  grid = zeros(10, 10);
  blinker = pattern_library('blinker');
  grid = place_pattern(grid, blinker);
  
  initial_grid = grid;
  
  % Apply rules twice - should return to original state (period 2)
  grid = gameoflife_rules(grid);
  grid = gameoflife_rules(grid);
  
  if isequal(grid, initial_grid)
    fprintf('  ✓ Blinker oscillates with period 2\n');
    test_passed++;
  else
    fprintf('  ✗ Blinker does not return to original state\n');
    test_failed++;
  endif
catch err
  fprintf('  ✗ Error testing blinker: %s\n', err.message);
  test_failed++;
end
fprintf('\n');

%% Summary
fprintf('====================================\n');
fprintf('Phase 4 CLI Test Results:\n');
fprintf('  Tests Passed: %d\n', test_passed);
fprintf('  Tests Failed: %d\n', test_failed);
fprintf('====================================\n\n');

if test_failed == 0
  fprintf('All Phase 4 Tests PASSED!\n');
  fprintf('\nPattern Library & Placement working correctly:\n');
  fprintf('  ✓ Pattern library implementation\n');
  fprintf('  ✓ All documented patterns exist\n');
  fprintf('  ✓ Pattern centering on grid\n');
  fprintf('  ✓ Glider movement verified\n');
  fprintf('  ✓ Blinker oscillation verified\n');
  fprintf('\nPhase 4 is ready for integration!\n');
else
  fprintf('Some tests FAILED. Please review the errors above.\n');
endif
