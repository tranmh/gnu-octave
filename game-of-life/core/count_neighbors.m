function neighbor_count = count_neighbors(grid)
  % COUNT_NEIGHBORS Count the number of living neighbors for each cell in the grid
  %
  % Usage: neighbor_count = count_neighbors(grid)
  %
  % Inputs:
  %   grid - MxN binary matrix where 1 = alive, 0 = dead
  %
  % Outputs:
  %   neighbor_count - MxN matrix containing neighbor counts for each cell
  %
  % Description:
  %   Counts the 8 neighbors (Moore neighborhood) for each cell.
  %   Uses toroidal boundary conditions (edges wrap around).
  %   Optimized using vectorized operations for efficiency.
  
  [rows, cols] = size(grid);
  neighbor_count = zeros(rows, cols);
  
  % Define 8 neighbor offsets (row, col)
  % Top-left, Top, Top-right, Left, Right, Bottom-left, Bottom, Bottom-right
  offsets = [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];
  
  % Count neighbors using vectorized operations with toroidal wrapping
  for i = 1:8
    row_offset = offsets(i, 1);
    col_offset = offsets(i, 2);
    
    % Calculate wrapped indices
    row_idx = mod((1:rows) - 1 + row_offset, rows) + 1;
    col_idx = mod((1:cols) - 1 + col_offset, cols) + 1;
    
    % Add neighbors from this direction
    neighbor_count = neighbor_count + grid(row_idx, col_idx);
  end
  
end
