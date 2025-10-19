function [results] = weekly_processor(varargin)
    % WEEKLY_PROCESSOR Main pipeline for weekly Kalman filter updates
    %
    % This function processes 52 weeks of polling data through the Kalman filter,
    % handling poll aggregation, probability conversion, and candidate transition
    %
    % Inputs (optional name-value pairs):
    %   'data_file'     - Path to weekly_polls.csv (default: data/processed/weekly_polls.csv)
    %   'Q'             - Process noise covariance (default: 0.001)
    %   'R_base'        - Base measurement noise (default: 0.05)
    %   'x0'            - Initial state (default: 0.5)
    %   'P0'            - Initial uncertainty (default: 0.1)
    %   'save_results'  - Save results to file (default: true)
    %   'verbose'       - Print progress (default: true)
    %
    % Outputs:
    %   results - Structure array with weekly results:
    %     .week_number    - Week number (1-52)
    %     .date           - Week start date
    %     .dem_candidate  - 'Biden' or 'Harris'
    %     .poll_obs       - Polling observation (win probability)
    %     .x_pred         - Predicted state
    %     .P_pred         - Predicted uncertainty
    %     .x_est          - Estimated state (after update)
    %     .P_est          - Estimated uncertainty (after update)
    %     .K              - Kalman gain
    %     .innovation     - Measurement innovation (z - x_pred)
    %     .Q_used         - Process noise used this week
    %     .R_used         - Measurement noise used this week
    %
    % Also saves to: results/kalman_estimates.csv
    %
    % Example:
    %   results = weekly_processor('Q', 0.002, 'verbose', true);
    
    fprintf('\n');
    fprintf('=================================================\n');
    fprintf('   KALMAN FILTER WEEKLY PROCESSOR - Phase 3\n');
    fprintf('=================================================\n\n');
    
    % Parse optional parameters
    p = inputParser;
    addParameter(p, 'data_file', '', @ischar);
    addParameter(p, 'params', [], @(x) isempty(x) || isstruct(x));  % NEW: Accept params struct
    addParameter(p, 'Q', 0.001, @isnumeric);
    addParameter(p, 'R_base', 0.05, @isnumeric);
    addParameter(p, 'x0', 0.5, @isnumeric);
    addParameter(p, 'P0', 0.1, @isnumeric);
    addParameter(p, 'save_results', true, @islogical);
    addParameter(p, 'verbose', true, @islogical);
    parse(p, varargin{:});
    
    % Extract params from struct if provided, otherwise use individual parameters
    if ~isempty(p.Results.params)
        params = p.Results.params;
        Q = params.Q;
        R_base = params.R;
        x0 = params.x0;
        P0 = params.P0;
    else
        Q = p.Results.Q;
        R_base = p.Results.R_base;
        x0 = p.Results.x0;
        P0 = p.Results.P0;
    end
    
    % Extract other parameters
    data_file = p.Results.data_file;
    save_results_flag = p.Results.save_results;
    verbose = p.Results.verbose;
    
    % Determine data file path
    if isempty(p.Results.data_file)
        script_dir = fileparts(mfilename('fullpath'));
        project_dir = fileparts(script_dir);
        data_file = fullfile(project_dir, 'data', 'processed', 'weekly_polls.csv');
    else
        data_file = p.Results.data_file;
    end
    
    % Verify data file exists
    if ~exist(data_file, 'file')
        error('Data file not found: %s\nRun aggregate_weekly.m first.', data_file);
    end
    
    if verbose
        fprintf('Reading data from: %s\n', data_file);
    end
    
    % Read weekly polling data
    fid = fopen(data_file, 'r');
    header = fgetl(fid);  % Skip header
    
    weekly_data = [];
    while ~feof(fid)
        line = fgetl(fid);
        if ~ischar(line)
            break;
        end
        
        parts = strsplit(line, ',');
        if length(parts) >= 9
            wk.week_number = str2double(parts{1});
            wk.week_start = parts{2};
            wk.week_end = parts{3};
            wk.dem_avg = str2double(parts{4});
            wk.rep_avg = str2double(parts{5});
            wk.dem_std = str2double(parts{6});
            wk.rep_std = str2double(parts{7});
            wk.num_polls = str2double(parts{8});
            wk.dem_candidate = parts{9};
            
            weekly_data = [weekly_data; wk];
        end
    end
    fclose(fid);
    
    if verbose
        fprintf('Loaded %d weeks of polling data\n\n', length(weekly_data));
    end
    
    % Initialize Kalman filter
    if verbose
        fprintf('Initializing Kalman filter...\n');
        fprintf('  Initial state x0 = %.3f\n', x0);
        fprintf('  Initial uncertainty P0 = %.3f\n', P0);
        fprintf('  Process noise Q = %.5f\n', Q);
        fprintf('  Base measurement noise R = %.3f\n\n', R_base);
    end
    
    % Initialize state
    x_est = x0;
    P_est = P0;
    
    % Initialize results storage
    details = struct('week_number', {}, 'date', {}, 'dem_candidate', {}, ...
                     'poll_obs', {}, 'x_pred', {}, 'P_pred', {}, ...
                     'x_est', {}, 'P_est', {}, 'K', {}, 'innovation', {}, ...
                     'Q_used', {}, 'R_used', {});
    
    if verbose
        fprintf('Processing 52 weeks...\n');
        fprintf('%-4s %-12s %-8s %-8s %-8s %-8s %-8s %-6s\n', ...
                'Week', 'Date', 'Cand', 'PollProb', 'Pred', 'Estimate', 'Uncert', 'Gain');
        fprintf('%s\n', repmat('-', 1, 75));
    end
    
    % Process each week
    for i = 1:length(weekly_data)
        wk = weekly_data(i);
        week_num = wk.week_number;
        
        % Handle candidate transition (adjust Q and P if needed)
        [Q_adj, P_adj, is_trans] = transition_handler(week_num, Q, P_est);
        
        % === PREDICTION STEP ===
        [x_pred, P_pred] = kalman_predict(x_est, P_est, Q_adj);
        
        % === MEASUREMENT PROCESSING ===
        % Aggregate polls for this week
        agg = multi_poll_aggregator(wk);
        
        % Convert polling percentages to win probability
        if ~isnan(agg.dem_pct)
            [z_obs, R_meas] = polls_to_probability(agg.dem_pct, agg.rep_pct, ...
                                                     agg.dem_std, agg.rep_std);
            
            % Adjust measurement noise based on number of polls (more polls = less noise)
            R_meas = R_meas * (1.0 / sqrt(max(1, agg.num_polls)));
            
        else
            % No measurement this week
            z_obs = NaN;
            R_meas = R_base;
        end
        
        % === UPDATE STEP ===
        if ~isnan(z_obs)
            % Measurement available - perform Kalman update
            [x_est, P_est, K, innovation] = kalman_update(x_pred, P_pred, z_obs, R_meas);
        else
            % No measurement - keep prediction as estimate
            x_est = x_pred;
            P_est = P_pred;
            K = 0;
            innovation = 0;
        end
        
        % Apply P adjustment from transition handler if needed
        if is_trans
            P_est = P_adj;
        end
        
        % Store results
        res.week_number = week_num;
        res.date = wk.week_start;
        res.dem_candidate = wk.dem_candidate;
        res.poll_obs = z_obs;
        res.x_pred = x_pred;
        res.P_pred = P_pred;
        res.x_est = x_est;
        res.P_est = P_est;
        res.K = K;
        res.innovation = innovation;
        res.Q_used = Q_adj;
        res.R_used = R_meas;
        
        details = [details; res];
        
        % Print progress
        if verbose
            cand_short = wk.dem_candidate(1);  % 'B' or 'H'
            if ~isnan(z_obs)
                fprintf('%-4d %-12s %-8s %-8.4f %-8.4f %-8.4f %-8.4f %-6.3f\n', ...
                        week_num, wk.week_start, cand_short, z_obs, x_pred, x_est, ...
                        sqrt(P_est), K);
            else
                fprintf('%-4d %-12s %-8s %-8s %-8.4f %-8.4f %-8.4f %-6s\n', ...
                        week_num, wk.week_start, cand_short, 'N/A', x_pred, x_est, ...
                        sqrt(P_est), '--');
            end
        end
    end
    
    if verbose
        fprintf('%s\n\n', repmat('-', 1, 75));
    end
    
    % Save results to file
    if save_results_flag
        script_dir = fileparts(mfilename('fullpath'));
        project_dir = fileparts(script_dir);
        results_dir = fullfile(project_dir, 'results');
        
        % Create results directory if it doesn't exist
        if ~exist(results_dir, 'dir')
            mkdir(results_dir);
        end
        
        output_file = fullfile(results_dir, 'kalman_estimates.csv');
        
        if verbose
            fprintf('Saving results to: %s\n', output_file);
        end
        
        fid = fopen(output_file, 'w');
        fprintf(fid, 'week_number,date,dem_candidate,poll_obs,x_pred,P_pred,x_est,P_est,K,innovation,Q_used,R_used\n');
        
        for i = 1:length(details)
            r = details(i);
            fprintf(fid, '%d,%s,%s,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.8f,%.6f\n', ...
                    r.week_number, r.date, r.dem_candidate, ...
                    r.poll_obs, r.x_pred, r.P_pred, r.x_est, r.P_est, ...
                    r.K, r.innovation, r.Q_used, r.R_used);
        end
        
        fclose(fid);
    end
    
    % Display summary statistics
    if verbose
        fprintf('\n=== Weekly Processing Summary ===\n');
        fprintf('Total weeks processed: %d\n', length(details));
        
        % Count measurements
        valid_obs = sum(~isnan([details.poll_obs]));
        fprintf('Weeks with polling observations: %d\n', valid_obs);
        fprintf('Weeks without observations: %d\n', 52 - valid_obs);
        
        % Final estimate
        final_est = details(end).x_est;
        final_std = sqrt(details(end).P_est);
        fprintf('\n--- Final Prediction (Week 52) ---\n');
        fprintf('Democratic win probability: %.2f%% ± %.2f%%\n', ...
                final_est * 100, final_std * 100 * 1.96);
        
        if final_est > 0.5
            fprintf('Prediction: Democratic nominee (Harris) wins\n');
        else
            fprintf('Prediction: Republican nominee (Trump) wins\n');
        end
        
        % Actual result (for reference)
        fprintf('\n--- Actual 2024 Result ---\n');
        fprintf('Winner: Donald Trump (Republican)\n');
        fprintf('Popular vote: Trump ~50.1%%, Harris ~48.3%%\n');
        
        % Compare prediction vs actual
        % Convert actual result to approximate win probability
        actual_margin = (48.3 - 50.1) / 100;  % Negative = Trump won
        actual_prob = 1.0 / (1.0 + exp(-15 * actual_margin));  % ~0.39
        
        prediction_error = abs(final_est - actual_prob);
        fprintf('\nPrediction error: %.2f%% (probability scale)\n', prediction_error * 100);
        
        % Kalman gain statistics
        valid_gains = [details.K](~isnan([details.poll_obs]));
        fprintf('\n--- Filter Statistics ---\n');
        fprintf('Average Kalman gain: %.3f\n', mean(valid_gains));
        fprintf('Kalman gain range: %.3f - %.3f\n', min(valid_gains), max(valid_gains));
        
        % Innovation statistics
        valid_innov = [details.innovation](~isnan([details.poll_obs]));
        fprintf('Mean innovation: %.4f\n', mean(valid_innov));
        fprintf('Innovation std: %.4f\n', std(valid_innov));
        
        fprintf('\n=== Processing Complete ===\n');
        fprintf('Next steps:\n');
        fprintf('  - Phase 4: Run backtesting (backtest/run_backtest.m)\n');
        fprintf('  - Phase 5: Generate visualizations (viz/plot_prediction_timeline.m)\n\n');
    end
    
    % Create output structure with both detailed results and convenience fields
    results = struct();
    results.details = details;  % Original struct array with all weekly details
    results.win_prob_history = [details.x_est]';
    results.uncertainty_history = sqrt([details.P_est]');
    results.week_numbers = [details.week_number]';
    results.dates = {details.date}';
    
end
