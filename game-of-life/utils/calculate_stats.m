function stats = calculate_stats(grid, prev_grid, generation)
  % CALCULATE_STATS - Calculate population statistics for Game of Life
  %
  % Syntax: stats = calculate_stats(grid, prev_grid, generation)
  %
  % Inputs:
  %   grid - Current game grid (matrix of 0s and 1s)
  %   prev_grid - Previous generation grid (for calculating change)
  %   generation - Current generation number
  %
  % Outputs:
  %   stats - Structure containing:
  %     .population - Current number of living cells
  %     .change - Population change from previous generation
  %     .change_rate - Percentage change from previous generation
  %     .density - Percentage of cells that are alive
  %     .generation - Current generation number
  %
  % Example:
  %   stats = calculate_stats(current_grid, previous_grid, 42);
  %   fprintf('Population: %d (change: %+d)\n', stats.population, stats.change);
  
  % Calculate current population (count living cells)
  stats.population = sum(grid(:));
  
  % Calculate change from previous generation
  if ~isempty(prev_grid)
    prev_population = sum(prev_grid(:));
    stats.change = stats.population - prev_population;
    
    % Calculate percentage change rate
    if prev_population > 0
      stats.change_rate = (stats.change / prev_population) * 100;
    else
      stats.change_rate = 0;
    end
  else
    stats.change = 0;
    stats.change_rate = 0;
  end
  
  % Calculate density (percentage of living cells)
  total_cells = numel(grid);
  stats.density = (stats.population / total_cells) * 100;
  
  % Store generation number
  stats.generation = generation;
  
  % Additional statistics: stability detection
  if ~isempty(prev_grid)
    % Check if grid is identical to previous (static pattern)
    stats.is_static = isequal(grid, prev_grid);
  else
    stats.is_static = false;
  end
  
end
