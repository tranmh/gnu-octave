function plot_2d_multiple(x, y, U, t, time_idx, params)
  % PLOT_2D_MULTIPLE Multiple view plots of 2D temperature field
  %
  % Creates a subplot figure showing surface, contour, and heatmap
  % views of the temperature field at a specific time.
  %
  % INPUTS:
  %   x        - X-axis grid points [1 x nx]
  %   y        - Y-axis grid points [1 x ny]
  %   U        - Temperature solution [nx x ny x nt]
  %   t        - Time values [1 x nt]
  %   time_idx - Index of time step to plot
  %   params   - Structure with plot parameters:
  %              .colormap     - Color scheme (default: 'jet')
  %              .title_prefix - Custom title (default: '2D Heat Diffusion')
  %              .view_angle   - [azimuth, elevation] for surface (default: [45, 30])
  %              .layout       - 'horizontal', 'vertical', or 'grid' (default: 'horizontal')
  %
  % EXAMPLE:
  %   % Show temperature field at t=0.5
  %   plot_2d_multiple(x, y, U, t, 501, params);
  
  % Parse parameters
  if nargin < 6
    params = struct();
  end
  
  colormap_choice = get_param(params, 'colormap', 'jet');
  title_prefix = get_param(params, 'title_prefix', '2D Heat Diffusion');
  view_angle = get_param(params, 'view_angle', [45, 30]);
  layout = get_param(params, 'layout', 'horizontal');
  
  % Validate time index
  nt = size(U, 3);
  if time_idx < 1 || time_idx > nt
    error('time_idx must be between 1 and %d', nt);
  end
  
  % Extract temperature field at specified time
  U_snapshot = U(:, :, time_idx);
  
  % Calculate temperature range
  T_min = min(U_snapshot(:));
  T_max = max(U_snapshot(:));
  
  % Create meshgrid
  [X, Y] = meshgrid(x, y);
  
  % Create figure with subplots
  figure('Name', sprintf('%s at t=%.4f', title_prefix, t(time_idx)), ...
         'NumberTitle', 'off', 'Position', [100, 100, 1200, 400]);
  
  % Determine subplot layout
  switch lower(layout)
    case 'horizontal'
      subplot_dims = [1, 3];
    case 'vertical'
      subplot_dims = [3, 1];
    case 'grid'
      subplot_dims = [2, 2];
    otherwise
      error('Unknown layout: %s. Use ''horizontal'', ''vertical'', or ''grid''.', layout);
  end
  
  % --- Subplot 1: Surface Plot ---
  subplot(subplot_dims(1), subplot_dims(2), 1);
  surf(X, Y, U_snapshot');
  shading interp;
  view(view_angle);
  colormap(colormap_choice);
  colorbar;
  caxis([T_min, T_max]);
  xlabel('X [m]', 'FontSize', 10);
  ylabel('Y [m]', 'FontSize', 10);
  zlabel('Temperature [°C]', 'FontSize', 10);
  title(sprintf('Surface Plot (t=%.4f s)', t(time_idx)), 'FontSize', 12);
  
  % --- Subplot 2: Contour Plot ---
  subplot(subplot_dims(1), subplot_dims(2), 2);
  levels = linspace(T_min, T_max, 20);
  contourf(X, Y, U_snapshot', levels);
  colormap(colormap_choice);
  colorbar;
  caxis([T_min, T_max]);
  xlabel('X [m]', 'FontSize', 10);
  ylabel('Y [m]', 'FontSize', 10);
  title(sprintf('Contour Plot (t=%.4f s)', t(time_idx)), 'FontSize', 12);
  axis equal tight;
  
  % --- Subplot 3: Heatmap ---
  subplot(subplot_dims(1), subplot_dims(2), 3);
  imagesc(x, y, U_snapshot');
  axis xy;  % Standard mathematical orientation
  colormap(colormap_choice);
  colorbar;
  caxis([T_min, T_max]);
  xlabel('X [m]', 'FontSize', 10);
  ylabel('Y [m]', 'FontSize', 10);
  title(sprintf('Heatmap (t=%.4f s)', t(time_idx)), 'FontSize', 12);
  axis equal tight;
  
  % Overall title
  sgtitle(sprintf('%s - Multiple Views', title_prefix), 'FontSize', 14, 'FontWeight', 'bold');
end

% Helper function to get parameter with default
function value = get_param(params, field, default)
  if isfield(params, field)
    value = params.(field);
  else
    value = default;
  end
end
