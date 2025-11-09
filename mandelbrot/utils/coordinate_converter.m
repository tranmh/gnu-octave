function complex_pos = coordinate_converter(pixel_pos, center, width, height, fig_width, fig_height)
  % COORDINATE_CONVERTER Convert screen pixel to complex plane coordinate
  %
  % Usage:
  %   complex_pos = coordinate_converter(pixel_pos, center, width, height, fig_width, fig_height)
  %
  % Inputs:
  %   pixel_pos  - [x, y] pixel coordinates
  %   center     - Complex center of view
  %   width      - View width in complex plane
  %   height     - View height in complex plane
  %   fig_width  - Figure width in pixels
  %   fig_height - Figure height in pixels
  %
  % Outputs:
  %   complex_pos - Corresponding complex number
  %
  % Example:
  %   c = coordinate_converter([400, 300], -0.5+0i, 3.5, 2.5, 800, 600);
  %
  % Phase: 3 - Interactive Explorer

  % Normalize pixel coordinates to [0, 1]
  norm_x = pixel_pos(1) / fig_width;
  norm_y = pixel_pos(2) / fig_height;

  % Convert to complex plane (Y axis inverted)
  cx = real(center);
  cy = imag(center);

  real_part = cx + (norm_x - 0.5) * width;
  imag_part = cy - (norm_y - 0.5) * height;

  complex_pos = real_part + 1i * imag_part;

end
