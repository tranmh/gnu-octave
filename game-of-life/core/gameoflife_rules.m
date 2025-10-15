function next_grid = gameoflife_rules(current_grid)
  % GAMEOFLIFE_RULES Apply Conway's Game of Life rules to calculate next generation
  %
  % Usage: next_grid = gameoflife_rules(current_grid)
  %
  % Inputs:
  %   current_grid - MxN binary matrix where 1 = alive, 0 = dead
  %
  % Outputs:
  %   next_grid - MxN binary matrix representing the next generation
  %
  % Conway's Game of Life Rules:
  %   1. Any live cell with 2 or 3 live neighbors survives
  %   2. Any dead cell with exactly 3 live neighbors becomes alive
  %   3. All other cells die or remain dead
  %
  % Description:
  %   Implements the classic Conway's Game of Life rules.
  %   Uses toroidal boundary conditions (edges wrap around).
  %   Optimized for performance using vectorized operations.
  
  % Count neighbors for all cells at once (vectorized operation)
  neighbor_count = count_neighbors(current_grid);
  
  % Initialize next generation grid (all dead)
  next_grid = zeros(size(current_grid));
  
  % Rule 1: Live cell with 2 or 3 neighbors survives
  % Rule 2: Dead cell with exactly 3 neighbors becomes alive
  % Combined: Cell is alive if it has 3 neighbors, OR if it has 2 neighbors and was alive
  
  % Vectorized implementation of rules:
  % A cell is alive in next generation if:
  %   - It has exactly 3 neighbors (birth or survival), OR
  %   - It has exactly 2 neighbors AND was alive (survival only)
  next_grid = (neighbor_count == 3) | ((neighbor_count == 2) & current_grid);
  
  % Convert logical to double (0s and 1s)
  next_grid = double(next_grid);
  
end
