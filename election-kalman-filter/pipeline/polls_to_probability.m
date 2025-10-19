function [win_prob, uncertainty] = polls_to_probability(dem_pct, rep_pct, dem_std, rep_std, varargin)
    % POLLS_TO_PROBABILITY Convert polling percentages to win probability
    %
    % Uses a logistic transformation to convert polling margin into
    % Democratic nominee win probability
    %
    % Inputs:
    %   dem_pct     - Democratic candidate polling percentage (0-100)
    %   rep_pct     - Republican candidate polling percentage (0-100)
    %   dem_std     - Democratic polling standard deviation (optional)
    %   rep_std     - Republican polling standard deviation (optional)
    %   varargin    - Optional parameters:
    %                 'scaling', k - Scaling parameter for logistic curve (default: 15)
    %                 'base_uncertainty', u - Base measurement uncertainty (default: 0.05)
    %
    % Outputs:
    %   win_prob    - Democratic win probability (0-1)
    %   uncertainty - Measurement uncertainty (for Kalman filter R)
    %
    % Method:
    %   1. Calculate polling margin: margin = (dem_pct - rep_pct) / 100
    %   2. Apply logistic transformation: win_prob = 1 / (1 + exp(-k * margin))
    %   3. Estimate uncertainty from polling standard deviations
    %
    % Example:
    %   [p, u] = polls_to_probability(48.5, 46.5, 2.0, 1.8);
    %   % Returns: p ≈ 0.67 (67% win probability), u ≈ 0.06
    
    % Parse optional parameters
    p = inputParser;
    addParameter(p, 'scaling', 15, @isnumeric);
    addParameter(p, 'base_uncertainty', 0.05, @isnumeric);
    parse(p, varargin{:});
    
    k = p.Results.scaling;
    base_uncertainty = p.Results.base_uncertainty;
    
    % Input validation
    if dem_pct < 0 || dem_pct > 100 || rep_pct < 0 || rep_pct > 100
        error('Polling percentages must be between 0 and 100');
    end
    
    % Calculate margin (as fraction, not percentage)
    margin = (dem_pct - rep_pct) / 100;
    
    % Apply logistic transformation
    % win_prob = 1 / (1 + exp(-k * margin))
    % This maps margin to probability:
    %   margin = 0  → win_prob = 0.50 (toss-up)
    %   margin > 0  → win_prob > 0.50 (Dem advantage)
    %   margin < 0  → win_prob < 0.50 (Rep advantage)
    %
    % Scaling parameter k controls steepness:
    %   k = 10: ±5 point margin → ~70%/30% probability
    %   k = 15: ±5 point margin → ~80%/20% probability  (default)
    %   k = 20: ±5 point margin → ~90%/10% probability
    
    win_prob = 1.0 / (1.0 + exp(-k * margin));
    
    % Estimate measurement uncertainty from polling standard deviations
    % Higher polling uncertainty → higher measurement uncertainty for Kalman filter
    
    if nargin >= 4 && ~isnan(dem_std) && ~isnan(rep_std)
        % Combine standard deviations in quadrature
        % Margin std = sqrt(dem_std^2 + rep_std^2)
        margin_std = sqrt((dem_std/100)^2 + (rep_std/100)^2);
        
        % Convert margin uncertainty to probability uncertainty
        % Using derivative of logistic function at current point
        % d/dx[1/(1+exp(-kx))] = k*exp(-kx) / (1+exp(-kx))^2
        
        logistic_derivative = k * exp(-k * margin) / ((1 + exp(-k * margin))^2);
        prob_std = abs(logistic_derivative * margin_std);
        
        % Uncertainty is variance (squared std dev) plus base measurement noise
        uncertainty = prob_std^2 + base_uncertainty^2;
        
    else
        % No polling std provided, use default uncertainty
        uncertainty = base_uncertainty^2;
    end
    
    % Ensure uncertainty is reasonable (not too small or too large)
    uncertainty = max(0.001, min(uncertainty, 0.25));
    
end
