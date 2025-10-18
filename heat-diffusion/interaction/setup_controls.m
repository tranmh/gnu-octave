function ctrl = setup_controls(fig_handle, dimension)
  % SETUP_CONTROLS Initialize interactive control system for heat diffusion simulation
  %
  % SYNTAX:
  %   ctrl = setup_controls(fig_handle, dimension)
  %
  % INPUTS:
  %   fig_handle - Figure handle for the simulation window
  %   dimension  - Dimension of simulation: '1d' or '2d'
  %
  % OUTPUTS:
  %   ctrl - Structure containing control state and handlers
  %     .is_paused    - Boolean: simulation paused state
  %     .speed_factor - Numeric: time step multiplier (default 1.0)
  %     .should_reset - Boolean: flag to reset simulation
  %     .should_quit  - Boolean: flag to quit simulation
  %     .should_save  - Boolean: flag to save current state
  %     .probe_mode   - Boolean: temperature probing mode (mouse)
  %     .add_heat     - Boolean: add heat source mode (2D only)
  %     .heat_pos     - [x,y] position for added heat (2D only)
  %     .show_help    - Boolean: display help overlay
  %
  % KEYBOARD CONTROLS:
  %   SPACE     - Pause/resume simulation
  %   UP        - Increase speed (faster time steps)
  %   DOWN      - Decrease speed (slower time steps)
  %   R         - Reset to initial condition
  %   Q/ESCAPE  - Quit simulation
  %   S         - Save current state to file
  %   P         - Toggle probe mode (click to see temperature)
  %   H         - Toggle help overlay
  %   A         - Add heat source mode (2D only, click and hold)
  %
  % MOUSE CONTROLS:
  %   Click       - Probe temperature at point (when probe mode active)
  %   Click+Hold  - Add heat source temporarily (2D, when add_heat mode active)
  %
  % EXAMPLES:
  %   % Basic setup for 1D
  %   fig = figure();
  %   ctrl = setup_controls(fig, '1d');
  %
  %   % Setup for 2D with interactive heat addition
  %   fig = figure();
  %   ctrl = setup_controls(fig, '2d');
  %
  % AUTHOR: Heat Diffusion Project
  % DATE: October 2025
  
  % Initialize control state structure
  ctrl = struct();
  ctrl.is_paused = false;
  ctrl.speed_factor = 1.0;
  ctrl.should_reset = false;
  ctrl.should_quit = false;
  ctrl.should_save = false;
  ctrl.probe_mode = false;
  ctrl.show_help = false;
  
  % 2D-specific controls
  if strcmp(dimension, '2d')
    ctrl.add_heat = false;
    ctrl.heat_pos = [];
    ctrl.heat_intensity = 0;
  endif
  
  % Store figure handle
  ctrl.fig_handle = fig_handle;
  ctrl.dimension = dimension;
  
  % Set up keyboard callback
  set(fig_handle, 'KeyPressFcn', @(src, event) keyboard_callback(event, ctrl));
  
  % Set up mouse callbacks for interactive features
  set(fig_handle, 'WindowButtonDownFcn', @(src, event) mouse_down_callback(ctrl));
  set(fig_handle, 'WindowButtonUpFcn', @(src, event) mouse_up_callback(ctrl));
  set(fig_handle, 'WindowButtonMotionFcn', @(src, event) mouse_motion_callback(ctrl));
  
  % Display initial help message
  display_status(ctrl);
  
endfunction


% ========================================================================
% CALLBACK FUNCTIONS
% ========================================================================

function keyboard_callback(event, ctrl)
  % Handle keyboard events
  
  key = event.Key;
  
  switch key
    case 'space'
      % Toggle pause
      ctrl.is_paused = ~ctrl.is_paused;
      if ctrl.is_paused
        fprintf('⏸  PAUSED (press SPACE to resume)\n');
      else
        fprintf('▶  RESUMED\n');
      endif
      
    case 'uparrow'
      % Increase speed
      ctrl.speed_factor = min(ctrl.speed_factor * 1.5, 10.0);
      fprintf('⏩ Speed: %.2fx\n', ctrl.speed_factor);
      
    case 'downarrow'
      % Decrease speed
      ctrl.speed_factor = max(ctrl.speed_factor / 1.5, 0.1);
      fprintf('⏪ Speed: %.2fx\n', ctrl.speed_factor);
      
    case 'r'
      % Reset simulation
      ctrl.should_reset = true;
      fprintf('🔄 RESET requested\n');
      
    case {'q', 'escape'}
      % Quit simulation
      ctrl.should_quit = true;
      fprintf('❌ QUIT requested\n');
      
    case 's'
      % Save current state
      ctrl.should_save = true;
      fprintf('💾 SAVE requested\n');
      
    case 'p'
      % Toggle probe mode
      ctrl.probe_mode = ~ctrl.probe_mode;
      if ctrl.probe_mode
        fprintf('🔍 PROBE MODE: Click to check temperature\n');
      else
        fprintf('🔍 Probe mode OFF\n');
      endif
      
    case 'h'
      % Toggle help display
      ctrl.show_help = ~ctrl.show_help;
      if ctrl.show_help
        display_help(ctrl.dimension);
      else
        fprintf('ℹ️  Help hidden\n');
      endif
      
    case 'a'
      % Toggle add heat mode (2D only)
      if strcmp(ctrl.dimension, '2d')
        ctrl.add_heat = ~ctrl.add_heat;
        if ctrl.add_heat
          fprintf('🔥 ADD HEAT MODE: Click and hold to add heat\n');
        else
          fprintf('🔥 Add heat mode OFF\n');
        endif
      endif
      
    otherwise
      % Ignore other keys
  endswitch
  
endfunction


function mouse_down_callback(ctrl)
  % Handle mouse button press
  
  % Get current point in axis coordinates
  ax = gca;
  pt = get(ax, 'CurrentPoint');
  
  if strcmp(ctrl.dimension, '1d')
    % 1D: probe temperature at clicked x position
    if ctrl.probe_mode
      x_click = pt(1, 1);
      % The probe functionality will be handled in update_simulation
      fprintf('🔍 Probing at x = %.3f\n', x_click);
    endif
    
  else  % 2D
    x_click = pt(1, 1);
    y_click = pt(1, 2);
    
    if ctrl.probe_mode
      % Probe temperature at (x,y)
      fprintf('🔍 Probing at (x,y) = (%.3f, %.3f)\n', x_click, y_click);
    elseif ctrl.add_heat
      % Start adding heat at this position
      ctrl.heat_pos = [x_click, y_click];
      ctrl.heat_intensity = 1.0;
      fprintf('🔥 Adding heat at (%.3f, %.3f)\n', x_click, y_click);
    endif
  endif
  
endfunction


function mouse_up_callback(ctrl)
  % Handle mouse button release
  
  if strcmp(ctrl.dimension, '2d') && ctrl.add_heat
    % Stop adding heat
    ctrl.heat_intensity = 0;
    ctrl.heat_pos = [];
  endif
  
endfunction


function mouse_motion_callback(ctrl)
  % Handle mouse motion (for drag-to-add-heat in 2D)
  
  if strcmp(ctrl.dimension, '2d') && ctrl.add_heat && ctrl.heat_intensity > 0
    % Update heat position while dragging
    ax = gca;
    pt = get(ax, 'CurrentPoint');
    ctrl.heat_pos = [pt(1, 1), pt(1, 2)];
  endif
  
endfunction


% ========================================================================
% HELPER FUNCTIONS
% ========================================================================

function display_status(ctrl)
  % Display current control status
  
  fprintf('\n');
  fprintf('╔════════════════════════════════════════╗\n');
  fprintf('║  Heat Diffusion - Interactive Controls ║\n');
  fprintf('╚════════════════════════════════════════╝\n');
  fprintf('  Press H for help\n');
  fprintf('  Press SPACE to pause/resume\n');
  fprintf('  Press Q to quit\n\n');
  
endfunction


function display_help(dimension)
  % Display comprehensive help overlay
  
  fprintf('\n');
  fprintf('╔════════════════════════════════════════════════════╗\n');
  fprintf('║          HEAT DIFFUSION CONTROLS - HELP            ║\n');
  fprintf('╠════════════════════════════════════════════════════╣\n');
  fprintf('║  KEYBOARD CONTROLS:                                ║\n');
  fprintf('║  ─────────────────                                 ║\n');
  fprintf('║  SPACE     - Pause/Resume simulation               ║\n');
  fprintf('║  UP        - Increase speed (faster)               ║\n');
  fprintf('║  DOWN      - Decrease speed (slower)               ║\n');
  fprintf('║  R         - Reset to initial condition            ║\n');
  fprintf('║  Q/ESC     - Quit simulation                       ║\n');
  fprintf('║  S         - Save current state                    ║\n');
  fprintf('║  P         - Toggle probe mode                     ║\n');
  fprintf('║  H         - Toggle this help                      ║\n');
  
  if strcmp(dimension, '2d')
    fprintf('║  A         - Toggle add heat mode (2D)             ║\n');
    fprintf('║                                                    ║\n');
    fprintf('║  MOUSE CONTROLS (2D):                              ║\n');
    fprintf('║  ──────────────────                                ║\n');
    fprintf('║  Click       - Probe temperature (P mode)          ║\n');
    fprintf('║  Click+Hold  - Add heat source (A mode)            ║\n');
  else
    fprintf('║                                                    ║\n');
    fprintf('║  MOUSE CONTROLS (1D):                              ║\n');
    fprintf('║  ──────────────────                                ║\n');
    fprintf('║  Click       - Probe temperature (P mode)          ║\n');
  endif
  
  fprintf('╚════════════════════════════════════════════════════╝\n');
  fprintf('\n');
  
endfunction
