function distance = mandelbox_3d(pos, scale, max_iter)
  % MANDELBOX_3D Calculate distance estimate for Mandelbox fractal
  %
  % Usage:
  %   distance = mandelbox_3d(pos, scale, max_iter)
  %
  % Inputs:
  %   pos      - 3D position [x, y, z] or Nx3 matrix
  %   scale    - Scale parameter (typically 2.0-3.0)
  %   max_iter - Maximum iterations (default: 16)
  %
  % Outputs:
  %   distance - Distance estimate to surface
  %
  % Algorithm:
  %   Uses box folding and sphere folding operations.
  %   Distance estimation for ray marching.
  %
  % Example:
  %   dist = mandelbox_3d([0, 0, 0], 2.5, 16);
  %
  % Phase: 5 - 3D Fractals

  if nargin < 2 || isempty(scale)
    scale = 2.5;
  end
  if nargin < 3 || isempty(max_iter)
    max_iter = 16;
  end

  % Handle single point or multiple points
  if size(pos, 1) == 1 && size(pos, 2) == 3
    % Single point
    distance = mandelbox_single(pos, scale, max_iter);
  else
    % Multiple points
    n_points = size(pos, 1);
    distance = zeros(n_points, 1);
    for i = 1:n_points
      distance(i) = mandelbox_single(pos(i, :), scale, max_iter);
    end
  end

end


function dist = mandelbox_single(pos, scale, max_iter)
  % Distance estimation for single point

  fixed_radius = 1.0;
  min_radius = 0.5;

  x = pos(1);
  y = pos(2);
  z = pos(3);

  dr = 1.0;  % Derivative

  % Iterate
  for n = 1:max_iter
    % Box fold
    if x > 1.0
      x = 2.0 - x;
    elseif x < -1.0
      x = -2.0 - x;
    end

    if y > 1.0
      y = 2.0 - y;
    elseif y < -1.0
      y = -2.0 - y;
    end

    if z > 1.0
      z = 2.0 - z;
    elseif z < -1.0
      z = -2.0 - z;
    end

    % Sphere fold
    r2 = x*x + y*y + z*z;

    if r2 < min_radius^2
      factor = (fixed_radius / min_radius)^2;
      x = x * factor;
      y = y * factor;
      z = z * factor;
      dr = dr * factor;
    elseif r2 < fixed_radius^2
      factor = fixed_radius^2 / r2;
      x = x * factor;
      y = y * factor;
      z = z * factor;
      dr = dr * factor;
    end

    % Scale and translate
    x = scale * x + pos(1);
    y = scale * y + pos(2);
    z = scale * z + pos(3);
    dr = dr * abs(scale);

    % Check escape
    r = sqrt(x*x + y*y + z*z);
    if r > 4.0
      break;
    end
  end

  % Distance estimate
  r = sqrt(x*x + y*y + z*z);
  dist = r / abs(dr);

end
