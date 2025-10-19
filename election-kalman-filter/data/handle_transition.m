function handle_transition()
    % HANDLE_TRANSITION Analyze and verify Biden→Harris transition period
    %
    % This function analyzes the candidate transition that occurred on July 21, 2024
    % and provides diagnostic information about how it affects the polling data.
    %
    % Key aspects checked:
    %   - Week number when transition occurred
    %   - Number of Biden vs Harris polls before/after
    %   - Polling percentage shifts
    %   - Recommendations for Kalman filter noise parameters
    %
    % Usage:
    %   handle_transition();
    
    fprintf('=== Biden→Harris Transition Analysis ===\n\n');
    
    % Get directory paths
    script_dir = fileparts(mfilename('fullpath'));
    processed_dir = fullfile(script_dir, 'processed');
    
    % Input files
    parsed_file = fullfile(processed_dir, 'parsed_polls.csv');
    weekly_file = fullfile(processed_dir, 'weekly_polls.csv');
    
    if ~exist(parsed_file, 'file')
        error('Parsed polls not found. Run parse_polls.m first.');
    end
    
    if ~exist(weekly_file, 'file')
        error('Weekly polls not found. Run aggregate_weekly.m first.');
    end
    
    % Define transition date
    transition_date = datenum('2024-07-21');
    election_date = datenum('2024-11-05');
    start_date = datenum('2023-11-05');
    
    % Calculate transition week number
    days_elapsed = transition_date - start_date;
    transition_week = ceil(days_elapsed / 7);
    
    fprintf('Transition date: July 21, 2024\n');
    fprintf('Transition week: %d (of 52)\n', transition_week);
    fprintf('Weeks remaining to election: %d\n\n', 52 - transition_week);
    
    % Read parsed polls
    fprintf('Reading parsed polls...\n');
    fid = fopen(parsed_file, 'r');
    header = fgetl(fid);  % Skip header
    
    poll_data = [];
    while ~feof(fid)
        line = fgetl(fid);
        if ~ischar(line)
            break;
        end
        
        parts = strsplit(line, ',');
        if length(parts) >= 10
            poll.date = str2double(parts{1});
            poll.dem_candidate = parts{7};
            poll.dem_pct = str2double(parts{9});
            poll.rep_pct = str2double(parts{10});
            poll_data = [poll_data; poll];
        end
    end
    fclose(fid);
    
    % Separate Biden and Harris polls
    biden_polls = poll_data(strcmp({poll_data.dem_candidate}, 'Biden'));
    harris_polls = poll_data(strcmp({poll_data.dem_candidate}, 'Harris'));
    
    fprintf('Total polls: %d\n', length(poll_data));
    fprintf('Biden polls: %d\n', length(biden_polls));
    fprintf('Harris polls: %d\n\n', length(harris_polls));
    
    % Analyze polling before and after transition
    % Look at 2 weeks before and 2 weeks after
    pre_window = [transition_date - 14, transition_date];
    post_window = [transition_date, transition_date + 14];
    
    biden_pre = biden_polls([biden_polls.date] >= pre_window(1) & [biden_polls.date] < pre_window(2));
    harris_post = harris_polls([harris_polls.date] >= post_window(1) & [harris_polls.date] <= post_window(2));
    
    fprintf('=== Two weeks before transition (Biden) ===\n');
    if ~isempty(biden_pre)
        fprintf('Number of polls: %d\n', length(biden_pre));
        fprintf('Biden average: %.1f%%\n', mean([biden_pre.dem_pct]));
        fprintf('Trump average: %.1f%%\n', mean([biden_pre.rep_pct]));
        fprintf('Biden margin: %.1f%%\n\n', mean([biden_pre.dem_pct]) - mean([biden_pre.rep_pct]));
    else
        fprintf('No polls found\n\n');
    end
    
    fprintf('=== Two weeks after transition (Harris) ===\n');
    if ~isempty(harris_post)
        fprintf('Number of polls: %d\n', length(harris_post));
        fprintf('Harris average: %.1f%%\n', mean([harris_post.dem_pct]));
        fprintf('Trump average: %.1f%%\n', mean([harris_post.rep_pct]));
        fprintf('Harris margin: %.1f%%\n\n', mean([harris_post.dem_pct]) - mean([harris_post.rep_pct]));
        
        % Calculate shift
        if ~isempty(biden_pre)
            shift = mean([harris_post.dem_pct]) - mean([biden_pre.dem_pct]);
            fprintf('Democratic polling shift: %.1f%% (%s)\n\n', ...
                    abs(shift), iif(shift > 0, 'Harris improved', 'Harris declined'));
        end
    else
        fprintf('No polls found\n\n');
    end
    
    % Read weekly data
    fprintf('Reading weekly aggregated data...\n');
    fid = fopen(weekly_file, 'r');
    header = fgetl(fid);  % Skip header
    
    weekly_data = [];
    while ~feof(fid)
        line = fgetl(fid);
        if ~ischar(line)
            break;
        end
        
        parts = strsplit(line, ',');
        if length(parts) >= 9
            wk.week = str2double(parts{1});
            wk.dem_avg = str2double(parts{4});
            wk.dem_candidate = parts{9};
            weekly_data = [weekly_data; wk];
        end
    end
    fclose(fid);
    
    % Find transition week in weekly data
    transition_week_data = weekly_data(transition_week);
    
    fprintf('Week %d candidate: %s\n', transition_week, transition_week_data.dem_candidate);
    fprintf('Week %d Dem average: %.1f%%\n\n', transition_week, transition_week_data.dem_avg);
    
    % Recommendations for Kalman filter
    fprintf('=== Recommendations for Kalman Filter ===\n\n');
    fprintf('1. Transition handling strategy:\n');
    fprintf('   - Increase process noise Q for weeks %d-%d\n', ...
            transition_week, transition_week + 2);
    fprintf('   - Suggested: Q_transition = 5 * Q_normal\n\n');
    
    fprintf('2. Uncertainty reset:\n');
    fprintf('   - Reset uncertainty P at week %d\n', transition_week);
    fprintf('   - Suggested: P_reset = 0.15 (higher uncertainty)\n\n');
    
    fprintf('3. Candidate tracking:\n');
    fprintf('   - Continue tracking "Democratic nominee" probability\n');
    fprintf('   - No state reset needed (both are Democratic candidates)\n\n');
    
    fprintf('4. Expected behavior:\n');
    fprintf('   - Filter should show increased uncertainty during transition\n');
    fprintf('   - Gradual convergence as Harris polls accumulate\n');
    fprintf('   - Sharp changes in win probability if polling shifts significantly\n\n');
    
    fprintf('=== Transition Analysis Complete ===\n');
    fprintf('Phase 1 complete. Ready for Phase 2: Kalman Filter Core Implementation\n');
    
end

function result = iif(condition, true_val, false_val)
    if condition
        result = true_val;
    else
        result = false_val;
    end
end
