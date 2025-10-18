function plot_1d_snapshot(x, U, t, time_indices, params)
  % PLOT_1D_SNAPSHOT Static plot of 1D temperature at specific time(s)
  %
  % Creates publication-quality plots showing temperature distribution
  % at one or more time snapshots for comparison.
  %
  % INPUTS:
  %   x             - Spatial grid points [1 x nx]
  %   U             - Temperature solution [nx x nt]
  %   t             - Time values [1 x nt]
  %   time_indices  - Indices of time steps to plot (vector)
  %   params        - Structure with plot parameters:
  %                   .colormap     - Color scheme (default: 'jet')
  %                   .title_prefix - Custom title (default: '1D Heat Diffusion Snapshot')
  %                   .legend_on    - Show legend (default: true)
  %                   .line_width   - Line width (default: 2)
  %
  % EXAMPLE:
  %   % Plot at t=0, t=0.1, t=0.5, t=1.0
  %   time_indices = [1, 101, 501, 1001];
  %   plot_1d_snapshot(x, U, t, time_indices, params);
  
  % Parse parameters
  if nargin < 5
    params = struct();
  end
  
  colormap_choice = get_param(params, 'colormap', 'jet');
  title_prefix = get_param(params, 'title_prefix', '1D Heat Diffusion Snapshot');
  legend_on = get_param(params, 'legend_on', true);
  line_width = get_param(params, 'line_width', 2);
  
  % Validate time indices
  nt = size(U, 2);
  if any(time_indices < 1) || any(time_indices > nt)
    error('time_indices must be between 1 and %d', nt);
  end
  
  % Create figure
  figure('Name', title_prefix, 'NumberTitle', 'off');
  hold on;
  grid on;
  
  % Generate colors for different time snapshots
  n_snapshots = length(time_indices);
  colors = colormap(colormap_choice);
  color_indices = round(linspace(1, size(colors, 1), n_snapshots));
  
  % Plot each time snapshot
  legend_labels = cell(1, n_snapshots);
  for i = 1:n_snapshots
    idx = time_indices(i);
    plot(x, U(:, idx), 'LineWidth', line_width, 'Color', colors(color_indices(i), :));
    legend_labels{i} = sprintf('t = %.4f s', t(idx));
  end
  
  % Add reference line at T=0
  plot(xlim, [0, 0], 'k--', 'LineWidth', 0.5, 'HandleVisibility', 'off');
  
  % Labels and formatting
  xlabel('Position x [m]', 'FontSize', 12);
  ylabel('Temperature u [°C]', 'FontSize', 12);
  title(title_prefix, 'FontSize', 14);
  
  % Add legend if requested
  if legend_on
    legend(legend_labels, 'Location', 'best', 'FontSize', 10);
  end
  
  % Set axis limits
  xlim([min(x), max(x)]);
  
  % Auto-scale y-axis with some padding
  T_min = min(U(:, time_indices), [], 'all');
  T_max = max(U(:, time_indices), [], 'all');
  T_range = T_max - T_min;
  ylim([T_min - 0.1 * T_range, T_max + 0.1 * T_range]);
  
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
