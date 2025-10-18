# Heat Diffusion PDE Solver

A simple and elegant implementation of the Heat Diffusion PDE in GNU Octave featuring both 1D and 2D simulations with real-time visualization and interactive controls.

## 🌡️ The Heat Equation

```
∂u/∂t = α ∇²u

where:
  u(x,t) or u(x,y,t) = temperature
  α = thermal diffusivity
  ∇² = Laplacian operator
```

## 📊 Project Status

| Phase | Status | Description |
|-------|--------|-------------|
| **Phase 1** | ✅ COMPLETE | Core PDE Solvers (Crank-Nicolson) |
| **Phase 2** | ✅ COMPLETE | Basic Visualization (animations & plots) |
| **Phase 3** | ⏳ TODO | Interactive Controls (keyboard/mouse) |
| **Phase 4** | ⏳ TODO | Pattern Library (initial conditions) |
| **Phase 5** | ⏳ TODO | Polish & Testing (complete system) |

## 🚀 Quick Start

### Run Tests
```bash
cd C:/Users/tranm/work/gnu-octave/heat-diffusion/tests
octave test_phase1.m  # Test core solvers
octave test_phase2.m  # Test visualizations
```

### Basic Usage

#### 1D Heat Diffusion
```octave
% Add paths
addpath('core', 'display');

% Parameters
nx = 100; L = 1.0; alpha = 0.01; dt = 0.001; t_final = 0.5;

% Initial condition (Gaussian)
x = linspace(0, L, nx)';
u0 = exp(-((x - 0.5).^2) / 0.02);

% Solve
[U, x, t] = heat_solver_1d(u0, L, alpha, dt, t_final);

% Animate
params.frame_skip = 10;
animate_1d(x, U, t, params);
```

#### 2D Heat Diffusion
```octave
% Parameters
nx = 50; ny = 50; Lx = 1.0; Ly = 1.0;
x = linspace(0, Lx, nx); y = linspace(0, Ly, ny);

% Initial condition (2D Gaussian)
[X, Y] = meshgrid(x, y);
u0 = exp(-(((X - 0.5).^2 + (Y - 0.5).^2)) / 0.04)';

% Solve
[U, x, y, t] = heat_solver_2d(u0, Lx, Ly, alpha, dt, t_final);

% Animate
params.plot_type = 'heatmap';  % or 'surface', 'contour'
params.frame_skip = 5;
animate_2d(x, y, U, t, params);
```

## 📁 Project Structure

```
heat-diffusion/
├── README.md                    # This file
├── ImplementationPlan.md        # Detailed phased development plan
├── QUICK_REFERENCE.md           # Quick reference guide
│
├── core/                        # Phase 1 ✅
│   ├── heat_solver_1d.m        # 1D Crank-Nicolson solver
│   ├── heat_solver_2d.m        # 2D Crank-Nicolson solver
│   ├── build_laplacian_matrix.m # Sparse Laplacian construction
│   └── README_PHASE1.md        # Phase 1 documentation
│
├── display/                     # Phase 2 ✅
│   ├── animate_1d.m            # Real-time 1D animation
│   ├── animate_2d.m            # Real-time 2D animation
│   ├── plot_1d_snapshot.m      # Static 1D snapshots
│   ├── plot_2d_multiple.m      # Multiple 2D views
│   └── README_PHASE2.md        # Phase 2 documentation
│
├── interaction/                 # Phase 3 ⏳ (coming next)
│   ├── setup_controls.m        # Event handlers
│   └── update_simulation.m     # Control loop
│
├── patterns/                    # Phase 4 ⏳
│   ├── get_pattern_1d.m        # 1D initial conditions
│   ├── get_pattern_2d.m        # 2D initial conditions
│   └── pattern_menu.m          # Pattern selector
│
├── utils/                       # Phase 5 ⏳
│   ├── validate_parameters.m   # Input validation
│   └── calculate_stability.m   # Diagnostics
│
└── tests/
    ├── test_phase1.m           # Core solver tests
    └── test_phase2.m           # Visualization tests
```

## ✨ Features

### Completed (Phases 1-2)

#### Core Solvers ✅
- **Crank-Nicolson method** - Unconditionally stable, 2nd-order accurate
- **1D solver** - Efficient tridiagonal system
- **2D solver** - Sparse matrices for large grids
- **Dirichlet boundaries** - Fixed temperature at boundaries

#### Visualization ✅
- **1D animations** - Smooth line plot updates (30+ fps)
- **2D animations** - Three modes: surface, heatmap, contour
- **Static plots** - Publication-quality snapshots
- **Multiple views** - Side-by-side comparison

### Coming Soon (Phases 3-5)

#### Interactive Controls ⏳
- Pause/resume simulation
- Speed adjustment
- Reset to initial condition
- Save/load states
- Temperature probing

#### Pattern Library ⏳
- Gaussian peaks
- Step functions
- Hot/cold regions
- Radial patterns
- Random fields
- Custom patterns

#### Polish & Testing ⏳
- Main entry points
- Parameter validation
- Stability diagnostics
- Comprehensive testing
- Complete documentation

## 🎯 Design Philosophy

- **Simple and elegant**: Clean, readable code
- **Modular architecture**: Organized components
- **Phased development**: Systematic implementation
- **Educational clarity**: Code teaches as it computes

## 📈 Performance

- **1D animations**: 30+ fps (up to 1000 points)
- **2D heatmaps**: 30+ fps (100×100 grids)
- **2D surfaces**: 30 fps (50×50 grids)
- **Sparse matrices**: Efficient for large domains
- **Vectorized code**: No explicit loops

## 🔧 Requirements

- **GNU Octave** 10.3.0 or later (tested)
- **MATLAB** compatibility maintained
- No external dependencies
- Standard graphics only

## 📚 Documentation

- `ImplementationPlan.md` - Complete phased development plan
- `QUICK_REFERENCE.md` - Quick reference guide
- `README_PHASE1.md` - Core solver documentation
- `README_PHASE2.md` - Visualization documentation
- `PHASE2_COMPLETE.md` - Phase 2 completion summary
- `IMPLEMENTATION_SUMMARY_PHASE2.md` - Detailed Phase 2 summary

## 🧪 Testing

Each phase includes comprehensive tests:

```bash
# Test core solvers
octave tests/test_phase1.m

# Test visualizations  
octave tests/test_phase2.m
```

All tests verify:
- Numerical accuracy
- Stability properties
- Performance metrics
- Visual correctness

## 🎓 Educational Value

This implementation:
- Shows connection between mathematics and code
- Uses industry-standard numerical methods
- Demonstrates vectorization techniques
- Includes extensive documentation
- Provides clear examples

## 📝 Default Parameters

### Physical
```octave
alpha = 0.01;      % Thermal diffusivity [m²/s]
L = 1.0;           % Domain length [m]
T_boundary = 0.0;  % Boundary temperature [°C]
```

### Numerical
```octave
nx = 100;          % Grid points (1D)
nx = 50; ny = 50;  % Grid points (2D)
dt = 0.001;        % Time step [s]
t_final = 1.0;     % Final time [s]
```

### Visualization
```octave
frame_skip = 10;   % Show every Nth frame
fps_target = 30;   % Target frame rate [Hz]
colormap = 'jet';  % Color scheme
```

## 🚦 Getting Started

1. **Clone or download** this repository
2. **Open Octave** and navigate to the directory
3. **Run tests** to verify everything works:
   ```octave
   cd tests
   test_phase1
   test_phase2
   ```
4. **Try examples** from the Quick Start section above

## 🔮 Future Enhancements

If needed:
- Neumann (insulated) boundary conditions
- Variable diffusivity (composite materials)
- Non-uniform grids
- Alternative methods (ADI for 2D)
- 3D visualization

## 👥 Development

**Current Phase**: Phase 2 Complete ✅  
**Next Phase**: Phase 3 - Interactive Controls ⏳  
**Development**: Systematic, phased approach  
**Testing**: Comprehensive at each phase

## 📄 License

Educational implementation for learning and teaching numerical methods for PDEs.

---

**Status**: 2 of 5 phases complete (40%)  
**Last Updated**: October 2025  
**Octave Version**: 10.3.0  
**MATLAB**: Compatible
