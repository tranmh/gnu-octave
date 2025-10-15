% TEST_PHASE3 - Test interactive controls for Game of Life
%
% Tests the mouse click and keyboard input handling functions.
% This test focuses on unit testing the interaction functions.

clear all;
close all;
clc;

fprintf('=== Testing Phase 3: Interactive Controls ===\n\n');

% Add necessary directories to path
addpath('core');
addpath('display');
addpath('interaction');

% Test 1: Mouse Click Handler - Valid clicks
fprintf('Test 1: Testing mouse click handler with valid coordinates...\n');
test_grid = zeros(10, 10);
test_grid(5, 5) = 1;

% Click on a dead cell - should become alive
new_grid = handle_mouse_click(test_grid, 3, 3);
if new_grid(3, 3) == 1 && sum(new_grid(:)) == 2
  fprintf('  ✓ Dead cell toggled to alive\n');
else
  fprintf('  ✗ FAILED: Dead cell not toggled correctly\n');
endif

% Click on a live cell - should become dead
new_grid2 = handle_mouse_click(test_grid, 5, 5);
if new_grid2(5, 5) == 0 && sum(new_grid2(:)) == 0
  fprintf('  ✓ Live cell toggled to dead\n');
else
  fprintf('  ✗ FAILED: Live cell not toggled correctly\n');
endif

% Test multiple toggles on same cell
toggle_grid = zeros(10, 10);
toggle_grid = handle_mouse_click(toggle_grid, 7, 7);
toggle_grid = handle_mouse_click(toggle_grid, 7, 7);
if toggle_grid(7, 7) == 0
  fprintf('  ✓ Double toggle returns to original state\n');
else
  fprintf('  ✗ FAILED: Double toggle did not work\n');
endif
fprintf('\n');

% Test 2: Mouse Click Handler - Invalid clicks (out of bounds)
fprintf('Test 2: Testing mouse click with out-of-bounds coordinates...\n');
test_grid2 = ones(5, 5);
original_sum = sum(test_grid2(:));

% Click outside grid boundaries
new_grid3 = handle_mouse_click(test_grid2, -1, 3);
new_grid4 = handle_mouse_click(test_grid2, 10, 3);
new_grid5 = handle_mouse_click(test_grid2, 3, 0);
new_grid6 = handle_mouse_click(test_grid2, 3, 10);

if sum(new_grid3(:)) == original_sum && sum(new_grid4(:)) == original_sum && ...
   sum(new_grid5(:)) == original_sum && sum(new_grid6(:)) == original_sum
  fprintf('  ✓ Out-of-bounds clicks ignored correctly\n');
else
  fprintf('  ✗ FAILED: Out-of-bounds clicks affected grid\n');
endif
fprintf('\n');

% Test 3: Keyboard Handler - Pause/Resume
fprintf('Test 3: Testing keyboard handler - toggle pause...\n');
action = handle_keyboard(' ', 0.2);
if strcmp(action.type, 'toggle_pause')
  fprintf('  ✓ SPACE key triggers toggle_pause action\n');
else
  fprintf('  ✗ FAILED: SPACE key not recognized\n');
endif
fprintf('\n');

% Test 4: Keyboard Handler - Single Step
fprintf('Test 4: Testing keyboard handler - single step...\n');
action = handle_keyboard('s', 0.2);
if strcmp(action.type, 'step')
  fprintf('  ✓ S key triggers step action\n');
else
  fprintf('  ✗ FAILED: S key not recognized\n');
endif

% Test case insensitivity
action_upper = handle_keyboard('S', 0.2);
if strcmp(action_upper.type, 'step')
  fprintf('  ✓ S key is case-insensitive\n');
else
  fprintf('  ✗ FAILED: Uppercase S not recognized\n');
endif
fprintf('\n');

% Test 5: Keyboard Handler - Reset and Clear
fprintf('Test 5: Testing keyboard handler - reset and clear...\n');
action_reset = handle_keyboard('r', 0.2);
action_clear = handle_keyboard('c', 0.2);

if strcmp(action_reset.type, 'reset')
  fprintf('  ✓ R key triggers reset action\n');
else
  fprintf('  ✗ FAILED: R key not recognized\n');
endif

if strcmp(action_clear.type, 'clear')
  fprintf('  ✓ C key triggers clear action\n');
else
  fprintf('  ✗ FAILED: C key not recognized\n');
endif
fprintf('\n');

% Test 6: Keyboard Handler - Quit
fprintf('Test 6: Testing keyboard handler - quit...\n');
action_quit = handle_keyboard('q', 0.2);
if strcmp(action_quit.type, 'quit')
  fprintf('  ✓ Q key triggers quit action\n');
else
  fprintf('  ✗ FAILED: Q key not recognized\n');
endif
fprintf('\n');

% Test 7: Keyboard Handler - Speed Control
fprintf('Test 7: Testing keyboard handler - speed control...\n');
current_speed = 0.5;

% Test increase speed (decrease delay)
action_faster = handle_keyboard('+', current_speed);
if strcmp(action_faster.type, 'speed') && action_faster.speed < current_speed
  fprintf('  ✓ + key increases speed (delay: %.2f -> %.2f)\n', current_speed, action_faster.speed);
else
  fprintf('  ✗ FAILED: + key did not increase speed\n');
endif

% Test decrease speed (increase delay)
action_slower = handle_keyboard('-', current_speed);
if strcmp(action_slower.type, 'speed') && action_slower.speed > current_speed
  fprintf('  ✓ - key decreases speed (delay: %.2f -> %.2f)\n', current_speed, action_slower.speed);
else
  fprintf('  ✗ FAILED: - key did not decrease speed\n');
endif

% Test speed limits - minimum
action_min = handle_keyboard('+', 0.01);
if action_min.speed >= 0.01
  fprintf('  ✓ Minimum speed limit enforced (>= 0.01)\n');
else
  fprintf('  ✗ FAILED: Minimum speed limit not enforced\n');
endif

% Test speed limits - maximum
action_max = handle_keyboard('-', 2.0);
if action_max.speed <= 2.0
  fprintf('  ✓ Maximum speed limit enforced (<= 2.0)\n');
else
  fprintf('  ✗ FAILED: Maximum speed limit not enforced\n');
endif
fprintf('\n');

% Test 8: Keyboard Handler - Help
fprintf('Test 8: Testing keyboard handler - help...\n');
action_help = handle_keyboard('h', 0.2);
if strcmp(action_help.type, 'help')
  fprintf('  ✓ H key triggers help action\n');
else
  fprintf('  ✗ FAILED: H key not recognized\n');
endif
fprintf('\n');

% Test 9: Keyboard Handler - Unknown keys
fprintf('Test 9: Testing keyboard handler - unknown keys...\n');
action_unknown1 = handle_keyboard('x', 0.2);
action_unknown2 = handle_keyboard('7', 0.2);
action_unknown3 = handle_keyboard('@', 0.2);

if strcmp(action_unknown1.type, 'none') && strcmp(action_unknown2.type, 'none') && ...
   strcmp(action_unknown3.type, 'none')
  fprintf('  ✓ Unknown keys return "none" action\n');
else
  fprintf('  ✗ FAILED: Unknown keys not handled correctly\n');
endif
fprintf('\n');

% Summary
fprintf('=== Phase 3 Testing Complete ===\n');
fprintf('All interactive control tests completed!\n');
fprintf('\n');
fprintf('Keyboard Controls Summary:\n');
fprintf('  SPACE - Pause/Resume\n');
fprintf('  S     - Single step forward\n');
fprintf('  R     - Reset to initial state\n');
fprintf('  C     - Clear grid\n');
fprintf('  +/-   - Increase/decrease speed\n');
fprintf('  H     - Show help\n');
fprintf('  Q     - Quit\n');
fprintf('\nMouse: Click on cells to toggle alive/dead\n');