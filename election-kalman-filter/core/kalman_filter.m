function results = kalman_filter(measurements, week_numbers, params, varargin)
    % KALMAN_FILTER Main Kalman filter loop for election prediction
    %
    % USAGE:
    %   results = kalman_filter(measurements, week_numbers, params)
    %   results = kalman_filter(measurements, week_numbers, params, 'ParamName', value, ...)
    %
    % DESCRIPTION:
    %   Runs the Kalman filter over a sequence of measurements (polling data)
    %   to estimate election win probability over time.
    %
    % INPUTS:
    %   measurements  - Vector of measurements (NaN for missing weeks)
    %   week_numbers  - Vector of week numbers corresponding to measurements
    %   params        - Parameters structure from kalman_init()
    %
    % OPTIONAL PARAMETERS:
    %   'verbose'     - Display progress (default: true)
    %   'transition_week' - Week of candidate transition (default: 38)
    %   'Q_transition'    - Increased Q during transition (default: 5*Q)
    %   'P_reset'         - Reset P during transition (default: 0.15)
    %
    % OUTPUTS:
    %   results - Structure containing:
    %       .x_est        : State estimates over time (Nx1)
    %       .P_est        : Covariance estimates over time (Nx1)
    %       .x_pred       : Predicted states (Nx1)
    %       .P_pred       : Predicted covariances (Nx1)
    %       .K            : Kalman gains (Nx1, NaN for missing data)
    %       .innovation   : Innovations (Nx1, NaN for missing data)
    %       .measurements : Original measurements (Nx1)
    %       .week_numbers : Week numbers (Nx1)
    %       .final_estimate   : Final win probability estimate
    %       .final_std        : Final standard deviation
    %       .transition_handled : Boolean if transition was applied
    %
    % EXAMPLE:
    %   params = kalman_init();
    %   measurements = [0.48, 0.47, NaN, 0.49, 0.50];
    %   week_numbers = [1, 2, 3, 4, 5];
    %   results = kalman_filter(measurements, week_numbers, params);
    %
    % See also: kalman_init, kalman_predict, kalman_update
    
    % Author: Election Kalman Filter Project
    % Date: October 2025
    
    %% Parse optional inputs
    p = inputParser;
    p.addParameter('verbose', true, @islogical);
    p.addParameter('transition_week', 38, @(x) isscalar(x) && x > 0);
    p.addParameter('Q_transition', 5 * params.Q, @(x) isscalar(x) && x > 0);
    p.addParameter('P_reset', 0.15, @(x) isscalar(x) && x > 0);
    p.parse(varargin{:});
    
    verbose = p.Results.verbose;
    transition_week = p.Results.transition_week;
    Q_transition = p.Results.Q_transition;
    P_reset = p.Results.P_reset;
    
    %% Validate inputs
    validateattributes(measurements, {'numeric'}, {'vector'}, ...
        'kalman_filter', 'measurements');
    validateattributes(week_numbers, {'numeric'}, {'vector'}, ...
        'kalman_filter', 'week_numbers');
    
    if length(measurements) ~= length(week_numbers)
        error('kalman_filter:InputSizeMismatch', ...
            'measurements and week_numbers must have the same length');
    end
    
    %% Initialize storage arrays
    N = length(measurements);
    x_est_history = zeros(N, 1);
    P_est_history = zeros(N, 1);
    x_pred_history = zeros(N, 1);
    P_pred_history = zeros(N, 1);
    K_history = nan(N, 1);  % NaN for weeks without measurements
    innovation_history = nan(N, 1);
    
    %% Initialize state
    x_est = params.x_est;
    P_est = params.P_est;
    transition_handled = false;
    
    %% Display header
    if verbose
        fprintf('\n=== Running Kalman Filter ===\n');
        fprintf('Total weeks: %d\n', N);
        fprintf('Measurements available: %d\n', sum(~isnan(measurements)));
        fprintf('Missing data: %d\n\n', sum(isnan(measurements)));
    end
    
    %% Main filter loop
    for i = 1:N
        week = week_numbers(i);
        z = measurements(i);
        
        % Check for candidate transition (Biden → Harris)
        if week == transition_week && ~transition_handled
            if verbose
                fprintf('Week %d: CANDIDATE TRANSITION (Biden → Harris)\n', week);
                fprintf('  Increasing process noise: Q = %.4f → %.4f\n', ...
                    params.Q, Q_transition);
                fprintf('  Resetting uncertainty: P = %.4f → %.4f\n', ...
                    P_est, P_reset);
            end
            P_est = P_reset;  % Reset uncertainty
            Q_current = Q_transition;  % Use increased process noise
            transition_handled = true;
        elseif week >= transition_week && week < transition_week + 3
            Q_current = Q_transition;  % Maintain high Q for 2-3 weeks
        else
            Q_current = params.Q;  % Normal process noise
        end
        
        % PREDICTION STEP
        [x_pred, P_pred] = kalman_predict(x_est, P_est, Q_current);
        
        % UPDATE STEP (if measurement available)
        if ~isnan(z)
            [x_est, P_est, K, innovation] = kalman_update(x_pred, P_pred, z, params.R);
            
            if verbose && (mod(i, 10) == 0 || week == transition_week)
                fprintf('Week %2d: z=%.3f → x=%.3f (±%.3f), K=%.3f, innov=%+.3f\n', ...
                    week, z, x_est, sqrt(P_est), K, innovation);
            end
        else
            % No measurement available - use prediction as estimate
            x_est = x_pred;
            P_est = P_pred;
            K = NaN;
            innovation = NaN;
            
            if verbose && mod(i, 10) == 0
                fprintf('Week %2d: [No data] → x=%.3f (±%.3f)\n', ...
                    week, x_est, sqrt(P_est));
            end
        end
        
        % Store results
        x_est_history(i) = x_est;
        P_est_history(i) = P_est;
        x_pred_history(i) = x_pred;
        P_pred_history(i) = P_pred;
        K_history(i) = K;
        innovation_history(i) = innovation;
    end
    
    %% Compile results
    results.x_est = x_est_history;
    results.P_est = P_est_history;
    results.x_pred = x_pred_history;
    results.P_pred = P_pred_history;
    results.K = K_history;
    results.innovation = innovation_history;
    results.measurements = measurements(:);
    results.week_numbers = week_numbers(:);
    results.final_estimate = x_est_history(end);
    results.final_std = sqrt(P_est_history(end));
    results.transition_handled = transition_handled;
    
    %% Display summary
    if verbose
        fprintf('\n=== Filtering Complete ===\n');
        fprintf('Final estimate: %.4f (%.2f%% win probability)\n', ...
            results.final_estimate, results.final_estimate * 100);
        fprintf('Final std dev:  %.4f\n', results.final_std);
        fprintf('95%% confidence: [%.2f%%, %.2f%%]\n', ...
            max(0, results.final_estimate - 1.96*results.final_std) * 100, ...
            min(1, results.final_estimate + 1.96*results.final_std) * 100);
        fprintf('Avg Kalman gain: %.3f\n', nanmean(K_history));
        fprintf('Avg innovation:  %.3f\n', nanmean(abs(innovation_history)));
    end
    
end
