function [u_history, x, y, t] = heat_solver_2d(u0, alpha, Lx, Ly, T_boundary, nx, ny, dt, t_final)
  % HEAT_SOLVER_2D - Solve 2D heat diffusion equation using Crank-Nicolson method
  %
  % Syntax:
  %   [u_history, x, y, t] = heat_solver_2d(u0, alpha, Lx, Ly, T_boundary, nx, ny, dt, t_final)
  %
  % Inputs:
  %   u0         - Initial temperature distribution (function handle or matrix)
  %                If function: u0(x,y) returns initial temperature
  %                If matrix: must be size (nx × ny)
  %   alpha      - Thermal diffusivity [m²/s] (positive scalar)
  %   Lx, Ly     - Domain dimensions [m] (positive scalars)
  %   T_boundary - Boundary temperature [°C] (scalar, all edges)
  %   nx, ny     - Number of interior grid points in x and y (positive integers)
  %   dt         - Time step [s] (positive scalar)
  %   t_final    - Final simulation time [s] (positive scalar)
  %
  % Outputs:
  %   u_history - Temperature evolution: (nx × ny × nt) array
  %               u_history(:,:,k) is 2D temperature field at time step k
  %   x, y      - Spatial grid points [m]: (nx × 1) and (ny × 1) vectors
  %   t         - Time points [s]: (nt × 1) vector
  %
  % Description:
  %   Solves the 2D heat equation:
  %     ∂u/∂t = α (∂²u/∂x² + ∂²u/∂y²) = α ∇²u
  %   on domain [0,Lx] × [0,Ly] with Dirichlet boundary conditions
  %
  %   Uses Crank-Nicolson with sparse matrices:
  %     (I - r/2 * L_mat) u^(n+1) = (I + r/2 * L_mat) u^n + boundary terms
  %   where r = α*dt/h² and L_mat is the 2D discrete Laplacian
  %
  %   Uses lexicographic ordering: 2D grid (i,j) -> 1D vector index k
  %   where k = i + (j-1)*nx
  %
  % Stability:
  %   Unconditionally stable (implicit method)
  %   For accuracy, typically want r = α*dt/h² < 1/4 (2D requirement)
  %
  % Example:
  %   % Gaussian hot spot at center
  %   u0 = @(x,y) 100 * exp(-100*((x-0.5).^2 + (y-0.5).^2));
  %   [u_history, x, y, t] = heat_solver_2d(u0, 0.01, 1, 1, 0, 50, 50, 0.001, 0.5);
  %   surf(x, y, u_history(:,:,end)');
  %
  % Phase: 1 - Core PDE Solvers

  % Input validation
  if nargin < 9
    error('heat_solver_2d: Requires 9 input arguments');
  end
  
  if ~isnumeric(alpha) || alpha <= 0
    error('heat_solver_2d: alpha must be positive');
  end
  
  if ~isnumeric(Lx) || Lx <= 0 || ~isnumeric(Ly) || Ly <= 0
    error('heat_solver_2d: Lx and Ly must be positive');
  end
  
  if ~isnumeric(T_boundary)
    error('heat_solver_2d: T_boundary must be numeric');
  end
  
  if ~isnumeric(nx) || nx < 2 || mod(nx, 1) ~= 0
    error('heat_solver_2d: nx must be integer >= 2');
  end
  
  if ~isnumeric(ny) || ny < 2 || mod(ny, 1) ~= 0
    error('heat_solver_2d: ny must be integer >= 2');
  end
  
  if ~isnumeric(dt) || dt <= 0
    error('heat_solver_2d: dt must be positive');
  end
  
  if ~isnumeric(t_final) || t_final <= 0
    error('heat_solver_2d: t_final must be positive');
  end
  
  % Grid setup (assuming uniform spacing: dx = dy = h)
  dx = Lx / (nx + 1);
  dy = Ly / (ny + 1);
  h = (dx + dy) / 2;  % Average spacing (for stability estimate)
  
  x = linspace(dx, Lx - dx, nx)';
  y = linspace(dy, Ly - dy, ny)';
  
  % Time setup
  nt = ceil(t_final / dt) + 1;
  t = linspace(0, t_final, nt)';
  dt = t(2) - t(1);  % Adjust to fit exactly
  
  % Initialize solution
  if isa(u0, 'function_handle')
    % Evaluate function on 2D grid
    [X, Y] = meshgrid(x, y);
    U_init = u0(X, Y);
    u_current_2d = U_init';  % Transpose to get (nx × ny) orientation
  elseif ismatrix(u0) && size(u0, 1) == nx && size(u0, 2) == ny
    u_current_2d = u0;
  else
    error('heat_solver_2d: u0 must be function handle or matrix of size (nx × ny)');
  end
  
  % Convert 2D grid to 1D vector (lexicographic ordering)
  % u_vec(k) corresponds to u_2d(i,j) where k = i + (j-1)*nx
  u_current = reshape(u_current_2d, nx * ny, 1);
  
  % Preallocate output (store as 3D array for convenience)
  u_history = zeros(nx, ny, nt);
  u_history(:, :, 1) = u_current_2d;
  
  % Stability parameter
  r = alpha * dt / (h^2);
  
  % Display warning if r > 0.25 (2D accuracy guideline)
  if r > 0.25
    warning('heat_solver_2d: r = %.3f > 0.25. Consider smaller dt for better accuracy.', r);
  end
  
  % Build 2D discrete Laplacian matrix (sparse)
  L_mat = build_laplacian_matrix('2d', nx, ny);
  
  % Adjust Laplacian for non-uniform grid (if dx ≠ dy)
  % For simplicity, we assume dx ≈ dy; generalization would scale different directions
  
  % Crank-Nicolson matrices
  N = nx * ny;
  I = speye(N);
  A_left = I - (r / 2) * L_mat;
  A_right = I + (r / 2) * L_mat;
  
  % Boundary contribution vector
  % For each interior point, check if it's adjacent to a boundary
  boundary_contrib = zeros(N, 1);
  
  for j = 1:ny
    for i = 1:nx
      k = i + (j - 1) * nx;
      
      % Left boundary (i=0): affects points with i=1
      if i == 1
        boundary_contrib(k) = boundary_contrib(k) + r * T_boundary;
      end
      
      % Right boundary (i=nx+1): affects points with i=nx
      if i == nx
        boundary_contrib(k) = boundary_contrib(k) + r * T_boundary;
      end
      
      % Bottom boundary (j=0): affects points with j=1
      if j == 1
        boundary_contrib(k) = boundary_contrib(k) + r * T_boundary;
      end
      
      % Top boundary (j=ny+1): affects points with j=ny
      if j == ny
        boundary_contrib(k) = boundary_contrib(k) + r * T_boundary;
      end
    end
  end
  
  % Time stepping loop
  for n = 2:nt
    % Right-hand side
    rhs = A_right * u_current + boundary_contrib;
    
    % Solve sparse linear system
    % Octave automatically uses efficient sparse solvers
    u_current = A_left \ rhs;
    
    % Convert back to 2D grid and store
    u_current_2d = reshape(u_current, nx, ny);
    u_history(:, :, n) = u_current_2d;
  end
end
