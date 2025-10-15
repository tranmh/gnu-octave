function grid = place_pattern(grid, pattern, center_row, center_col)
  % PLACE_PATTERN - Place a pattern on the grid at specified location
  %
  % Usage:
  %   grid = place_pattern(grid, pattern, center_row, center_col)
  %
  % Inputs:
  %   grid       - Current grid state (rows x cols binary matrix)
  %   pattern    - Pattern to place (binary matrix)
  %   center_row - Row coordinate for pattern center (optional)
  %   center_col - Column coordinate for pattern center (optional)
  %
  % Output:
  %   grid - Updated grid with pattern placed
  %
  % If center coordinates not provided, pattern is centered on grid
  
  [grid_rows, grid_cols] = size(grid);
  [pattern_rows, pattern_cols] = size(pattern);
  
  % If no center coordinates provided, center the pattern
  if nargin < 3
    center_row = floor(grid_rows / 2);
    center_col = floor(grid_cols / 2);
  endif
  
  % Calculate starting position (top-left corner of pattern)
  start_row = center_row - floor(pattern_rows / 2);
  start_col = center_col - floor(pattern_cols / 2);
  
  % Calculate the region to place the pattern
  % Handle boundary cases with modulo arithmetic (toroidal wrapping)
  for i = 1:pattern_rows
    for j = 1:pattern_cols
      % Calculate grid position with wrapping
      grid_row = mod(start_row + i - 1, grid_rows) + 1;
      grid_col = mod(start_col + j - 1, grid_cols) + 1;
      
      % Place the pattern cell (using OR to not erase existing cells if desired)
      % Change to assignment (=) if you want to replace existing cells
      grid(grid_row, grid_col) = pattern(i, j);
    endfor
  endfor
  
endfunction
