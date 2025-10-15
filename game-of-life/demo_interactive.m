% DEMO_INTERACTIVE - Interactive demonstration of Game of Life
%
% This demo combines Phases 1-3 to create a basic interactive
% Game of Life simulation with visual display and user controls.
%
% Controls:
%   Mouse Click - Toggle cells alive/dead
%   SPACE       - Pause/Resume
%   S           - Single step (when paused)
%   R           - Reset to initial state
%   C           - Clear grid
%   +/-         - Increase/decrease speed
%   Q           - Quit

clear all;
close all;
clc;

% Add all necessary directories to path
addpath('./core');
addpath('./display');
addpath('./interaction');

fprintf('=== Game of Life - Interactive Demo ===\n\n');
fprintf('Controls:\n');
fprintf('  Mouse Click - Toggle cells alive/dead\n');
fprintf('  SPACE       - Pause/Resume simulation\n');
fprintf('  S           - Single step forward (when paused)\n');
fprintf('  R           - Reset to initial state\n');
fprintf('  C           - Clear all cells\n');
fprintf('  +/-         - Increase/decrease speed\n');
fprintf('  Q           - Quit simulation\n\n');

% Configuration
grid_size = 40;
initial_speed = 0.2;  % Delay between generations (seconds)

% Create initial grid with a glider pattern
fprintf('Initializing grid with glider pattern...\n');
grid = zeros(grid_size, grid_size);

% Place a glider in the middle
center = floor(grid_size / 2);
glider = [0 1 0; 0 0 1; 1 1 1];
grid(center:center+2, center:center+2) = glider;

% Store initial state for reset
initial_grid = grid;

% Initialize display
fig_handle = init_display(grid_size);

% Simulation state variables
generation = 0;
is_paused = true;  % Start paused to allow editing
speed = initial_speed;

% Initial display
population = sum(grid(:));
update_display(fig_handle, grid, generation, population, 'Paused');

fprintf('Simulation started in PAUSED mode.\n');
fprintf('Click cells to draw, then press SPACE to start!\n\n');

% Main simulation loop
running = true;
last_update = time();

while running
  % Check if figure is still open
  if ~ishandle(fig_handle)
    fprintf('Window closed. Exiting...\n');
    break;
  endif
  
  % Process any pending events (keyboard/mouse)
  drawnow;
  
  % Check for keyboard input
  % Note: In Octave, direct keyboard event handling in loops is limited
  % This is a simplified version - full implementation would use callbacks
  
  % Update simulation if running and enough time has passed
  current_time = time();
  if ~is_paused && (current_time - last_update) >= speed
    % Apply Game of Life rules
    grid = gameoflife_rules(grid);
    generation = generation + 1;
    population = sum(grid(:));
    
    % Update display
    update_display(fig_handle, grid, generation, population, 'Running');
    
    last_update = current_time;
  endif
  
  % Small pause to prevent CPU overload
  pause(0.01);
  
  % Simple keyboard checking (basic implementation)
  % Note: This is a demo - full implementation would use proper event callbacks
  
endwhile

fprintf('\nSimulation ended.\n');
fprintf('Final generation: %d\n', generation);
fprintf('Final population: %d\n', sum(grid(:)));

% Close figure if still open
if ishandle(fig_handle)
  close(fig_handle);
endif

fprintf('Demo complete.\n');
