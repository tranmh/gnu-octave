function [iter_count, final_z, X, Y] = burning_ship(center, width, height, nx, ny, max_iter, escape_radius)
  % BURNING_SHIP Calculate the Burning Ship fractal
  %
  % Usage:
  %   [iter_count, final_z, X, Y] = burning_ship(center, width, height, nx, ny, max_iter, escape_radius)
  %
  % Inputs:
  %   center        - Center point in complex plane (default: -0.5 - 0.5i)
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
  %   For each point c in the complex plane:
  %     z_0 = 0
  %     z_{n+1} = (|Re(z_n)| + i|Im(z_n)|)^2 + c
  %
  %   The absolute value operations create the distinctive "ship" appearance.
  %   The fractal appears upside-down compared to Mandelbrot.
  %
  % Example:
  %   % Default view of Burning Ship
  %   [iter, final_z] = burning_ship(-0.5-0.5i, 4.0, 3.0, 800, 600);
  %
  %   % Ship's bow
  %   [iter, final_z] = burning_ship(-1.75+0.05i, 0.1, 0.1, 800, 600, 512);
  %
  % Famous Locations:
  %   Ship's Bow:    -1.75 + 0.05i  (width: 0.1)
  %   Masts:         -1.625 + 0.02i (width: 0.01)
  %   Full View:     -0.5 - 0.5i    (width: 4.0)
  %
  % Phase: 4 - Extended 2D Fractals

  % Default parameters
  if nargin < 1 || isempty(center)
    center = -0.5 - 0.5i;
  end
  if nargin < 2 || isempty(width)
    width = 4.0;
  end
  if nargin < 3 || isempty(height)
    height = 3.0;
  end
  if nargin < 4 || isempty(nx)
    nx = 800;
  end
  if nargin < 5 || isempty(ny)
    ny = 600;
  end
  if nargin < 6 || isempty(max_iter)
    max_iter = 256;
  end
  if nargin < 7 || isempty(escape_radius)
    escape_radius = 2.0;
  end

  % Generate complex grid
  [X, Y, C] = complex_grid(center, width, height, nx, ny);

  % For Burning Ship: z_0 = 0
  z0 = zeros(size(C));

  % Compute escape times using burning_ship iteration
  [iter_count, final_z] = escape_time_common(z0, C, max_iter, escape_radius, 'burning_ship');

end
