function [iter_count, final_z, X, Y] = mandelbrot_2d(center, width, height, nx, ny, max_iter, escape_radius)
  % MANDELBROT_2D Calculate the Mandelbrot set
  %
  % Usage:
  %   [iter_count, final_z, X, Y] = mandelbrot_2d(center, width, height, nx, ny, max_iter, escape_radius)
  %
  % Inputs:
  %   center        - Center point in complex plane (default: -0.5 + 0i)
  %   width         - Width of view (default: 3.5)
  %   height        - Height of view (default: 2.5)
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
  %     z_{n+1} = z_n^2 + c
  %   The Mandelbrot set consists of points where |z| remains bounded
  %
  % Example:
  %   % Default view of Mandelbrot set
  %   [iter, final_z] = mandelbrot_2d(-0.5+0i, 3.5, 2.5, 800, 600);
  %
  %   % Zoomed view of Seahorse Valley
  %   [iter, final_z] = mandelbrot_2d(-0.745+0.113i, 0.01, 0.01, 800, 600, 512);
  %
  % Phase: 1 - Core 2D Fractals

  % Default parameters
  if nargin < 1 || isempty(center)
    center = -0.5 + 0i;
  end
  if nargin < 2 || isempty(width)
    width = 3.5;
  end
  if nargin < 3 || isempty(height)
    height = 2.5;
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

  % For Mandelbrot: z_0 = 0, iterate z = z^2 + c
  z0 = zeros(size(C));

  % Compute escape times
  [iter_count, final_z] = escape_time_common(z0, C, max_iter, escape_radius, 'mandelbrot');

end
