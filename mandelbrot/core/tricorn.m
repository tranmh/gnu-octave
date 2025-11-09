function [iter_count, final_z, X, Y] = tricorn(center, width, height, nx, ny, max_iter, escape_radius)
  % TRICORN Calculate the Tricorn (Mandelbar) fractal
  %
  % Usage:
  %   [iter_count, final_z, X, Y] = tricorn(center, width, height, nx, ny, max_iter, escape_radius)
  %
  % Inputs:
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
  %   For each point c in the complex plane:
  %     z_0 = 0
  %     z_{n+1} = conj(z_n)^2 + c
  %
  %   The complex conjugate operation creates unique three-fold symmetry.
  %   Also known as the Mandelbar set.
  %
  % Example:
  %   % Default view of Tricorn
  %   [iter, final_z] = tricorn(0+0i, 4.0, 3.0, 800, 600);
  %
  %   % Detailed view
  %   [iter, final_z] = tricorn(0+0i, 2.0, 1.5, 800, 600, 512);
  %
  % Phase: 4 - Extended 2D Fractals

  % Default parameters
  if nargin < 1 || isempty(center)
    center = 0 + 0i;
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

  % For Tricorn: z_0 = 0
  z0 = zeros(size(C));

  % Compute escape times using tricorn iteration
  [iter_count, final_z] = escape_time_common(z0, C, max_iter, escape_radius, 'tricorn');

end
