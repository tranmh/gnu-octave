% calculate_stability.m
% Calculates stability metrics and diagnostics for heat diffusion simulation
%
% INPUTS:
%   params - Structure containing simulation parameters
%   dimension - '1d' or '2d' to specify problem dimension
%
% OUTPUTS:
%   stability - Structure containing:
%     .cfl - CFL (Courant-Friedrichs-Lewy) number
%     .status - 'Stable' or 'Unstable' (for explicit methods)
%     .accuracy - 'Good', 'Acceptable', or 'Poor'
%     .recommendation - Suggestions for improving parameters (if needed)
%
% NOTES ON CRANK-NICOLSON:
%   The Crank-Nicolson method is unconditionally stable for any CFL number.
%   However, accuracy still depends on the CFL number:
%     - CFL < 0.5: Excellent accuracy
%     - 0.5 < CFL < 2.0: Good accuracy
%     - CFL > 2.0: Stable but reduced accuracy
%
% CFL NUMBER DEFINITION:
%   CFL = α * Δt / (Δx)²  for 1D
%   CFL = α * Δt / min(Δx², Δy²)  for 2D
%
%   where α is thermal diffusivity, Δt is time step,
%   Δx and Δy are spatial step sizes

function stability = calculate_stability(params, dimension)
    
    % Initialize structure
    stability = struct();
    
    % Calculate CFL number based on dimension
    if strcmp(dimension, '1d')
        % 1D case
        dx = params.L / (params.nx - 1);
        stability.cfl = params.alpha * params.dt / (dx^2);
        stability.dx = dx;
        
    elseif strcmp(dimension, '2d')
        % 2D case
        dx = params.Lx / (params.nx - 1);
        dy = params.Ly / (params.ny - 1);
        min_spacing_sq = min(dx^2, dy^2);
        stability.cfl = params.alpha * params.dt / min_spacing_sq;
        stability.dx = dx;
        stability.dy = dy;
        
    else
        error('Invalid dimension. Must be ''1d'' or ''2d''');
    end
    
    % ====================================================================
    % STABILITY ASSESSMENT
    % ====================================================================
    
    % Crank-Nicolson is unconditionally stable
    stability.status = 'Stable (Crank-Nicolson is unconditionally stable)';
    
    % ====================================================================
    % ACCURACY ASSESSMENT
    % ====================================================================
    
    % Accuracy depends on CFL number even though method is stable
    if stability.cfl < 0.5
        stability.accuracy = 'Excellent (CFL < 0.5)';
        stability.efficiency = 'Consider increasing dt for faster computation';
        
    elseif stability.cfl < 1.0
        stability.accuracy = 'Very Good (CFL < 1.0)';
        stability.efficiency = 'Good balance between accuracy and speed';
        
    elseif stability.cfl < 2.0
        stability.accuracy = 'Good (CFL < 2.0)';
        stability.efficiency = 'Acceptable for most applications';
        
    elseif stability.cfl < 5.0
        stability.accuracy = 'Acceptable (2.0 < CFL < 5.0)';
        stability.recommendation = 'Consider reducing dt or refining grid for better accuracy';
        
    else
        stability.accuracy = 'Poor (CFL > 5.0)';
        stability.recommendation = 'Strongly recommend reducing dt or refining grid';
    end
    
    % ====================================================================
    % TIME STEP RECOMMENDATIONS
    % ====================================================================
    
    % Recommend optimal time step for best accuracy
    if strcmp(dimension, '1d')
        dt_optimal = 0.5 * dx^2 / params.alpha;
        stability.dt_optimal = dt_optimal;
        
        if params.dt > 2.0 * dt_optimal
            if ~isfield(stability, 'recommendation')
                stability.recommendation = sprintf(...
                    'For better accuracy, try dt ≈ %.2e (currently %.2e)', ...
                    dt_optimal, params.dt);
            end
        end
        
    elseif strcmp(dimension, '2d')
        dt_optimal = 0.5 * min_spacing_sq / params.alpha;
        stability.dt_optimal = dt_optimal;
        
        if params.dt > 2.0 * dt_optimal
            if ~isfield(stability, 'recommendation')
                stability.recommendation = sprintf(...
                    'For better accuracy, try dt ≈ %.2e (currently %.2e)', ...
                    dt_optimal, params.dt);
            end
        end
    end
    
    % ====================================================================
    % COMPUTATIONAL COST ESTIMATE
    % ====================================================================
    
    % Estimate number of time steps
    n_steps = ceil(params.t_final / params.dt);
    stability.n_time_steps = n_steps;
    
    % Estimate computational complexity
    if strcmp(dimension, '1d')
        % 1D: O(nx) per time step (tridiagonal solver)
        stability.complexity = sprintf('O(%d) per step, %d total steps', ...
                                        params.nx, n_steps);
    else
        % 2D: O(nx * ny) per time step (sparse solver)
        n_points = params.nx * params.ny;
        stability.complexity = sprintf('O(%d) per step, %d total steps', ...
                                        n_points, n_steps);
    end
    
end
