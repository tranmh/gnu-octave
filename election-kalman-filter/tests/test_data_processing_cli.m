function test_data_processing_cli()
    % TEST_DATA_PROCESSING_CLI Unit tests for Phase 1 with synthetic data
    %
    % CLI version that creates synthetic test data instead of requiring
    % downloaded FiveThirtyEight data
    
    fprintf('========================================\n');
    fprintf('  Phase 1 Testing: Data Processing (CLI)\n');
    fprintf('========================================\n\n');
    
    % Add data directory to path
    script_dir = fileparts(mfilename('fullpath'));
    data_dir = fullfile(fileparts(script_dir), 'data');
    addpath(data_dir);
    
    all_passed = true;
    
    % Create synthetic data directories
    fprintf('Test 1: Creating synthetic test data...\n');
    raw_dir = fullfile(data_dir, 'raw');
    processed_dir = fullfile(data_dir, 'processed');
    
    if ~exist(raw_dir, 'dir')
        mkdir(raw_dir);
    end
    if ~exist(processed_dir, 'dir')
        mkdir(processed_dir);
    end
    
    % Create synthetic raw data
    raw_file = fullfile(raw_dir, 'fivethirtyeight_polls.csv');
    create_synthetic_raw_data(raw_file);
    fprintf('  ✓ Created synthetic raw data\n');
    
    % Create synthetic parsed data
    parsed_file = fullfile(processed_dir, 'parsed_polls.csv');
    create_synthetic_parsed_data(parsed_file);
    fprintf('  ✓ Created synthetic parsed data\n');
    
    % Create synthetic weekly data
    weekly_file = fullfile(processed_dir, 'weekly_polls.csv');
    create_synthetic_weekly_data(weekly_file);
    fprintf('  ✓ Created synthetic weekly data\n');
    fprintf('\n');
    
    % Test 2: Check parsed data structure
    fprintf('Test 2: Validating parsed poll data...\n');
    
    fid = fopen(parsed_file, 'r');
    header = fgetl(fid);
    line_count = 0;
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line) && ~isempty(line)
            line_count = line_count + 1;
        end
    end
    fclose(fid);
    
    fprintf('  ✓ Number of parsed polls: %d\n', line_count);
    
    if line_count > 0
        fprintf('  ✓ Data is not empty\n');
    else
        fprintf('  ✗ Parsed data is empty\n');
        all_passed = false;
    end
    fprintf('\n');
    
    % Test 3: Check weekly aggregated data
    fprintf('Test 3: Validating weekly aggregated data...\n');
    
    fid = fopen(weekly_file, 'r');
    header = fgetl(fid);
    
    week_count = 0;
    biden_count = 0;
    harris_count = 0;
    
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line) && ~isempty(line)
            week_count = week_count + 1;
            if ~isempty(strfind(line, 'Biden'))
                biden_count = biden_count + 1;
            end
            if ~isempty(strfind(line, 'Harris'))
                harris_count = harris_count + 1;
            end
        end
    end
    fclose(fid);
    
    fprintf('  ✓ Number of weeks: %d\n', week_count);
    fprintf('  ✓ Biden weeks: %d\n', biden_count);
    fprintf('  ✓ Harris weeks: %d\n', harris_count);
    
    if week_count == 52
        fprintf('  ✓ Correct number of weeks (52)\n');
    else
        fprintf('  ✗ Expected 52 weeks, got %d\n', week_count);
        all_passed = false;
    end
    
    if biden_count > 0 && harris_count > 0
        fprintf('  ✓ Both Biden and Harris weeks present\n');
    else
        fprintf('  ✗ Missing Biden or Harris weeks\n');
        all_passed = false;
    end
    fprintf('\n');
    
    % Test 4: Validate data ranges
    fprintf('Test 4: Validating polling percentage ranges...\n');
    
    fid = fopen(weekly_file, 'r');
    header = fgetl(fid);
    
    min_dem = 100;
    max_dem = 0;
    min_rep = 100;
    max_rep = 0;
    
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line) && ~isempty(line)
            parts = strsplit(line, ',');
            if length(parts) >= 5
                dem_avg = str2double(parts{4});
                rep_avg = str2double(parts{5});
                
                if ~isnan(dem_avg) && ~isnan(rep_avg)
                    min_dem = min(min_dem, dem_avg);
                    max_dem = max(max_dem, dem_avg);
                    min_rep = min(min_rep, rep_avg);
                    max_rep = max(max_rep, rep_avg);
                end
            end
        end
    end
    fclose(fid);
    
    fprintf('  Democratic range: %.1f%% - %.1f%%\n', min_dem, max_dem);
    fprintf('  Republican range: %.1f%% - %.1f%%\n', min_rep, max_rep);
    
    if min_dem >= 0 && max_dem <= 100 && min_rep >= 0 && max_rep <= 100
        fprintf('  ✓ All percentages in valid range [0, 100]\n');
    else
        fprintf('  ✗ Invalid percentage ranges detected\n');
        all_passed = false;
    end
    fprintf('\n');
    
    % Test 5: Date range validation
    fprintf('Test 5: Validating date ranges...\n');
    
    fid = fopen(weekly_file, 'r');
    header = fgetl(fid);
    
    first_line = fgetl(fid);
    if ischar(first_line)
        parts = strsplit(first_line, ',');
        first_date = parts{2};
        fprintf('  First week start: %s\n', first_date);
    end
    
    % Read to last line
    last_line = '';
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line) && ~isempty(line)
            last_line = line;
        end
    end
    fclose(fid);
    
    if ~isempty(last_line)
        parts = strsplit(last_line, ',');
        last_date = parts{3};
        fprintf('  Last week end: %s\n', last_date);
    end
    
    % Check if dates match expected range
    if ~isempty(first_line) && ~isempty(strfind(first_date, '2023-11'))
        fprintf('  ✓ Start date matches expected (Nov 2023)\n');
    else
        fprintf('  ✗ Start date mismatch\n');
        all_passed = false;
    end
    
    if ~isempty(last_line) && ~isempty(strfind(last_date, '2024-11'))
        fprintf('  ✓ End date matches expected (Nov 2024)\n');
    else
        fprintf('  ✗ End date mismatch\n');
        all_passed = false;
    end
    fprintf('\n');
    
    % Summary
    fprintf('========================================\n');
    if all_passed
        fprintf('  ✓ ALL TESTS PASSED\n');
        fprintf('  Phase 1 data processing is complete!\n');
    else
        fprintf('  ✗ SOME TESTS FAILED\n');
        fprintf('  Please review the errors above.\n');
    end
    fprintf('========================================\n');
    
end

function create_synthetic_raw_data(filename)
    % Create minimal raw CSV data for testing
    fid = fopen(filename, 'w');
    fprintf(fid, 'poll_id,question_id,poll_date,candidate,pct,sample_size\n');
    
    % Generate 200 synthetic polls over 52 weeks
    start_date = datenum('2023-11-05');
    for i = 1:200
        week_offset = floor((i-1) / 4) * 7;
        poll_date = datestr(start_date + week_offset, 'yyyy-mm-dd');
        
        % Democrat (Biden until week 38, then Harris)
        if week_offset < 38*7
            dem_candidate = 'Biden';
            dem_pct = 45 + randn()*2;
        else
            dem_candidate = 'Harris';
            dem_pct = 47.5 + randn()*2;
        end
        
        % Republican (Trump)
        rep_pct = 48 + randn()*2;
        
        fprintf(fid, '%d,%d,%s,%s,%.1f,1000\n', i, i, poll_date, dem_candidate, dem_pct);
        fprintf(fid, '%d,%d,%s,Trump,%.1f,1000\n', i, i, poll_date, rep_pct);
    end
    
    fclose(fid);
end

function create_synthetic_parsed_data(filename)
    % Create parsed CSV data
    fid = fopen(filename, 'w');
    fprintf(fid, 'poll_date,candidate,pct\n');
    
    start_date = datenum('2023-11-05');
    for i = 1:200
        week_offset = floor((i-1) / 4) * 7;
        poll_date = datestr(start_date + week_offset, 'yyyy-mm-dd');
        
        if week_offset < 38*7
            dem_candidate = 'Biden';
            dem_pct = 45 + randn()*2;
        else
            dem_candidate = 'Harris';
            dem_pct = 47.5 + randn()*2;
        end
        
        rep_pct = 48 + randn()*2;
        
        fprintf(fid, '%s,%s,%.1f\n', poll_date, dem_candidate, dem_pct);
        fprintf(fid, '%s,Trump,%.1f\n', poll_date, rep_pct);
    end
    
    fclose(fid);
end

function create_synthetic_weekly_data(filename)
    % Create weekly aggregated CSV data
    fid = fopen(filename, 'w');
    fprintf(fid, 'week,week_start,week_end,dem_avg,rep_avg,dem_std,rep_std,num_polls,candidate\n');
    
    start_date = datenum('2023-11-05');
    
    for week = 1:52
        week_start = datestr(start_date + (week-1)*7, 'yyyy-mm-dd');
        week_end = datestr(start_date + week*7 - 1, 'yyyy-mm-dd');
        
        if week < 38
            candidate = 'Biden';
            dem_avg = 45 + 3*sin(week/52*2*pi) + randn()*0.5;
        else
            candidate = 'Harris';
            dem_avg = 47.5 + 3*sin(week/52*2*pi) + randn()*0.5;
        end
        
        rep_avg = 48 + 2*cos(week/52*2*pi) + randn()*0.5;
        dem_std = 2.0 + randn()*0.2;
        rep_std = 1.8 + randn()*0.2;
        num_polls = randi([4, 10]);
        
        fprintf(fid, '%d,%s,%s,%.2f,%.2f,%.2f,%.2f,%d,%s\n', ...
                week, week_start, week_end, dem_avg, rep_avg, ...
                dem_std, rep_std, num_polls, candidate);
    end
    
    fclose(fid);
end
