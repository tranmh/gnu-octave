function game_of_life(grid_size)
  % GAME_OF_LIFE - Conway's Game of Life with interactive GUI
  %
  % Syntax: game_of_life(grid_size)
  %
  % Inputs:
  %   grid_size - Optional size of the grid (default: 50)
  %               Can be scalar for square grid or [rows, cols]
  %
  % Description:
  %   Interactive implementation of Conway's Game of Life with:
  %   - Visual display with statistics
  %   - Mouse and keyboard controls
  %   - Pattern library
  %   - Save/Load functionality
  %   - Speed control
  %
  % Controls:
  %   SPACE     - Pause/Resume
  %   S         - Single step
  %   R         - Reset
  %   C         - Clear
  %   +/-       - Speed control
  %   H         - Help
  %   Q         - Quit
  %   Ctrl+S    - Save pattern
  %   Ctrl+L    - Load pattern
  %   L         - List saved patterns
  %   Click     - Toggle cells
  %
  % Example:
  %   game_of_life(50)     % 50x50 grid
  %   game_of_life([40 60]) % 40x60 grid
  
  % Add paths
  addpath('core');
  addpath('display');
  addpath('interaction');
  addpath('patterns');
  addpath('utils');
  
  % Default grid size
  if nargin < 1
    grid_size = 50;
  endif
  
  % Print welcome message
  fprintf('\n');
  fprintf('═══════════════════════════════════════════════════════════════════\n');
  fprintf('           CONWAY''S GAME OF LIFE - Interactive Simulator          \n');
  fprintf('═══════════════════════════════════════════════════════════════════\n');
  fprintf('\nInitializing...\n');
  
  % Show pattern selection menu
  [grid, pattern_name] = show_menu(grid_size);
  
  if isempty(grid)
    fprintf('Initialization cancelled.\n');
    return;
  endif
  
  fprintf('Pattern selected: %s\n', pattern_name);
  fprintf('Grid size: %dx%d\n', size(grid, 1), size(grid, 2));
  fprintf('Starting simulation...\n');
  fprintf('\nPress H at any time for help.\n\n');
  
  % Initialize display
  fig_handle = init_display(size(grid));
  
  % Store initial state for reset
  initial_grid = grid;
  
  % Game state variables
  generation = 0;
  is_paused = true;
  is_running = true;
  speed_delay = 0.1;  % Delay between generations (seconds)
  prev_grid = [];
  
  % Set up mouse click callback
  set(fig_handle, 'WindowButtonDownFcn', @(src, evt) mouse_callback());
  
  % Set up keyboard callback
  set(fig_handle, 'KeyPressFcn', @(src, evt) keyboard_callback(evt));
  
  % Calculate initial statistics
  stats = calculate_stats(grid, prev_grid, generation);
  
  % Initial display
  status_str = 'Paused';
  update_display(fig_handle, grid, stats, status_str);
  
  % Main game loop
  while is_running && ishandle(fig_handle)
    
    % Check if paused
    if is_paused
      pause(0.05);  % Small delay to prevent CPU spinning
      continue;
    endif
    
    % Store previous grid for statistics
    prev_grid = grid;
    
    % Calculate next generation
    grid = gameoflife_rules(grid);
    generation = generation + 1;
    
    % Calculate statistics
    stats = calculate_stats(grid, prev_grid, generation);
    
    % Determine status
    if stats.is_static
      status_str = 'Static';
      is_paused = true;  % Auto-pause on static pattern
    else
      status_str = 'Running';
    endif
    
    % Update display
    update_display(fig_handle, grid, stats, status_str);
    
    % Speed control delay
    pause(speed_delay);
    
  endwhile
  
  % Cleanup
  if ishandle(fig_handle)
    close(fig_handle);
  endif
  
  fprintf('\nSimulation ended.\n');
  fprintf('Final generation: %d\n', generation);
  fprintf('Final population: %d\n', stats.population);
  fprintf('═══════════════════════════════════════════════════════════════════\n\n');
  
  % ==================== NESTED CALLBACK FUNCTIONS ====================
  
  function mouse_callback()
    % Handle mouse clicks to toggle cells
    if ~ishandle(fig_handle)
      return;
    endif
    
    % Get click position
    pos = get(gca, 'CurrentPoint');
    col = round(pos(1, 1));
    row = round(pos(1, 2));
    
    % Check bounds
    [rows, cols] = size(grid);
    if row >= 1 && row <= rows && col >= 1 && col <= cols
      % Toggle cell
      grid(row, col) = ~grid(row, col);
      
      % Pause if not already paused
      if ~is_paused
        is_paused = true;
      endif
      
      % Update statistics
      stats = calculate_stats(grid, prev_grid, generation);
      
      % Update display
      update_display(fig_handle, grid, stats, 'Paused - Editing');
    endif
  endfunction
  
  function keyboard_callback(evt)
    % Handle keyboard input
    key = evt.Key;
    modifier = evt.Modifier;
    
    % Handle modifier keys (Ctrl+S, Ctrl+L)
    if ~isempty(modifier) && strcmp(modifier{1}, 'control')
      if strcmp(key, 's')
        % Save pattern
        fprintf('\n--- Save Pattern ---\n');
        pattern_name = input('Enter pattern name: ', 's');
        if ~isempty(pattern_name)
          save_pattern(grid, pattern_name);
        endif
        return;
      elseif strcmp(key, 'l')
        % Load pattern
        fprintf('\n--- Load Pattern ---\n');
        list_saved_patterns();
        pattern_name = input('Enter pattern name to load: ', 's');
        if ~isempty(pattern_name)
          loaded_grid = load_pattern(pattern_name);
          if ~isempty(loaded_grid)
            % Resize if necessary
            [rows, cols] = size(grid);
            [l_rows, l_cols] = size(loaded_grid);
            if l_rows <= rows && l_cols <= cols
              grid = place_pattern(loaded_grid, [rows, cols]);
              initial_grid = grid;
              generation = 0;
              prev_grid = [];
              stats = calculate_stats(grid, prev_grid, generation);
              update_display(fig_handle, grid, stats, 'Paused - Loaded');
            else
              fprintf('Pattern too large for current grid!\n');
            endif
          endif
        endif
        return;
      endif
    endif
    
    % Handle regular keys
    switch key
      case 'space'
        % Toggle pause/resume
        is_paused = ~is_paused;
        if is_paused
          stats = calculate_stats(grid, prev_grid, generation);
          update_display(fig_handle, grid, stats, 'Paused');
        endif
        
      case 's'
        % Single step (only when paused)
        if is_paused
          prev_grid = grid;
          grid = gameoflife_rules(grid);
          generation = generation + 1;
          stats = calculate_stats(grid, prev_grid, generation);
          status_str = stats.is_static ? 'Static' : 'Paused';
          update_display(fig_handle, grid, stats, status_str);
        endif
        
      case 'r'
        % Reset to initial state
        grid = initial_grid;
        generation = 0;
        prev_grid = [];
        is_paused = true;
        stats = calculate_stats(grid, prev_grid, generation);
        update_display(fig_handle, grid, stats, 'Paused - Reset');
        fprintf('Grid reset to initial state.\n');
        
      case 'c'
        % Clear grid
        grid = zeros(size(grid));
        initial_grid = grid;
        generation = 0;
        prev_grid = [];
        is_paused = true;
        stats = calculate_stats(grid, prev_grid, generation);
        update_display(fig_handle, grid, stats, 'Paused - Cleared');
        fprintf('Grid cleared.\n');
        
      case 'equal'  % + key (with shift)
        % Increase speed (decrease delay)
        speed_delay = max(0.01, speed_delay - 0.05);
        fprintf('Speed increased (delay: %.2fs)\n', speed_delay);
        
      case 'hyphen'  % - key
        % Decrease speed (increase delay)
        speed_delay = min(1.0, speed_delay + 0.05);
        fprintf('Speed decreased (delay: %.2fs)\n', speed_delay);
        
      case 'h'
        % Show help
        is_paused = true;
        display_help();
        pause;  % Wait for key press
        stats = calculate_stats(grid, prev_grid, generation);
        update_display(fig_handle, grid, stats, 'Paused');
        
      case 'l'
        % List saved patterns
        fprintf('\n--- Saved Patterns ---\n');
        list_saved_patterns();
        fprintf('Use Ctrl+L to load a pattern.\n\n');
        
      case 'q'
        % Quit
        fprintf('\nQuitting...\n');
        is_running = false;
        
      otherwise
        % Unknown key - do nothing
    endswitch
    
  endfunction
  
endfunction
