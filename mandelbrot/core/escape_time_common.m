function [iter_count, final_z] = escape_time_common(z0, c, max_iter, escape_radius, func_type)
  % ESCAPE_TIME_COMMON Generic escape-time algorithm for various fractals
  %
  % Usage:
  %   [iter_count, final_z] = escape_time_common(z0, c, max_iter, escape_radius, func_type)
  %
  % Inputs:
  %   z0            - Initial z values (complex matrix)
  %   c             - Parameter values (complex matrix, same size as z0)
  %   max_iter      - Maximum iteration count
  %   escape_radius - Escape threshold (typically 2.0)
  %   func_type     - Function type: 'mandelbrot', 'julia', 'burning_ship', etc.
  %
  % Outputs:
  %   iter_count - Iteration count at escape (0 = never escaped)
  %   final_z    - Final z value (for smooth coloring)
  %
  % Algorithm:
  %   Iterates z_{n+1} = f(z_n, c) until |z| > escape_radius or max_iter reached
  %   Uses vectorized operations for efficiency
  %
  % Example:
  %   [X, Y, C] = complex_grid(-0.5+0i, 3.5, 2.5, 800, 600);
  %   [iter, final_z] = escape_time_common(zeros(size(C)), C, 256, 2.0, 'mandelbrot');
  %
  % Phase: 1 - Core 2D Fractals

  % Initialize
  z = z0;
  iter_count = zeros(size(z0));
  final_z = zeros(size(z0));

  % Active pixels (not yet escaped)
  active = true(size(z0));

  % Main iteration loop
  for n = 1:max_iter
    % Apply iteration function based on type
    switch func_type
      case 'mandelbrot'
        z(active) = z(active).^2 + c(active);

      case 'julia'
        z(active) = z(active).^2 + c(active);

      case 'burning_ship'
        % Burning Ship: z_{n+1} = (|Re(z)| + i|Im(z)|)^2 + c
        z_abs = abs(real(z(active))) + 1i * abs(imag(z(active)));
        z(active) = z_abs.^2 + c(active);

      case 'tricorn'
        % Tricorn: z_{n+1} = conj(z)^2 + c
        z(active) = conj(z(active)).^2 + c(active);

      case 'multibrot'
        % For multibrot, c should contain the power in the imaginary part
        % and the actual c value in the real part (handled by caller)
        z(active) = z(active).^2 + c(active);

      otherwise
        error('Unknown function type: %s', func_type);
    end

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
