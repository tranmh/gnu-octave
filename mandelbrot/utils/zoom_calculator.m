function [new_center, new_width, new_height] = zoom_calculator(click_pos, current_center, current_width, current_height, zoom_factor, fig_width, fig_height)
  % ZOOM_CALCULATOR Calculate new view parameters after zoom operation
  %
  % Usage:
  %   [new_center, new_width, new_height] = zoom_calculator(click_pos, current_center, current_width, current_height, zoom_factor, fig_width, fig_height)
  %
  % Inputs:
  %   click_pos       - [x, y] pixel coordinates of click (from figure)
  %   current_center  - Current complex center point
  %   current_width   - Current view width
  %   current_height  - Current view height
  %   zoom_factor     - Zoom multiplier (>1 zoom in, <1 zoom out)
  %   fig_width       - Figure width in pixels
  %   fig_height      - Figure height in pixels
  %
  % Outputs:
  %   new_center - New complex center point
  %   new_width  - New view width
  %   new_height - New view height
  %
  % Example:
  %   % Zoom in 2x at pixel (400, 300)
  %   [center, w, h] = zoom_calculator([400, 300], -0.5+0i, 3.5, 2.5, 2.0, 800, 600);
  %
  % Phase: 3 - Interactive Explorer

  % Convert pixel coordinates to complex plane coordinates
  % Pixel (0,0) is top-left, complex plane has y-axis inverted
  pixel_x = click_pos(1);
  pixel_y = click_pos(2);

  % Normalize to [0, 1]
  norm_x = pixel_x / fig_width;
  norm_y = pixel_y / fig_height;

  % Convert to complex plane coordinates
  cx = real(current_center);
  cy = imag(current_center);

  % Calculate click position in complex plane
  click_real = cx + (norm_x - 0.5) * current_width;
  click_imag = cy - (norm_y - 0.5) * current_height;  % Y inverted
  click_complex = click_real + 1i * click_imag;

  % Calculate new dimensions
  new_width = current_width / zoom_factor;
  new_height = current_height / zoom_factor;

  % New center is the click point
  new_center = click_complex;

end
