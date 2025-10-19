function test_data_processing()
    % TEST_DATA_PROCESSING Unit tests for Phase 1: Data Acquisition & Preprocessing
    %
    % This script tests all functions in the data processing pipeline:
    %   - download_data.m
    %   - parse_polls.m
    %   - aggregate_weekly.m
    %   - handle_transition.m
    %
    % Usage:
    %   test_data_processing();
    
    fprintf('========================================\n');
    fprintf('  Phase 1 Testing: Data Processing\n');
    fprintf('========================================\n\n');
    
    % Add data directory to path
    script_dir = fileparts(mfilename('fullpath'));
    data_dir = fullfile(fileparts(script_dir), 'data');
    addpath(data_dir);
    
    all_passed = true;
    
    % Test 1: Check if raw data exists
    fprintf('Test 1: Checking raw data files...\n');
    raw_dir = fullfile(data_dir, 'raw');
    raw_file = fullfile(raw_dir, 'fivethirtyeight_polls.csv');
    
    if exist(raw_file, 'file')
        fprintf('  ✓ Raw data file exists\n');
    else
        fprintf('  ✗ Raw data file missing. Run download_data.m first\n');
        all_passed = false;
    end
    fprintf('\n');
    
    % Test 2: Check if parsed data exists and is valid
    fprintf('Test 2: Checking parsed poll data...\n');
    processed_dir = fullfile(data_dir, 'processed');
    parsed_file = fullfile(processed_dir, 'parsed_polls.csv');
    
    if exist(parsed_file, 'file')
        fprintf('  ✓ Parsed polls file exists\n');
        
        % Read and validate
        fid = fopen(parsed_file, 'r');
        header = fgetl(fid);
        line_count = 0;
        while ~feof(fid)
            line = fgetl(fid);
            if ischar(line)
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
    else
        fprintf('  ✗ Parsed polls file missing. Run parse_polls.m first\n');
        all_passed = false;
    end
    fprintf('\n');
    
    % Test 3: Check weekly aggregated data
    fprintf('Test 3: Checking weekly aggregated data...\n');
    weekly_file = fullfile(processed_dir, 'weekly_polls.csv');
    
    if exist(weekly_file, 'file')
        fprintf('  ✓ Weekly polls file exists\n');
        
        % Read and validate
        fid = fopen(weekly_file, 'r');
        header = fgetl(fid);
        
        week_count = 0;
        biden_count = 0;
        harris_count = 0;
        
        while ~feof(fid)
            line = fgetl(fid);
            if ischar(line)
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
    else
        fprintf('  ✗ Weekly polls file missing. Run aggregate_weekly.m first\n');
        all_passed = false;
    end
    fprintf('\n');
    
    % Test 4: Validate data ranges
    fprintf('Test 4: Validating polling percentage ranges...\n');
    
    if exist(weekly_file, 'file')
        fid = fopen(weekly_file, 'r');
        header = fgetl(fid);
        
        min_dem = 100;
        max_dem = 0;
        min_rep = 100;
        max_rep = 0;
        
        while ~feof(fid)
            line = fgetl(fid);
            if ischar(line)
                parts = strsplit(line, ',');
                if length(parts) >= 5
                    dem_avg = str2double(parts{4});
                    rep_avg = str2double(parts{5});
                    
                    min_dem = min(min_dem, dem_avg);
                    max_dem = max(max_dem, dem_avg);
                    min_rep = min(min_rep, rep_avg);
                    max_rep = max(max_rep, rep_avg);
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
    end
    fprintf('\n');
    
    % Test 5: Date range validation
    fprintf('Test 5: Validating date ranges...\n');
    
    if exist(weekly_file, 'file')
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
            if ischar(line)
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
