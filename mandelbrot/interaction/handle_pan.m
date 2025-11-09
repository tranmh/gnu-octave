function state = handle_pan(state, direction)
  % HANDLE_PAN Pan the view in specified direction
  %
  % Usage:
  %   state = handle_pan(state, direction)
  %
  % Inputs:
  %   state     - Current application state struct
  %   direction - 'up', 'down', 'left', 'right'
  %
  % Outputs:
  %   state - Updated state with new center
  %
  % Example:
  %   state = handle_pan(state, 'left');
  %
  % Phase: 3 - Interactive Explorer

  % Pan distance (10% of current view)
  pan_factor = 0.1;

  % Calculate pan offset
  switch lower(direction)
    case 'up'
      offset = 0 + 1i * state.height * pan_factor;
    case 'down'
      offset = 0 - 1i * state.height * pan_factor;
    case 'left'
      offset = -state.width * pan_factor + 0i;
    case 'right'
      offset = state.width * pan_factor + 0i;
    otherwise
      offset = 0 + 0i;
  end

  % Update center
  state.center = state.center + offset;
  state.needs_render = true;

end
