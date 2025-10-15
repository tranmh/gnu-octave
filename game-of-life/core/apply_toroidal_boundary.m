function idx = apply_toroidal_boundary(idx, max_size)
  % APPLY_TOROIDAL_BOUNDARY Apply wrap-around boundary conditions
  %
  % Usage: idx = apply_toroidal_boundary(idx, max_size)
  %
  % Inputs:
  %   idx - Index or array of indices
  %   max_size - Maximum size of the dimension
  %
  % Outputs:
  %   idx - Wrapped indices within valid range [1, max_size]
  %
  % Description:
  %   Implements toroidal (wrap-around) boundary conditions.
  %   Indices that go below 1 wrap to max_size.
  %   Indices that exceed max_size wrap to 1.
  %   This creates a "toroidal" topology where edges connect.
  %
  % Examples:
  %   apply_toroidal_boundary(0, 50) returns 50
  %   apply_toroidal_boundary(51, 50) returns 1
  %   apply_toroidal_boundary([0 1 50 51], 50) returns [50 1 50 1]
  
  % Use modular arithmetic for wrapping
  % Subtract 1 to make 0-based, apply mod, add 1 to make 1-based
  idx = mod(idx - 1, max_size) + 1;
  
end
