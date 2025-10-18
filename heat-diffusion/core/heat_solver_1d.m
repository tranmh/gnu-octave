function [u_history, x, t] = heat_solver_1d(u0, alpha, L, T_boundary, nx, dt, t_final)
  % HEAT_SOLVER_1D - Solve 1D heat diffusion equation using Crank-Nicolson method
  %
  % Syntax:
  %   [u_history, x, t] = heat_solver_1d(u0, alpha, L, T_boundary, nx, dt, t_final)
  %
  % Inputs:
  %   u0         - Initial temperature distribution (function handle or vector)
  %                If function: u0(x) returns initial temperature
  %                If vector: must have length nx
  %   alpha      - Thermal diffusivity [m²/s] (positive scalar)
  %   L          - Domain length [m] (positive scalar)
  %   T_boundary - Boundary temperature [°C] (scalar, both ends)
  %   nx         - Number of interior grid points (positive integer)
  %   dt         - Time step [s] (positive scalar)
  %   t_final    - Final simulation time [s] (positive scalar)
  %
  % Outputs:
  %   u_history - Temperature evolution: (nx × nt) matrix
  %               u_history(:,k) is temperature at time step k
  %   x         - Spatial grid points [m]: (nx × 1) vector (interior only)
  %   t         - Time points [s]: (nt × 1) vector
  %
  % Description:
  %   Solves the 1D heat equation:
  %     ∂u/∂t = α ∂²u/∂x²
  %   on domain [0, L] with Dirichlet boundary conditions:
  %     u(0,t) = u(L,t) = T_boundary
  %
  %   Uses the Crank-Nicolson method (implicit, unconditionally stable):
  %     (I - r/2 * L_mat) u^(n+1) = (I + r/2 * L_mat) u^n + boundary terms
  %   where r = α*dt/dx² and L_mat is the discrete Laplacian
  %
  % Stability:
  %   Unconditionally stable (implicit method)
  %   For accuracy, typically want r = α*dt/dx² < 1/2
  %
  % Example:
  %   % Gaussian initial condition
  %   u0 = @(x) 100 * exp(-100*(x-0.5).^2);
  %   [u_history, x, t] = heat_solver_1d(u0, 0.01, 1.0, 0, 100, 0.001, 1.0);
  %   plot(x, u_history(:,1), x, u_history(:,end));
  %
  % Phase: 1 - Core PDE Solvers

  % Input validation
  if nargin < 7
    error('heat_solver_1d: Requires 7 input arguments');
  end
  
  if ~isnumeric(alpha) || alpha <= 0
    error('heat_solver_1d: alpha must be positive');
  end
  
  if ~isnumeric(L) || L <= 0
    error('heat_solver_1d: L must be positive');
  end
  
  if ~isnumeric(T_boundary)
    error('heat_solver_1d: T_boundary must be numeric');
  end
  
  if ~isnumeric(nx) || nx < 2 || mod(nx, 1) ~= 0
    error('heat_solver_1d: nx must be integer >= 2');
  end
  
  if ~isnumeric(dt) || dt <= 0
    error('heat_solver_1d: dt must be positive');
  end
  
  if ~isnumeric(t_final) || t_final <= 0
    error('heat_solver_1d: t_final must be positive');
  end
  
  % Grid setup
  dx = L / (nx + 1);              % Spatial step (nx interior + 2 boundary points)
  x = linspace(dx, L - dx, nx)';  % Interior grid points only
  
  % Time setup
  nt = ceil(t_final / dt) + 1;    % Number of time steps
  t = linspace(0, t_final, nt)';
  dt = t(2) - t(1);               % Adjust dt to fit exactly into t_final
  
  % Initialize solution
  if isa(u0, 'function_handle')
    u_current = u0(x);            % Evaluate function at grid points
  elseif isvector(u0) && length(u0) == nx
    u_current = u0(:);            % Ensure column vector
  else
    error('heat_solver_1d: u0 must be function handle or vector of length nx');
  end
  
  % Preallocate output
  u_history = zeros(nx, nt);
  u_history(:, 1) = u_current;
  
  % Stability parameter
  r = alpha * dt / (dx^2);
  
  % Display warning if r > 0.5 (may affect accuracy, though still stable)
  if r > 0.5
    warning('heat_solver_1d: r = %.3f > 0.5. Consider smaller dt for better accuracy.', r);
  end
  
  % Build discrete Laplacian matrix
  L_mat = build_laplacian_matrix('1d', nx);
  
  % Crank-Nicolson matrices
  % Left side:  (I - r/2 * L_mat) * u^(n+1)
  % Right side: (I + r/2 * L_mat) * u^n + boundary_terms
  I = speye(nx);
  A_left = I - (r / 2) * L_mat;
  A_right = I + (r / 2) * L_mat;
  
  % Boundary contribution vector (constant for fixed Dirichlet BCs)
  % At left boundary (i=0): affects first interior point (i=1)
  % At right boundary (i=nx+1): affects last interior point (i=nx)
  boundary_contrib = zeros(nx, 1);
  boundary_contrib(1) = boundary_contrib(1) + r * T_boundary;   % Left boundary
  boundary_contrib(nx) = boundary_contrib(nx) + r * T_boundary; % Right boundary
  
  % Time stepping loop
  for n = 2:nt
    % Right-hand side: A_right * u^n + boundary_contrib
    rhs = A_right * u_current + boundary_contrib;
    
    % Solve linear system: A_left * u^(n+1) = rhs
    % The backslash operator efficiently solves tridiagonal systems
    u_current = A_left \ rhs;
    
    % Store solution
    u_history(:, n) = u_current;
  end
end
