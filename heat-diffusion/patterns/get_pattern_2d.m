function u0 = get_pattern_2d(pattern_name, nx, ny, varargin)
    % GET_PATTERN_2D - Generate 2D initial temperature distributions
    %
    % Usage:
    %   u0 = get_pattern_2d(pattern_name, nx, ny)
    %   u0 = get_pattern_2d(pattern_name, nx, ny, param1, value1, ...)
    %
    % Inputs:
    %   pattern_name - String identifier for the pattern
    %   nx          - Number of spatial grid points in x-direction
    %   ny          - Number of spatial grid points in y-direction
    %   varargin    - Optional parameter-value pairs
    %
    % Outputs:
    %   u0 - Matrix of initial temperatures (nx x ny)
    %
    % Available Patterns:
    %   'center_hot'    - Hot spot at center
    %   'corner_hot'    - Hot corners, cold center
    %   'gaussian'      - 2D Gaussian peak
    %   'ring'          - Hot ring, cold interior/exterior
    %   'checkerboard'  - Alternating hot/cold patches
    %   'radial'        - Radially symmetric gradient
    %   'random'        - Random 2D temperature field
    %
    % Optional Parameters:
    %   'amplitude'   - Peak temperature (default: 100)
    %   'width'       - Characteristic width (default: 0.1)
    %   'center_x'    - Center position in x [0,1] (default: 0.5)
    %   'center_y'    - Center position in y [0,1] (default: 0.5)
    %   'ring_radius' - Ring radius [0,1] (default: 0.3)
    %   'num_checks'  - Number of checkerboard squares (default: 4)
    %   'noise_level' - Amplitude of random component (default: 50)
    %
    % Examples:
    %   % Default Gaussian at center
    %   u0 = get_pattern_2d('gaussian', 50, 50);
    %
    %   % Wide Gaussian off-center
    %   u0 = get_pattern_2d('gaussian', 50, 50, 'width', 0.2, 'center_x', 0.7);
    %
    %   % Ring with custom radius
    %   u0 = get_pattern_2d('ring', 50, 50, 'ring_radius', 0.25);
    %
    %   % Fine checkerboard pattern
    %   u0 = get_pattern_2d('checkerboard', 50, 50, 'num_checks', 8);
    
    % Parse optional parameters
    p = inputParser();
    addParameter(p, 'amplitude', 100);
    addParameter(p, 'width', 0.1);
    addParameter(p, 'center_x', 0.5);
    addParameter(p, 'center_y', 0.5);
    addParameter(p, 'ring_radius', 0.3);
    addParameter(p, 'num_checks', 4);
    addParameter(p, 'noise_level', 50);
    parse(p, varargin{:});
    
    amp = p.Results.amplitude;
    width = p.Results.width;
    cx = p.Results.center_x;
    cy = p.Results.center_y;
    ring_r = p.Results.ring_radius;
    num_checks = p.Results.num_checks;
    noise_amp = p.Results.noise_level;
    
    % Create 2D spatial grid (0 to 1 in both directions, excluding boundaries)
    x = linspace(0, 1, nx+2)(2:end-1);
    y = linspace(0, 1, ny+2)(2:end-1);
    [X, Y] = meshgrid(x, y);
    
    % Initialize output
    u0 = zeros(ny, nx);  % Note: ny rows, nx columns for matrix indexing
    
    % Generate pattern based on name
    switch lower(pattern_name)
        case 'center_hot'
            % Hot spot at center with Gaussian profile
            % u(x,y) = A * exp(-((x-cx)^2 + (y-cy)^2) / (2*width^2))
            r2 = (X - cx).^2 + (Y - cy).^2;
            u0 = amp * exp(-r2 / (2 * width^2));
            
        case 'corner_hot'
            % Hot spots at four corners
            % Superposition of four Gaussians
            corners = [0.1, 0.1; 0.1, 0.9; 0.9, 0.1; 0.9, 0.9];
            for i = 1:4
                r2 = (X - corners(i,1)).^2 + (Y - corners(i,2)).^2;
                u0 = u0 + amp * exp(-r2 / (2 * width^2));
            end
            
        case 'gaussian'
            % 2D Gaussian peak (same as center_hot, but named for clarity)
            r2 = (X - cx).^2 + (Y - cy).^2;
            u0 = amp * exp(-r2 / (2 * width^2));
            
        case 'ring'
            % Hot ring at specified radius
            % Ring thickness determined by width parameter
            r = sqrt((X - cx).^2 + (Y - cy).^2);
            u0 = amp * exp(-((r - ring_r).^2) / (2 * width^2));
            
        case 'checkerboard'
            % Alternating hot/cold patches
            % Creates num_checks x num_checks grid
            x_idx = floor(X * num_checks);
            y_idx = floor(Y * num_checks);
            u0 = amp * mod(x_idx + y_idx, 2);
            
        case 'radial'
            % Radially symmetric gradient from center
            % Hot at center, cooling with distance
            r = sqrt((X - cx).^2 + (Y - cy).^2);
            max_r = sqrt(2) * 0.5;  % Maximum possible distance from center
            u0 = amp * (1 - r / max_r);
            u0 = max(u0, 0);  % Clip negative values
            
        case 'random'
            % Random 2D temperature field
            % Uniformly distributed
            u0 = noise_amp * rand(ny, nx);
            
        otherwise
            error('Unknown pattern name: %s\nAvailable patterns: center_hot, corner_hot, gaussian, ring, checkerboard, radial, random', ...
                  pattern_name);
    end
    
    % Ensure proper matrix dimensions (ny x nx)
    u0 = reshape(u0, ny, nx);
    
end
