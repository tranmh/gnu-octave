% validate_parameters.m
% Validates simulation parameters for heat diffusion
%
% INPUTS:
%   params - Structure containing simulation parameters
%   dimension - '1d' or '2d' to specify problem dimension
%
% OUTPUTS:
%   is_valid - Boolean indicating if parameters are valid
%   warnings - Cell array of warning messages (empty if none)
%
% PARAMETER REQUIREMENTS:
%   Physical:
%     - alpha > 0 (thermal diffusivity must be positive)
%     - L, Lx, Ly > 0 (domain lengths must be positive)
%   
%   Numerical:
%     - nx, ny >= 10 (minimum grid resolution)
%     - dt > 0 (positive time step)
%     - t_final > 0 (positive final time)
%   
%   Warnings issued for:
%     - Very small time steps (dt < 1e-5)
%     - Large grids (nx or ny > 200)
%     - Long simulations (t_final > 10)

function [is_valid, warnings] = validate_parameters(params, dimension)
    
    % Initialize outputs
    is_valid = true;
    warnings = {};
    
    % ====================================================================
    % COMMON PARAMETERS (1D and 2D)
    % ====================================================================
    
    % Check thermal diffusivity
    if ~isfield(params, 'alpha')
        fprintf('ERROR: Missing parameter ''alpha'' (thermal diffusivity)\n');
        is_valid = false;
        return;
    end
    
    if params.alpha <= 0
        fprintf('ERROR: Thermal diffusivity (alpha) must be positive\n');
        is_valid = false;
        return;
    end
    
    % Check time step
    if ~isfield(params, 'dt')
        fprintf('ERROR: Missing parameter ''dt'' (time step)\n');
        is_valid = false;
        return;
    end
    
    if params.dt <= 0
        fprintf('ERROR: Time step (dt) must be positive\n');
        is_valid = false;
        return;
    end
    
    if params.dt < 1e-5
        warnings{end+1} = sprintf('Very small time step (dt = %.2e). Consider dt >= 1e-4', params.dt);
    end
    
    % Check final time
    if ~isfield(params, 't_final')
        fprintf('ERROR: Missing parameter ''t_final'' (final simulation time)\n');
        is_valid = false;
        return;
    end
    
    if params.t_final <= 0
        fprintf('ERROR: Final time (t_final) must be positive\n');
        is_valid = false;
        return;
    end
    
    if params.t_final > 10
        warnings{end+1} = sprintf('Long simulation time (t_final = %.2f). May take a while', params.t_final);
    end
    
    % Check boundary temperature (optional, but validate if present)
    if isfield(params, 'T_boundary')
        if ~isnumeric(params.T_boundary)
            fprintf('ERROR: Boundary temperature (T_boundary) must be numeric\n');
            is_valid = false;
            return;
        end
    end
    
    % ====================================================================
    % DIMENSION-SPECIFIC PARAMETERS
    % ====================================================================
    
    if strcmp(dimension, '1d')
        % Validate 1D parameters
        [is_valid, warnings] = validate_1d_params(params, warnings);
    elseif strcmp(dimension, '2d')
        % Validate 2D parameters
        [is_valid, warnings] = validate_2d_params(params, warnings);
    else
        fprintf('ERROR: Invalid dimension ''%s''. Must be ''1d'' or ''2d''\n', dimension);
        is_valid = false;
        return;
    end
    
end

% ====================================================================
% HELPER FUNCTION: Validate 1D Parameters
% ====================================================================

function [is_valid, warnings] = validate_1d_params(params, warnings)
    
    is_valid = true;
    
    % Check domain length
    if ~isfield(params, 'L')
        fprintf('ERROR: Missing parameter ''L'' (domain length)\n');
        is_valid = false;
        return;
    end
    
    if params.L <= 0
        fprintf('ERROR: Domain length (L) must be positive\n');
        is_valid = false;
        return;
    end
    
    % Check spatial grid points
    if ~isfield(params, 'nx')
        fprintf('ERROR: Missing parameter ''nx'' (number of spatial points)\n');
        is_valid = false;
        return;
    end
    
    if params.nx < 10
        fprintf('ERROR: Minimum 10 spatial points required (nx = %d)\n', params.nx);
        is_valid = false;
        return;
    end
    
    if params.nx > 500
        warnings{end+1} = sprintf('Large grid (nx = %d). May be slow', params.nx);
    end
    
    % Spatial resolution check
    dx = params.L / (params.nx - 1);
    if dx < 1e-4
        warnings{end+1} = sprintf('Very fine spatial resolution (dx = %.2e)', dx);
    end
    
end

% ====================================================================
% HELPER FUNCTION: Validate 2D Parameters
% ====================================================================

function [is_valid, warnings] = validate_2d_params(params, warnings)
    
    is_valid = true;
    
    % Check domain lengths
    if ~isfield(params, 'Lx') || ~isfield(params, 'Ly')
        fprintf('ERROR: Missing parameters ''Lx'' or ''Ly'' (domain lengths)\n');
        is_valid = false;
        return;
    end
    
    if params.Lx <= 0 || params.Ly <= 0
        fprintf('ERROR: Domain lengths (Lx, Ly) must be positive\n');
        is_valid = false;
        return;
    end
    
    % Check spatial grid points
    if ~isfield(params, 'nx') || ~isfield(params, 'ny')
        fprintf('ERROR: Missing parameters ''nx'' or ''ny'' (grid points)\n');
        is_valid = false;
        return;
    end
    
    if params.nx < 10 || params.ny < 10
        fprintf('ERROR: Minimum 10 grid points required in each direction\n');
        fprintf('       Current: nx = %d, ny = %d\n', params.nx, params.ny);
        is_valid = false;
        return;
    end
    
    if params.nx > 200 || params.ny > 200
        warnings{end+1} = sprintf('Large grid (%d × %d). Computation may be slow', ...
                                   params.nx, params.ny);
    end
    
    % Total grid size warning
    total_points = params.nx * params.ny;
    if total_points > 50000
        warnings{end+1} = sprintf('Very large grid (%d total points). Consider reducing resolution', ...
                                   total_points);
    end
    
    % Spatial resolution check
    dx = params.Lx / (params.nx - 1);
    dy = params.Ly / (params.ny - 1);
    if dx < 1e-4 || dy < 1e-4
        warnings{end+1} = sprintf('Very fine spatial resolution (dx = %.2e, dy = %.2e)', dx, dy);
    end
    
end
