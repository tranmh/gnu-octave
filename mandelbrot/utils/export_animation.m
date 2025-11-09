function success = export_animation(start_state, end_state, num_frames, output_dir, resolution)
  % EXPORT_ANIMATION Generate deep zoom animation frames
  %
  % Usage:
  %   export_animation(start_state, end_state, num_frames, output_dir)
  %   export_animation(start_state, end_state, num_frames, output_dir, [800, 600])
  %
  % Inputs:
  %   start_state - Initial fractal state
  %   end_state   - Final fractal state
  %   num_frames  - Number of frames to generate
  %   output_dir  - Directory for frame images
  %   resolution  - [width, height] (default: [800, 600])
  %
  % Outputs:
  %   success - true if animation export successful
  %
  % Example:
  %   % Create zoom animation from full view to detail
  %   start_state.center = -0.5 + 0i;
  %   start_state.width = 3.5;
  %   end_state.center = -0.745 + 0.113i;
  %   end_state.width = 0.01;
  %   export_animation(start_state, end_state, 100, 'zoom_frames');
  %
  % Phase: 6 - Advanced Features

  % Default resolution
  if nargin < 5 || isempty(resolution)
    resolution = [800, 600];
  end

  % Create output directory
  if ~exist(output_dir, 'dir')
    mkdir(output_dir);
  end

  fprintf('========================================\n');
  fprintf('  GENERATING ZOOM ANIMATION\n');
  fprintf('========================================\n');
  fprintf('Frames: %d\n', num_frames);
  fprintf('Resolution: %dx%d\n', resolution(1), resolution(2));
  fprintf('Output: %s\n', output_dir);
  fprintf('Fractal: %s\n', start_state.fractal_type);
  fprintf('\nStart:\n');
  fprintf('  Center: %.6f%+.6fi\n', real(start_state.center), imag(start_state.center));
  fprintf('  Width: %.6f\n', start_state.width);
  fprintf('\nEnd:\n');
  fprintf('  Center: %.6f%+.6fi\n', real(end_state.center), imag(end_state.center));
  fprintf('  Width: %.6f\n', end_state.width);
  fprintf('\nZoom factor: %.2ex\n\n', start_state.width / end_state.width);

  % Extract resolution
  nx = resolution(1);
  ny = resolution(2);

  % Check if 3D fractal
  is_3d = strcmp(start_state.fractal_type, 'mandelbulb') || ...
          strcmp(start_state.fractal_type, 'mandelbox');

  % Interpolation parameters
  start_center = start_state.center;
  end_center = end_state.center;
  start_width = start_state.width;
  end_width = end_state.width;
  start_height = start_state.height;
  end_height = end_state.height;

  % Logarithmic interpolation for zoom (smoother)
  log_start_width = log(start_width);
  log_end_width = log(end_width);

  % Start timing
  total_tic = tic;
  estimated_time = 0;

  % Generate frames
  for frame = 1:num_frames
    frame_tic = tic;

    % Interpolation parameter (0 to 1)
    t = (frame - 1) / (num_frames - 1);

    % Smooth interpolation (ease in/out)
    t_smooth = 0.5 - 0.5 * cos(t * pi);

    % Interpolate center (linear)
    current_center = start_center + t_smooth * (end_center - start_center);

    % Interpolate width (logarithmic for smooth zoom)
    log_current_width = log_start_width + t_smooth * (log_end_width - log_start_width);
    current_width = exp(log_current_width);

    % Interpolate height
    log_start_height = log(start_height);
    log_end_height = log(end_height);
    log_current_height = log_start_height + t_smooth * (log_end_height - log_start_height);
    current_height = exp(log_current_height);

    % Interpolate max_iter (more iterations for deeper zoom)
    current_max_iter = round(start_state.max_iter + ...
                             t_smooth * (end_state.max_iter - start_state.max_iter));
    current_max_iter = max(64, current_max_iter);

    % Create current state
    current_state = start_state;
    current_state.center = current_center;
    current_state.width = current_width;
    current_state.height = current_height;
    current_state.max_iter = current_max_iter;
    current_state.zoom_level = start_state.zoom_level * (start_width / current_width);

    % Render frame
    if is_3d
      % 3D rendering
      params = struct();
      params.power = current_state.mandelbulb_power;
      params.scale = current_state.mandelbox_scale;
      params.max_iter = 16;
      params.max_steps = 80;
      params.camera_pos = [0, 0, -3];
      params.camera_target = [0, 0, 0];

      [gray_image, ~] = render_3d(current_state.fractal_type, params, nx, ny);
      rgb_image = repmat(gray_image, [1, 1, 3]);

    else
      % 2D rendering
      switch current_state.fractal_type
        case 'mandelbrot'
          [iter, final_z] = mandelbrot_2d(current_center, current_width, current_height, ...
                                          nx, ny, current_max_iter, current_state.escape_radius);

        case 'julia'
          [iter, final_z] = julia_2d(current_state.julia_c, current_center, current_width, current_height, ...
                                     nx, ny, current_max_iter, current_state.escape_radius);

        case 'burning_ship'
          [iter, final_z] = burning_ship(current_center, current_width, current_height, ...
                                         nx, ny, current_max_iter, current_state.escape_radius);

        case 'tricorn'
          [iter, final_z] = tricorn(current_center, current_width, current_height, ...
                                    nx, ny, current_max_iter, current_state.escape_radius);

        case 'multibrot'
          [iter, final_z] = multibrot(current_state.multibrot_power, current_center, current_width, current_height, ...
                                      nx, ny, current_max_iter, current_state.escape_radius);

        case 'phoenix'
          [iter, final_z] = phoenix(current_state.phoenix_c, current_state.phoenix_p, current_center, current_width, current_height, ...
                                    nx, ny, current_max_iter, current_state.escape_radius);

        otherwise
          error('Unknown fractal type: %s', current_state.fractal_type);
      end

      % Apply smooth coloring
      smooth = smooth_coloring(iter, final_z, current_state.escape_radius);
      rgb_image = apply_colormap(smooth, current_state.palette);
    end

    % Save frame
    frame_filename = fullfile(output_dir, sprintf('frame_%04d.png', frame));
    imwrite(rgb_image, frame_filename, 'png');

    % Timing and progress
    frame_time = toc(frame_tic);
    if frame == 1
      estimated_time = frame_time * num_frames;
    end

    elapsed = toc(total_tic);
    remaining = estimated_time - elapsed;

    fprintf('Frame %d/%d (%.1f%%) - %.2fs - Remaining: %.1fs\n', ...
            frame, num_frames, 100*frame/num_frames, frame_time, remaining);
  end

  total_time = toc(total_tic);

  fprintf('\n========================================\n');
  fprintf('Animation export complete!\n');
  fprintf('Total time: %.2f seconds (%.2f sec/frame)\n', total_time, total_time/num_frames);
  fprintf('Frames saved to: %s\n', output_dir);
  fprintf('\nTo create video (using ffmpeg):\n');
  fprintf('  ffmpeg -framerate 30 -i %s/frame_%%04d.png output.mp4\n', output_dir);
  fprintf('========================================\n\n');

  success = true;

end
