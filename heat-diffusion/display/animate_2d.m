function animate_2d(x, y, U, t, params)
  % ANIMATE_2D Real-time animation of 2D heat diffusion
  %
  % Displays temperature field evolving over time using surface plots,
  % heatmaps, or contour plots with smooth updates.
  %
  % INPUTS:
  %   x      - X-axis grid points [1 x nx]
  %   y      - Y-axis grid points [1 x ny]
  %   U      - Temperature solution [nx x ny x nt], each slice is one time step
  %   t      - Time values [1 x nt]
  %   params - Structure with animation parameters:
  %            .frame_skip    - Show every Nth time step (default: 1)
  %            .fps_target    - Target frames per second (default: 30)
  %            .colormap      - Color scheme (default: 'jet')
  %            .plot_type     - 'surface', 'heatmap', or 'contour' (default: 'heatmap')
  %            .title_prefix  - Custom title prefix (default: '2D Heat Diffusion')
  %            .view_angle    - [azimuth, elevation] for surface plots (default: [45, 30])
  %
  % EXAMPLE:
  %   params.frame_skip = 5;
  %   params.plot_type = 'surface';
  %   params.view_angle = [30, 45];
  %   animate_2d(x, y, U, t, params);
  
  % Parse parameters
  if nargin < 5
    params = struct();
  end
  
  frame_skip = get_param(params, 'frame_skip', 1);
  fps_target = get_param(params, 'fps_target', 30);
  colormap_choice = get_param(params, 'colormap', 'jet');
  plot_type = get_param(params, 'plot_type', 'heatmap');
  title_prefix = get_param(params, 'title_prefix', '2D Heat Diffusion');
  view_angle = get_param(params, 'view_angle', [45, 30]);
  
  % Get dimensions
  [nx, ny, nt] = size(U);
  
  % Calculate temperature range for consistent color scale
  T_min = min(U(:));
  T_max = max(U(:));
  
  % Create figure
  figure('Name', title_prefix, 'NumberTitle', 'off');
  
  % Create meshgrid for plotting
  [X, Y] = meshgrid(x, y);
  
  % Initialize plot based on type
  switch lower(plot_type)
    case 'surface'
      h_plot = surf(X, Y, U(:, :, 1)');
      shading interp;
      view(view_angle);
      xlabel('X [m]', 'FontSize', 12);
      ylabel('Y [m]', 'FontSize', 12);
      zlabel('Temperature [°C]', 'FontSize', 12);
      zlim([T_min, T_max]);
      
    case 'heatmap'
      h_plot = imagesc(x, y, U(:, :, 1)');
      axis xy;  % Flip y-axis to match mathematical convention
      xlabel('X [m]', 'FontSize', 12);
      ylabel('Y [m]', 'FontSize', 12);
      colorbar;
      axis equal tight;
      
    case 'contour'
      levels = linspace(T_min, T_max, 20);
      [~, h_plot] = contourf(X, Y, U(:, :, 1)', levels);
      xlabel('X [m]', 'FontSize', 12);
      ylabel('Y [m]', 'FontSize', 12);
      colorbar;
      axis equal tight;
      
    otherwise
      error('Unknown plot_type: %s. Use ''surface'', ''heatmap'', or ''contour''.', plot_type);
  end
  
  % Set colormap and color limits
  colormap(colormap_choice);
  caxis([T_min, T_max]);
  
  % Set title
  title(sprintf('%s - t = %.4f s', title_prefix, t(1)), 'FontSize', 14);
  
  % Calculate frame delay for target fps
  frame_delay = 1.0 / fps_target;
  
  % Animation loop
  fprintf('Animating %d frames (showing every %d time steps)...\n', ...
          floor(nt / frame_skip), frame_skip);
  
  for i = 1:frame_skip:nt
    % Update plot data efficiently
    switch lower(plot_type)
      case 'surface'
        set(h_plot, 'ZData', U(:, :, i)');
        
      case 'heatmap'
        set(h_plot, 'CData', U(:, :, i)');
        
      case 'contour'
        % Contour plots need to be redrawn (no efficient update method)
        cla;
        levels = linspace(T_min, T_max, 20);
        [~, h_plot] = contourf(X, Y, U(:, :, i)', levels);
        colormap(colormap_choice);
        caxis([T_min, T_max]);
        colorbar;
        axis equal tight;
    end
    
    % Update title with current time
    title(sprintf('%s - t = %.4f s', title_prefix, t(i)), 'FontSize', 14);
    
    % Refresh display
    drawnow;
    
    % Control frame rate
    pause(frame_delay);
  end
  
  fprintf('Animation complete.\n');
end

% Helper function to get parameter with default
function value = get_param(params, field, default)
  if isfield(params, field)
    value = params.(field);
  else
    value = default;
  end
end
