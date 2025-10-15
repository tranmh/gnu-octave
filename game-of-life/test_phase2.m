% TEST_PHASE2 - Test basic visualization for Game of Life
%
% Tests the display initialization and update functions with
% a simple animated pattern.

clear all;
close all;
clc;

fprintf('=== Testing Phase 2: Basic Visualization ===\n\n');

% Add core directory to path
addpath('../core');
addpath('../display');

% Test 1: Initialize display
fprintf('Test 1: Initializing display window...\n');
grid_size = 30;
fig_handle = init_display(grid_size);
fprintf('  ✓ Display initialized successfully\n\n');

pause(1);

% Test 2: Display empty grid
fprintf('Test 2: Displaying empty grid...\n');
grid = zeros(grid_size, grid_size);
update_display(fig_handle, grid, 0, 0, 'Paused');
fprintf('  ✓ Empty grid displayed\n\n');

pause(1);

% Test 3: Display grid with some live cells
fprintf('Test 3: Displaying grid with live cells...\n');
% Create a simple blinker pattern in the center
center = floor(grid_size / 2);
grid(center, center-1:center+1) = 1;
update_display(fig_handle, grid, 1, 3, 'Paused');
fprintf('  ✓ Grid with live cells displayed\n\n');

pause(1);

% Test 4: Animate the blinker pattern
fprintf('Test 4: Animating blinker pattern (10 generations)...\n');
for gen = 2:11
  % Apply Game of Life rules
  grid = gameoflife_rules(grid);
  population = sum(grid(:));
  update_display(fig_handle, grid, gen, population, 'Running');
  pause(0.3);
endfor
fprintf('  ✓ Animation completed successfully\n\n');

pause(1);

% Test 5: Display a glider pattern
fprintf('Test 5: Displaying glider pattern...\n');
grid = zeros(grid_size, grid_size);
% Place glider in top-left corner
glider = [0 1 0; 0 0 1; 1 1 1];
grid(5:7, 5:7) = glider;
update_display(fig_handle, grid, 0, 5, 'Paused');
fprintf('  ✓ Glider pattern displayed\n\n');

pause(1);

% Test 6: Animate glider moving across screen
fprintf('Test 6: Animating glider (20 generations)...\n');
for gen = 1:20
  grid = gameoflife_rules(grid);
  population = sum(grid(:));
  update_display(fig_handle, grid, gen, population, 'Running');
  pause(0.2);
endfor
fprintf('  ✓ Glider animation completed\n\n');

pause(1);

% Test 7: Test status changes
fprintf('Test 7: Testing status display changes...\n');
update_display(fig_handle, grid, 20, population, 'Paused');
pause(0.5);
fprintf('  ✓ Status: Paused\n');

update_display(fig_handle, grid, 20, population, 'Running');
pause(0.5);
fprintf('  ✓ Status: Running\n');

update_display(fig_handle, grid, 20, population, 'Stopped');
pause(0.5);
fprintf('  ✓ Status: Stopped\n\n');

% Test 8: Test with larger grid
fprintf('Test 8: Testing with larger grid (50x50)...\n');
close(fig_handle);
grid_size_large = 50;
fig_handle2 = init_display(grid_size_large);
grid_large = rand(grid_size_large, grid_size_large) > 0.7;
population_large = sum(grid_large(:));
update_display(fig_handle2, grid_large, 0, population_large, 'Paused');
fprintf('  ✓ Large grid displayed successfully\n\n');

pause(1);

% Test 9: Quick animation of random pattern
fprintf('Test 9: Animating random pattern (15 generations)...\n');
for gen = 1:15
  grid_large = gameoflife_rules(grid_large);
  population_large = sum(grid_large(:));
  update_display(fig_handle2, grid_large, gen, population_large, 'Running');
  pause(0.15);
endfor
fprintf('  ✓ Random pattern animation completed\n\n');

% Summary
fprintf('=== Phase 2 Testing Complete ===\n');
fprintf('All visualization tests passed successfully!\n');
fprintf('Press any key to close the test window...\n');
pause;
close(fig_handle2);
fprintf('Test window closed.\n');
