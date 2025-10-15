function display_help()
  % DISPLAY_HELP - Display help screen with controls and instructions
  %
  % Syntax: display_help()
  %
  % Shows a formatted help screen with all keyboard and mouse controls
  % for the Game of Life simulation.
  %
  % Example:
  %   display_help();
  
  fprintf('\n');
  fprintf('═══════════════════════════════════════════════════════════════════\n');
  fprintf('                   CONWAY''S GAME OF LIFE - HELP                    \n');
  fprintf('═══════════════════════════════════════════════════════════════════\n');
  fprintf('\n');
  
  fprintf('KEYBOARD CONTROLS:\n');
  fprintf('─────────────────────────────────────────────────────────────────\n');
  fprintf('  SPACE     : Pause/Resume simulation\n');
  fprintf('  S         : Single step forward (when paused)\n');
  fprintf('  R         : Reset to initial state\n');
  fprintf('  C         : Clear grid (all cells dead)\n');
  fprintf('  +         : Increase simulation speed\n');
  fprintf('  -         : Decrease simulation speed\n');
  fprintf('  H         : Show this help screen\n');
  fprintf('  Q         : Quit simulation\n');
  fprintf('\n');
  
  fprintf('FILE OPERATIONS:\n');
  fprintf('─────────────────────────────────────────────────────────────────\n');
  fprintf('  Ctrl+S    : Save current pattern\n');
  fprintf('  Ctrl+L    : Load saved pattern\n');
  fprintf('  L         : List available saved patterns\n');
  fprintf('\n');
  
  fprintf('MOUSE CONTROLS:\n');
  fprintf('─────────────────────────────────────────────────────────────────\n');
  fprintf('  Left Click: Toggle cell state (alive/dead)\n');
  fprintf('  Note: Automatically pauses simulation while editing\n');
  fprintf('\n');
  
  fprintf('RULES OF CONWAY''S GAME OF LIFE:\n');
  fprintf('─────────────────────────────────────────────────────────────────\n');
  fprintf('  1. Any live cell with 2 or 3 neighbors survives\n');
  fprintf('  2. Any dead cell with exactly 3 neighbors becomes alive\n');
  fprintf('  3. All other cells die or stay dead\n');
  fprintf('\n');
  
  fprintf('DISPLAY INFORMATION:\n');
  fprintf('─────────────────────────────────────────────────────────────────\n');
  fprintf('  Generation : Current generation number\n');
  fprintf('  Population : Number of living cells\n');
  fprintf('  Change     : Population change from previous generation\n');
  fprintf('  Density    : Percentage of cells that are alive\n');
  fprintf('  Status     : Running/Paused/Static (no changes)\n');
  fprintf('\n');
  
  fprintf('TIPS:\n');
  fprintf('─────────────────────────────────────────────────────────────────\n');
  fprintf('  • Try different patterns from the menu to see various behaviors\n');
  fprintf('  • Use pause and single step to study patterns in detail\n');
  fprintf('  • The grid wraps around at edges (toroidal topology)\n');
  fprintf('  • Save interesting patterns you create for later use\n');
  fprintf('  • Adjust speed to observe fast-moving patterns like gliders\n');
  fprintf('\n');
  
  fprintf('═══════════════════════════════════════════════════════════════════\n');
  fprintf('\nPress any key to close this help screen...\n');
  
end
