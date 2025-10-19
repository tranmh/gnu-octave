function [Q_adjusted, P_adjusted, is_transition] = transition_handler(week_number, Q_base, P_current, varargin)
    % TRANSITION_HANDLER Handle Biden→Harris candidate transition
    %
    % On July 21, 2024 (approximately week 38), the Democratic candidate
    % switched from Biden to Harris. This function adjusts Kalman filter
    % parameters during the transition period to handle increased uncertainty
    %
    % Inputs:
    %   week_number - Current week number (1-52)
    %   Q_base      - Base process noise covariance
    %   P_current   - Current state uncertainty covariance
    %   varargin    - Optional parameters:
    %                 'transition_week', w - Week of transition (default: 38)
    %                 'transition_duration', d - Duration in weeks (default: 3)
    %                 'Q_multiplier', m - Process noise multiplier (default: 5.0)
    %                 'P_reset_value', p - Reset uncertainty value (default: 0.15)
    %
    % Outputs:
    %   Q_adjusted    - Adjusted process noise for this week
    %   P_adjusted    - Adjusted state uncertainty for this week
    %   is_transition - Boolean flag indicating if in transition period
    %
    % Transition Strategy:
    %   Week 38: Increase Q by 5x, reset P to 0.15 (high uncertainty)
    %   Week 39-40: Gradually decrease Q multiplier back to 1x
    %   Week 41+: Return to normal Q and P evolution
    %
    % Example:
    %   [Q, P, in_trans] = transition_handler(38, 0.001, 0.05);
    %   % Returns: Q = 0.005, P = 0.15, in_trans = true
    
    % Parse optional parameters
    p = inputParser;
    addParameter(p, 'transition_week', 38, @isnumeric);
    addParameter(p, 'transition_duration', 3, @isnumeric);
    addParameter(p, 'Q_multiplier', 5.0, @isnumeric);
    addParameter(p, 'P_reset_value', 0.15, @isnumeric);
    parse(p, varargin{:});
    
    transition_week = p.Results.transition_week;
    transition_duration = p.Results.transition_duration;
    Q_multiplier = p.Results.Q_multiplier;
    P_reset_value = p.Results.P_reset_value;
    
    % Initialize with base values
    Q_adjusted = Q_base;
    P_adjusted = P_current;
    is_transition = false;
    
    % Check if we're in the transition period
    if week_number >= transition_week && week_number < (transition_week + transition_duration)
        is_transition = true;
        
        % Calculate weeks since transition start
        weeks_since_transition = week_number - transition_week;
        
        if weeks_since_transition == 0
            % Week 38: Peak transition uncertainty
            % - Multiply Q by full multiplier (5x)
            % - Reset P to high value
            Q_adjusted = Q_base * Q_multiplier;
            P_adjusted = P_reset_value;
            
            fprintf('TRANSITION WEEK %d: Biden → Harris\n', week_number);
            fprintf('  Q increased: %.5f → %.5f (×%.1f)\n', Q_base, Q_adjusted, Q_multiplier);
            fprintf('  P reset: %.5f → %.5f\n', P_current, P_adjusted);
            
        else
            % Weeks 39-40: Gradually decrease multiplier
            % Linear decay: multiplier = Q_multiplier * (1 - weeks_since / duration)
            decay_factor = 1.0 - (weeks_since_transition / transition_duration);
            current_multiplier = 1.0 + (Q_multiplier - 1.0) * decay_factor;
            
            Q_adjusted = Q_base * current_multiplier;
            
            % P evolves naturally (no reset), but don't let it drop too fast
            P_adjusted = max(P_current, P_reset_value * decay_factor);
            
            fprintf('TRANSITION WEEK %d: Adjusting (day %d of transition)\n', ...
                    week_number, weeks_since_transition * 7);
            fprintf('  Q multiplier: %.2fx\n', current_multiplier);
            fprintf('  P maintained at: %.5f\n', P_adjusted);
        end
        
    else
        % Normal operation (not in transition)
        Q_adjusted = Q_base;
        P_adjusted = P_current;
    end
    
    % Validate outputs
    if Q_adjusted <= 0
        error('Q_adjusted must be positive');
    end
    if P_adjusted <= 0
        error('P_adjusted must be positive');
    end
    
end
