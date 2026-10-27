function [weekly_data] = aggregate_weekly()
    % AGGREGATE_WEEKLY Create weekly aggregated polling averages
    %
    % This function takes the parsed poll data and creates weekly averages
    % for the 52-week period from Nov 5, 2023 to Nov 5, 2024
    %
    % Aggregation method:
    %   - Group polls by week number
    %   - Calculate mean and standard deviation for each candidate
    %   - Weight by sample size (optional)
    %   - Handle weeks with no polls (interpolation)
    %
    % Output:
    %   weekly_data: Structure array with fields:
    %     .week_number    - Week number (1-52)
    %     .week_start     - Week start date (datenum)
    %     .week_end       - Week end date (datenum)
    %     .dem_avg        - Democratic candidate average percentage
    %     .rep_avg        - Republican candidate average percentage
    %     .dem_std        - Democratic candidate std dev
    %     .rep_std        - Republican candidate std dev
    %     .num_polls      - Number of polls in this week
    %     .dem_candidate  - 'Biden' or 'Harris'
    %
    % Also saves to: data/processed/weekly_polls.csv
    %
    % Usage:
    %   weekly_data = aggregate_weekly();
    
    fprintf('=== Aggregating Weekly Polling Data ===\n\n');
    
    % Get directory paths
    script_dir = fileparts(mfilename('fullpath'));
    processed_dir = fullfile(script_dir, 'processed');
    
    % Input file
    input_file = fullfile(processed_dir, 'parsed_polls.csv');
    
    if ~exist(input_file, 'file')
        error('Input file not found: %s\nRun parse_polls.m first.', input_file);
    end
    
    fprintf('Reading: %s\n', input_file);
    
    % Read parsed polls
    fid = fopen(input_file, 'r');
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
            poll.date_str = parts{2};
            poll.pollster = parts{3};
            poll.sample_size = str2double(parts{4});
            poll.population = parts{5};
            poll.state = parts{6};
            poll.dem_candidate = parts{7};
            poll.rep_candidate = parts{8};
            poll.dem_pct = str2double(parts{9});
            poll.rep_pct = str2double(parts{10});
            
            poll_data = [poll_data; poll];
        end
    end
    fclose(fid);
    
    fprintf('Read %d polls\n', length(poll_data));
    
    % Define 52-week period
    election_date = datenum('2024-11-05');
    start_date = datenum('2023-11-05');
    
    % Initialize weekly data structure for 52 weeks
    weekly_data = struct('week_number', {}, 'week_start', {}, 'week_end', {}, ...
                         'week_start_str', {}, 'week_end_str', {}, ...
                         'dem_avg', {}, 'rep_avg', {}, 'dem_std', {}, 'rep_std', {}, ...
                         'num_polls', {}, 'dem_candidate', {});
    
    fprintf('\nAggregating by week...\n');
    
    for week = 1:52
        % Calculate week boundaries
        week_start = start_date + (week - 1) * 7;
        week_end = week_start + 6;
        
        % Find polls in this week
        week_mask = ([poll_data.date] >= week_start) & ([poll_data.date] <= week_end);
        week_polls = poll_data(week_mask);
        
        % Create week entry
        wk.week_number = week;
        wk.week_start = week_start;
        wk.week_end = week_end;
        wk.week_start_str = datestr(week_start, 'yyyy-mm-dd');
        wk.week_end_str = datestr(week_end, 'yyyy-mm-dd');
        wk.num_polls = length(week_polls);
        
        if wk.num_polls > 0
            % Calculate averages and std devs
            wk.dem_avg = mean([week_polls.dem_pct]);
            wk.rep_avg = mean([week_polls.rep_pct]);
            wk.dem_std = std([week_polls.dem_pct]);
            wk.rep_std = std([week_polls.rep_pct]);
            
            % Determine candidate (majority vote in the week)
            candidates = {week_polls.dem_candidate};
            if sum(strcmp(candidates, 'Harris')) > sum(strcmp(candidates, 'Biden'))
                wk.dem_candidate = 'Harris';
            else
                wk.dem_candidate = 'Biden';
            end
        else
            % No polls this week - will be handled by interpolation later
            wk.dem_avg = NaN;
            wk.rep_avg = NaN;
            wk.dem_std = NaN;
            wk.rep_std = NaN;
            wk.dem_candidate = 'Unknown';
        end
        
        weekly_data = [weekly_data; wk];
    end
    
    % Handle missing weeks with linear interpolation
    fprintf('Handling weeks with no polls...\n');
    
    weeks_with_polls = sum([weekly_data.num_polls] > 0);
    weeks_without_polls = 52 - weeks_with_polls;
    fprintf('  Weeks with polls: %d\n', weeks_with_polls);
    fprintf('  Weeks without polls: %d\n', weeks_without_polls);
    
    if weeks_without_polls > 0
        % Get indices of weeks with data
        valid_idx = find([weekly_data.num_polls] > 0);
        
        % Interpolate dem_avg
        dem_avg_interp = interp1(valid_idx, [weekly_data(valid_idx).dem_avg], ...
                                 1:52, 'linear', 'extrap');
        
        % Interpolate rep_avg
        rep_avg_interp = interp1(valid_idx, [weekly_data(valid_idx).rep_avg], ...
                                 1:52, 'linear', 'extrap');
        
        % Fill in missing values
        for i = 1:52
            if weekly_data(i).num_polls == 0
                weekly_data(i).dem_avg = dem_avg_interp(i);
                weekly_data(i).rep_avg = rep_avg_interp(i);
                weekly_data(i).dem_std = 2.0;  % Default uncertainty
                weekly_data(i).rep_std = 2.0;
            end
        end
    end
    
    % Determine candidate for missing weeks based on date
    transition_date = datenum('2024-07-21');
    for i = 1:52
        if strcmp(weekly_data(i).dem_candidate, 'Unknown')
            if weekly_data(i).week_start < transition_date
                weekly_data(i).dem_candidate = 'Biden';
            else
                weekly_data(i).dem_candidate = 'Harris';
            end
        end
    end
    
    % Save to CSV
    output_file = fullfile(processed_dir, 'weekly_polls.csv');
    fprintf('\nSaving to: %s\n', output_file);
    
    fid = fopen(output_file, 'w');
    fprintf(fid, 'week_number,week_start,week_end,dem_avg,rep_avg,dem_std,rep_std,num_polls,dem_candidate\n');
    
    for i = 1:length(weekly_data)
        fprintf(fid, '%d,%s,%s,%.2f,%.2f,%.2f,%.2f,%d,%s\n', ...
                weekly_data(i).week_number, ...
                weekly_data(i).week_start_str, ...
                weekly_data(i).week_end_str, ...
                weekly_data(i).dem_avg, ...
                weekly_data(i).rep_avg, ...
                weekly_data(i).dem_std, ...
                weekly_data(i).rep_std, ...
                weekly_data(i).num_polls, ...
                weekly_data(i).dem_candidate);
    end
    
    fclose(fid);
    
    % Display summary statistics
    fprintf('\n=== Weekly Aggregation Summary ===\n');
    fprintf('Total weeks: 52\n');
    fprintf('Weeks with actual polls: %d\n', weeks_with_polls);
    fprintf('Weeks interpolated: %d\n', weeks_without_polls);
    
    biden_weeks = sum(strcmp({weekly_data.dem_candidate}, 'Biden'));
    harris_weeks = sum(strcmp({weekly_data.dem_candidate}, 'Harris'));
    fprintf('Biden weeks: %d\n', biden_weeks);
    fprintf('Harris weeks: %d\n', harris_weeks);
    
    fprintf('\nDemocratic average range: %.1f%% - %.1f%%\n', ...
            min([weekly_data.dem_avg]), max([weekly_data.dem_avg]));
    fprintf('Republican average range: %.1f%% - %.1f%%\n', ...
            min([weekly_data.rep_avg]), max([weekly_data.rep_avg]));
    
    fprintf('\n=== Aggregation Complete ===\n');
    fprintf('Next step: Run handle_transition.m to verify Biden→Harris transition\n');
    
end
