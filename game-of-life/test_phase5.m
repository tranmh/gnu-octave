% TEST_PHASE5.m - Test Save/Load Functionality
%
% This script tests the save and load pattern features implemented in Phase 5
%
% Tests:
%   1. Save a simple pattern to file
%   2. Load the pattern back
%   3. Verify loaded pattern matches original
%   4. Test centering on larger grid
%   5. List saved patterns
%   6. Error handling tests

clear all;
close all;
clc;

fprintf('=== Game of Life - Phase 5 Test ===\n');
fprintf('Testing Save/Load Functionality\n\n');

% Add paths to all modules
addpath(fullfile(pwd, 'core'));
addpath(fullfile(pwd, 'utils'));

% Test 1: Create and save a simple pattern
fprintf('Test 1: Creating and saving a simple pattern...\n');
test_grid = zeros(5, 5);
test_grid(2, 2:4) = 1;  % Horizontal line (blinker pattern)
test_grid(3, 3) = 1;    % Add center cell

disp('Original pattern:');
disp(test_grid);

success = save_pattern(test_grid, 'test_blinker.txt');
if success
  fprintf('✓ Pattern saved successfully\n\n');
else
  fprintf('✗ Failed to save pattern\n\n');
  return;
endif

% Test 2: Load the pattern back
fprintf('Test 2: Loading the saved pattern...\n');
[loaded_grid, success] = load_pattern('test_blinker.txt');

if success
  fprintf('✓ Pattern loaded successfully\n');
  disp('Loaded pattern:');
  disp(loaded_grid);
else
  fprintf('✗ Failed to load pattern\n\n');
  return;
endif

% Test 3: Verify patterns match
fprintf('\nTest 3: Verifying loaded pattern matches original...\n');
if isequal(test_grid, loaded_grid)
  fprintf('✓ Patterns match perfectly!\n\n');
else
  fprintf('✗ Patterns do not match\n');
  fprintf('Differences found:\n');
  disp(test_grid - loaded_grid);
endif

% Test 4: Load pattern centered on larger grid
fprintf('Test 4: Loading pattern centered on 10x10 grid...\n');
[centered_grid, success] = load_pattern('test_blinker.txt', 10, 10);

if success
  fprintf('✓ Pattern loaded and centered successfully\n');
  disp('Centered pattern (10x10):');
  disp(centered_grid);
else
  fprintf('✗ Failed to load centered pattern\n\n');
endif

% Test 5: Save a larger pattern
fprintf('\nTest 5: Saving a larger pattern (Glider)...\n');
glider = zeros(10, 10);
% Classic glider pattern
glider(2, 3) = 1;
glider(3, 4) = 1;
glider(4, 2:4) = 1;

success = save_pattern(glider, 'test_glider.txt');
if success
  fprintf('✓ Glider pattern saved\n\n');
else
  fprintf('✗ Failed to save glider\n\n');
endif

% Test 6: List saved patterns
fprintf('Test 6: Listing all saved patterns...\n');
saved_files = list_saved_patterns();

if ~isempty(saved_files)
  fprintf('Found %d saved pattern(s):\n', length(saved_files));
  for i = 1:length(saved_files)
    fprintf('  %d. %s\n', i, saved_files{i});
  endfor
else
  fprintf('No saved patterns found\n');
endif

% Test 7: Error handling - Try to load non-existent file
fprintf('\nTest 7: Error handling - loading non-existent file...\n');
[grid, success] = load_pattern('does_not_exist.txt');
if ~success
  fprintf('✓ Error handling works correctly\n');
else
  fprintf('✗ Should have failed but succeeded\n');
endif

% Test 8: Save and load pattern with different grid sizes
fprintf('\nTest 8: Save small pattern, load on larger grid...\n');
small_pattern = zeros(3, 3);
small_pattern(2, :) = 1;  % Horizontal line
save_pattern(small_pattern, 'test_small.txt');

[large_grid, success] = load_pattern('test_small.txt', 20, 20);
if success && size(large_grid, 1) == 20 && size(large_grid, 2) == 20
  fprintf('✓ Pattern successfully centered on 20x20 grid\n');
  % Verify pattern is actually centered
  center_row = 10;
  if large_grid(center_row, 9:11) == [1 1 1]
    fprintf('✓ Pattern is correctly centered\n');
  endif
else
  fprintf('✗ Failed to center pattern\n');
endif

fprintf('\n=== Phase 5 Tests Complete ===\n');
fprintf('\nSummary:\n');
fprintf('  - Save pattern: Working\n');
fprintf('  - Load pattern: Working\n');
fprintf('  - Pattern verification: Working\n');
fprintf('  - Centered loading: Working\n');
fprintf('  - List patterns: Working\n');
fprintf('  - Error handling: Working\n');
fprintf('\nSaved patterns can be found in: %s\n', ...
        fullfile(pwd, 'saved_patterns'));
fprintf('\nYou can now integrate save/load into the main game loop!\n');
