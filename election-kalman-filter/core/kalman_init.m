function params = kalman_init(varargin)
    % KALMAN_INIT Initialize Kalman filter parameters
    %
    % USAGE:
    %   params = kalman_init()
    %   params = kalman_init('ParamName', value, ...)
    %
    % DESCRIPTION:
    %   Initializes the Kalman filter state, covariance, and noise parameters
    %   for election win probability prediction.
    %
    % OPTIONAL PARAMETERS:
    %   'x0'        - Initial state estimate (default: 0.5, 50% win probability)
    %   'P0'        - Initial state uncertainty (default: 0.1)
    %   'Q'         - Process noise covariance (default: 0.001)
    %   'R'         - Measurement noise covariance (default: 0.05)
    %   'k_scale'   - Polling margin scaling factor (default: 15)
    %
    % OUTPUTS:
    %   params - Structure containing:
    %       .x_est      : Current state estimate
    %       .P_est      : Current state covariance (uncertainty)
    %       .Q          : Process noise covariance
    %       .R          : Measurement noise covariance
    %       .k_scale    : Polling margin scaling factor
    %       .history    : Structure to store estimation history
    %
    % EXAMPLE:
    %   % Default initialization
    %   params = kalman_init();
    %
    %   % Custom initialization
    %   params = kalman_init('x0', 0.55, 'Q', 0.002, 'R', 0.04);
    %
    % MATHEMATICAL BACKGROUND:
    %   State variable x(t) represents true Democratic nominee win probability
    %   Initial state x(0) = 0.5 represents neutral 50-50 prior
    %   P(0) represents initial uncertainty in the estimate
    %
    % See also: kalman_predict, kalman_update, kalman_filter
    
    % Author: Election Kalman Filter Project
    % Date: October 2025
    
    %% Parse input parameters
    p = inputParser;
    p.addParameter('x0', 0.5, @(x) isscalar(x) && x >= 0 && x <= 1);
    p.addParameter('P0', 0.1, @(x) isscalar(x) && x > 0);
    p.addParameter('Q', 0.001, @(x) isscalar(x) && x > 0);
    p.addParameter('R', 0.05, @(x) isscalar(x) && x > 0);
    p.addParameter('k_scale', 15, @(x) isscalar(x) && x > 0);
    p.parse(varargin{:});
    
    %% Initialize state and covariance
    params.x_est = p.Results.x0;  % Initial state estimate
    params.P_est = p.Results.P0;  % Initial state covariance
    
    %% Set noise parameters
    params.Q = p.Results.Q;       % Process noise covariance
    params.R = p.Results.R;       % Measurement noise covariance
    params.k_scale = p.Results.k_scale;  % Polling margin scaling

    % Add aliases for compatibility with weekly_processor
    params.x0 = params.x_est;
    params.P0 = params.P_est;
    
    %% Initialize history tracking
    params.history.x_est = [];        % State estimates over time
    params.history.P_est = [];        % Covariance estimates over time
    params.history.x_pred = [];       % Predicted states
    params.history.P_pred = [];       % Predicted covariances
    params.history.K = [];            % Kalman gains
    params.history.innovation = [];   % Innovations (measurement residuals)
    params.history.measurements = []; % Actual measurements
    params.history.week_number = [];  % Week numbers
    
    %% Validate parameters
    if params.Q > params.R
        warning('kalman_init:LargeProcessNoise', ...
            'Process noise Q (%g) is larger than measurement noise R (%g). This may indicate high system uncertainty.', ...
            params.Q, params.R);
    end
    
    if params.P_est > 0.3
        warning('kalman_init:LargeInitialUncertainty', ...
            'Initial uncertainty P0 (%g) is quite large. Consider reducing for faster convergence.', ...
            params.P_est);
    end
    
    %% Display initialization info (optional, can be suppressed)
    if nargout == 0 || nargout == 1
        fprintf('Kalman Filter Initialized:\n');
        fprintf('  Initial state x0:       %.4f (%.1f%% win probability)\n', ...
            params.x_est, params.x_est * 100);
        fprintf('  Initial uncertainty P0: %.4f\n', params.P_est);
        fprintf('  Process noise Q:        %.4f\n', params.Q);
        fprintf('  Measurement noise R:    %.4f\n', params.R);
        fprintf('  Polling scale k:        %.1f\n', params.k_scale);
    end
    
end
