function smooth_values = smooth_coloring(iter_count, final_z, escape_radius)
  % SMOOTH_COLORING Convert discrete iteration counts to smooth continuous values
  %
  % Usage:
  %   smooth_values = smooth_coloring(iter_count, final_z, escape_radius)
  %
  % Inputs:
  %   iter_count    - Integer escape iteration counts (0 = never escaped)
  %   final_z       - Final z values at escape
  %   escape_radius - Escape threshold used (typically 2.0)
  %
  % Outputs:
  %   smooth_values - Continuous iteration values (eliminates banding)
  %
  % Algorithm:
  %   For escaped pixels:
  %     mu = n + 1 - log(log(|z_n|)) / log(2)
  %
  %   This formula provides smooth, continuous values between iteration counts,
  %   eliminating the color banding artifacts of discrete iteration counts.
  %
  % Example:
  %   [iter, final_z] = mandelbrot_2d(-0.5+0i, 3.5, 2.5, 800, 600);
  %   smooth = smooth_coloring(iter, final_z, 2.0);
  %
  % Phase: 2 - Visualization & Color Palettes

  % Initialize smooth values with iteration counts
  smooth_values = double(iter_count);

  % Find escaped pixels (iter_count > 0)
  escaped = iter_count > 0;

  % Calculate magnitude of final z for escaped pixels
  z_magnitude = abs(final_z(escaped));

  % Smooth coloring formula: mu = n + 1 - log(log(|z|)) / log(2)
  % This requires |z| > 1, which is guaranteed since escape_radius >= 2
  log_z = log(z_magnitude);
  log_log_z = log(log_z);

  % Apply smoothing correction
  smooth_values(escaped) = double(iter_count(escaped)) + 1 - log_log_z / log(2);

  % Handle any numerical issues (NaN, Inf)
  smooth_values(isnan(smooth_values)) = 0;
  smooth_values(isinf(smooth_values)) = 0;

  % Ensure non-negative values
  smooth_values = max(smooth_values, 0);

end
