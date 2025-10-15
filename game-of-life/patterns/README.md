# Pattern Library - Game of Life Patterns

This directory contains the pattern library system for Conway's Game of Life.

## Files

### pattern_library.m
The core pattern library containing 13 classic Game of Life patterns organized by category.

### place_pattern.m
Function to place patterns on the grid with automatic centering and toroidal boundary support.

### show_menu.m
Interactive menu system for pattern selection and grid configuration.

## Available Patterns

### Oscillators (Repeating Patterns)
These patterns cycle through a sequence of states and return to their original form.

- **Blinker** (Period 2): Simplest oscillator - a line of 3 cells that flips between horizontal and vertical
- **Toad** (Period 2): 6-cell oscillator that rocks back and forth
- **Beacon** (Period 2): Two 2x2 blocks that toggle cells on and off
- **Pulsar** (Period 3): Large, beautiful 13x13 symmetric oscillator

### Spaceships (Moving Patterns)
These patterns translate across the grid while maintaining their shape.

- **Glider**: The most famous pattern - moves diagonally across the grid
- **LWSS** (Lightweight Spaceship): Moves horizontally, larger than a glider

### Still Lifes (Static Patterns)
These patterns never change - they are completely stable.

- **Block**: Simple 2x2 square - the smallest still life
- **Beehive**: Hexagonal shaped still life
- **Loaf**: Asymmetric stable pattern resembling a loaf of bread
- **Boat**: Small 3x3 stable pattern
- **Tub**: Symmetric 3x3 ring pattern

### Complex Patterns
Sophisticated patterns with interesting long-term behavior.

- **Gosper Glider Gun**: A pattern that continuously generates gliders - the first discovered finite pattern with unbounded growth

### Procedural Patterns
- **Random**: Generates a random starting configuration with approximately 30% cell density

## Usage

### Using the Menu System
```octave
% Show menu and get user's pattern choice
[pattern_choice, grid_size] = show_menu();
```

### Getting Patterns Programmatically
```octave
% Get a specific pattern
glider = pattern_library('glider');
pulsar = pattern_library('pulsar');

% Available pattern names:
% 'blinker', 'toad', 'beacon', 'pulsar'
% 'glider', 'lwss'
% 'block', 'beehive', 'loaf', 'boat', 'tub'
% 'glider_gun', 'random'
```

### Placing Patterns on Grid
```octave
% Create empty grid
grid = zeros(50, 50);

% Get pattern
pattern = pattern_library('glider');

% Place at center (default)
grid = place_pattern(grid, pattern);

% Or place at specific location (row, col)
grid = place_pattern(grid, pattern, 25, 25);
```

## Pattern Characteristics

| Pattern | Size | Type | Period/Speed | Interest Level |
|---------|------|------|--------------|----------------|
| Blinker | 3x1 | Oscillator | 2 | ★☆☆☆☆ |
| Toad | 2x4 | Oscillator | 2 | ★★☆☆☆ |
| Beacon | 4x4 | Oscillator | 2 | ★★☆☆☆ |
| Pulsar | 13x13 | Oscillator | 3 | ★★★★☆ |
| Glider | 3x3 | Spaceship | n/a | ★★★★★ |
| LWSS | 4x5 | Spaceship | n/a | ★★★☆☆ |
| Block | 2x2 | Still Life | n/a | ★☆☆☆☆ |
| Beehive | 3x4 | Still Life | n/a | ★★☆☆☆ |
| Loaf | 4x4 | Still Life | n/a | ★★☆☆☆ |
| Boat | 3x3 | Still Life | n/a | ★★☆☆☆ |
| Tub | 3x3 | Still Life | n/a | ★★☆☆☆ |
| Glider Gun | 11x38 | Gun | n/a | ★★★★★ |
| Random | Variable | Mixed | n/a | ★★★★☆ |

## Adding New Patterns

To add a new pattern to the library:

1. Open `pattern_library.m`
2. Add a new case to the switch statement
3. Define the pattern as a binary matrix (0 = dead, 1 = alive)
4. Add pattern name to the menu in `show_menu.m`

Example:
```octave
case 'my_pattern'
  % Description of pattern
  pattern = [
    0, 1, 0;
    1, 1, 1;
    0, 1, 0
  ];
```

---

**Note**: All patterns use standard Game of Life rules (B3/S23)
