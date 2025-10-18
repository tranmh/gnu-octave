function animate_1d(x, U, t, params)
  % ANIMATE_1D Real-time animation of 1D heat diffusion
  %
  % Displays temperature distribution evolving over time as a smooth
  % line plot animation with no flickering.
  %
  % INPUTS:
  %   x      - Spatial grid points [1 x nx]
  %   U      - Temperature solution [nx x nt], each column is one time step
  %   t      - Time values [1 x nt]
  %   params - Structure with animation parameters:
  %            .frame_skip    - Show every Nth time step (default: 1)
  %            .fps_target    - Target frames per second (default: 30)
  %            .colormap      - Color scheme (default: 'jet')
  %            .title_prefix  - Custom title prefix (default: '1D Heat Diffusion')
  %
  % EXAMPLE:
  %   params.frame_skip = 10;
  %   params.fps_target = 30;
  %   animate_1d(x, U, t, params);
  
  % Parse parameters
  if nargin < 4
    params = struct();
  end
  
  frame_skip = get_param(params, 'frame_skip', 1);
  fps_target = get_param(params, 'fps_target', 30);
  colormap_choice = get_param(params, 'colormap', 'jet');
  title_prefix = get_param(params, 'title_prefix', '1D Heat Diffusion');
  
  % Get dimensions
  [nx, nt] = size(U);
  
  % Calculate temperature range for consistent y-axis
  T_min = min(U(:));
  T_max = max(U(:));
  T_range = T_max - T_min;
  y_min = T_min - 0.1 * T_range;
  y_max = T_max + 0.1 * T_range;
  
  % Create figure and set up plot
  figure('Name', title_prefix, 'NumberTitle', 'off');
  hold on;
  grid on;
  
  % Initialize plot line (will update data, not recreate)
  h_line = plot(x, U(:, 1), 'b-', 'LineWidth', 2);
  
  % Set up axes
  xlabel('Position x [m]', 'FontSize', 12);
  ylabel('Temperature u [°C]', 'FontSize', 12);
  title(sprintf('%s - t = %.4f s', title_prefix, t(1)), 'FontSize', 14);
  xlim([min(x), max(x)]);
  ylim([y_min, y_max]);
  
  % Add reference lines at 0 and initial max
  plot(xlim, [0, 0], 'k--', 'LineWidth', 0.5, 'HandleVisibility', 'off');
  if T_max > 0
    plot(xlim, [T_max, T_max], 'r--', 'LineWidth', 0.5, 'HandleVisibility', 'off');
  end
  
  % Color the line based on temperature
  colormap(colormap_choice);
  
  % Calculate frame delay for target fps
  frame_delay = 1.0 / fps_target;
  
  % Animation loop
  fprintf('Animating %d frames (showing every %d time steps)...\n', ...
          floor(nt / frame_skip), frame_skip);
  
  for i = 1:frame_skip:nt
    % Update plot data (efficient - no redrawing entire plot)
    set(h_line, 'XData', x, 'YData', U(:, i));
    
    % Update title with current time
    title(sprintf('%s - t = %.4f s', title_prefix, t(i)), 'FontSize', 14);
    
    % Refresh display
    drawnow;
    
    % Control frame rate
    pause(frame_delay);
  end
  
  fprintf('Animation complete.\n');
  hold off;
end

% Helper function to get parameter with default
function value = get_param(params, field, default)
  if isfield(params, field)
    value = params.(field);
  else
    value = default;
  end
end
