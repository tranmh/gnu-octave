# Conway's Game of Life - GNU Octave Implementation

An elegant and interactive implementation of Conway's Game of Life in GNU Octave with full graphical visualization and comprehensive controls.

![Game of Life Banner](https://upload.wikimedia.org/wikipedia/commons/e/e5/Gospers_glider_gun.gif)

## Features

### Core Simulation
- **Accurate Rules**: Faithful implementation of Conway's Game of Life rules
- **Toroidal Grid**: Wrap-around boundaries for continuous patterns
- **Real-time Statistics**: Population tracking, change rates, and density metrics
- **Static Detection**: Automatic identification of stable patterns

### Interactive Controls
- **Mouse Interaction**: Click to toggle individual cells
- **Keyboard Controls**: Full keyboard interface for all operations
- **Speed Control**: Adjustable simulation speed
- **Step Mode**: Single-step through generations

### Pattern Library
Pre-loaded with classic patterns:
- **Random**: Random initial configuration
- **Glider**: Simple moving pattern
- **Blinker**: Period-2 oscillator
- **Toad**: Period-2 oscillator
- **Beacon**: Period-2 oscillator
- **Pulsar**: Period-3 oscillator
- **Gosper Glider Gun**: Generates endless gliders
- **LWSS**: Lightweight spaceship

### Persistence
- **Save Patterns**: Save your creations for later
- **Load Patterns**: Load saved patterns
- **Pattern Library**: Organized storage for custom patterns


---

## Installation

### Requirements
- **GNU Octave 10.3.0** (or compatible version)
- No additional packages required

### Setup
1. Extract or clone the repository to your local machine
2. Navigate to the `game-of-life` directory in Octave

```octave
cd C:\Users\tranm\work\gnu-octave\game-of-life
```

---

## Usage

### Starting the Game

#### Default 50x50 Grid
```octave
game_of_life()
```

#### Custom Square Grid
```octave
game_of_life(75)  % 75x75 grid
```

#### Custom Rectangular Grid
```octave
game_of_life([40, 60])  % 40 rows, 60 columns
```

### Pattern Selection

When you start the game, you'll see a pattern selection menu:

```
═══════════════════════════════════════════════
      CONWAY'S GAME OF LIFE - PATTERN MENU
═══════════════════════════════════════════════
1. Random - Random initial state
2. Glider - Simple diagonal mover
3. Blinker - Period-2 oscillator
4. Toad - Period-2 oscillator
5. Beacon - Period-2 oscillator
6. Pulsar - Period-3 oscillator
7. Gosper Glider Gun - Generates gliders
8. LWSS - Lightweight Spaceship
═══════════════════════════════════════════════
Enter pattern number (1-8):
```

---

## Controls Reference

### Keyboard Controls

| Key | Action |
|-----|--------|
| `SPACE` | Pause/Resume simulation |
| `S` | Single step forward (when paused) |
| `R` | Reset to initial pattern |
| `C` | Clear all cells |
| `+` | Increase simulation speed |
| `-` | Decrease simulation speed |
| `H` | Display help screen |
| `Q` | Quit simulation |
| `Ctrl+S` | Save current pattern |
| `Ctrl+L` | Load saved pattern |
| `L` | List available saved patterns |

### Mouse Controls

| Action | Effect |
|--------|--------|
| **Left Click** | Toggle cell between alive/dead |

*Note: Clicking automatically pauses the simulation for editing*

---

## Display Information

The simulation window displays comprehensive statistics:


### Statistics Panel

- **Generation**: Current generation number (updates each step)
- **Population**: Number of living cells (with change indicator)
- **Density**: Percentage of grid occupied by living cells
- **Status**: Current simulation state
  - 🟢 `Running` - Simulation in progress
  - 🟡 `Paused` - Simulation paused
  - 🔵 `Static` - No changes detected (auto-paused)
  - `Editing` - User is modifying cells

---

## Game Rules

Conway's Game of Life follows three simple rules:

1. **Survival**: Any live cell with 2 or 3 living neighbors survives
2. **Birth**: Any dead cell with exactly 3 living neighbors becomes alive
3. **Death**: All other cells die or remain dead

### Boundary Conditions
The grid uses **toroidal topology** (wrap-around edges), meaning:
- The top edge connects to the bottom edge
- The left edge connects to the right edge
- This allows patterns to move continuously without hitting walls

---

## File Structure

```
game-of-life/
├── README.md                       # This file
├── ImplementationPlan.md          # Development roadmap
├── game_of_life.m                  # Main entry point
│
├── core/                           # Game logic
│   ├── gameoflife_rules.m         # Apply Conway's rules
│   ├── count_neighbors.m          # Count living neighbors
│   └── apply_toroidal_boundary.m  # Handle wrap-around
│
├── display/                        # Visualization
│   ├── init_display.m              # Create figure window
│   ├── update_display.m           # Refresh visualization
│   └── display_help.m             # Show help screen
│
├── interaction/                    # User input
│   ├── handle_mouse_click.m       # Mouse input (legacy)
│   └── handle_keyboard.m          # Keyboard input (legacy)
│
├── patterns/                       # Pattern library
│   ├── pattern_library.m          # Collection of patterns
│   ├── place_pattern.m            # Center patterns on grid
│   └── show_menu.m                # Pattern selection menu
│
├── utils/                          # Utilities
│   ├── calculate_stats.m          # Population statistics
│   ├── save_pattern.m             # Save patterns to file
│   ├── load_pattern.m             # Load patterns from file
│   └── list_saved_patterns.m      # List available patterns
│
└── saved_patterns/                 # User-saved patterns
    └── (your custom patterns)
```

---

## Pattern Examples

### Still Lifes (Static Patterns)
These patterns remain unchanged:
- **Block**: 2×2 square of cells
- **Beehive**: 6 cells in hexagonal arrangement

### Oscillators (Repeating Patterns)
These patterns cycle through states:
- **Blinker**: Period 2 (alternates horizontal/vertical)
- **Toad**: Period 2 (expanding/contracting)
- **Beacon**: Period 2 (flashing corners)
- **Pulsar**: Period 3 (complex pulsing)

### Spaceships (Moving Patterns)
These patterns travel across the grid:
- **Glider**: Moves diagonally, period 4
- **LWSS**: Moves horizontally, period 4


### Methuselahs (Long-Lived Patterns)
Small patterns that take many generations to stabilize:
- **R-pentomino**: 5 cells, stabilizes after 1103 generations

### Guns (Pattern Generators)
Patterns that continuously produce other patterns:
- **Gosper Glider Gun**: Produces gliders infinitely

---

## Saving and Loading Patterns

### Saving Your Creation

1. Pause the simulation (`SPACE`)
2. Press `Ctrl+S`
3. Enter a name for your pattern
4. Pattern saved to `saved_patterns/` directory

```octave
Enter pattern name: my_awesome_pattern
Pattern saved successfully to: saved_patterns/my_awesome_pattern.txt
```

### Loading a Saved Pattern

1. Press `Ctrl+L`
2. You'll see a list of available patterns
3. Enter the pattern name (without .txt extension)
4. Pattern loads and grid resets

### Listing Available Patterns

Press `L` to see all saved patterns in the console.

---

## Tips and Tricks

### Observation Tips
- Use **pause** (`SPACE`) and **single-step** (`S`) to study pattern behavior
- Adjust **speed** (`+`/`-`) to observe fast-moving patterns like gliders
- Watch the **population counter** for oscillator period detection

### Creating Patterns
- **Click cells** to draw your own patterns
- Start with **clear grid** (`C`) for a blank canvas
- Use **reset** (`R`) to restore the original pattern if you make mistakes
- **Save** (`Ctrl+S`) interesting discoveries for later

### Performance
- Larger grids (100×100+) may have slower frame rates
- Reduce speed delay if the simulation feels sluggish
- Close other Octave figure windows for better performance

### Interesting Experiments
- Place multiple gliders heading toward each other
- Observe glider collisions and emergent patterns
- Try random patterns on large grids to see what evolves
- Combine multiple small patterns to create complex behaviors

---

## Technical Details

### Implementation
- **Language**: GNU Octave (MATLAB-compatible)
- **Graphics**: Built-in Octave plotting functions
- **Algorithm**: Vectorized matrix operations for efficiency
- **Grid Type**: Toroidal (wrap-around) topology

### Performance Characteristics
- **Grid Updates**: O(n×m) where n×m is grid size
- **Neighbor Counting**: Vectorized convolution-based approach
- **Display**: Efficient `imagesc()` rendering
- **Memory**: Minimal - two grids stored (current + previous)

### Code Organization
- **Modular Design**: Separate files for each functionality
- **Clean Separation**: Core logic, display, interaction, and utilities
- **Extensibility**: Easy to add new patterns or features

---

## Troubleshooting

### Issue: Figure Window Doesn't Appear
**Solution**: Check that you have graphics enabled in Octave
```octave
graphics_toolkit()  % Should show current graphics toolkit
```

### Issue: Keyboard Controls Not Working
**Solution**: Make sure the figure window has focus (click on it)

### Issue: Patterns Look Wrong
**Solution**: Verify Octave version is compatible (10.x recommended)

### Issue: Simulation Runs Too Fast/Slow
**Solution**: Use `+` and `-` keys to adjust speed during runtime

### Issue: Can't Save Patterns
**Solution**: Ensure `saved_patterns/` directory exists and is writable

---

## Development

### Running Tests

Individual phase tests are available:
```octave
test_phase1  % Test core game logic
test_phase2  % Test visualization
test_phase3  % Test interactive controls
test_phase4  # Test pattern library
test_phase5  % Test save/load
test_phase6  % Test statistics and polish
```

### Code Standards
- 2-space indentation
- Descriptive variable names
- Comprehensive function comments
- Modular, single-responsibility functions

---

## About Conway's Game of Life

Conway's Game of Life, created by mathematician John Horton Conway in 1970, is a cellular automaton that demonstrates how complex patterns can emerge from simple rules. Despite its name, it's not a traditional game with players—it's a zero-player game where evolution is determined entirely by the initial state.

### Mathematical Properties
- **Turing Complete**: Can simulate any computation
- **Emergence**: Complex behavior from simple rules  
- **Self-Organization**: Patterns organize without external direction
- **Unpredictability**: Long-term behavior is computationally irreducible

### Cultural Impact
The Game of Life has influenced:
- Computer science (cellular automata theory)
- Artificial life research
- Complexity science
- Art and recreational mathematics

---

## References

- [Wikipedia: Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)
- [LifeWiki](https://conwaylife.com/wiki/Main_Page) - Comprehensive pattern database
- [Original Scientific American Article](https://web.archive.org/web/20090603015231/http://ddi.cs.uni-potsdam.de/HyFISCH/Produzieren/lis_projekt/proj_gamelife/ConwayScientificAmerican.htm)

---

## License

This implementation is provided as-is for educational and recreational purposes.

---

## Credits

**Implementation**: GNU Octave Game of Life Project  
**Algorithm**: John Horton Conway (1970)  
**Platform**: GNU Octave 10.3.0  
**Created**: October 2025

---

## Version History

- **v1.0** (October 2025): Initial release with all features

---

*Enjoy exploring the fascinating world of cellular automata!* 🎮✨

