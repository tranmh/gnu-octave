function success = export_image(state, filename, resolution)
  % EXPORT_IMAGE Render and export high-resolution fractal image
  %
  % Usage:
  %   export_image(state, filename)                % Default resolution
  %   export_image(state, filename, [1920, 1080])  % HD resolution
  %   export_image(state, filename, [3840, 2160])  % 4K resolution
  %
  % Inputs:
  %   state      - Fractal state structure
  %   filename   - Output filename (PNG format)
  %   resolution - [width, height] in pixels (default: [3840, 2160] = 4K)
  %
  % Outputs:
  %   success - true if export successful
  %
  % Examples:
  %   % Export 4K image
  %   export_image(state, 'mandelbrot_4k.png');
  %
  %   % Export HD image
  %   export_image(state, 'mandelbrot_hd.png', [1920, 1080]);
  %
  % Phase: 6 - Advanced Features

  % Default to 4K resolution
  if nargin < 3 || isempty(resolution)
    resolution = [3840, 2160];
  end

  % Add .png extension if not provided
  if ~endsWith(filename, '.png')
    filename = [filename, '.png'];
  end

  % Extract resolution
  nx = resolution(1);
  ny = resolution(2);

  fprintf('========================================\n');
  fprintf('  EXPORTING HIGH-RESOLUTION IMAGE\n');
  fprintf('========================================\n');
  fprintf('Resolution: %dx%d\n', nx, ny);
  fprintf('Fractal: %s\n', state.fractal_type);
  fprintf('Center: %.6f%+.6fi\n', real(state.center), imag(state.center));
  fprintf('Zoom: %.2e\n', state.zoom_level);
  fprintf('Max iterations: %d\n', state.max_iter);
  fprintf('Palette: %s\n\n', state.palette);

  % Check if 3D fractal
  is_3d = strcmp(state.fractal_type, 'mandelbulb') || ...
          strcmp(state.fractal_type, 'mandelbox');

  fprintf('Rendering...\n');
  tic;

  if is_3d
    % 3D fractal rendering
    params = struct();
    params.power = state.mandelbulb_power;
    params.scale = state.mandelbox_scale;
    params.max_iter = 16;
    params.max_steps = 150;  % More steps for better quality
    params.camera_pos = [0, 0, -3];
    params.camera_target = [0, 0, 0];

    [gray_image, ~] = render_3d(state.fractal_type, params, nx, ny);

    % Convert grayscale to RGB
    rgb_image = repmat(gray_image, [1, 1, 3]);

  else
    % 2D fractal rendering
    switch state.fractal_type
      case 'mandelbrot'
        [iter, final_z] = mandelbrot_2d(state.center, state.width, state.height, ...
                                        nx, ny, state.max_iter, state.escape_radius);

      case 'julia'
        [iter, final_z] = julia_2d(state.julia_c, state.center, state.width, state.height, ...
                                   nx, ny, state.max_iter, state.escape_radius);

      case 'burning_ship'
        [iter, final_z] = burning_ship(state.center, state.width, state.height, ...
                                       nx, ny, state.max_iter, state.escape_radius);

      case 'tricorn'
        [iter, final_z] = tricorn(state.center, state.width, state.height, ...
                                  nx, ny, state.max_iter, state.escape_radius);

      case 'multibrot'
        [iter, final_z] = multibrot(state.multibrot_power, state.center, state.width, state.height, ...
                                    nx, ny, state.max_iter, state.escape_radius);

      case 'phoenix'
        [iter, final_z] = phoenix(state.phoenix_c, state.phoenix_p, state.center, state.width, state.height, ...
                                  nx, ny, state.max_iter, state.escape_radius);

      otherwise
        error('Unknown fractal type: %s', state.fractal_type);
    end

    % Apply smooth coloring
    smooth = smooth_coloring(iter, final_z, state.escape_radius);
    rgb_image = apply_colormap(smooth, state.palette);
  end

  render_time = toc;
  fprintf('Rendering complete: %.2f seconds\n\n', render_time);

  % Save image
  fprintf('Saving image to: %s\n', filename);

  try
    % Ensure output directory exists
    [dir_path, ~, ~] = fileparts(filename);
    if ~isempty(dir_path) && ~exist(dir_path, 'dir')
      mkdir(dir_path);
    end

    % Write image with maximum quality
    imwrite(rgb_image, filename, 'png');

    % Get file size
    file_info = dir(filename);
    file_size_mb = file_info.bytes / (1024 * 1024);

    fprintf('Export successful!\n');
    fprintf('File size: %.2f MB\n', file_size_mb);
    fprintf('========================================\n\n');

    success = true;

  catch err
    fprintf('Error saving image: %s\n', err.message);
    fprintf('========================================\n\n');
    success = false;
  end

end
