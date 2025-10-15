% HANDLE_KEYBOARD - Process keyboard input for Game of Life controls
%
% This function interprets keyboard commands and returns appropriate
% actions for the main game loop to execute.
%
% Usage:
%   action = handle_keyboard(key, current_speed)
%
% Inputs:
%   key           - Character or key code from keyboard input
%   current_speed - Current simulation speed (delay in seconds)
%
% Output:
%   action - Structure containing:
%     .type  - Action type: 'pause', 'resume', 'step', 'reset', 
%              'clear', 'save', 'load', 'quit', 'speed', 'none'
%     .speed - New speed value (only for 'speed' action)
%
% Keyboard Controls:
%   SPACE - Pause/Resume simulation
%   S     - Single step forward (when paused)
%   R     - Reset to initial state
%   C     - Clear grid (kill all cells)
%   V     - Save current pattern to file
%   L     - Load pattern from file
%   +/=   - Increase speed (decrease delay)
%   -/_   - Decrease speed (increase delay)
%   Q     - Quit simulation
%   H     - Show help (future implementation)
%
% Speed Control:
%   - Minimum delay: 0.01 seconds (very fast)
%   - Maximum delay: 2.0 seconds (very slow)
%   - Speed change step: 0.05 seconds

function action = handle_keyboard(key, current_speed)
  % Initialize action structure with default 'none' action
  action.type = 'none';
  action.speed = current_speed;
  
  % Convert key to lowercase for case-insensitive matching
  key_lower = lower(key);
  
  % Process keyboard commands
  switch key_lower
    case ' '
      % SPACE - Toggle pause/resume
      action.type = 'toggle_pause';
      
    case 's'
      % S - Single step forward
      action.type = 'step';
      
    case 'r'
      % R - Reset to initial state
      action.type = 'reset';
      
    case 'c'
      % C - Clear grid
      action.type = 'clear';
      
    case 'q'
      % Q - Quit simulation
      action.type = 'quit';
      
    case 'h'
      % H - Show help
      action.type = 'help';
      
    case 'v'
      % V - Save pattern
      action.type = 'save';
      
    case 'l'
      % L - Load pattern
      action.type = 'load';
      
    case {'+', '='}
      % +/= - Increase speed (decrease delay)
      action.type = 'speed';
      new_speed = current_speed - 0.05;
      % Enforce minimum speed (maximum delay)
      action.speed = max(0.01, new_speed);
      
    case {'-', '_'}
      % -/_ - Decrease speed (increase delay)
      action.type = 'speed';
      new_speed = current_speed + 0.05;
      % Enforce maximum speed (minimum delay)
      action.speed = min(2.0, new_speed);
      
    otherwise
      % Unknown key - no action
      action.type = 'none';
  endswitch
  
endfunction
