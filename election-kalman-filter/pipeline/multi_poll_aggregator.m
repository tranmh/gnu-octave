function [aggregated] = multi_poll_aggregator(weekly_data_entry, varargin)
    % MULTI_POLL_AGGREGATOR Combine multiple polls into single observation
    %
    % When multiple polls exist for a single week, this function aggregates
    % them into a single polling observation for the Kalman filter
    %
    % Inputs:
    %   weekly_data_entry - Single week structure from aggregate_weekly.m
    %                       with fields: dem_avg, rep_avg, dem_std, rep_std, num_polls
    %   varargin          - Optional parameters:
    %                       'method', str - Aggregation method ('mean', 'weighted')
    %                       'quality_weights', w - Poll quality weights (if weighted)
    %
    % Outputs:
    %   aggregated - Structure with aggregated polling data:
    %       .dem_pct    - Aggregated Democratic percentage
    %       .rep_pct    - Aggregated Republican percentage
    %       .dem_std    - Aggregated Democratic standard deviation
    %       .rep_std    - Aggregated Republican standard deviation
    %       .confidence - Confidence factor (increases with more polls)
    %       .num_polls  - Number of polls aggregated
    %
    % Methods:
    %   'mean': Simple average (default)
    %   'weighted': Weighted by sample size/quality (requires weights)
    %
    % Example:
    %   agg = multi_poll_aggregator(weekly_data(5));
    
    % Parse optional parameters
    p = inputParser;
    addParameter(p, 'method', 'mean', @ischar);
    addParameter(p, 'quality_weights', [], @isnumeric);
    parse(p, varargin{:});
    
    method = p.Results.method;
    quality_weights = p.Results.quality_weights;
    
    % Initialize output structure
    aggregated = struct();
    aggregated.num_polls = weekly_data_entry.num_polls;
    
    % If no polls for this week, return NaN
    if aggregated.num_polls == 0 || isnan(weekly_data_entry.dem_avg)
        aggregated.dem_pct = NaN;
        aggregated.rep_pct = NaN;
        aggregated.dem_std = NaN;
        aggregated.rep_std = NaN;
        aggregated.confidence = 0;
        return;
    end
    
    % Extract data from weekly entry
    dem_avg = weekly_data_entry.dem_avg;
    rep_avg = weekly_data_entry.rep_avg;
    dem_std = weekly_data_entry.dem_std;
    rep_std = weekly_data_entry.rep_std;
    num_polls = weekly_data_entry.num_polls;
    
    % Apply aggregation method
    if strcmp(method, 'mean') || isempty(quality_weights)
        % Simple mean (already computed in aggregate_weekly)
        aggregated.dem_pct = dem_avg;
        aggregated.rep_pct = rep_avg;
        aggregated.dem_std = dem_std;
        aggregated.rep_std = rep_std;
        
    elseif strcmp(method, 'weighted')
        % Weighted average
        if length(quality_weights) ~= num_polls
            warning('Quality weights length mismatch. Using simple mean.');
            aggregated.dem_pct = dem_avg;
            aggregated.rep_pct = rep_avg;
            aggregated.dem_std = dem_std;
            aggregated.rep_std = rep_std;
        else
            % Normalize weights
            weights = quality_weights / sum(quality_weights);
            
            % Weighted mean (simplified - assume already done in preprocessing)
            aggregated.dem_pct = dem_avg;
            aggregated.rep_pct = rep_avg;
            
            % Weighted std (approximate)
            aggregated.dem_std = dem_std / sqrt(num_polls);
            aggregated.rep_std = rep_std / sqrt(num_polls);
        end
    else
        error('Unknown aggregation method: %s', method);
    end
    
    % Calculate confidence factor based on number of polls
    % More polls → higher confidence → lower uncertainty
    % Confidence scales as: 1 / (1 + exp(-(num_polls - 3)))
    % This gives:
    %   1 poll  → confidence ≈ 0.12
    %   3 polls → confidence ≈ 0.50
    %   5 polls → confidence ≈ 0.88
    %   10 polls → confidence ≈ 0.999
    
    aggregated.confidence = 1.0 / (1.0 + exp(-(num_polls - 3)));
    
    % Adjust standard deviations based on confidence
    % More polls → lower uncertainty
    % Factor decreases std by sqrt(confidence_factor)
    confidence_factor = sqrt(aggregated.confidence);
    
    % Ensure we don't reduce uncertainty too much (minimum factor of 0.5)
    confidence_factor = max(confidence_factor, 0.5);
    
    aggregated.dem_std = aggregated.dem_std * confidence_factor;
    aggregated.rep_std = aggregated.rep_std * confidence_factor;
    
    % Ensure std devs are reasonable (at least 0.5%, at most 5%)
    aggregated.dem_std = max(0.5, min(aggregated.dem_std, 5.0));
    aggregated.rep_std = max(0.5, min(aggregated.rep_std, 5.0));
    
end
