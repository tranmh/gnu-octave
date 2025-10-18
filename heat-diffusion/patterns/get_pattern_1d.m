function u0 = get_pattern_1d(pattern_name, nx, varargin)
    % GET_PATTERN_1D - Generate 1D initial temperature distributions
    %
    % Usage:
    %   u0 = get_pattern_1d(pattern_name, nx)
    %   u0 = get_pattern_1d(pattern_name, nx, param1, value1, ...)
    %
    % Inputs:
    %   pattern_name - String identifier for the pattern
    %   nx          - Number of spatial grid points
    %   varargin    - Optional parameter-value pairs
    %
    % Outputs:
    %   u0 - Column vector of initial temperatures (nx x 1)
    %
    % Available Patterns:
    %   'gaussian'    - Single Gaussian peak
    %   'step'        - Step function (hot/cold interface)
    %   'double_peak' - Two separated Gaussians
    %   'sine'        - Sinusoidal distribution
    %   'random'      - Random temperature field
    %
    % Optional Parameters:
    %   'amplitude'   - Peak temperature (default: 100)
    %   'width'       - Characteristic width (default: 0.1)
    %   'center'      - Center position [0,1] (default: 0.5)
    %   'center1'     - First peak position (default: 0.3)
    %   'center2'     - Second peak position (default: 0.7)
    %   'frequency'   - Number of oscillations (default: 2)
    %   'noise_level' - Amplitude of random component (default: 50)
    %
    % Examples:
    %   % Default Gaussian
    %   u0 = get_pattern_1d('gaussian', 100);
    %
    %   % Wide Gaussian at right side
    %   u0 = get_pattern_1d('gaussian', 100, 'width', 0.2, 'center', 0.7);
    %
    %   % Step function at x=0.4
    %   u0 = get_pattern_1d('step', 100, 'center', 0.4);
    %
    %   % Two peaks with custom positions
    %   u0 = get_pattern_1d('double_peak', 100, 'center1', 0.25, 'center2', 0.75);
    
    % Parse optional parameters
    p = inputParser();
    addParameter(p, 'amplitude', 100);
    addParameter(p, 'width', 0.1);
    addParameter(p, 'center', 0.5);
    addParameter(p, 'center1', 0.3);
    addParameter(p, 'center2', 0.7);
    addParameter(p, 'frequency', 2);
    addParameter(p, 'noise_level', 50);
    parse(p, varargin{:});
    
    amp = p.Results.amplitude;
    width = p.Results.width;
    center = p.Results.center;
    center1 = p.Results.center1;
    center2 = p.Results.center2;
    freq = p.Results.frequency;
    noise_amp = p.Results.noise_level;
    
    % Create spatial grid (0 to 1, excluding boundaries)
    x_full = linspace(0, 1, nx+2);
    x = x_full(2:end-1)';  % Interior points only
    
    % Initialize output
    u0 = zeros(nx, 1);
    
    % Generate pattern based on name
    switch lower(pattern_name)
        case 'gaussian'
            % Single Gaussian peak
            % u(x) = A * exp(-((x - center)^2) / (2 * width^2))
            u0 = amp * exp(-((x - center).^2) / (2 * width^2));
            
        case 'step'
            % Step function (Heaviside-like)
            % Hot on left, cold on right (or vice versa)
            u0 = amp * (x < center);
            
        case 'double_peak'
            % Two separated Gaussians
            peak1 = amp * exp(-((x - center1).^2) / (2 * width^2));
            peak2 = amp * exp(-((x - center2).^2) / (2 * width^2));
            u0 = peak1 + peak2;
            
        case 'sine'
            % Sinusoidal distribution
            % u(x) = A * (1 + sin(2*pi*freq*x)) / 2
            % Scaled to [0, amp]
            u0 = amp * (1 + sin(2*pi*freq*x)) / 2;
            
        case 'random'
            % Random temperature field
            % Normally distributed around noise_amp/2
            u0 = noise_amp * rand(nx, 1);
            
        otherwise
            error('Unknown pattern name: %s\nAvailable patterns: gaussian, step, double_peak, sine, random', ...
                  pattern_name);
    end
    
    % Ensure column vector output
    u0 = u0(:);
    
end
