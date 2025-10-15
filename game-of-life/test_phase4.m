% TEST_PHASE4.M - Test Pattern Library & Menu functionality
% 
% This script tests Phase 4 implementation:
%   - Pattern library with multiple classic patterns
%   - Pattern placement on grid
%   - Menu system for pattern selection
%   - Integration with previous phases (visualization and core logic)
%
% Usage: Run this script in Octave: test_phase4

clear all;
close all;
clc;

% Add necessary paths
addpath('./core');
addpath('./display');
addpath('./patterns');
addpath('./interaction');

printf('═══════════════════════════════════════════════════════════════\n');
printf('  PHASE 4 TEST: Pattern Library & Menu\n');
printf('═══════════════════════════════════════════════════════════════\n');
printf('\n');

% Show menu and get user choices
[pattern_choice, grid_size] = show_menu();

% Initialize grid
grid = zeros(grid_size, grid_size);

% Get the selected pattern from library
if strcmp(pattern_choice, 'random')
  % For random pattern, fill with random values
  pattern = rand(grid_size, grid_size) > 0.7;  % 30% alive probability
  grid = pattern;
else
  % Get pattern from library and place it on grid
  pattern = pattern_library(pattern_choice);
  grid = place_pattern(grid, pattern);
endif

% Initialize display
fig = init_display(grid);

% Simulation parameters
generation = 0;
running = true;
speed = 0.1;  % seconds between generations

printf('\n');
printf('═══════════════════════════════════════════════════════════════\n');
printf('  Controls:\n');
printf('    SPACE  - Pause/Resume\n');
printf('    S      - Single step\n');
printf('    R      - Reset to initial pattern\n');
printf('    C      - Clear grid\n');
printf('    +/-    - Speed up/slow down\n');
printf('    Q      - Quit\n');
printf('═══════════════════════════════════════════════════════════════\n');
printf('\n');

% Store initial state for reset
initial_grid = grid;
paused = false;

% Main simulation loop
try
  while running && ishandle(fig)
    % Update display
    update_display(fig, grid, generation);
    
    if ~paused
      % Apply Game of Life rules
      grid = gameoflife_rules(grid);
      generation = generation + 1;
    endif
    
    % Check for keyboard input (non-blocking)
    drawnow;
    pause(speed);
    
    % Simple keyboard handling (basic version)
    % Note: Full keyboard handling from Phase 3 can be integrated here
  endwhile
  
catch err
  printf('Error during simulation: %s\n', err.message);
end

printf('\n');
printf('Simulation ended. Total generations: %d\n', generation);
printf('\n');
printf('PHASE 4 TEST COMPLETE!\n');
printf('\n');
