function distance = mandelbulb_3d(pos, power, max_iter)
  % MANDELBULB_3D Calculate distance estimate for Mandelbulb fractal
  %
  % Usage:
  %   distance = mandelbulb_3d(pos, power, max_iter)
  %
  % Inputs:
  %   pos      - 3D position [x, y, z] or Nx3 matrix
  %   power    - Power parameter (typically 8)
  %   max_iter - Maximum iterations (default: 16)
  %
  % Outputs:
  %   distance - Distance estimate to surface
  %
  % Algorithm:
  %   Uses distance estimation for ray marching:
  %   DE = 0.5 * r * log(r) / dr
  %
  %   The Mandelbulb extends the Mandelbrot set to 3D using
  %   spherical coordinates with power n (typically 8).
  %
  % Example:
  %   dist = mandelbulb_3d([0, 0, 0], 8, 16);
  %
  % Phase: 5 - 3D Fractals

  if nargin < 2 || isempty(power)
    power = 8;
  end
  if nargin < 3 || isempty(max_iter)
    max_iter = 16;
  end

  % Handle single point or multiple points
  if size(pos, 1) == 1 && size(pos, 2) == 3
    % Single point
    distance = mandelbulb_single(pos, power, max_iter);
  else
    % Multiple points
    n_points = size(pos, 1);
    distance = zeros(n_points, 1);
    for i = 1:n_points
      distance(i) = mandelbulb_single(pos(i, :), power, max_iter);
    end
  end

end


function dist = mandelbulb_single(pos, power, max_iter)
  % Distance estimation for single point

  x = pos(1);
  y = pos(2);
  z = pos(3);

  % Initialize
  dr = 1.0;  % Derivative
  r = sqrt(x*x + y*y + z*z);

  % Bailout if starting point is too far
  if r > 2.0
    dist = r;
    return;
  end

  % Iterate
  for n = 1:max_iter
    % Convert to spherical coordinates
    theta = atan2(sqrt(x*x + y*y), z);
    phi = atan2(y, x);

    % Scale and rotate
    dr = power * r^(power-1) * dr + 1.0;

    % New radius
    r_new = r^power;

    % New angles
    theta_new = theta * power;
    phi_new = phi * power;

    % Convert back to Cartesian with new radius
    sin_theta = sin(theta_new);
    x = r_new * sin_theta * cos(phi_new) + pos(1);
    y = r_new * sin_theta * sin(phi_new) + pos(2);
    z = r_new * cos(theta_new) + pos(3);

    % Calculate new radius
    r = sqrt(x*x + y*y + z*z);

    % Escape condition
    if r > 2.0
      break;
    end
  end

  % Distance estimate
  if r < 2.0
    % Didn't escape - very close to or inside fractal
    dist = 0.0;
  else
    % Escaped - compute distance estimate
    dist = 0.5 * r * log(r) / dr;
  end

end
