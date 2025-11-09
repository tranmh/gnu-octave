function [image, hit_map] = render_3d(fractal_type, params, nx, ny)
  % RENDER_3D Ray march 3D fractal to create 2D image
  %
  % Usage:
  %   [image, hit_map] = render_3d(fractal_type, params, nx, ny)
  %
  % Inputs:
  %   fractal_type - 'mandelbulb' or 'mandelbox'
  %   params       - Structure with:
  %                  .power (for Mandelbulb, default 8)
  %                  .scale (for Mandelbox, default 2.5)
  %                  .max_iter (default 16)
  %                  .camera_pos (default [0, 0, -3])
  %                  .camera_target (default [0, 0, 0])
  %                  .max_steps (default 100)
  %   nx           - Horizontal resolution (default 400)
  %   ny           - Vertical resolution (default 300)
  %
  % Outputs:
  %   image   - Grayscale image (shaded)
  %   hit_map - Boolean map of hits
  %
  % Example:
  %   params.power = 8;
  %   [img, hits] = render_3d('mandelbulb', params, 400, 300);
  %   imshow(img);
  %
  % Phase: 5 - 3D Fractals

  % Default parameters
  if nargin < 3 || isempty(nx)
    nx = 400;
  end
  if nargin < 4 || isempty(ny)
    ny = 300;
  end

  % Extract or set default parameters
  if ~isfield(params, 'max_iter')
    params.max_iter = 16;
  end
  if ~isfield(params, 'camera_pos')
    params.camera_pos = [0, 0, -3];
  end
  if ~isfield(params, 'camera_target')
    params.camera_target = [0, 0, 0];
  end
  if ~isfield(params, 'max_steps')
    params.max_steps = 100;
  end
  if ~isfield(params, 'power')
    params.power = 8;
  end
  if ~isfield(params, 'scale')
    params.scale = 2.5;
  end

  % Initialize output
  image = zeros(ny, nx);
  hit_map = false(ny, nx);

  % Camera setup
  camera_pos = params.camera_pos;
  camera_target = params.camera_target;

  % Camera direction
  forward = camera_target - camera_pos;
  forward = forward / norm(forward);

  % Up vector
  up = [0, 1, 0];

  % Right vector
  right = cross(forward, up);
  right = right / norm(right);

  % Recompute up
  up = cross(right, forward);

  % Field of view
  fov = 0.8;

  fprintf('  Ray marching %dx%d image...\n', nx, ny);

  % Ray march each pixel
  for j = 1:ny
    if mod(j, 50) == 0
      fprintf('    Row %d/%d...\n', j, ny);
    end

    for i = 1:nx
      % Screen coordinates [-1, 1]
      screen_x = (2.0 * i / nx - 1.0) * fov * nx / ny;
      screen_y = -(2.0 * j / ny - 1.0) * fov;

      % Ray direction
      ray_dir = forward + screen_x * right + screen_y * up;
      ray_dir = ray_dir / norm(ray_dir);

      % Ray march
      [hit, pos] = ray_march(camera_pos, ray_dir, fractal_type, params);

      if hit
        hit_map(j, i) = true;

        % Calculate lighting
        normal = calculate_normal(pos, fractal_type, params);
        light_dir = [0.5, 0.7, -1.0];
        light_dir = light_dir / norm(light_dir);

        % Diffuse lighting
        diffuse = max(0, dot(normal, light_dir));

        % Ambient
        ambient = 0.3;

        % Final intensity
        intensity = ambient + 0.7 * diffuse;
        image(j, i) = min(1.0, intensity);
      else
        image(j, i) = 0;
      end
    end
  end

  fprintf('  Ray marching complete.\n');

end


function [hit, pos] = ray_march(ray_origin, ray_dir, fractal_type, params)
  % Ray march to find surface intersection

  t = 0.0;
  max_dist = 10.0;
  min_dist = 0.001;

  for step = 1:params.max_steps
    pos = ray_origin + t * ray_dir;

    % Calculate distance to fractal
    if strcmp(fractal_type, 'mandelbulb')
      dist = mandelbulb_3d(pos, params.power, params.max_iter);
    else
      dist = mandelbox_3d(pos, params.scale, params.max_iter);
    end

    % Hit surface
    if dist < min_dist
      hit = true;
      return;
    end

    % Escaped bounds
    if t > max_dist
      hit = false;
      pos = ray_origin;
      return;
    end

    % March forward
    t = t + dist * 0.5;
  end

  hit = false;
  pos = ray_origin;

end


function normal = calculate_normal(pos, fractal_type, params)
  % Estimate surface normal using gradient

  epsilon = 0.001;

  if strcmp(fractal_type, 'mandelbulb')
    d0 = mandelbulb_3d(pos, params.power, params.max_iter);
    dx = mandelbulb_3d(pos + [epsilon, 0, 0], params.power, params.max_iter);
    dy = mandelbulb_3d(pos + [0, epsilon, 0], params.power, params.max_iter);
    dz = mandelbulb_3d(pos + [0, 0, epsilon], params.power, params.max_iter);
  else
    d0 = mandelbox_3d(pos, params.scale, params.max_iter);
    dx = mandelbox_3d(pos + [epsilon, 0, 0], params.scale, params.max_iter);
    dy = mandelbox_3d(pos + [0, epsilon, 0], params.scale, params.max_iter);
    dz = mandelbox_3d(pos + [0, 0, epsilon], params.scale, params.max_iter);
  end

  normal = [(dx - d0), (dy - d0), (dz - d0)];
  normal = normal / norm(normal);

end
