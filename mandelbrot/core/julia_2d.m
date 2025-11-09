function [iter_count, final_z, X, Y] = julia_2d(julia_c, center, width, height, nx, ny, max_iter, escape_radius)
  % JULIA_2D Calculate a Julia set for a given parameter c
  %
  % Usage:
  %   [iter_count, final_z, X, Y] = julia_2d(julia_c, center, width, height, nx, ny, max_iter, escape_radius)
  %
  % Inputs:
  %   julia_c       - Julia set parameter (e.g., -0.7 + 0.27i)
  %   center        - Center point in complex plane (default: 0 + 0i)
  %   width         - Width of view (default: 4.0)
  %   height        - Height of view (default: 3.0)
  %   nx            - Horizontal resolution (default: 800)
  %   ny            - Vertical resolution (default: 600)
  %   max_iter      - Maximum iterations (default: 256)
  %   escape_radius - Escape threshold (default: 2.0)
  %
  % Outputs:
  %   iter_count - Escape iteration count (0 = never escaped)
  %   final_z    - Final z value (for smooth coloring)
  %   X          - Real coordinate grid
  %   Y          - Imaginary coordinate grid
  %
  % Algorithm:
  %   For each point z_0 in the complex plane:
  %     z_{n+1} = z_n^2 + c (where c is the fixed Julia parameter)
  %   The Julia set consists of points where |z| remains bounded
  %
  % Example:
  %   % Classic Julia set
  %   [iter, final_z] = julia_2d(-0.7 + 0.27i);
  %
  %   % Dendrite Julia
  %   [iter, final_z] = julia_2d(0 + 1i);
  %
  %   % Rabbit Julia
  %   [iter, final_z] = julia_2d(-0.123 + 0.745i);
  %
  % Famous Julia Parameters:
  %   c = -0.7 + 0.27i   - Classic spiral
  %   c = 0 + 1i         - Dendrite
  %   c = -0.123 + 0.745i - Rabbit
  %   c = -0.4 + 0.6i    - Snowflake
  %   c = 0.285 + 0.01i  - Douady's rabbit
  %
  % Phase: 1 - Core 2D Fractals

  % Validate julia_c
  if nargin < 1 || isempty(julia_c)
    error('Julia parameter c is required');
  end

  % Default parameters
  if nargin < 2 || isempty(center)
    center = 0 + 0i;
  end
  if nargin < 3 || isempty(width)
    width = 4.0;
  end
  if nargin < 4 || isempty(height)
    height = 3.0;
  end
  if nargin < 5 || isempty(nx)
    nx = 800;
  end
  if nargin < 6 || isempty(ny)
    ny = 600;
  end
  if nargin < 7 || isempty(max_iter)
    max_iter = 256;
  end
  if nargin < 8 || isempty(escape_radius)
    escape_radius = 2.0;
  end

  % Generate complex grid (this becomes z_0 for each pixel)
  [X, Y, C] = complex_grid(center, width, height, nx, ny);

  % For Julia set: z_0 = C (varies), c = julia_c (constant)
  z0 = C;
  c = julia_c * ones(size(C));

  % Compute escape times
  [iter_count, final_z] = escape_time_common(z0, c, max_iter, escape_radius, 'julia');

end
