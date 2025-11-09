function colormap_gallery()
  % COLORMAP_GALLERY Display all 5 color palettes side-by-side
  %
  % Usage:
  %   colormap_gallery()
  %
  % Shows all available palettes:
  %   1. Deep Ocean
  %   2. Sunset Fire
  %   3. Electric Dream
  %   4. Monochrome Elegance
  %   5. Northern Lights
  %
  % Example:
  %   colormap_gallery();
  %
  % Phase: 2 - Visualization & Color Palettes

  % Palette names
  palettes = {'deep_ocean', 'sunset_fire', 'electric_dream', 'monochrome', 'northern_lights'};
  titles = {'Deep Ocean 🌊', 'Sunset Fire 🔥', 'Electric Dream ⚡', ...
            'Monochrome Elegance 🎨', 'Northern Lights 🌌'};

  % Create figure
  figure('Name', 'Fractal Color Palette Gallery', ...
         'Position', [50, 50, 1400, 300], ...
         'Color', [0.1, 0.1, 0.1]);

  % Generate test Mandelbrot set (same for all palettes)
  fprintf('Generating Mandelbrot set for palette comparison...\n');
  [iter, final_z] = mandelbrot_2d(-0.5+0i, 3.5, 2.5, 400, 300, 256);
  smooth = smooth_coloring(iter, final_z, 2.0);

  % Display each palette
  for i = 1:length(palettes)
    subplot(1, 5, i);

    % Apply colormap
    rgb_image = apply_colormap(smooth, palettes{i});

    % Display
    image(rgb_image);
    axis equal tight off;

    % Title
    title(titles{i}, 'Color', 'white', 'FontSize', 11, 'Interpreter', 'none');
  end

  fprintf('Gallery complete! Compare the 5 palettes.\n');

end
