function [iter_count, final_z, X, Y] = multibrot(power, center, width, height, nx, ny, max_iter, escape_radius)
  % MULTIBROT Calculate the Multibrot set with variable power
  %
  % Usage:
  %   [iter_count, final_z, X, Y] = multibrot(power, center, width, height, nx, ny, max_iter, escape_radius)
  %
  % Inputs:
  %   power         - Exponent (e.g., 3, 4, 5) - REQUIRED
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
  %     z_{n+1} = z_n^d + c  (where d = power)
  %
  %   Different powers create different symmetries:
  %   - power = 2: Standard Mandelbrot
  %   - power = 3: Three-fold symmetry (Multibrot-3)
  %   - power = 4: Four-fold symmetry (Multibrot-4)
  %   - power = 5+: Higher-order symmetries
  %
  % Example:
  %   % Multibrot-3 (tricorn-like)
  %   [iter, final_z] = multibrot(3, 0+0i, 3.0, 3.0, 800, 600);
  %
  %   % Multibrot-4 (four-fold symmetry)
  %   [iter, final_z] = multibrot(4, 0+0i, 3.0, 3.0, 800, 600);
  %
  %   % High power creates star-like patterns
  %   [iter, final_z] = multibrot(8, 0+0i, 2.5, 2.5, 800, 600);
  %
  % Phase: 4 - Extended 2D Fractals

  % Validate power parameter
  if nargin < 1 || isempty(power)
    error('Power parameter is required for Multibrot');
  end
  if power < 2
    error('Power must be >= 2');
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

  % Generate complex grid
  [X, Y, C] = complex_grid(center, width, height, nx, ny);

  % For Multibrot: z_0 = 0
  z0 = zeros(size(C));

  % Compute escape times with custom power
  [iter_count, final_z] = multibrot_iterate(z0, C, max_iter, escape_radius, power);

end


function [iter_count, final_z] = multibrot_iterate(z0, c, max_iter, escape_radius, power)
  % Custom iteration for Multibrot with variable power

  z = z0;
  iter_count = zeros(size(z0));
  final_z = zeros(size(z0));
  active = true(size(z0));

  for n = 1:max_iter
    % z_{n+1} = z_n^power + c
    z(active) = z(active).^power + c(active);

    % Check for escape
    magnitude = abs(z);
    escaped = active & (magnitude > escape_radius);

    % Record iteration count for newly escaped pixels
    iter_count(escaped) = n;
    final_z(escaped) = z(escaped);

    % Remove escaped pixels from active set
    active(escaped) = false;

    % Early exit if all pixels have escaped
    if ~any(active(:))
      break;
    end
  end

  % For pixels that never escaped, store final z value
  final_z(active) = z(active);

end
