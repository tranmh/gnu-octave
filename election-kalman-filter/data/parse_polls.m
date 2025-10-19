function [poll_data] = parse_polls()
    % PARSE_POLLS Parse and clean raw polling data from FiveThirtyEight
    %
    % This function reads the downloaded polling CSV, filters for 2024 presidential
    % polls between Trump and Biden/Harris, and cleans the data for further processing
    %
    % Filters applied:
    %   - Presidential race only
    %   - 2024 election cycle (Nov 5, 2023 - Nov 5, 2024)
    %   - Trump vs Biden or Trump vs Harris matchups
    %   - Valid polling percentages (0-100)
    %
    % Output:
    %   poll_data: Structure array with fields:
    %     .date         - Poll date (datenum)
    %     .pollster     - Pollster name
    %     .sample_size  - Number of respondents
    %     .dem_pct      - Democratic candidate percentage
    %     .rep_pct      - Republican candidate percentage
    %     .dem_candidate - 'Biden' or 'Harris'
    %     .rep_candidate - 'Trump'
    %     .state        - State (or 'National')
    %     .population   - Sample type (rv, lv, a)
    %
    % Also saves processed data to: data/processed/parsed_polls.csv
    %
    % Usage:
    %   poll_data = parse_polls();
    
    fprintf('=== Parsing Polling Data ===\n\n');
    
    % Get directory paths
    script_dir = fileparts(mfilename('fullpath'));
    raw_dir = fullfile(script_dir, 'raw');
    processed_dir = fullfile(script_dir, 'processed');
    
    % Create processed directory if it doesn't exist
    if ~exist(processed_dir, 'dir')
        mkdir(processed_dir);
    end
    
    % Input file
    input_file = fullfile(raw_dir, 'fivethirtyeight_polls.csv');
    
    if ~exist(input_file, 'file')
        error('Input file not found: %s\nRun download_data.m first.', input_file);
    end
    
    fprintf('Reading: %s\n', input_file);
    
    % Read CSV file
    % Note: FiveThirtyEight CSV has many columns, we'll read as text first
    fid = fopen(input_file, 'r');
    if fid == -1
        error('Could not open file: %s', input_file);
    end
    
    % Read header line
    header_line = fgetl(fid);
    headers = strsplit(header_line, ',');
    
    % Find column indices (FiveThirtyEight column names)
    col_idx = struct();
    for i = 1:length(headers)
        h = strtrim(headers{i});
        if strcmp(h, 'question_id')
            col_idx.question_id = i;
        elseif strcmp(h, 'poll_id')
            col_idx.poll_id = i;
        elseif strcmp(h, 'pollster')
            col_idx.pollster = i;
        elseif strcmp(h, 'sponsor')
            col_idx.sponsor = i;
        elseif strcmp(h, 'start_date')
            col_idx.start_date = i;
        elseif strcmp(h, 'end_date')
            col_idx.end_date = i;
        elseif strcmp(h, 'sample_size')
            col_idx.sample_size = i;
        elseif strcmp(h, 'population')
            col_idx.population = i;
        elseif strcmp(h, 'candidate_name')
            col_idx.candidate_name = i;
        elseif strcmp(h, 'candidate_party')
            col_idx.candidate_party = i;
        elseif strcmp(h, 'pct')
            col_idx.pct = i;
        elseif strcmp(h, 'state')
            col_idx.state = i;
        end
    end
    
    fprintf('Reading poll data...\n');
    
    % Read all data lines
    data_lines = {};
    line_count = 0;
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            line_count = line_count + 1;
            data_lines{end+1} = line;
        end
    end
    fclose(fid);
    
    fprintf('Read %d data rows\n', line_count);
    
    % Parse data and filter for 2024 presidential race
    fprintf('Filtering for 2024 presidential polls...\n');
    
    % Define date range: Nov 5, 2023 - Nov 5, 2024
    start_date = datenum('2023-11-05');
    end_date = datenum('2024-11-05');
    
    % Initialize storage
    poll_records = [];
    skipped_count = 0;
    
    % Process each line
    for i = 1:length(data_lines)
        try
            parts = strsplit(data_lines{i}, ',');
            
            if length(parts) < max(struct2array(col_idx))
                skipped_count = skipped_count + 1;
                continue;
            end
            
            % Extract fields
            poll_date_str = strtrim(parts{col_idx.end_date});
            candidate_name = strtrim(parts{col_idx.candidate_name});
            candidate_party = strtrim(parts{col_idx.candidate_party});
            pct_str = strtrim(parts{col_idx.pct});
            
            % Parse date
            poll_date = datenum(poll_date_str);
            
            % Filter by date range
            if poll_date < start_date || poll_date > end_date
                continue;
            end
            
            % Filter by candidates (Trump, Biden, Harris)
            if ~(strcmp(candidate_name, 'Donald Trump') || ...
                 strcmp(candidate_name, 'Joe Biden') || ...
                 strcmp(candidate_name, 'Kamala Harris'))
                continue;
            end
            
            % Parse percentage
            pct = str2double(pct_str);
            if isnan(pct) || pct < 0 || pct > 100
                continue;
            end
            
            % Store record
            record.poll_id = strtrim(parts{col_idx.poll_id});
            record.question_id = strtrim(parts{col_idx.question_id});
            record.pollster = strtrim(parts{col_idx.pollster});
            record.date = poll_date;
            record.date_str = poll_date_str;
            record.sample_size = str2double(strtrim(parts{col_idx.sample_size}));
            record.population = strtrim(parts{col_idx.population});
            record.state = strtrim(parts{col_idx.state});
            record.candidate_name = candidate_name;
            record.candidate_party = candidate_party;
            record.pct = pct;
            
            poll_records = [poll_records; record];
            
        catch err
            skipped_count = skipped_count + 1;
        end
    end
    
    fprintf('Processed %d valid poll entries\n', length(poll_records));
    fprintf('Skipped %d invalid entries\n', skipped_count);
    
    % Group by question_id to get Trump vs Biden/Harris matchups
    fprintf('\nGrouping polls by question...\n');
    
    % Get unique question IDs
    question_ids = unique({poll_records.question_id});
    
    % Initialize poll data structure
    poll_data = [];
    valid_polls = 0;
    
    for i = 1:length(question_ids)
        qid = question_ids{i};
        
        % Find all records for this question
        mask = strcmp({poll_records.question_id}, qid);
        q_records = poll_records(mask);
        
        if length(q_records) < 2
            continue;  % Need at least 2 candidates
        end
        
        % Extract candidate data
        has_trump = false;
        has_dem = false;
        trump_pct = NaN;
        dem_pct = NaN;
        dem_candidate = '';
        
        for j = 1:length(q_records)
            if strcmp(q_records(j).candidate_name, 'Donald Trump')
                has_trump = true;
                trump_pct = q_records(j).pct;
            elseif strcmp(q_records(j).candidate_name, 'Joe Biden')
                has_dem = true;
                dem_pct = q_records(j).pct;
                dem_candidate = 'Biden';
            elseif strcmp(q_records(j).candidate_name, 'Kamala Harris')
                has_dem = true;
                dem_pct = q_records(j).pct;
                dem_candidate = 'Harris';
            end
        end
        
        % Only keep Trump vs Democrat matchups
        if ~has_trump || ~has_dem
            continue;
        end
        
        % Create poll entry
        poll.date = q_records(1).date;
        poll.date_str = q_records(1).date_str;
        poll.pollster = q_records(1).pollster;
        poll.sample_size = q_records(1).sample_size;
        poll.population = q_records(1).population;
        poll.state = q_records(1).state;
        poll.dem_candidate = dem_candidate;
        poll.rep_candidate = 'Trump';
        poll.dem_pct = dem_pct;
        poll.rep_pct = trump_pct;
        poll.question_id = qid;
        
        poll_data = [poll_data; poll];
        valid_polls = valid_polls + 1;
    end
    
    fprintf('Found %d valid Trump vs Biden/Harris polls\n', valid_polls);
    
    % Sort by date
    [~, idx] = sort([poll_data.date]);
    poll_data = poll_data(idx);
    
    % Display date range
    fprintf('\nDate range: %s to %s\n', ...
            datestr(poll_data(1).date), ...
            datestr(poll_data(end).date));
    
    % Count by candidate
    biden_count = sum(strcmp({poll_data.dem_candidate}, 'Biden'));
    harris_count = sum(strcmp({poll_data.dem_candidate}, 'Harris'));
    fprintf('Biden polls: %d\n', biden_count);
    fprintf('Harris polls: %d\n', harris_count);
    
    % Save to CSV
    output_file = fullfile(processed_dir, 'parsed_polls.csv');
    fprintf('\nSaving to: %s\n', output_file);
    
    fid = fopen(output_file, 'w');
    fprintf(fid, 'date,date_str,pollster,sample_size,population,state,dem_candidate,rep_candidate,dem_pct,rep_pct\n');
    
    for i = 1:length(poll_data)
        fprintf(fid, '%.0f,%s,%s,%d,%s,%s,%s,%s,%.1f,%.1f\n', ...
                poll_data(i).date, ...
                poll_data(i).date_str, ...
                poll_data(i).pollster, ...
                poll_data(i).sample_size, ...
                poll_data(i).population, ...
                poll_data(i).state, ...
                poll_data(i).dem_candidate, ...
                poll_data(i).rep_candidate, ...
                poll_data(i).dem_pct, ...
                poll_data(i).rep_pct);
    end
    
    fclose(fid);
    
    fprintf('\n=== Parsing Complete ===\n');
    fprintf('Next step: Run aggregate_weekly.m to create weekly averages\n');
    
end
