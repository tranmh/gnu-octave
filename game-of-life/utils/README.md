# Utils Directory

This directory contains utility functions for the Game of Life implementation.

## Files

### `save_pattern.m`
Saves the current grid state to a file in the `saved_patterns/` directory.

**Usage**:
```octave
success = save_pattern(grid, 'my_pattern.txt');
```

**Features**:
- Simple text format (0 for dead, 1 for alive)
- Automatic .txt extension
- Creates saved_patterns directory if needed
- Includes metadata header with size and timestamp

### `load_pattern.m`
Loads a pattern from a file in the `saved_patterns/` directory.

**Usage**:
```octave
% Load at original size
[grid, success] = load_pattern('my_pattern.txt');

% Load centered on specific grid size
[grid, success] = load_pattern('my_pattern.txt', 50, 50);
```

**Features**:
- Optional centering on target grid size
- Skips comment lines
- Validates data consistency
- Returns both grid and success status

### `list_saved_patterns.m`
Lists all available pattern files in the `saved_patterns/` directory.

**Usage**:
```octave
files = list_saved_patterns();
for i = 1:length(files)
  fprintf('%d. %s\n', i, files{i});
endfor
```

**Features**:
- Returns alphabetically sorted list
- Returns empty array if no patterns found
- Useful for pattern selection menus

### `calculate_stats.m` *(Coming in Phase 6)*
Will track population statistics including:
- Current population count
- Population change rate
- Generation count

## File Format

Saved patterns use a simple text format:

```
% Game of Life Pattern
% Size: 5x5
% Saved: 15-Oct-2025 10:30:45
%
0 1 0 1 0
1 1 1 0 1
0 0 1 1 0
1 0 0 0 1
0 1 1 1 0
```

- Lines starting with `%` are comments (skipped when loading)
- Each row is one line
- 0 = dead cell, 1 = alive cell
- Cells separated by spaces

## Integration Example

```octave
% Add utils to path
addpath(fullfile(pwd, 'utils'));

% Save current state
if save_pattern(grid, 'interesting_pattern.txt')
  disp('Saved!');
endif

% Load it back later
[grid, success] = load_pattern('interesting_pattern.txt', 50, 50);
if success
  disp('Loaded and centered!');
endif

% Browse available patterns
files = list_saved_patterns();
disp(files);
```

## Notes

- All patterns are saved to `../saved_patterns/` relative to this directory
- The directory is automatically created if it doesn't exist
- Patterns can be shared by copying the .txt files
- File format is human-readable for easy editing
