# Phase 4: Pattern Library - Complete

## Overview
Phase 4 implements a comprehensive pattern library for generating initial temperature distributions in both 1D and 2D simulations. The library provides physically reasonable, pedagogically interesting, and visually distinct patterns for exploring heat diffusion behavior.

## Components Implemented

### 1. get_pattern_1d.m
**Purpose**: Generate 1D initial temperature distributions

**Available Patterns**:
- `gaussian` - Single Gaussian peak (smooth, localized heat source)
- `step` - Step function (sharp hot/cold interface)
- `double_peak` - Two separated Gaussians (multiple heat sources)
- `sine` - Sinusoidal distribution (periodic pattern)
- `random` - Random temperature field (noise)

**Features**:
- Flexible parameter customization via name-value pairs
- All patterns defined on normalized domain [0, 1]
- Interior points only (excludes boundaries for Dirichlet BC)
- Column vector output (nx × 1)

**Example Usage**:
```octave
% Default Gaussian at center
u0 = get_pattern_1d('gaussian', 100);

% Wide Gaussian at right side
u0 = get_pattern_1d('gaussian', 100, 'width', 0.2, 'center', 0.7);

% Step function at x=0.4
u0 = get_pattern_1d('step', 100, 'center', 0.4);

% Two peaks with custom positions
u0 = get_pattern_1d('double_peak', 100, 'center1', 0.25, 'center2', 0.75);
```

### 2. get_pattern_2d.m
**Purpose**: Generate 2D initial temperature distributions

**Available Patterns**:
- `center_hot` - Hot spot at center (single radial source)
- `corner_hot` - Hot corners, cold center (four sources)
- `gaussian` - 2D Gaussian peak (radially symmetric)
- `ring` - Hot ring, cold interior/exterior (annular pattern)
- `checkerboard` - Alternating hot/cold patches (2D periodic)
- `radial` - Radially symmetric gradient (cooling from center)
- `random` - Random 2D temperature field (noise)

**Features**:
- All 2D patterns on normalized domain [0,1] × [0,1]
- Matrix output (ny × nx) matching solver expectations
- Customizable centers, widths, and pattern-specific parameters
- Physically realistic temperature distributions

**Example Usage**:
```octave
% Default Gaussian at center
u0 = get_pattern_2d('gaussian', 50, 50);

% Wide Gaussian off-center
u0 = get_pattern_2d('gaussian', 50, 50, 'width', 0.2, 'center_x', 0.7);

% Ring with custom radius
u0 = get_pattern_2d('ring', 50, 50, 'ring_radius', 0.25);

% Fine checkerboard
u0 = get_pattern_2d('checkerboard', 50, 50, 'num_checks', 8);
```

### 3. pattern_menu.m
**Purpose**: Interactive pattern selector with live preview

**Features**:
- Clean menu interface listing all available patterns
- Pattern descriptions explaining physical behavior
- Optional parameter customization
- Live preview visualization (1D: line plot, 2D: heatmap)
- Returns pattern name and parameter structure

**Workflow**:
1. Display numbered menu of available patterns
2. User selects pattern by number
3. Option to customize parameters (amplitude, width, centers, etc.)
4. Generate and display preview
5. Return pattern name and parameters for use in simulation

**Example Usage**:
```octave
% Interactive 1D pattern selection
[name, params] = pattern_menu(1);
u0 = get_pattern_1d(name, 100, params);

% Interactive 2D pattern selection
[name, params] = pattern_menu(2);
u0 = get_pattern_2d(name, 50, 50, params);
```

## Pattern Parameters

### Common Parameters (Both 1D and 2D)
- `amplitude` (default: 100) - Peak temperature value
- `width` (default: 0.1) - Characteristic width of features
- `noise_level` (default: 50) - Amplitude for random patterns

### 1D-Specific Parameters
- `center` (default: 0.5) - Center position for single-peak patterns
- `center1`, `center2` (default: 0.3, 0.7) - Positions for double_peak
- `frequency` (default: 2) - Number of oscillations for sine pattern

### 2D-Specific Parameters
- `center_x`, `center_y` (default: 0.5, 0.5) - 2D center position
- `ring_radius` (default: 0.3) - Radius for ring pattern
- `num_checks` (default: 4) - Number of squares per side for checkerboard

## Physical and Pedagogical Properties

### Pattern Selection Rationale

**1D Patterns**:
- **Gaussian**: Classic localized source, demonstrates symmetric diffusion
- **Step**: Shows diffusion across sharp interfaces (smoothing effect)
- **Double Peak**: Illustrates how separate sources interact and merge
- **Sine**: Periodic initial condition, useful for Fourier analysis
- **Random**: Tests solver stability with irregular input

**2D Patterns**:
- **Center Hot**: Simplest 2D case, radial symmetry preserved
- **Corner Hot**: Demonstrates superposition and multi-source interaction
- **Gaussian**: 2D equivalent of 1D Gaussian, pedagogically clear
- **Ring**: Shows diffusion from curved sources (inward and outward)
- **Checkerboard**: High-frequency pattern that quickly smooths
- **Radial**: Gradient test case, monotonic radial decrease
- **Random**: 2D noise field for testing robustness

### Expected Diffusion Behaviors
- **Smooth patterns** (Gaussian, radial): Maintain overall shape while spreading
- **Sharp features** (step, checkerboard): Rapidly smooth out
- **Multiple sources** (double_peak, corner_hot): Merge over time
- **Symmetric patterns**: Preserve symmetry during diffusion
- **Random patterns**: Quickly average out to uniform temperature

## Testing and Validation

### Pattern Quality Checks
✓ All patterns produce physically reasonable temperatures
✓ Patterns are visually distinct and recognizable
✓ Parameter ranges validated (e.g., centers in [0,1])
✓ Patterns integrate seamlessly with core solvers
✓ Preview functionality works correctly for both dimensions

### Integration Testing
- Patterns tested with Phase 1 solvers (heat_solver_1d, heat_solver_2d)
- Visualization tested with Phase 2 display functions
- Interactive menu tested with Phase 3 control system

## Usage in Main Simulations

### Quick Pattern Generation
```octave
% 1D: Generate pattern directly
u0 = get_pattern_1d('gaussian', 100);

% 2D: Generate pattern directly
u0 = get_pattern_2d('center_hot', 50, 50);
```

### Interactive Pattern Selection
```octave
% 1D with menu
[name, params] = pattern_menu(1);
u0 = get_pattern_1d(name, 100, params);

% 2D with menu
[name, params] = pattern_menu(2);
u0 = get_pattern_2d(name, 50, 50, params);
```

### Custom Pattern Parameters
```octave
% 1D: Two narrow peaks close together
u0 = get_pattern_1d('double_peak', 200, ...
                   'amplitude', 150, ...
                   'width', 0.05, ...
                   'center1', 0.45, ...
                   'center2', 0.55);

% 2D: Large ring off-center
u0 = get_pattern_2d('ring', 100, 100, ...
                   'amplitude', 200, ...
                   'ring_radius', 0.4, ...
                   'center_x', 0.6, ...
                   'center_y', 0.4);
```

## Design Decisions

### Mathematical Foundations
- **Gaussians**: Exp(-r²/(2σ²)) provides smooth, differentiable profiles
- **Step Functions**: Heaviside-like for studying smoothing of discontinuities
- **Superposition**: Multiple Gaussians show linear combination principle
- **Normalization**: All coordinates in [0,1] for unit-independent physics

### Implementation Choices
- **Vectorized Operations**: All patterns use vectorized Octave code
- **Consistent Interface**: Name-value pairs for all optional parameters
- **Default Values**: Reasonable defaults that work well out-of-box
- **Error Handling**: Clear error messages for invalid pattern names

### User Experience
- **Descriptive Names**: Pattern names are self-explanatory
- **Menu Descriptions**: Help users understand physical meaning
- **Preview System**: Visual feedback before committing to simulation
- **Flexible Customization**: Easy defaults, optional fine-tuning

## Files Delivered

1. **get_pattern_1d.m** (108 lines)
   - Five 1D patterns
   - Seven customizable parameters
   - Input validation and error handling

2. **get_pattern_2d.m** (135 lines)
   - Seven 2D patterns
   - Eight customizable parameters
   - Proper matrix dimensioning (ny × nx)

3. **pattern_menu.m** (210 lines)
   - Interactive selection for both dimensions
   - Parameter customization interface
   - Live preview with matplotlib integration

4. **README_PHASE4.md** (this file)
   - Complete documentation
   - Usage examples
   - Physical and pedagogical rationale

## Next Steps (Phase 5)

Phase 4 is now complete. The pattern library is ready for integration into main simulation scripts. Phase 5 will focus on:

1. Creating main entry points (main_1d.m, main_2d.m)
2. Implementing validation utilities
3. Adding stability calculations
4. Comprehensive system testing
5. Final documentation and polish

## Phase 4 Status: ✓ COMPLETE

All pattern library components have been implemented and documented. The library provides:
- ✓ 5 distinct 1D patterns
- ✓ 7 distinct 2D patterns  
- ✓ Interactive pattern selection menu
- ✓ Flexible parameter customization
- ✓ Live preview functionality
- ✓ Complete documentation

The pattern library is ready for use in the complete heat diffusion simulation system.
