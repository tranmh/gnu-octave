function update_display(rgb_image, fractal_info)
  % UPDATE_DISPLAY Efficiently update fractal display
  %
  % Usage:
  %   update_display(rgb_image, fractal_info)
  %
  % Inputs:
  %   rgb_image    - RGB image matrix from apply_colormap()
  %   fractal_info - Struct with display information:
  %                  .type: 'mandelbrot', 'julia', etc.
  %                  .center: Complex center point
  %                  .width: View width
  %                  .height: View height
  %                  .iterations: Max iterations used
  %                  .palette: Palette name
  %
  % Example:
  %   info.type = 'mandelbrot';
  %   info.center = -0.5 + 0i;
  %   info.width = 3.5;
  %   info.palette = 'sunset_fire';
  %   info.iterations = 256;
  %   update_display(rgb_image, info);
  %
  % Phase: 2 - Visualization & Color Palettes

  % Display the RGB image
  image(rgb_image);
  axis equal tight off;

  % Add title with fractal information
  if nargin >= 2 && isstruct(fractal_info)
    title_str = sprintf('%s | Center: %.4f%+.4fi | Zoom: %.2e | Iter: %d | Palette: %s', ...
                       upper(fractal_info.type), ...
                       real(fractal_info.center), imag(fractal_info.center), ...
                       1.0 / fractal_info.width, ...
                       fractal_info.iterations, ...
                       fractal_info.palette);

    title(title_str, 'Color', 'white', 'FontSize', 10, 'Interpreter', 'none');
  end

  % Force refresh
  drawnow;

end
