function plot_2d_snapshot(u, x, y, t, options)
  % PLOT_2D_SNAPSHOT - Plot a single snapshot of 2D temperature distribution
  %
  % Syntax:
  %   plot_2d_snapshot(u, x, y, t)
  %   plot_2d_snapshot(u, x, y, t, options)
  %
  % Inputs:
  %   u       - Temperature matrix (ny × nx)
  %   x       - Spatial grid in x-direction (nx × 1)
  %   y       - Spatial grid in y-direction (ny × 1)
  %   t       - Time value for title
  %   options - Optional struct with fields:
  %             .colormap - Colormap name (default: 'hot')
  %             .colorbar - Show colorbar (default: true)
  %             .title    - Custom title (default: auto-generated)
  %
  % Example:
  %   plot_2d_snapshot(u_history(:,:,50), x, y, t(50));
  
  % Default options
  if nargin < 5
    options = struct();
  end
  
  if ~isfield(options, 'colormap')
    options.colormap = 'hot';
  end
  
  if ~isfield(options, 'colorbar')
    options.colorbar = true;
  end
  
  if ~isfield(options, 'title')
    options.title = sprintf('Temperature Distribution at t = %.3f s', t);
  end
  
  % Create surface plot
  surf(x, y, u, 'EdgeColor', 'none');
  
  % Set view and labels
  view(2);  % Top-down view
  xlabel('x [m]');
  ylabel('y [m]');
  title(options.title);
  
  % Apply colormap
  colormap(options.colormap);
  
  % Show colorbar if requested
  if options.colorbar
    cb = colorbar;
    ylabel(cb, 'Temperature [°C]');
  end
  
  % Set axis properties
  axis tight;
  shading flat;
end
