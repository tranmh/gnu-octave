function [should_continue, u_modified] = update_simulation(ctrl, u_current, ...
                                                           x, y, t_current)
  % UPDATE_SIMULATION Main control loop for interactive heat diffusion simulation
  %
  % SYNTAX:
  %   [should_continue, u_modified] = update_simulation(ctrl, u_current, x, y, t_current)
  %
  % INPUTS:
  %   ctrl      - Control structure from setup_controls()
  %   u_current - Current temperature field (1D vector or 2D matrix)
  %   x         - Spatial grid in x direction (for 1D and 2D)
  %   y         - Spatial grid in y direction (for 2D only, [] for 1D)
  %   t_current - Current simulation time [s]
  %
  % OUTPUTS:
  %   should_continue - Boolean: true to continue simulation, false to stop
  %   u_modified      - Modified temperature field (same shape as u_current)
  %                     Returns u_current if no modifications made
  %
  % DESCRIPTION:
  %   Processes control state and user interactions:
  %   - Handles pause/resume state
  %   - Processes reset, quit, and save requests
  %   - Implements temperature probing
  %   - Adds heat sources in 2D (interactive)
  %   - Manages speed adjustments
  %   - Provides user feedback
  %
  % EXAMPLES:
  %   % In main simulation loop (1D):
  %   while t < t_final
  %     [cont, u] = update_simulation(ctrl, u, x, [], t);
  %     if ~cont; break; endif
  %     % ... continue with time stepping ...
  %   end
  %
  %   % In main simulation loop (2D):
  %   while t < t_final
  %     [cont, u] = update_simulation(ctrl, u, x, y, t);
  %     if ~cont; break; endif
  %     % ... continue with time stepping ...
  %   end
  %
  % AUTHOR: Heat Diffusion Project
  % DATE: October 2025
  
  % Initialize output
  should_continue = true;
  u_modified = u_current;
  
  % ========================================================================
  % HANDLE QUIT REQUEST
  % ========================================================================
  if ctrl.should_quit
    fprintf('\n🛑 Simulation terminated by user\n');
    should_continue = false;
    return;
  endif
  
  % ========================================================================
  % HANDLE PAUSE STATE
  % ========================================================================
  if ctrl.is_paused
    % Wait for user to resume
    pause(0.1);  % Small delay to prevent CPU spinning
    return;
  endif
  
  % ========================================================================
  % HANDLE RESET REQUEST
  % ========================================================================
  if ctrl.should_reset
    fprintf('🔄 Reset requested - returning to initial condition\n');
    ctrl.should_reset = false;  % Clear flag
    % Note: Actual reset must be handled in main script
    % This just signals the need for reset
    should_continue = false;  % Exit to allow main script to reset
    return;
  endif
  
  % ========================================================================
  % HANDLE SAVE REQUEST
  % ========================================================================
  if ctrl.should_save
    save_state(u_current, x, y, t_current, ctrl.dimension);
    ctrl.should_save = false;  % Clear flag
  endif
  
  % ========================================================================
  % HANDLE TEMPERATURE PROBING
  % ========================================================================
  if ctrl.probe_mode
    % Get current mouse position
    ax = gca;
    pt = get(ax, 'CurrentPoint');
    
    if strcmp(ctrl.dimension, '1d')
      % 1D probing
      x_probe = pt(1, 1);
      
      % Find nearest grid point
      [~, idx] = min(abs(x - x_probe));
      
      if idx >= 1 && idx <= length(u_current)
        T_probe = u_current(idx);
        fprintf('🔍 T(x=%.3f) = %.4f°C at t=%.3fs\n', ...
                x(idx), T_probe, t_current);
      endif
      
    else
      % 2D probing
      x_probe = pt(1, 1);
      y_probe = pt(1, 2);
      
      % Find nearest grid points
      [~, idx_x] = min(abs(x - x_probe));
      [~, idx_y] = min(abs(y - y_probe));
      
      if idx_x >= 1 && idx_x <= length(x) && idx_y >= 1 && idx_y <= length(y)
        T_probe = u_current(idx_y, idx_x);
        fprintf('🔍 T(x=%.3f, y=%.3f) = %.4f°C at t=%.3fs\n', ...
                x(idx_x), y(idx_y), T_probe, t_current);
      endif
    endif
  endif
  
  % ========================================================================
  % HANDLE HEAT ADDITION (2D only)
  % ========================================================================
  if strcmp(ctrl.dimension, '2d') && ctrl.add_heat && ...
     ~isempty(ctrl.heat_pos) && ctrl.heat_intensity > 0
    
    % Add Gaussian heat source at mouse position
    x_heat = ctrl.heat_pos(1);
    y_heat = ctrl.heat_pos(2);
    
    % Create 2D Gaussian heat addition
    [X, Y] = meshgrid(x, y);
    heat_width = 0.05;  % Width of heat source
    heat_amplitude = 5.0 * ctrl.heat_intensity;  % Temperature increase
    
    heat_source = heat_amplitude * exp(-((X - x_heat).^2 + ...
                                         (Y - y_heat).^2) / heat_width^2);
    
    % Add heat to current temperature field
    u_modified = u_current + heat_source;
    
    fprintf('🔥 Adding heat at (%.3f, %.3f) - ΔT_max = %.2f°C\n', ...
            x_heat, y_heat, heat_amplitude);
  endif
  
  % ========================================================================
  % APPLY SPEED ADJUSTMENT
  % ========================================================================
  % Note: Speed adjustment is applied in main loop by modifying dt
  % The speed_factor is read from ctrl.speed_factor
  
  % Small pause to prevent overwhelming the graphics system
  if strcmp(ctrl.dimension, '2d')
    pause(0.01);  % 2D needs slightly more time for rendering
  else
    pause(0.005); % 1D is faster
  endif
  
endfunction


% ========================================================================
% HELPER FUNCTIONS
% ========================================================================

function save_state(u, x, y, t, dimension)
  % Save current simulation state to file
  
  % Generate filename with timestamp
  timestamp = datestr(now, 'yyyymmdd_HHMMSS');
  filename = sprintf('heat_state_%s_%s.mat', dimension, timestamp);
  
  % Save data
  if strcmp(dimension, '1d')
    save(filename, 'u', 'x', 't', 'dimension');
    fprintf('💾 State saved to: %s\n', filename);
    fprintf('   Variables: u (temperature), x (grid), t (time)\n');
  else
    save(filename, 'u', 'x', 'y', 't', 'dimension');
    fprintf('💾 State saved to: %s\n', filename);
    fprintf('   Variables: u (temperature), x, y (grids), t (time)\n');
  endif
  
  fprintf('   To load: load(''%s'')\n', filename);
  
endfunction
