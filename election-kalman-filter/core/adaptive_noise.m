function [Q_est, R_est, diagnostics] = adaptive_noise(results, varargin)
    % ADAPTIVE_NOISE Estimate optimal process and measurement noise from filter results
    %
    % USAGE:
    %   [Q_est, R_est, diagnostics] = adaptive_noise(results)
    %   [Q_est, R_est, diagnostics] = adaptive_noise(results, 'ParamName', value, ...)
    %
    % DESCRIPTION:
    %   Uses innovation sequence and Kalman gain history to estimate
    %   optimal process noise (Q) and measurement noise (R) parameters.
    %
    % INPUTS:
    %   results - Results structure from kalman_filter()
    %
    % OPTIONAL PARAMETERS:
    %   'method'    - Estimation method: 'innovation' or 'likelihood' (default: 'innovation')
    %   'window'    - Moving window size for estimation (default: 10 weeks)
    %   'verbose'   - Display diagnostics (default: false)
    %
    % OUTPUTS:
    %   Q_est       - Estimated process noise covariance
    %   R_est       - Estimated measurement noise covariance  
    %   diagnostics - Structure with estimation details
    %
    % METHODS:
    %   'innovation': Uses innovation sequence statistics
    %     - Innovation variance should equal (P_pred + R)
    %     - Can back out Q and R from innovation and covariance sequences
    %
    %   'likelihood': Maximum likelihood estimation (not yet implemented)
    %
    % MATHEMATICAL BACKGROUND:
    %   Innovation sequence: ε(t) = z(t) - x_pred(t)
    %   Expected innovation variance: E[ε²] = P_pred + R
    %   
    %   From Kalman filter equations:
    %     P_pred = P_est + Q
    %     K = P_pred / (P_pred + R)
    %   
    %   Solving for R: R = P_pred * (1/K - 1)
    %   Solving for Q: Q = P_pred - P_est
    %
    % EXAMPLE:
    %   params = kalman_init();
    %   results = kalman_filter(measurements, weeks, params);
    %   [Q_est, R_est] = adaptive_noise(results);
    %
    % NOTES:
    %   - Estimates are more reliable after filter convergence (after ~10 weeks)
    %   - Transition periods should be excluded from estimation
    %   - Outliers in innovation sequence can bias estimates
    %
    % See also: kalman_filter, kalman_init
    
    % Author: Election Kalman Filter Project
    % Date: October 2025
    
    %% Parse inputs
    p = inputParser;
    p.addParameter('method', 'innovation', @(x) ismember(x, {'innovation', 'likelihood'}));
    p.addParameter('window', 10, @(x) isscalar(x) && x > 0);
    p.addParameter('verbose', false, @islogical);
    p.parse(varargin{:});
    
    method = p.Results.method;
    window = p.Results.window;
    verbose = p.Results.verbose;
    
    %% Extract data (exclude NaN values)
    valid_idx = ~isnan(results.innovation);
    innovations = results.innovation(valid_idx);
    P_pred = results.P_pred(valid_idx);
    P_est = results.P_est(valid_idx);
    K = results.K(valid_idx);
    
    if length(innovations) < window
        warning('adaptive_noise:InsufficientData', ...
            'Insufficient data points (%d) for reliable estimation (need at least %d)', ...
            length(innovations), window);
    end
    
    %% Estimation based on method
    if strcmp(method, 'innovation')
        % Innovation-based estimation
        
        % Estimate R from innovation variance and predicted covariance
        % E[ε²] = P_pred + R  →  R = E[ε²] - E[P_pred]
        innovation_var = var(innovations);
        mean_P_pred = mean(P_pred);
        R_est = innovation_var - mean_P_pred;
        
        % Ensure R is positive
        if R_est <= 0
            R_est = 0.01;  % Minimum measurement noise
            if verbose
                warning('adaptive_noise:NegativeR', ...
                    'Estimated R was negative. Setting to minimum value %.4f', R_est);
            end
        end
        
        % Estimate Q from covariance difference
        % P_pred = P_est + Q  →  Q = P_pred - P_est
        Q_estimates = P_pred - P_est;
        Q_est = mean(Q_estimates(Q_estimates > 0));  % Average positive values
        
        % Ensure Q is positive
        if isnan(Q_est) || Q_est <= 0
            Q_est = 0.001;  % Minimum process noise
            if verbose
                warning('adaptive_noise:InvalidQ', ...
                    'Estimated Q was invalid. Setting to minimum value %.4f', Q_est);
            end
        end
        
        % Alternative R estimation from Kalman gain
        % K = P_pred / (P_pred + R)  →  R = P_pred * (1/K - 1)
        R_from_K = mean(P_pred .* (1 ./ K - 1));
        
        % Compile diagnostics
        diagnostics.innovation_variance = innovation_var;
        diagnostics.mean_P_pred = mean_P_pred;
        diagnostics.R_from_innovation = R_est;
        diagnostics.R_from_K = R_from_K;
        diagnostics.Q_estimates = Q_estimates;
        diagnostics.mean_K = mean(K);
        diagnostics.method = 'innovation';
        
    elseif strcmp(method, 'likelihood')
        % Maximum likelihood estimation (future enhancement)
        error('adaptive_noise:NotImplemented', ...
            'Maximum likelihood estimation is not yet implemented. Use ''innovation'' method.');
    end
    
    %% Display results
    if verbose
        fprintf('\n=== Adaptive Noise Estimation ===\n');
        fprintf('Method: %s\n', method);
        fprintf('Data points: %d\n', length(innovations));
        fprintf('\nEstimated parameters:\n');
        fprintf('  Q (process noise):     %.6f\n', Q_est);
        fprintf('  R (measurement noise): %.6f\n', R_est);
        fprintf('\nDiagnostics:\n');
        fprintf('  Innovation variance:   %.6f\n', innovation_var);
        fprintf('  Mean predicted cov:    %.6f\n', mean_P_pred);
        fprintf('  R from Kalman gain:    %.6f\n', R_from_K);
        fprintf('  Average Kalman gain:   %.4f\n', mean(K));
        fprintf('  Q/R ratio:             %.4f\n', Q_est / R_est);
    end
    
    %% Validate estimates
    if Q_est > R_est
        if verbose
            warning('adaptive_noise:LargeProcessNoise', ...
                'Estimated Q (%.4f) > R (%.4f). System may have high inherent variability.', ...
                Q_est, R_est);
        end
    end
    
    if R_est > 0.2
        if verbose
            warning('adaptive_noise:LargeMeasurementNoise', ...
                'Estimated R (%.4f) is quite large. Measurements may be very noisy.', R_est);
        end
    end
    
end
