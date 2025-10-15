function update_display(fig_handle, grid, generation, population, status)
  % UPDATE_DISPLAY Update the Game of Life display with current state
  %
  % Usage: update_display(fig_handle, grid, generation, population, status)
  %
  % Inputs:
  %   fig_handle - Handle to the figure window
  %   grid       - Current state of the game grid (0=dead, 1=alive)
  %   generation - Current generation number
  %   population - Current population count (optional, calculated if not provided)
  %   status     - Status string (optional, e.g., 'Running', 'Paused')
  %
  % Updates the display with the current grid state, generation counter,
  % and population statistics.

  % Check if figure is still valid
  if ~ishandle(fig_handle)
    error('Invalid figure handle');
  endif
  
  % Set current figure
  figure(fig_handle);
  
  % Get or create axes
  ax = findobj(fig_handle, 'Type', 'axes');
  if isempty(ax)
    error('No axes found in figure');
  endif
  axes(ax);
  
  % Calculate population if not provided
  if nargin < 4 || isempty(population)
    population = sum(grid(:));
  endif
  
  % Default status
  if nargin < 5
    status = 'Running';
  endif
  
  % Display the grid using imagesc for efficient rendering
  % Create custom colormap: black for dead (0), green for alive (1)
  colormap([0 0 0; 0 0.8 0.2]);
  
  % Display grid
  imagesc(grid, [0 1]);
  
  % Keep axis properties
  axis equal;
  axis tight;
  set(ax, 'XTick', [], 'YTick', [], 'Box', 'on');
  
  % Update title
  title('Conway''s Game of Life', ...
        'Color', [0.9 0.9 0.9], ...
        'FontSize', 16, ...
        'FontWeight', 'bold');
  
  % Update generation counter
  gen_text = findobj(fig_handle, 'Tag', 'GenerationCounter');
  if ~isempty(gen_text)
    set(gen_text, 'String', sprintf('Generation: %d', generation));
  endif
  
  % Update population counter
  pop_text = findobj(fig_handle, 'Tag', 'PopulationCounter');
  if ~isempty(pop_text)
    set(pop_text, 'String', sprintf('Population: %d', population));
  endif
  
  % Update status text
  status_text = findobj(fig_handle, 'Tag', 'StatusText');
  if ~isempty(status_text)
    set(status_text, 'String', sprintf('Status: %s', status));
    
    % Color code status
    if strcmp(status, 'Running')
      set(status_text, 'ForegroundColor', [0.2 1.0 0.2]);
    elseif strcmp(status, 'Paused')
      set(status_text, 'ForegroundColor', [1.0 0.8 0.0]);
    else
      set(status_text, 'ForegroundColor', [0.9 0.9 0.9]);
    endif
  endif
  
  % Force display update
  drawnow;
  
endfunction
