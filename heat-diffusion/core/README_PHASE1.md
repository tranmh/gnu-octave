# Phase 1: Core PDE Solvers - Completion Summary

## Overview
Phase 1 implements the fundamental numerical methods for solving the heat diffusion equation in both 1D and 2D using the Crank-Nicolson method. This phase establishes the mathematical foundation for the entire project.

## Implemented Components

### 1. build_laplacian_matrix.m
**Purpose**: Constructs discrete Laplacian operators for 1D and 2D domains

**Features**:
- **1D**: Efficient tridiagonal matrix using `spdiags`
- **2D**: Five-point stencil with lexicographic ordering
- **Sparse matrices**: Memory-efficient for large grids
- **Dirichlet boundaries**: Fixed temperatures at domain edges

**Mathematical Foundation**:
- 1D stencil: `[-1, 2, -1] / dx²`
- 2D stencil: Five-point star pattern for `∇²u`

### 2. heat_solver_1d.m
**Purpose**: Solve 1D heat equation: `∂u/∂t = α ∂²u/∂x²`

**Features**:
- **Crank-Nicolson method**: Unconditionally stable, O(dt², dx²) accuracy
- **Flexible input**: Function handles or vectors for initial conditions
- **Efficient**: Tridiagonal solver via backslash operator
- **Validated**: Comprehensive input checking with helpful error messages
- **Performance warnings**: Alerts for potentially inaccurate parameter choices

**Key Parameters**:
- Stability parameter: `r = α*dt/dx²`
- Recommended: `r < 0.5` for best accuracy

### 3. heat_solver_2d.m
**Purpose**: Solve 2D heat equation: `∂u/∂t = α ∇²u`

**Features**:
- **Sparse matrices**: Handles large grids (100×100 and beyond)
- **Vectorized operations**: Converts 2D grid to 1D vector for solving
- **Lexicographic ordering**: Systematic indexing: `k = i + (j-1)*nx`
- **3D output**: Easy visualization with `u_history(:,:,n)` format
- **Boundary handling**: All four edges maintained at specified temperature

**Key Parameters**:
- Stability parameter: `r = α*dt/h²`
- Recommended: `r < 0.25` for 2D accuracy (more restrictive than 1D)

## Testing Results

### Test Suite: test_phase1.m
Comprehensive validation covering 8 distinct test categories:

1. **✓ 1D Laplacian Construction**: Verifies correct tridiagonal structure
2. **✓ 2D Laplacian Construction**: Validates five-point stencil and dimensions
3. **✓ Analytical Comparison (1D)**: Tests against exponential decay solution
4. **✓ Symmetry Preservation (2D)**: Confirms symmetric solutions remain symmetric
5. **✓ Maximum Principle**: No spurious extrema created during evolution
6. **✓ Unconditional Stability**: Remains stable with large time steps
7. **✓ Grid Convergence**: Solution improves with refinement
8. **✓ Performance Benchmark**: 100×100 grid completes in reasonable time

### Key Validation Metrics
- **Analytical accuracy**: < 1% relative error for known solutions
- **Symmetry preservation**: < 1% deviation for symmetric initial conditions
- **Stability**: No numerical blow-up even with `r >> 1`
- **Performance**: 100×100 2D grid, 100 time steps completes in ~5-30 seconds

## Usage Examples

### 1D Heat Diffusion
```octave
% Add core directory to path
addpath('core');

% Define initial condition - Gaussian pulse
u0 = @(x) 100 * exp(-100 * (x - 0.5).^2);

% Physical parameters
alpha = 0.01;        % Thermal diffusivity [m²/s]
L = 1.0;             % Domain length [m]
T_boundary = 0.0;    % Boundary temperature [°C]

% Numerical parameters
nx = 100;            % Interior grid points
dt = 0.001;          % Time step [s]
t_final = 1.0;       % Final time [s]

% Solve
[u_history, x, t] = heat_solver_1d(u0, alpha, L, T_boundary, nx, dt, t_final);

% Visualize
plot(x, u_history(:,1), 'b-', 'LineWidth', 2);  % Initial
hold on;
plot(x, u_history(:,end), 'r-', 'LineWidth', 2);  % Final
xlabel('Position [m]');
ylabel('Temperature [°C]');
legend('Initial', 'Final');
title('1D Heat Diffusion');
grid on;
```

### 2D Heat Diffusion
```octave
% Add core directory to path
addpath('core');

% Define initial condition - Hot spot at center
u0 = @(x,y) 100 * exp(-100 * ((x-0.5).^2 + (y-0.5).^2));

% Physical parameters
alpha = 0.01;        % Thermal diffusivity [m²/s]
Lx = 1.0;            % Domain length in x [m]
Ly = 1.0;            % Domain length in y [m]
T_boundary = 0.0;    % Boundary temperature [°C]

% Numerical parameters
nx = 50;             % Grid points in x
ny = 50;             % Grid points in y
dt = 0.001;          % Time step [s]
t_final = 0.5;       % Final time [s]

% Solve
[u_history, x, y, t] = heat_solver_2d(u0, alpha, Lx, Ly, T_boundary, nx, ny, dt, t_final);

% Visualize - Surface plot
[X, Y] = meshgrid(x, y);
surf(X, Y, u_history(:,:,end)');
xlabel('x [m]');
ylabel('y [m]');
zlabel('Temperature [°C]');
title('2D Heat Diffusion - Final State');
colorbar;
shading interp;
```

## Mathematical Details

### Crank-Nicolson Method
The scheme averages explicit and implicit Euler methods:

```
(I - (α*dt/2) * L) u^(n+1) = (I + (α*dt/2) * L) u^n + boundary_terms

where:
- I: Identity matrix
- L: Discrete Laplacian operator
- u^n: Solution at time step n
- α: Thermal diffusivity
- dt: Time step
```

**Properties**:
- **Unconditionally stable**: No CFL restriction on dt
- **Second-order accurate**: O(dt², dx²) convergence
- **Implicit**: Requires solving linear system each step
- **Tridiagonal (1D)**: Very efficient direct solve
- **Sparse (2D)**: Iterative or direct sparse solvers

### Discrete Laplacian

**1D**:
```
L * u = [u(i-1) - 2*u(i) + u(i+1)] / dx²
```

Matrix form (5 points example):
```
[-2  1  0  0  0]   [u1]
[ 1 -2  1  0  0]   [u2]
[ 0  1 -2  1  0] * [u3]
[ 0  0  1 -2  1]   [u4]
[ 0  0  0  1 -2]   [u5]
```

**2D**:
```
L * u = [u(i-1,j) + u(i+1,j) + u(i,j-1) + u(i,j+1) - 4*u(i,j)] / h²
```

Five-point stencil:
```
     [0  1  0]
     [1 -4  1]
     [0  1  0]
```

### Boundary Conditions
Dirichlet (fixed temperature) boundaries implemented by:
1. Solving only for interior points
2. Adding boundary contributions to right-hand side
3. Maintaining boundary values constant throughout simulation

## Performance Characteristics

### 1D Solver
- **Complexity**: O(nx * nt) for tridiagonal solve
- **Memory**: O(nx * nt) for storing history
- **Typical performance**: 1000 points, 1000 steps → ~1 second

### 2D Solver
- **Complexity**: O(N log N * nt) where N = nx * ny (sparse solver)
