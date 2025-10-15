# Phase 3: Interactive Controls

This module provides keyboard and mouse interaction capabilities for the Game of Life simulation.

## Components

### handle_keyboard.m
Processes keyboard input and returns action commands for the main game loop.

**Supported Keys:**
- **SPACE** - Toggle pause/resume simulation
- **S** - Single step forward (useful when paused)
- **R** - Reset grid to initial state
- **C** - Clear all cells (kill everything)
- **+/=** - Increase speed (decrease delay between generations)
- **-/_** - Decrease speed (increase delay between generations)
- **H** - Show help (for future implementation)
- **Q** - Quit simulation

**Speed Control:**
- Minimum delay: 0.01 seconds (very fast)
- Maximum delay: 2.0 seconds (very slow)
- Speed change increment: 0.05 seconds per keypress

**Usage:**
```octave
action = handle_keyboard(key_pressed, current_speed);

switch action.type
  case 'toggle_pause'
    is_paused = ~is_paused;
  case 'step'
    % Execute one generation
  case 'reset'
    grid = initial_grid;
  case 'clear'
    grid = zeros(size(grid));
  case 'speed'
    speed = action.speed;
  case 'quit'
    running = false;
  case 'help'
    % Show help screen
endswitch
```

### handle_mouse_click.m
Toggles cell state (alive/dead) based on mouse click coordinates.

**Features:**
- Converts screen coordinates to grid indices
- Toggles cell state (0→1 or 1→0)
- Validates coordinates are within grid bounds
- Returns unchanged grid if click is outside bounds

**Usage:**
```octave
% In figure button press callback:
[x, y] = ginput(1);  % Get mouse click coordinates
grid = handle_mouse_click(grid, x, y);
update_display(fig_handle, grid, generation, population, status);
```

## Testing

Run the test suite:
```octave
cd game-of-life
test_phase3
```

## Integration Notes

### Event Handling in Octave
Octave's event handling capabilities are somewhat limited compared to MATLAB. For full interactive functionality:

1. **Figure Callbacks**: Use `set(fig, 'ButtonDownFcn', @callback)` for mouse clicks
2. **Key Press Callbacks**: Use `set(fig, 'KeyPressFcn', @callback)` for keyboard input
3. **Timer Objects**: Use `timer()` for non-blocking animation loops

### Recommended Implementation Pattern
```octave
% Create figure with callbacks
fig = figure('KeyPressFcn', @key_callback, ...
             'ButtonDownFcn', @mouse_callback);

% Key callback function
function key_callback(src, evt)
  action = handle_keyboard(evt.Key, speed);
  % Process action...
endfunction

% Mouse callback function  
function mouse_callback(src, evt)
  pos = get(gca, 'CurrentPoint');
  grid = handle_mouse_click(grid, pos(1,1), pos(1,2));
  % Update display...
endfunction
```

## Status

✅ **Phase 3 Complete** - All interactive control functions implemented and tested.

### What Works
- ✅ Keyboard command parsing for all planned keys
- ✅ Mouse click cell toggling with bounds checking
- ✅ Speed control with min/max limits
- ✅ Case-insensitive key handling
- ✅ Comprehensive unit tests

### Next Steps
- Phase 4: Pattern Library & Menu system
- Integration into main game_of_life.m with proper callbacks

## Examples

See `demo_interactive.m` for a basic integration example (note: simplified event handling).

See `test_phase3.m` for comprehensive unit tests of both modules.
