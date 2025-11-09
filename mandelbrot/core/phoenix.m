function [iter_count, final_z, X, Y] = phoenix(phoenix_c, phoenix_p, center, width, height, nx, ny, max_iter, escape_radius)
  % PHOENIX Calculate the Phoenix fractal
  %
  % Usage:
  %   [iter_count, final_z, X, Y] = phoenix(phoenix_c, phoenix_p, center, width, height, nx, ny, max_iter, escape_radius)
  %
  % Inputs:
  %   phoenix_c     - Complex parameter c (default: 0.5 - 0.1i)
  %   phoenix_p     - Complex parameter p (default: -0.5 + 0i)
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
  %     z_{n+1} = z_n^2 + Re(c) + Im(c) * z_{n-1}
  %
  %   This is a two-parameter system that requires tracking the previous value.
  %   Creates unique phoenix-like patterns.
  %
  % Example:
  %   % Classic Phoenix
  %   [iter, final_z] = phoenix(0.5-0.1i, -0.5+0i, 0+0i, 4.0, 3.0, 800, 600);
  %
  %   % Variant
  %   [iter, final_z] = phoenix(0.56667-0.5i, -0.5+0i, 0+0i, 4.0, 3.0, 800, 600);
  %
  % Phase: 4 - Extended 2D Fractals

  % Default parameters
  if nargin < 1 || isempty(phoenix_c)
    phoenix_c = 0.5 - 0.1i;
  end
  if nargin < 2 || isempty(phoenix_p)
    phoenix_p = -0.5 + 0i;
  end
  if nargin < 3 || isempty(center)
    center = 0 + 0i;
  end
  if nargin < 4 || isempty(width)
    width = 4.0;
  end
  if nargin < 5 || isempty(height)
    height = 3.0;
  end
  if nargin < 6 || isempty(nx)
    nx = 800;
  end
  if nargin < 7 || isempty(ny)
    ny = 600;
  end
  if nargin < 8 || isempty(max_iter)
    max_iter = 256;
  end
  if nargin < 9 || isempty(escape_radius)
    escape_radius = 2.0;
  end

  % Generate complex grid (this becomes z_0)
  [X, Y, C] = complex_grid(center, width, height, nx, ny);

  % Compute escape times with Phoenix iteration
  [iter_count, final_z] = phoenix_iterate(C, phoenix_c, phoenix_p, max_iter, escape_radius);

end


function [iter_count, final_z] = phoenix_iterate(z0, phoenix_c, phoenix_p, max_iter, escape_radius)
  % Custom iteration for Phoenix fractal

  z_curr = z0;
  z_prev = zeros(size(z0));  % z_{n-1} starts at 0

  iter_count = zeros(size(z0));
  final_z = zeros(size(z0));
  active = true(size(z0));

  % Extract real and imaginary parts of parameters
  c_real = real(phoenix_c);
  c_imag = imag(phoenix_c);

  for n = 1:max_iter
    % z_{n+1} = z_n^2 + Re(c) + Im(c) * z_{n-1}
    z_new = z_curr(active).^2 + c_real + c_imag * z_prev(active);

    % Update z values
    z_prev(active) = z_curr(active);
    z_curr(active) = z_new;

    % Check for escape
    magnitude = abs(z_curr);
    escaped = active & (magnitude > escape_radius);

    % Record iteration count for newly escaped pixels
    iter_count(escaped) = n;
    final_z(escaped) = z_curr(escaped);

    % Remove escaped pixels from active set
    active(escaped) = false;

    % Early exit if all pixels have escaped
    if ~any(active(:))
      break;
    end
  end

  % For pixels that never escaped, store final z value
  final_z(active) = z_curr(active);

end
