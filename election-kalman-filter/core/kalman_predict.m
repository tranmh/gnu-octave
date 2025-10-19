function [x_pred, P_pred] = kalman_predict(x_est, P_est, Q)
    % KALMAN_PREDICT Perform Kalman filter prediction (time update) step
    %
    % USAGE:
    %   [x_pred, P_pred] = kalman_predict(x_est, P_est, Q)
    %
    % DESCRIPTION:
    %   Predicts the next state and covariance based on the process model.
    %   This is the "time update" or "prediction" step of the Kalman filter.
    %
    % INPUTS:
    %   x_est - Current state estimate (scalar: win probability)
    %   P_est - Current state covariance (scalar: uncertainty)
    %   Q     - Process noise covariance (scalar)
    %
    % OUTPUTS:
    %   x_pred - Predicted state for next time step
    %   P_pred - Predicted covariance for next time step
    %
    % MATHEMATICAL FORMULATION:
    %   State equation: x(t+1) = x(t) + w(t), where w(t) ~ N(0, Q)
    %   
    %   Prediction equations:
    %     x_pred = F * x_est          (F = 1 for random walk model)
    %     P_pred = F * P_est * F' + Q (F = 1, so P_pred = P_est + Q)
    %
    % NOTES:
    %   - Uses random walk process model (state is expected to remain constant)
    %   - Process noise Q captures unpredictable campaign dynamics
    %   - Uncertainty always increases during prediction step
    %
    % EXAMPLE:
    %   x_est = 0.52;    % Current estimate: 52% win probability
    %   P_est = 0.08;    % Current uncertainty
    %   Q = 0.001;       % Process noise
    %   [x_pred, P_pred] = kalman_predict(x_est, P_est, Q);
    %
    % See also: kalman_update, kalman_init, kalman_filter
    
    % Author: Election Kalman Filter Project
    % Date: October 2025
    
    %% Validate inputs
    validateattributes(x_est, {'numeric'}, {'scalar', '>=', 0, '<=', 1}, ...
        'kalman_predict', 'x_est');
    validateattributes(P_est, {'numeric'}, {'scalar', 'positive'}, ...
        'kalman_predict', 'P_est');
    validateattributes(Q, {'numeric'}, {'scalar', 'positive'}, ...
        'kalman_predict', 'Q');
    
    %% Prediction step equations
    % State transition matrix F = 1 (random walk model)
    % x(t+1) = F * x(t) + w(t) = x(t) + w(t)
    x_pred = x_est;
    
    % Covariance prediction
    % P(t+1) = F * P(t) * F' + Q = P(t) + Q
    P_pred = P_est + Q;
    
    %% Ensure valid probability range
    % State should remain in [0, 1] even after prediction
    % (Though in practice, updates should keep it bounded)
    x_pred = max(0, min(1, x_pred));
    
    %% Check for numerical issues
    if P_pred < 0
        warning('kalman_predict:NegativeCovariance', ...
            'Predicted covariance became negative (%g). Resetting to small positive value.', P_pred);
        P_pred = 1e-6;
    end
    
    if P_pred > 1
        warning('kalman_predict:LargeCovariance', ...
            'Predicted covariance (%g) is very large. Filter may be diverging.', P_pred);
    end
    
end
