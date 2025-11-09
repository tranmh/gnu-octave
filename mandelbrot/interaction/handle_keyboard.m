function state = handle_keyboard(state, key)
  % HANDLE_KEYBOARD Process keyboard input
  %
  % Usage:
  %   state = handle_keyboard(state, key)
  %
  % Inputs:
  %   state - Current application state struct
  %   key   - Key character or name
  %
  % Outputs:
  %   state - Updated state
  %
  % Keyboard Controls:
  %   1-5     - Switch color palettes
  %   M       - Mandelbrot set
  %   J       - Julia set
  %   +/=     - Increase iterations
  %   -       - Decrease iterations
  %   Arrows  - Pan view
  %   R       - Reset to default view
  %   H       - Show help
  %   Q       - Quit
  %
  % Phase: 3 - Interactive Explorer

  switch key
    % Palette selection (1-5)
    case '1'
      state.palette = 'deep_ocean';
      state.needs_render = true;
      fprintf('Palette: Deep Ocean 🌊\n');

    case '2'
      state.palette = 'sunset_fire';
      state.needs_render = true;
      fprintf('Palette: Sunset Fire 🔥\n');

    case '3'
      state.palette = 'electric_dream';
      state.needs_render = true;
      fprintf('Palette: Electric Dream ⚡\n');

    case '4'
      state.palette = 'monochrome';
      state.needs_render = true;
      fprintf('Palette: Monochrome Elegance 🎨\n');

    case '5'
      state.palette = 'northern_lights';
      state.needs_render = true;
      fprintf('Palette: Northern Lights 🌌\n');

    % Fractal type
    case {'m', 'M'}
      state.fractal_type = 'mandelbrot';
      state.center = -0.5 + 0i;
      state.width = 3.5;
      state.height = 2.5;
      state.needs_render = true;
      fprintf('Fractal: Mandelbrot Set\n');

    case {'j', 'J'}
      state.fractal_type = 'julia';
      state.center = 0 + 0i;
      state.width = 4.0;
      state.height = 3.0;
      state.needs_render = true;
      fprintf('Fractal: Julia Set (c = %.3f%+.3fi)\n', real(state.julia_c), imag(state.julia_c));

    case {'b', 'B'}
      state.fractal_type = 'burning_ship';
      state.center = -0.5 - 0.5i;
      state.width = 4.0;
      state.height = 3.0;
      state.needs_render = true;
      fprintf('Fractal: Burning Ship\n');

    case {'t', 'T'}
      state.fractal_type = 'tricorn';
      state.center = 0 + 0i;
      state.width = 4.0;
      state.height = 3.0;
      state.needs_render = true;
      fprintf('Fractal: Tricorn (Mandelbar)\n');

    case {'p', 'P'}
      state.fractal_type = 'multibrot';
      state.center = 0 + 0i;
      state.width = 4.0;
      state.height = 3.0;
      state.needs_render = true;
      fprintf('Fractal: Multibrot (power = %d)\n', state.multibrot_power);

    case {'x', 'X'}
      state.fractal_type = 'phoenix';
      state.center = 0 + 0i;
      state.width = 4.0;
      state.height = 3.0;
      state.needs_render = true;
      fprintf('Fractal: Phoenix (c = %.3f%+.3fi)\n', real(state.phoenix_c), imag(state.phoenix_c));

    case {'v', 'V'}
      state.fractal_type = 'mandelbulb';
      state.needs_render = true;
      fprintf('Fractal: 3D Mandelbulb (power = %d)\n', state.mandelbulb_power);

    case {'n', 'N'}
      state.fractal_type = 'mandelbox';
      state.needs_render = true;
      fprintf('Fractal: 3D Mandelbox (scale = %.2f)\n', state.mandelbox_scale);

    % Iterations
    case {'+', '=', 'add', 'equal'}
      state.max_iter = min(state.max_iter * 2, 4096);
      state.needs_render = true;
      fprintf('Iterations: %d\n', state.max_iter);

    case {'-', 'subtract', 'hyphen'}
      state.max_iter = max(floor(state.max_iter / 2), 64);
      state.needs_render = true;
      fprintf('Iterations: %d\n', state.max_iter);

    % Pan controls
    case {'uparrow', 'up'}
      state = handle_pan(state, 'up');

    case {'downarrow', 'down'}
      state = handle_pan(state, 'down');

    case {'leftarrow', 'left'}
      state = handle_pan(state, 'left');

    case {'rightarrow', 'right'}
      state = handle_pan(state, 'right');

    % Reset
    case {'r', 'R'}
      state = reset_view(state);
      fprintf('View reset to default\n');

    % Help
    case {'h', 'H'}
      show_help();

    % Quit
    case {'q', 'Q'}
      state.running = false;
      fprintf('Quitting...\n');

    % Save bookmark
    case {'s', 'S'}
      bookmark_name = input('Bookmark name: ', 's');
      if ~isempty(bookmark_name)
        bookmark_manager('save', state, bookmark_name);
      end

    % Load bookmark
    case {'l', 'L'}
      bookmarks = bookmark_manager('list');
      if ~isempty(bookmarks)
        bookmark_num = input('Enter bookmark number to load: ');
        if bookmark_num >= 1 && bookmark_num <= length(bookmarks)
          loaded_state = bookmark_manager('load', bookmarks{bookmark_num}.filename);
          % Update current state with loaded values
          fields = fieldnames(loaded_state);
          for i = 1:length(fields)
            state.(fields{i}) = loaded_state.(fields{i});
          end
          state.needs_render = true;
          fprintf('Bookmark loaded!\n');
        end
      end

    % Export image
    case {'e', 'E'}
      filename = input('Export filename (PNG): ', 's');
      if ~isempty(filename)
        res_choice = input('Resolution: (1) HD, (2) 4K [2]: ', 's');
        if isempty(res_choice) || strcmp(res_choice, '2')
          resolution = [3840, 2160];
        else
          resolution = [1920, 1080];
        end
        export_image(state, filename, resolution);
      end

    % Pattern gallery
    case {'g', 'G'}
      show_pattern_gallery(state);

    otherwise
      % Unknown key - ignore
  end

end


function state = reset_view(state)
  % Reset to default view for current fractal type
  switch state.fractal_type
    case 'mandelbrot'
      state.center = -0.5 + 0i;
      state.width = 3.5;
      state.height = 2.5;
    case 'burning_ship'
      state.center = -0.5 - 0.5i;
      state.width = 4.0;
      state.height = 3.0;
    otherwise
      state.center = 0 + 0i;
      state.width = 4.0;
      state.height = 3.0;
  end
  state.zoom_level = 1.0;
  state.max_iter = 256;
  state.needs_render = true;
end


function show_help()
  % Display help information
  fprintf('\n========================================\n');
  fprintf('  FRACTAL EXPLORER - KEYBOARD CONTROLS\n');
  fprintf('========================================\n');
  fprintf('Palettes:\n');
  fprintf('  1 - Deep Ocean 🌊\n');
  fprintf('  2 - Sunset Fire 🔥\n');
  fprintf('  3 - Electric Dream ⚡\n');
  fprintf('  4 - Monochrome Elegance 🎨\n');
  fprintf('  5 - Northern Lights 🌌\n\n');
  fprintf('Fractals (2D):\n');
  fprintf('  M - Mandelbrot Set\n');
  fprintf('  J - Julia Set\n');
  fprintf('  B - Burning Ship\n');
  fprintf('  T - Tricorn\n');
  fprintf('  P - Multibrot\n');
  fprintf('  X - Phoenix\n\n');
  fprintf('Fractals (3D):\n');
  fprintf('  V - Mandelbulb\n');
  fprintf('  N - Mandelbox\n\n');
  fprintf('Navigation:\n');
  fprintf('  Click - Zoom in 2x at point\n');
  fprintf('  Arrows - Pan view\n');
  fprintf('  + - Increase iterations\n');
  fprintf('  - - Decrease iterations\n');
  fprintf('  R - Reset to default view\n\n');
  fprintf('Advanced Features:\n');
  fprintf('  G - Pattern gallery (famous locations)\n');
  fprintf('  S - Save bookmark\n');
  fprintf('  L - Load bookmark\n');
  fprintf('  E - Export image (HD/4K)\n\n');
  fprintf('Other:\n');
  fprintf('  H - Show this help\n');
  fprintf('  Q - Quit\n');
  fprintf('========================================\n\n');
end


function show_pattern_gallery(state)
  % Display pattern gallery and select location

  patterns = pattern_library();

  fprintf('\n========================================\n');
  fprintf('  PATTERN GALLERY - FAMOUS LOCATIONS\n');
  fprintf('========================================\n\n');

  % Group by fractal type
  fractal_types = unique(cellfun(@(x) x.fractal_type, patterns, 'UniformOutput', false));

  pattern_num = 1;
  for ft = 1:length(fractal_types)
    ftype = fractal_types{ft};
    type_patterns = pattern_library(ftype);

    fprintf('%s:\n', upper(ftype));
    fprintf('-------------------\n');

    for i = 1:length(type_patterns)
      p = type_patterns{i};
      fprintf('  %d. %s\n', pattern_num, p.name);
      fprintf('     %s\n', p.description);
      pattern_num = pattern_num + 1;
    end
    fprintf('\n');
  end

  fprintf('Enter pattern number to load (0 to cancel): ');
  choice = input('');

  if choice > 0 && choice <= length(patterns)
    fprintf('\nLoading pattern: %s\n', patterns{choice}.name);
    fprintf('Press any key when ready to continue with explorer...\n');
  end

end
