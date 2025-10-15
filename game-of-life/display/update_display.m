function update_display(fig_handle, grid, varargin)
  % UPDATE_DISPLAY Update the Game of Life display with current state
  %
  % Usage: 
  %   update_display(fig_handle, grid, generation, population, status)  % Old style
  %   update_display(fig_handle, grid, stats, status)                    % New style with stats struct
  %
  % Inputs:
  %   fig_handle - Handle to the figure window
  %   grid       - Current state of the game grid (0=dead, 1=alive)
  %   
  % Optional inputs (old style):
  %   generation - Current generation number
  %   population - Current population count
  %   status     - Status string (e.g., 'Running', 'Paused')
  %
  % Optional inputs (new style):
  %   stats      - Statistics structure from calculate_stats()
  %   status     - Status string
  %
  % Updates the display with the current grid state, generation counter,
  % population statistics, and additional metrics.

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
  
  % Parse input arguments
  if nargin >= 3 && isstruct(varargin{1})
    % New style: stats structure provided
    stats = varargin{1};
    generation = stats.generation;
    population = stats.population;
    change = stats.change;
    density = stats.density;
    if nargin >= 4
      status = varargin{2};
    else
      status = 'Running';
    endif
  else
    % Old style: individual parameters
    if nargin >= 3
      generation = varargin{1};
    else
      generation = 0;
    endif
    
    if nargin >= 4
      population = varargin{2};
    else
      population = sum(grid(:));
    endif
    
    if nargin >= 5
      status = varargin{3};
    else
      status = 'Running';
    endif
    
    change = 0;
    density = (population / numel(grid)) * 100;
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
  
  % Update population counter with change indicator
  pop_text = findobj(fig_handle, 'Tag', 'PopulationCounter');
  if ~isempty(pop_text)
    if change ~= 0
      change_str = sprintf(' (%+d)', change);
    else
      change_str = '';
    endif
    set(pop_text, 'String', sprintf('Population: %d%s', population, change_str));
  endif
  
  % Update density display
  density_text = findobj(fig_handle, 'Tag', 'DensityText');
  if ~isempty(density_text)
    set(density_text, 'String', sprintf('Density: %.1f%%', density));
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
    elseif strcmp(status, 'Static')
      set(status_text, 'ForegroundColor', [0.7 0.7 1.0]);
    else
      set(status_text, 'ForegroundColor', [0.9 0.9 0.9]);
    endif
  endif
  
  % Force display update
  drawnow;
  
endfunction
