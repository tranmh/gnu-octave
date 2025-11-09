function rgb_image = apply_colormap(smooth_values, palette_name, interior_color)
  % APPLY_COLORMAP Convert smooth iteration values to RGB image
  %
  % Usage:
  %   rgb_image = apply_colormap(smooth_values, palette_name, interior_color)
  %
  % Inputs:
  %   smooth_values  - Smooth iteration counts from smooth_coloring()
  %   palette_name   - Name of color palette (default: 'deep_ocean')
  %   interior_color - RGB color for interior points [R G B] (default: [0 0 0])
  %
  % Outputs:
  %   rgb_image - Height × Width × 3 RGB image matrix [0,1]
  %
  % Example:
  %   [iter, final_z] = mandelbrot_2d(-0.5+0i, 3.5, 2.5, 800, 600);
  %   smooth = smooth_coloring(iter, final_z, 2.0);
  %   rgb_image = apply_colormap(smooth, 'sunset_fire');
  %   imshow(rgb_image);
  %
  % Phase: 2 - Visualization & Color Palettes

  if nargin < 2 || isempty(palette_name)
    palette_name = 'deep_ocean';
  end
  if nargin < 3 || isempty(interior_color)
    interior_color = [0, 0, 0];  % Black for interior
  end

  % Get dimensions
  [height, width] = size(smooth_values);

  % Create palette
  num_colors = 256;
  palette = create_palette(palette_name, num_colors);

  % Find interior points (smooth_values == 0)
  interior = smooth_values == 0;

  % Normalize smooth values to palette range
  max_val = max(smooth_values(:));
  if max_val > 0
    % Map to [1, num_colors] range
    normalized = smooth_values / max_val * (num_colors - 1) + 1;
  else
    normalized = ones(size(smooth_values));
  end

  % Ensure valid indices
  normalized = max(1, min(num_colors, normalized));

  % Initialize RGB image
  rgb_image = zeros(height, width, 3);

  % Map pixels to palette colors (vectorized)
  indices = round(normalized);

  % Get RGB values for all pixels at once (reshape to maintain dimensions)
  indices_linear = indices(:);
  r_values = palette(indices_linear, 1);
  g_values = palette(indices_linear, 2);
  b_values = palette(indices_linear, 3);

  % Reshape back to 2D and assign
  rgb_image(:, :, 1) = reshape(r_values, height, width);
  rgb_image(:, :, 2) = reshape(g_values, height, width);
  rgb_image(:, :, 3) = reshape(b_values, height, width);

  % Set interior points to interior color
  if any(interior(:))
    interior_3d = repmat(interior, [1, 1, 3]);
    rgb_image(interior_3d & rgb_image(:,:,1:3) >= 0) = repmat(interior_color(:)', [sum(interior(:)), 1]);
  end

end
