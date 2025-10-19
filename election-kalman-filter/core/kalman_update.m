function [x_est, P_est, K, innovation] = kalman_update(x_pred, P_pred, z, R)
    % KALMAN_UPDATE Perform Kalman filter correction (measurement update) step
    %
    % USAGE:
    %   [x_est, P_est, K, innovation] = kalman_update(x_pred, P_pred, z, R)
    %
    % DESCRIPTION:
    %   Updates the predicted state using a new measurement.
    %   This is the "measurement update" or "correction" step of the Kalman filter.
    %
    % INPUTS:
    %   x_pred - Predicted state (scalar: win probability)
    %   P_pred - Predicted covariance (scalar: uncertainty)
    %   z      - Measurement (scalar: observed win probability from polls)
    %   R      - Measurement noise covariance (scalar)
    %
    % OUTPUTS:
    %   x_est      - Updated state estimate after incorporating measurement
    %   P_est      - Updated covariance after incorporating measurement
    %   K          - Kalman gain (weight given to measurement)
    %   innovation - Innovation/residual (z - x_pred)
    %
    % MATHEMATICAL FORMULATION:
    %   Measurement equation: z(t) = H * x(t) + v(t), where v(t) ~ N(0, R)
    %   For our problem, H = 1 (direct observation of win probability)
    %   
    %   Update equations:
    %     K = P_pred / (P_pred + R)           [Kalman gain]
    %     innovation = z - x_pred             [Measurement residual]
    %     x_est = x_pred + K * innovation     [State update]
    %     P_est = (1 - K) * P_pred            [Covariance update]
    %
    % NOTES:
    %   - Kalman gain K determines how much to trust the measurement
    %   - K → 1 when P_pred >> R (trust measurement more)
    %   - K → 0 when P_pred << R (trust prediction more)
    %   - Uncertainty always decreases during update step
    %
    % EXAMPLE:
    %   x_pred = 0.52;  % Predicted: 52% win probability
    %   P_pred = 0.10;  % Predicted uncertainty
    %   z = 0.55;       % Measurement from polls: 55%
    %   R = 0.05;       % Measurement noise
    %   [x_est, P_est, K, innovation] = kalman_update(x_pred, P_pred, z, R);
    %
    % See also: kalman_predict, kalman_init, kalman_filter
    
    % Author: Election Kalman Filter Project
    % Date: October 2025
    
    %% Validate inputs
    validateattributes(x_pred, {'numeric'}, {'scalar', '>=', 0, '<=', 1}, ...
        'kalman_update', 'x_pred');
    validateattributes(P_pred, {'numeric'}, {'scalar', 'positive'}, ...
        'kalman_update', 'P_pred');
    validateattributes(z, {'numeric'}, {'scalar', '>=', 0, '<=', 1}, ...
        'kalman_update', 'z');
    validateattributes(R, {'numeric'}, {'scalar', 'positive'}, ...
        'kalman_update', 'R');
    
    %% Calculate Kalman gain
    % K = P_pred * H' / (H * P_pred * H' + R)
    % With H = 1: K = P_pred / (P_pred + R)
    K = P_pred / (P_pred + R);
    
    %% Calculate innovation (measurement residual)
    % innovation = z - H * x_pred
    % With H = 1: innovation = z - x_pred
    innovation = z - x_pred;
    
    %% Update state estimate
    % x_est = x_pred + K * innovation
    x_est = x_pred + K * innovation;
    
    %% Update covariance
    % P_est = (I - K * H) * P_pred
    % With H = 1: P_est = (1 - K) * P_pred
    % Alternative form (Joseph form, numerically stable):
    % P_est = (1 - K) * P_pred * (1 - K)' + K * R * K'
    % For scalar case: P_est = (1 - K)^2 * P_pred + K^2 * R
    % We use the simpler form which is equivalent and stable for scalar case
    P_est = (1 - K) * P_pred;
    
    %% Ensure valid probability range
    x_est = max(0, min(1, x_est));
    
    %% Check for numerical issues
    if K < 0 || K > 1
        warning('kalman_update:InvalidKalmanGain', ...
            'Kalman gain K = %g is outside [0, 1]. This indicates numerical issues.', K);
        K = max(0, min(1, K));
    end
    
    if P_est < 0
        warning('kalman_update:NegativeCovariance', ...
            'Updated covariance became negative (%g). Resetting to small positive value.', P_est);
        P_est = 1e-6;
    end
    
    if P_est > P_pred
        warning('kalman_update:IncreasingUncertainty', ...
            'Covariance increased during update (P_pred=%g, P_est=%g). This should not happen.', ...
            P_pred, P_est);
    end
    
    %% Diagnostic information (optional)
    % Check if innovation is suspiciously large
    if abs(innovation) > 0.3
        warning('kalman_update:LargeInnovation', ...
            'Large innovation detected: %+.3f. Measurement may be an outlier.', innovation);
    end
    
end
