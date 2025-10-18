u0, L, alpha, dt, t_final);
animate_1d(x, U, t, struct('frame_skip', 10));

% 2D Heat Diffusion
nx = 50; ny = 50; Lx = 1.0; Ly = 1.0;
x = linspace(0, Lx, nx); y = linspace(0, Ly, ny);
[X, Y] = meshgrid(x, y);
u0 = exp(-(((X - 0.5).^2 + (Y - 0.5).^2)) / 0.04)';
[U, x, y, t] = heat_solver_2d(u0, Lx, Ly, alpha, dt, t_final);
animate_2d(x, y, U, t, struct('plot_type', 'heatmap', 'frame_skip', 5));
```

## Available Functions

### Core Solvers (Phase 1)
- `heat_solver_1d(u0, L, alpha, dt, t_final)` - 1D heat equation
- `heat_solver_2d(u0, Lx, Ly, alpha, dt, t_final)` - 2D heat equation
- `build_laplacian_matrix(nx, dx, bc_type, dimension)` - Laplacian matrix

### Visualization (Phase 2)
- `animate_1d(x, U, t, params)` - Real-time 1D animation
- `animate_2d(x, y, U, t, params)` - Real-time 2D animation
- `plot_1d_snapshot(x, U, t, time_indices, params)` - 1D snapshots
- `plot_2d_multiple(x, y, U, t, time_idx, params)` - 2D multiple views

## Common Parameters

```octave
% Animation parameters
params.frame_skip = 10;      % Show every Nth frame
params.fps_target = 30;      % Target frame rate
params.colormap = 'jet';     % Color scheme

% 2D specific
params.plot_type = 'heatmap'; % or 'surface', 'contour'
params.view_angle = [45, 30]; % Surface view angle
params.layout = 'horizontal'; % Subplot layout
```

## Next Phase: Interactive Controls

Phase 3 will implement:
- `setup_controls.m` - Event handlers
- `update_simulation.m` - Control loop

Keyboard controls (planned):
- SPACE: pause/resume
- UP/DOWN: speed adjustment  
- R: reset
- Q: quit
- S: save state
- H: help overlay

---

**Current Phase**: Phase 2 Complete ✓  
**Next Up**: Phase 3 - Interactive Controls
