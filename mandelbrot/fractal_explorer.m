function fractal_explorer(resolution)
  % FRACTAL_EXPLORER Interactive fractal exploration application
  %
  % Usage:
  %   fractal_explorer()           % Default 800x600
  %   fractal_explorer([1920 1080]) % Custom resolution [width height]
  %
  % Controls:
  %   Click - Zoom in 2x at point
  %   1-5 - Switch color palettes
  %   M - Mandelbrot set
  %   J - Julia set
  %   +/- - Adjust iterations
  %   Arrows - Pan view
  %   R - Reset view
  %   H - Help
  %   Q - Quit
  %
  % Example:
  %   fractal_explorer();           % Start default explorer
  %   fractal_explorer([1280 720]); % HD resolution
  %
  % Phase: 3 - Interactive Explorer

  % Add paths
  addpath('core', 'display', 'interaction', 'utils');

  % Default resolution
  if nargin < 1 || isempty(resolution)
    resolution = [800, 600];
  end

  % Initialize state
  state = struct();
  state.resolution = resolution;
  state.fractal_type = 'mandelbrot';
  state.center = -0.5 + 0i;
  state.width = 3.5;
  state.height = 2.5;
  state.max_iter = 256;
  state.escape_radius = 2.0;
  state.palette = 'deep_ocean';
  state.julia_c = -0.7 + 0.27i;  % Classic Julia parameter
  state.multibrot_power = 3;      % Power for Multibrot
  state.phoenix_c = 0.5 - 0.1i;   % Phoenix parameter c
  state.phoenix_p = -0.5 + 0i;    % Phoenix parameter p
  state.mandelbulb_power = 8;     % Mandelbulb power
  state.mandelbox_scale = 2.5;    % Mandelbox scale
  state.zoom_level = 1.0;
  state.running = true;
  state.needs_render = true;

  % Create figure window
  fprintf('========================================\n');
  fprintf('  FRACTAL EXPLORER\n');
  fprintf('========================================\n');
  fprintf('Resolution: %dx%d\n', resolution(1), resolution(2));
  fprintf('Press H for help\n\n');

  fig = figure('Name', 'Fractal Explorer', ...
               'NumberTitle', 'off', ...
               'Position', [100, 100, resolution(1), resolution(2)], ...
               'Color', [0.1, 0.1, 0.1], ...
               'MenuBar', 'none', ...
               'ToolBar', 'none', ...
               'KeyPressFcn', @(src, evt) key_callback(evt), ...
               'WindowButtonDownFcn', @(src, evt) mouse_callback(evt), ...
               'CloseRequestFcn', @(src, evt) close_callback());

  % Create axes
  ax = axes('Position', [0, 0, 1, 1], ...
            'XTick', [], 'YTick', [], ...
            'Box', 'off');
  axis equal tight off;

  % Store state in figure
  setappdata(fig, 'state', state);
  setappdata(fig, 'ax', ax);

  % Initial render
  render_fractal(fig);

  % Show initial help
  fprintf('Fractal Explorer ready!\n');
  fprintf('Click to zoom, press H for help, Q to quit\n\n');

  % Main event loop - just wait for callbacks
  % Octave handles events automatically
  waitfor(fig);

  fprintf('Fractal Explorer closed.\n');


  %% Callback Functions

  function key_callback(evt)
    % Keyboard event handler
    if ~ishandle(fig)
      return;
    end

    state = getappdata(fig, 'state');
    if isempty(state) || ~state.running
      return;
    end

    % Handle key press
    key = evt.Key;
    if isempty(key)
      key = evt.Character;
    end

    state = handle_keyboard(state, key);

    % Update state
    setappdata(fig, 'state', state);

    % Render if needed
    if state.needs_render
      render_fractal(fig);
    end

    % Check if should quit
    if ~state.running
      close(fig);
    end
  end


  function mouse_callback(evt)
    % Mouse click event handler
    if ~ishandle(fig)
      return;
    end

    state = getappdata(fig, 'state');
    if isempty(state) || ~state.running
      return;
    end

    % Get click position
    click_pos = get(gca, 'CurrentPoint');
    pixel_x = click_pos(1, 1);
    pixel_y = click_pos(1, 2);

    % Check if click is within axes bounds
    xlims = xlim(gca);
    ylims = ylim(gca);

    if pixel_x < xlims(1) || pixel_x > xlims(2) || ...
       pixel_y < ylims(1) || pixel_y > ylims(2)
      return;  % Click outside image
    end

    % Convert to pixel coordinates [0, width] [0, height]
    pixel_pos = [pixel_x, pixel_y];

    % Determine zoom factor
    button = get(fig, 'SelectionType');
    switch button
      case 'normal'  % Left click
        zoom_factor = 2.0;
        fprintf('Zooming in 2x...\n');
      case 'alt'     % Right click
        zoom_factor = 0.5;
        fprintf('Zooming out 2x...\n');
      otherwise
        return;
    end

    % Handle zoom
    state = handle_zoom(state, pixel_pos, zoom_factor);

    % Update state
    setappdata(fig, 'state', state);

    % Render
    render_fractal(fig);
  end


  function close_callback()
    % Window close handler
    if ishandle(fig)
      delete(fig);
    end
  end

end


function render_fractal(fig)
  % Render the current fractal state
  state = getappdata(fig, 'state');
  ax = getappdata(fig, 'ax');

  if isempty(state)
    return;
  end

  fprintf('Rendering %s (center: %.4f%+.4fi, zoom: %.2e, iter: %d)...\n', ...
          state.fractal_type, real(state.center), imag(state.center), ...
          state.zoom_level, state.max_iter);

  tic;

  % Compute fractal
  is_3d = strcmp(state.fractal_type, 'mandelbulb') || strcmp(state.fractal_type, 'mandelbox');

  if is_3d
    % 3D fractal rendering
    params.power = state.mandelbulb_power;
    params.scale = state.mandelbox_scale;
    params.max_iter = 16;  % 3D uses fewer iterations
    params.max_steps = 100;
    params.camera_pos = [0, 0, -3];
    params.camera_target = [0, 0, 0];

    [gray_image, hit_map] = render_3d(state.fractal_type, params, ...
                                      state.resolution(1), state.resolution(2));

    time_compute = toc;
    time_color = 0;

    % Convert grayscale to RGB
    rgb_image = repmat(gray_image, [1, 1, 3]);
  else
    % 2D fractal rendering
    switch state.fractal_type
      case 'mandelbrot'
        [iter, final_z] = mandelbrot_2d(state.center, state.width, state.height, ...
                                        state.resolution(1), state.resolution(2), ...
                                        state.max_iter, state.escape_radius);
      case 'julia'
        [iter, final_z] = julia_2d(state.julia_c, state.center, state.width, state.height, ...
                                   state.resolution(1), state.resolution(2), ...
                                   state.max_iter, state.escape_radius);
      case 'burning_ship'
        [iter, final_z] = burning_ship(state.center, state.width, state.height, ...
                                       state.resolution(1), state.resolution(2), ...
                                       state.max_iter, state.escape_radius);
      case 'tricorn'
        [iter, final_z] = tricorn(state.center, state.width, state.height, ...
                                  state.resolution(1), state.resolution(2), ...
                                  state.max_iter, state.escape_radius);
      case 'multibrot'
        [iter, final_z] = multibrot(state.multibrot_power, state.center, state.width, state.height, ...
                                    state.resolution(1), state.resolution(2), ...
                                    state.max_iter, state.escape_radius);
      case 'phoenix'
        [iter, final_z] = phoenix(state.phoenix_c, state.phoenix_p, state.center, state.width, state.height, ...
                                  state.resolution(1), state.resolution(2), ...
                                  state.max_iter, state.escape_radius);
      otherwise
        error('Unknown fractal type: %s', state.fractal_type);
    end

    time_compute = toc;

    % Apply smooth coloring
    tic;
    smooth = smooth_coloring(iter, final_z, state.escape_radius);
    rgb_image = apply_colormap(smooth, state.palette);
    time_color = toc;
  end

  % Display
  axes(ax);
  image(rgb_image);
  axis equal tight off;

  % Title with information
  title_str = sprintf('%s | Center: %.6f%+.6fi | Zoom: %.2e | Iter: %d | Palette: %s', ...
                     upper(state.fractal_type), ...
                     real(state.center), imag(state.center), ...
                     state.zoom_level, ...
                     state.max_iter, ...
                     state.palette);
  title(title_str, 'Color', 'white', 'FontSize', 9, 'Interpreter', 'none');

  drawnow;

  fprintf('  Render complete: %.2fs (compute: %.2fs, color: %.2fs)\n\n', ...
          time_compute + time_color, time_compute, time_color);

  % Mark render complete
  state.needs_render = false;
  setappdata(fig, 'state', state);
end
