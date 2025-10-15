% HANDLE_MOUSE_CLICK - Toggle cell state with mouse clicks
%
% This function handles mouse click events on the Game of Life grid,
% allowing users to interactively toggle cells between alive and dead states.
%
% Usage:
%   new_grid = handle_mouse_click(grid, x, y)
%
% Inputs:
%   grid - Current grid state matrix (NxN)
%   x    - X coordinate of click (column)
%   y    - Y coordinate of click (row)
%
% Output:
%   new_grid - Updated grid with toggled cell
%
% The function converts mouse coordinates to grid indices and flips
% the state of the clicked cell (0->1 or 1->0).

function new_grid = handle_mouse_click(grid, x, y)
  % Get grid dimensions
  [rows, cols] = size(grid);
  
  % Convert coordinates to grid indices
  % Round to nearest integer to get cell position
  col_idx = round(x);
  row_idx = round(y);
  
  % Validate coordinates are within grid bounds
  if col_idx < 1 || col_idx > cols || row_idx < 1 || row_idx > rows
    % Click is outside grid, return unchanged grid
    new_grid = grid;
    return;
  endif
  
  % Create a copy of the grid
  new_grid = grid;
  
  % Toggle the cell state (flip between 0 and 1)
  new_grid(row_idx, col_idx) = ~new_grid(row_idx, col_idx);
  
endfunction
