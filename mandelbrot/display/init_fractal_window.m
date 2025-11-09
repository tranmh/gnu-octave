function fig_handle = init_fractal_window(width, height, title_text)
  % INIT_FRACTAL_WINDOW Initialize a figure window for fractal display
  %
  % Usage:
  %   fig_handle = init_fractal_window(width, height, title_text)
  %
  % Inputs:
  %   width      - Window width in pixels (default: 1000)
  %   height     - Window height in pixels (default: 750)
  %   title_text - Window title (default: 'Fractal Explorer')
  %
  % Outputs:
  %   fig_handle - Figure handle for updating
  %
  % Example:
  %   fig = init_fractal_window(800, 600, 'Mandelbrot Set');
  %   % ... render fractal ...
  %   % ... display in figure ...
  %
  % Phase: 2 - Visualization & Color Palettes

  if nargin < 1 || isempty(width)
    width = 1000;
  end
  if nargin < 2 || isempty(height)
    height = 750;
  end
  if nargin < 3 || isempty(title_text)
    title_text = 'Fractal Explorer';
  end

  % Create figure
  fig_handle = figure('Name', title_text, ...
                      'NumberTitle', 'off', ...
                      'Position', [100, 100, width, height], ...
                      'Color', [0.1, 0.1, 0.1], ...
                      'MenuBar', 'none', ...
                      'ToolBar', 'none');

  % Set up axes for image display
  axes('Position', [0, 0, 1, 1], ...
       'XTick', [], ...
       'YTick', [], ...
       'Box', 'off');

  % Optimize for image display
  axis equal tight;

end
