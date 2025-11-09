# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of GNU Octave scientific computing projects demonstrating numerical methods, simulations, and data analysis. The repository contains four main projects:

1. **game-of-life**: Conway's Game of Life cellular automaton simulator
2. **heat-diffusion**: Heat equation PDE solver using Crank-Nicolson method
3. **election-kalman-filter**: Kalman filter for 2024 US election prediction
4. **mandelbrot**: Mandelbrot & Fractal Explorer with 8 fractal types, 5 color palettes, and advanced export features

**GNU Octave Installation**: C:\Users\tranm\AppData\Local\Programs\GNU Octave\Octave-10.3.0

## Common Development Commands

### Running Projects

Each project has its own entry point. Navigate to the project directory first:

```octave
% Game of Life
cd game-of-life
game_of_life()           % Default 50x50 grid
game_of_life(75)         % Custom 75x75 grid
game_of_life([40, 60])   % Custom 40x60 grid

% Heat Diffusion
cd heat-diffusion
main_1d                  % 1D heat diffusion simulation
main_2d                  % 2D heat diffusion simulation

% Election Kalman Filter
cd election-kalman-filter/pipeline
weekly_processor()       % Run full 52-week Kalman filter

% Mandelbrot & Fractal Explorer
cd mandelbrot
fractal_explorer()            % Default 800x600 resolution
fractal_explorer([1920, 1080]) % HD resolution
fractal_explorer([400, 300])   % Smaller for 3D (faster)
colormap_gallery()            % Compare all 5 color palettes
```

### Running Tests

All projects follow a phased development approach with test files for each phase:

```octave
% Game of Life tests
cd game-of-life
test_phase1    % Core game logic
test_phase2    % Visualization
test_phase3    % Interactive controls
test_phase4    % Pattern library
test_phase5    % Save/load functionality
test_phase6    % Statistics and polish

% Heat Diffusion tests
cd heat-diffusion/tests
test_phase1    % Core PDE solvers
test_phase2    % Visualization
test_phase3    % Interactive controls
test_phase4    % Pattern library
test_phase5    % Polish and testing

% Election Kalman Filter tests
cd election-kalman-filter/tests
test_data_processing()   % Phase 1: Data processing
test_kalman_core()       % Phase 2: Kalman filter core
test_pipeline()          % Phase 3: Weekly processing
test_backtest()          % Phase 4: Backtesting
test_tuning()            % Phase 6: Parameter tuning

% Mandelbrot & Fractal Explorer tests
cd mandelbrot/tests
test_phase1    % Core fractal algorithms (Mandelbrot, Julia)
test_phase2    % Visualization and color palettes
test_phase3    % Interactive controls (zoom, pan, keyboard)
test_phase4    % Extended 2D fractals (Burning Ship, Tricorn, Multibrot, Phoenix)
test_phase5    % 3D fractals (Mandelbulb, Mandelbox)
test_phase6    % Advanced features (pattern library, bookmarks, export)

% CLI test runners (for automated/non-interactive testing)
test_phase2_cli
test_phase3_cli
test_phase4_cli
test_phase6_cli
test_data_processing_cli()
test_tuning_cli()
```

### Comprehensive Testing

```octave
% Heat Diffusion - Run all tests
cd heat-diffusion
run_all_tests

% For automated/batch testing of interactive features, use CLI test scripts
% which bypass graphics and user input requirements
```

## Project Architecture

### Game of Life

A modular Conway's Game of Life implementation with the following structure:

- **core/**: Game logic (rules, neighbor counting, toroidal boundaries)
- **display/**: Visualization (figure initialization, updates, help screen)
- **interaction/**: User controls (keyboard and mouse handlers - legacy)
- **patterns/**: Pattern library (glider, blinker, oscillators, spaceships, etc.)
- **utils/**: Utilities (statistics, save/load patterns)

**Key Design**: The main simulation loop is in `game_of_life.m` which integrates all components. Patterns are centered on the grid using `place_pattern.m`. The system uses toroidal (wrap-around) boundaries for continuous patterns. Interactive controls are handled directly in the main loop (not through separate handler files).

### Heat Diffusion

A Crank-Nicolson PDE solver for 1D and 2D heat diffusion:

- **core/**: PDE solvers (`heat_solver_1d.m`, `heat_solver_2d.m`, Laplacian matrix construction)
- **display/**: Visualization (animations for 1D/2D, static plots, multiple views)
- **interaction/**: Controls (pause/resume, speed adjustment, reset)
- **patterns/**: Initial condition library (Gaussian, step functions, hot/cold regions)
- **utils/**: Validation and diagnostics (parameter validation, stability calculations)

**Key Design**: Uses unconditionally stable Crank-Nicolson method (implicit scheme). 1D uses efficient tridiagonal solver; 2D uses sparse matrices for large grids. The system maintains Dirichlet (fixed temperature) boundary conditions at domain edges.

**Mathematical Foundation**:
```
Heat equation: ∂u/∂t = α ∇²u
Crank-Nicolson: (I - α·Δt/2 · L) u^(n+1) = (I + α·Δt/2 · L) u^n
```

### Election Kalman Filter

A Kalman filter system for election prediction using polling data:

- **data/**: Data acquisition and preprocessing (download, parse, aggregate weekly)
- **core/**: Kalman filter implementation (predict, update, initialization, adaptive noise)
- **pipeline/**: Weekly processing (polls → probability conversion, multi-poll aggregation)
- **backtest/**: Validation framework (metrics calculation, confidence intervals)
- **viz/**: Visualization (timeline plots, confidence bands, diagnostics)
- **tuning/**: Parameter optimization (grid search, cross-validation, sensitivity analysis)

**Key Design**: Models Democratic nominee win probability as state variable. Handles Biden→Harris transition (Week 38) by increasing process noise 5x for 3 weeks. Converts polling percentages to win probabilities using logistic transformation. Uses NaN propagation for missing data (prediction-only updates).

**Kalman Filter Model**:
- State (x): Democratic candidate win probability [0,1]
- Measurement (z): Poll-derived win probability
- Process noise (Q): Campaign dynamics (default 0.001)
- Measurement noise (R): Polling uncertainty (default 0.05)

**Critical Files**:
- `data/aggregate_weekly.m`: Creates 52-week dataset driving entire system
- `pipeline/weekly_processor.m`: Main entry point for full analysis
- `backtest/run_backtest.m`: Validates against actual 2024 results

### Mandelbrot & Fractal Explorer

An interactive fractal visualization system featuring 8 fractal types, 5 color palettes, and professional export capabilities:

- **core/**: Fractal algorithms (8 types: Mandelbrot, Julia, Burning Ship, Tricorn, Multibrot, Phoenix, Mandelbulb, Mandelbox)
- **display/**: Visualization (smooth coloring, 5 color palettes, 3D ray marching renderer)
- **interaction/**: User controls (zoom/pan handlers, keyboard shortcuts)
- **utils/**: Advanced features (pattern library with 24 locations, bookmarks, HD/4K export, animation generation)
- **tests/**: Comprehensive test suite (50 tests across 6 phases)

**Key Design**: Interactive explorer (`fractal_explorer.m`) integrates all components in an event-driven loop. Smooth coloring eliminates banding using continuous iteration values (mu = n + 1 - log(log(|z|))/log(2)). 3D rendering uses distance estimation with ray marching for performance. Pattern library provides 24 famous fractal locations across all types.

**Mathematical Foundation**:
```
Mandelbrot Set: z_{n+1} = z_n^2 + c, z_0 = 0
Julia Sets: z_{n+1} = z_n^2 + c (fixed c), z_0 = pixel coordinate
Burning Ship: z_{n+1} = (|Re(z_n)| + i|Im(z_n)|)^2 + c
Tricorn: z_{n+1} = conj(z_n)^2 + c
Multibrot: z_{n+1} = z_n^d + c (variable power d)
Phoenix: z_{n+1} = z_n^2 + Re(c) + Im(c) * z_{n-1}

3D Mandelbulb: Spherical coordinate transformation, power-8 formula
  DE = 0.5 * r * log(r) / dr (distance estimation)
3D Mandelbox: Box folding + sphere folding + scale/translate

Smooth coloring: mu = n + 1 - log(log(|z_n|)) / log(2)
```

**Interactive Controls**:
- Mouse: Left click = zoom in 2x, Right click = zoom out 2x
- Keyboard: 1-5 (palettes), M/J/B/T/P/X (2D fractals), V/N (3D fractals)
- Navigation: +/- (iterations), Arrows (pan), R (reset)
- Advanced: G (gallery), S (save bookmark), L (load bookmark), E (export HD/4K)

**Critical Files**:
- `fractal_explorer.m`: Main interactive application and event loop
- `core/mandelbrot_2d.m`, `core/julia_2d.m`, etc.: Individual fractal algorithms
- `display/smooth_coloring.m`: Continuous iteration formula (170x speedup via vectorization)
- `display/render_3d.m`: Ray marching renderer for 3D fractals
- `utils/pattern_library.m`: Database of 24 famous locations
- `utils/export_image.m`: HD/4K image export
- `utils/export_animation.m`: Zoom animation frame generation

## Development Patterns

### Phased Development Approach

All projects follow systematic phased development documented in `ImplementationPlan.md`:

1. **Phase 1**: Core algorithms/solvers
2. **Phase 2**: Basic visualization
3. **Phase 3**: Interactive controls
4. **Phase 4**: Pattern/data libraries
5. **Phase 5**: Polish, utilities, comprehensive testing
6. **Phase 6**: Advanced features (election-kalman-filter: parameter tuning; mandelbrot: pattern library, bookmarks, export)

Each phase has corresponding test files (`test_phase*.m`) that must pass before proceeding.

### Testing Strategy

Tests follow a consistent pattern:
- Unit tests for individual functions
- Integration tests for phase combinations
- Known analytical solutions for validation
- CLI variants (`test_*_cli.m`) for automated/non-interactive testing

Test files use:
- `fprintf()` for progress reporting
- `assert()` for validation
- Clear separation between test cases
- Summary statistics at the end

### Code Organization Standards

- 2-space indentation (Game of Life), consistent indentation across projects
- Descriptive variable names
- Comprehensive function comments with usage examples
- Modular, single-responsibility functions
- Header comments include: function purpose, inputs, outputs, usage examples

### Visualization Standards

- Clear axis labels with units
- Colorbars for temperature/density scales
- Time/generation counters
- Grid lines for readability
- Efficient updates (no figure recreation, use `imagesc()` or `surf()` updates)

### File Naming Conventions

- Main entry points: `main_*.m`, `game_of_life.m`
- Test files: `test_phase*.m`, `test_*_cli.m` (CLI variants)
- Core algorithms: descriptive names in `core/` directory
- Patterns/utilities: `get_pattern_*.m`, `calculate_*.m`, `validate_*.m`

## Important Implementation Details

### Octave-Specific Considerations

- Use `addpath()` to include directories (done at start of test scripts)
- Sparse matrices (`sparse()`) for large 2D systems
- `tic`/`toc` for performance timing
- `pause()` for animation control
- Figure handles for interactive controls
- Vectorized operations preferred over explicit loops

### Common Patterns

**Loading dependencies**:
```octave
addpath('core', 'display', 'patterns', 'utils');
```

**Animation loop pattern**:
```octave
while running
  % Update state
  % Refresh display (no figure recreation)
  % Process events
  pause(delay)
end
```

**Test structure**:
```octave
fprintf('Test %d: Description\n', test_num);
try
  % Test logic with assertions
  fprintf('  ✓ PASSED: ...\n');
  tests_passed = tests_passed + 1;
catch err
  fprintf('  ✗ FAILED: %s\n', err.message);
  tests_failed = tests_failed + 1;
end
```

### Performance Optimization

- Vectorize operations (no explicit loops over grid points)
- Pre-allocate arrays
- Use sparse matrix solvers for 2D systems
- Efficient colormap updates (don't recreate figure each frame)
- Frame skipping for real-time animation (`frame_skip` parameter)

### Known Considerations

**Game of Life**:
- Toroidal boundaries (edges wrap around)
- Static detection prevents unnecessary computation
- Save/load uses simple text format (0/1 matrix)

**Heat Diffusion**:
- Crank-Nicolson is unconditionally stable (can use large time steps)
- 2D grids >200×200 may be slow without sparse matrices
- Maximum principle: no new temperature extrema created

**Election Kalman Filter**:
- Biden→Harris transition at Week 38 (July 21, 2024)
- Polls converted to win probability via logistic transformation
- Missing weeks handled by prediction-only updates (no measurement)
- Probability bounds enforced [0,1]

**Mandelbrot & Fractal Explorer**:
- Smooth coloring eliminates banding using continuous iteration values
- 2D fractals: 800×600 renders in <1s, 1920×1080 in ~10s, 4K in <10s
- 3D fractals: Much slower, use 400×300 for interaction (~5s), 1920×1080 takes 15-40s
- Pattern library contains 24 famous locations (Seahorse Valley, Elephant Valley, etc.)
- Bookmarks saved as .mat files in bookmarks/ directory
- Export supports HD (1920×1080) and 4K (3840×2160)
- Animation export uses logarithmic interpolation for smooth zoom
- Distance estimation in 3D (Mandelbulb, Mandelbox) improves ray marching performance

## Data Files and Formats

### Game of Life

**Saved patterns** (`saved_patterns/*.txt`):
```
# Simple text matrix: 0 (dead) or 1 (alive)
0 0 0 0 0
0 0 1 0 0
0 0 1 0 0
0 0 1 0 0
0 0 0 0 0
```

### Heat Diffusion

**Pattern functions**: Return function handles for initial conditions
```octave
u0 = @(x) exp(-((x - 0.5).^2) / 0.02);  % 1D Gaussian
u0 = @(x, y) exp(-(((x-0.5).^2 + (y-0.5).^2)) / 0.04);  % 2D Gaussian
```

### Election Kalman Filter

**Weekly polls CSV** (`data/processed/weekly_polls.csv`):
```
week,week_start,week_end,dem_avg,rep_avg,dem_std,rep_std,num_polls,candidate
1,2023-11-05,2023-11-12,45.2,46.8,2.1,1.9,5,Biden
...
38,2024-07-14,2024-07-21,46.5,47.5,2.0,1.8,6,Biden
39,2024-07-21,2024-07-28,48.1,46.9,2.2,2.1,7,Harris
```

### Mandelbrot & Fractal Explorer

**Bookmark files** (`bookmarks/*.mat`):
- MATLAB .mat format containing state structures
- Fields: fractal_type, center, width, height, max_iter, palette, zoom_level
- Fractal-specific: julia_c, multibrot_power, phoenix_c, phoenix_p, mandelbulb_power, mandelbox_scale
- Metadata: timestamp, description

**Pattern library** (`utils/pattern_library.m`):
```octave
% Pattern structure:
pattern.name = 'Seahorse Valley';
pattern.fractal_type = 'mandelbrot';
pattern.center = -0.745 + 0.113i;
pattern.width = 0.01;
pattern.height = 0.01;
pattern.max_iter = 512;
pattern.description = 'Delicate seahorse shapes in spiral valley';
```

**Exported images** (`FINAL_OUTPUT/*.png`, or custom paths):
- HD: 1920×1080 pixels
- 4K: 3840×2160 pixels
- PNG format with full RGB color

**Animation frames** (custom directory, e.g., `zoom_frames/frame_*.png`):
- Sequential PNG files: frame_0001.png, frame_0002.png, ...
- Ready for ffmpeg conversion to video

## Debugging and Troubleshooting

### Common Issues

**Graphics not appearing**:
```octave
graphics_toolkit()  % Check current toolkit
```

**Path issues**:
```octave
addpath('core', 'display', 'patterns', 'utils')  % Add necessary directories
```

**Performance issues**:
- Use CLI test variants for automated testing
- Reduce grid size for faster iteration
- Use `frame_skip` parameter to reduce visualization overhead

### Filter Diagnostics (Election Kalman Filter)

```octave
cd viz
plot_diagnostics()  % Shows innovation, Kalman gain, uncertainty evolution
```

## Project Status

All four projects are feature-complete:

- **game-of-life**: ✅ All 6 phases complete (23 tests passing)
- **heat-diffusion**: ✅ All 5 phases complete (30 tests passing)
- **election-kalman-filter**: ✅ All 6 phases complete (comprehensive validation)
- **mandelbrot**: ✅ All 6 phases complete (50 tests passing)

Each project includes comprehensive tests, documentation, and example usage patterns. Refer to individual README.md files in each project directory for detailed usage instructions.

**Mandelbrot Gallery**: 6 high-resolution fractal images exported to `mandelbrot/FINAL_OUTPUT/` showcasing all major fractal types and famous locations.
