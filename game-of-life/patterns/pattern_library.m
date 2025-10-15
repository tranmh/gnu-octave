function pattern = pattern_library(pattern_name)
  % PATTERN_LIBRARY - Collection of classic Game of Life patterns
  %
  % Usage:
  %   pattern = pattern_library(pattern_name)
  %
  % Input:
  %   pattern_name - String name of pattern to retrieve
  %
  % Output:
  %   pattern - Binary matrix representing the pattern
  %
  % Available Patterns:
  %   'random'    - Random initial state
  %   'glider'    - Simple moving pattern
  %   'blinker'   - Period-2 oscillator
  %   'toad'      - Period-2 oscillator
  %   'beacon'    - Period-2 oscillator
  %   'pulsar'    - Period-3 oscillator
  %   'glider_gun' - Gosper Glider Gun (generates gliders)
  %   'lwss'      - Lightweight Spaceship (moving pattern)
  %   'block'     - 2x2 still life
  %   'beehive'   - Stable hexagonal pattern
  %   'loaf'      - Stable loaf pattern
  %   'boat'      - Stable boat pattern
  %   'tub'       - Stable tub pattern
  
  switch lower(pattern_name)
    case 'random'
      % Random pattern - will be sized by caller
      pattern = [];  % Empty, will be filled with random values by main program
      
    case 'glider'
      % Glider - moves diagonally across the grid
      pattern = [
        0, 1, 0;
        0, 0, 1;
        1, 1, 1
      ];
      
    case 'blinker'
      % Blinker - simple period-2 oscillator
      pattern = [
        1, 1, 1
      ];
      
    case 'toad'
      % Toad - period-2 oscillator
      pattern = [
        0, 1, 1, 1;
        1, 1, 1, 0
      ];
      
    case 'beacon'
      % Beacon - period-2 oscillator
      pattern = [
        1, 1, 0, 0;
        1, 1, 0, 0;
        0, 0, 1, 1;
        0, 0, 1, 1
      ];
      
    case 'pulsar'
      % Pulsar - period-3 oscillator
      pattern = [
        0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0;
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
        1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1;
        1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1;
        1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1;
        0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0;
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
        0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0;
        1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1;
        1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1;
        1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1;
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
        0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0
      ];
      
    case 'glider_gun'
      % Gosper Glider Gun - generates gliders
      pattern = zeros(11, 38);
      % Left square
      pattern(5, 1:2) = 1;
      pattern(6, 1:2) = 1;
      
      % Left part of gun
      pattern(5, 11) = 1;
      pattern(6, 11:12) = 1;
      pattern(7, 13) = 1;
      pattern(4, 13) = 1;
      pattern(3, 14:15) = 1;
      pattern(8, 14:15) = 1;
      pattern(5, 16) = 1;
      pattern(4, 17) = 1;
      pattern(6, 17:18) = 1;
      pattern(7, 17) = 1;
      pattern(5, 19) = 1;
      pattern(5, 21:22) = 1;
      pattern(4, 21:22) = 1;
      pattern(3, 21:22) = 1;
      pattern(6, 23) = 1;
      pattern(2, 23) = 1;
      pattern(2, 25) = 1;
      pattern(1, 25) = 1;
      pattern(6, 25) = 1;
      pattern(7, 25) = 1;
      
      % Right square
      pattern(3, 35:36) = 1;
      pattern(4, 35:36) = 1;
      
    case 'lwss'
      % Lightweight Spaceship - moves horizontally
      pattern = [
        0, 1, 0, 0, 1;
        1, 0, 0, 0, 0;
        1, 0, 0, 0, 1;
        1, 1, 1, 1, 0
      ];
      
    case 'block'
      % Block - 2x2 still life
      pattern = [
        1, 1;
        1, 1
      ];
      
    case 'beehive'
      % Beehive - stable hexagonal pattern
      pattern = [
        0, 1, 1, 0;
        1, 0, 0, 1;
        0, 1, 1, 0
      ];
      
    case 'loaf'
      % Loaf - stable loaf pattern
      pattern = [
        0, 1, 1, 0;
        1, 0, 0, 1;
        0, 1, 0, 1;
        0, 0, 1, 0
      ];
      
    case 'boat'
      % Boat - stable boat pattern
      pattern = [
        1, 1, 0;
        1, 0, 1;
        0, 1, 0
      ];
      
    case 'tub'
      % Tub - stable tub pattern
      pattern = [
        0, 1, 0;
        1, 0, 1;
        0, 1, 0
      ];
      
    otherwise
      error('Unknown pattern: %s', pattern_name);
  end
  
endfunction
