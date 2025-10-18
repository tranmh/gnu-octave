function L = build_laplacian_matrix(dim, nx, ny)
  % BUILD_LAPLACIAN_MATRIX - Construct sparse Laplacian matrix for heat equation
  %
  % Syntax:
  %   L = build_laplacian_matrix('1d', nx)
  %   L = build_laplacian_matrix('2d', nx, ny)
  %
  % Inputs:
  %   dim - Dimension: '1d' or '2d'
  %   nx  - Number of interior grid points in x-direction
  %   ny  - Number of interior grid points in y-direction (2D only)
  %
  % Output:
  %   L - Sparse Laplacian matrix with Dirichlet boundary conditions
  %
  % Description:
  %   Constructs discrete Laplacian operator using central differences:
  %   - 1D: Three-point stencil [-1, 2, -1] / dx²
  %   - 2D: Five-point stencil for ∂²/∂x² + ∂²/∂y²
  %
  %   Boundary conditions (Dirichlet): Fixed temperature at boundaries
  %   Interior points only - boundaries handled separately
  %
  % Mathematical Foundation:
  %   1D: d²u/dx² ≈ (u(i-1) - 2u(i) + u(i+1)) / dx²
  %   2D: ∇²u ≈ (u(i-1,j) + u(i+1,j) + u(i,j-1) + u(i,j+1) - 4u(i,j)) / h²
  %
  % Example:
  %   L = build_laplacian_matrix('1d', 100);
  %   L = build_laplacian_matrix('2d', 50, 50);
  %
  % Phase: 1 - Core PDE Solvers

  % Input validation
  if ~ischar(dim) || ~ismember(dim, {'1d', '2d'})
    error('build_laplacian_matrix: dim must be ''1d'' or ''2d''');
  end
  
  if nargin < 2 || ~isnumeric(nx) || nx < 2
    error('build_laplacian_matrix: nx must be numeric and >= 2');
  end
  
  if strcmp(dim, '1d')
    L = build_laplacian_1d(nx);
  else  % '2d'
    if nargin < 3 || ~isnumeric(ny) || ny < 2
      error('build_laplacian_matrix: ny must be numeric and >= 2');
    end
    L = build_laplacian_2d(nx, ny);
  end
end


function L = build_laplacian_1d(nx)
  % 1D Laplacian: Tridiagonal matrix
  % For interior points i = 1, 2, ..., nx (boundaries at i=0 and i=nx+1)
  %
  % L * u = [u(i-1) - 2*u(i) + u(i+1)] / dx²
  %
  % Matrix structure:
  % [-2  1  0  0 ...]
  % [ 1 -2  1  0 ...]
  % [ 0  1 -2  1 ...]
  % [      ...      ]
  %
  % Note: We don't divide by dx² here - that's handled in the solver
  
  % Main diagonal: -2
  main_diag = -2 * ones(nx, 1);
  
  % Off-diagonals: 1 (padded to length nx for spdiags)
  off_diag_lower = [ones(nx - 1, 1); 0];
  off_diag_upper = [0; ones(nx - 1, 1)];
  
  % Construct sparse tridiagonal matrix
  L = spdiags([off_diag_lower, main_diag, off_diag_upper], [-1, 0, 1], nx, nx);
end


function L = build_laplacian_2d(nx, ny)
  % 2D Laplacian: Five-point stencil on Cartesian grid
  % For interior points (i,j) where i=1..nx, j=1..ny
  % Boundaries at i=0, i=nx+1, j=0, j=ny+1
  %
  % L * u = [u(i-1,j) + u(i+1,j) + u(i,j-1) + u(i,j+1) - 4*u(i,j)] / h²
  %
  % Using lexicographic ordering: map (i,j) -> k = i + (j-1)*nx
  %
  % Five-point stencil:
  %        [0  1  0]     North: u(i,j+1)
  %        [1 -4  1] --> West/Center/East: u(i-1,j), u(i,j), u(i+1,j)
  %        [0  1  0]     South: u(i,j-1)
  
  N = nx * ny;  % Total number of interior points
  
  % Preallocate arrays for sparse matrix construction
  % Each interior point connects to at most 5 points (itself + 4 neighbors)
  max_entries = 5 * N;
  row_indices = zeros(max_entries, 1);
  col_indices = zeros(max_entries, 1);
  values = zeros(max_entries, 1);
  
  entry_count = 0;
  
  % Loop over all interior grid points
  for j = 1:ny
    for i = 1:nx
      % Current point in lexicographic ordering
      k = i + (j - 1) * nx;
      
      % Center: -4
      entry_count = entry_count + 1;
      row_indices(entry_count) = k;
      col_indices(entry_count) = k;
      values(entry_count) = -4;
      
      % West neighbor: i-1, j (if not on left boundary)
      if i > 1
        k_west = (i - 1) + (j - 1) * nx;
        entry_count = entry_count + 1;
        row_indices(entry_count) = k;
        col_indices(entry_count) = k_west;
        values(entry_count) = 1;
      end
      
      % East neighbor: i+1, j (if not on right boundary)
      if i < nx
        k_east = (i + 1) + (j - 1) * nx;
        entry_count = entry_count + 1;
        row_indices(entry_count) = k;
        col_indices(entry_count) = k_east;
        values(entry_count) = 1;
      end
      
      % South neighbor: i, j-1 (if not on bottom boundary)
      if j > 1
        k_south = i + (j - 2) * nx;
        entry_count = entry_count + 1;
        row_indices(entry_count) = k;
        col_indices(entry_count) = k_south;
        values(entry_count) = 1;
      end
      
      % North neighbor: i, j+1 (if not on top boundary)
      if j < ny
        k_north = i + j * nx;
        entry_count = entry_count + 1;
        row_indices(entry_count) = k;
        col_indices(entry_count) = k_north;
        values(entry_count) = 1;
      end
    end
  end
  
  % Trim preallocated arrays to actual size
  row_indices = row_indices(1:entry_count);
  col_indices = col_indices(1:entry_count);
  values = values(1:entry_count);
  
  % Construct sparse matrix
  L = sparse(row_indices, col_indices, values, N, N);
end
