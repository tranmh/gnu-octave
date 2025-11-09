function state = handle_zoom(state, click_pos, zoom_factor)
  % HANDLE_ZOOM Process zoom operation at clicked position
  %
  % Usage:
  %   state = handle_zoom(state, click_pos, zoom_factor)
  %
  % Inputs:
  %   state       - Current application state struct
  %   click_pos   - [x, y] pixel coordinates of click
  %   zoom_factor - Zoom multiplier (2.0 = zoom in, 0.5 = zoom out)
  %
  % Outputs:
  %   state - Updated state with new view parameters
  %
  % Example:
  %   state = handle_zoom(state, [400, 300], 2.0);  % Zoom in at point
  %
  % Phase: 3 - Interactive Explorer

  % Calculate new view parameters
  [new_center, new_width, new_height] = zoom_calculator(...
    click_pos, ...
    state.center, ...
    state.width, ...
    state.height, ...
    zoom_factor, ...
    state.resolution(1), ...
    state.resolution(2));

  % Update state
  state.center = new_center;
  state.width = new_width;
  state.height = new_height;
  state.needs_render = true;

  % Update zoom level for display
  state.zoom_level = state.zoom_level * zoom_factor;

end
