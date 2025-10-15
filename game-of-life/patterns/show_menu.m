function [pattern_choice, grid_size] = show_menu()
  % SHOW_MENU - Display pattern selection menu and get user choices
  %
  % Usage:
  %   [pattern_choice, grid_size] = show_menu()
  %
  % Outputs:
  %   pattern_choice - String name of selected pattern
  %   grid_size      - Desired grid size (rows and cols, assumes square grid)
  %
  % Displays a menu of available patterns and prompts for grid size
  
  clc;  % Clear command window for clean menu display
  
  printf('\n');
  printf('╔════════════════════════════════════════════════════════════════╗\n');
  printf('║           CONWAY''S GAME OF LIFE - Pattern Selection           ║\n');
  printf('╚════════════════════════════════════════════════════════════════╝\n');
  printf('\n');
  printf('Available Patterns:\n');
  printf('─────────────────────────────────────────────────────────────────\n');
  printf('\n');
  printf('  OSCILLATORS (Repeating Patterns):\n');
  printf('    [1]  Blinker       - Period-2 oscillator (simple line)\n');
  printf('    [2]  Toad          - Period-2 oscillator\n');
  printf('    [3]  Beacon        - Period-2 oscillator\n');
  printf('    [4]  Pulsar        - Period-3 oscillator (large)\n');
  printf('\n');
  printf('  SPACESHIPS (Moving Patterns):\n');
  printf('    [5]  Glider        - Small diagonal mover\n');
  printf('    [6]  LWSS          - Lightweight Spaceship\n');
  printf('\n');
  printf('  STILL LIFES (Static Patterns):\n');
  printf('    [7]  Block         - 2x2 square\n');
  printf('    [8]  Beehive       - Hexagonal shape\n');
  printf('    [9]  Loaf          - Loaf shape\n');
  printf('    [10] Boat          - Boat shape\n');
  printf('    [11] Tub           - Tub shape\n');
  printf('\n');
  printf('  COMPLEX PATTERNS:\n');
  printf('    [12] Glider Gun    - Gosper Glider Gun (generates gliders!)\n');
  printf('\n');
  printf('  RANDOM:\n');
  printf('    [13] Random        - Random initial state\n');
  printf('\n');
  printf('─────────────────────────────────────────────────────────────────\n');
  printf('\n');
  
  % Get user choice for pattern
  choice = input('Enter pattern number [1-13]: ');
  
  % Validate input
  while isempty(choice) || choice < 1 || choice > 13 || floor(choice) ~= choice
    printf('Invalid choice. Please enter a number between 1 and 13.\n');
    choice = input('Enter pattern number [1-13]: ');
  endwhile
  
  % Map choice to pattern name
  pattern_names = {
    'blinker',     % 1
    'toad',        % 2
    'beacon',      % 3
    'pulsar',      % 4
    'glider',      % 5
    'lwss',        % 6
    'block',       % 7
    'beehive',     % 8
    'loaf',        % 9
    'boat',        % 10
    'tub',         % 11
    'glider_gun',  % 12
    'random'       % 13
  };
  
  pattern_choice = pattern_names{choice};
  
  printf('\n');
  
  % Get grid size
  grid_size = input('Enter grid size (e.g., 50 for 50x50 grid) [default: 50]: ');
  
  % Validate grid size
  if isempty(grid_size)
    grid_size = 50;  % Default
  else
    % Ensure valid size
    while grid_size < 10 || grid_size > 200 || floor(grid_size) ~= grid_size
      printf('Invalid size. Please enter an integer between 10 and 200.\n');
      grid_size = input('Enter grid size [default: 50]: ');
      if isempty(grid_size)
        grid_size = 50;
        break;
      endif
    endwhile
  endif
  
  printf('\n');
  printf('Starting Game of Life with %s pattern on %dx%d grid...\n', ...
         pattern_choice, grid_size, grid_size);
  printf('Press any key to continue...\n');
  pause;
  
endfunction
