function create_test_data()
    % CREATE_TEST_DATA - Generate synthetic polling data for testing
    %
    % Creates minimal weekly_polls.mat file for Phase 6 testing
    
    fprintf('Creating synthetic polling data for testing...\n');
    
    % Create 52 weeks of synthetic polling data
    weeks = (1:52)';
    dates = cell(52, 1);
    start_date = datenum('2023-11-05');
    
    for i = 1:52
        dates{i} = datestr(start_date + (i-1)*7, 'yyyy-mm-dd');
    end
    
    % Synthetic polling: Trump gradually ahead, transition at week 38
    % Democrat percentages (Biden/Harris)
    dem_avg = 45 + 3*sin((1:52)/52*2*pi) + randn(52,1)*0.5;
    
    % Add Harris boost at week 38
    dem_avg(38:end) = dem_avg(38:end) + 2.5;
    
    % Republican percentages (Trump)
    rep_avg = 48 + 2*cos((1:52)/52*2*pi) + randn(52,1)*0.5;
    
    % Standard deviations
    dem_std = 2.0 + randn(52,1)*0.2;
    rep_std = 1.8 + randn(52,1)*0.2;
    
    % Number of polls per week
    num_polls = randi([4, 10], 52, 1);
    
    % Candidate names (Biden until week 38, then Harris)
    candidate = cell(52, 1);
    for i = 1:52
        if i < 38
            candidate{i} = 'Biden';
        else
            candidate{i} = 'Harris';
        end
    end
    
    % Create the struct
    weekly_polls = struct();
    weekly_polls.weeks = weeks;
    weekly_polls.dates = dates;
    weekly_polls.dem_avg = dem_avg;
    weekly_polls.rep_avg = rep_avg;
    weekly_polls.dem_std = dem_std;
    weekly_polls.rep_std = rep_std;
    weekly_polls.num_polls = num_polls;
    weekly_polls.candidate = candidate;
    
    % Create output directory if needed
    output_dir = 'processed';
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    % Save to MAT file
    output_file = fullfile(output_dir, 'weekly_polls.mat');
    save(output_file, 'weekly_polls');
    
    fprintf('✓ Created: %s\n', output_file);
    fprintf('  - 52 weeks of synthetic polling data\n');
    fprintf('  - Biden → Harris transition at week 38\n');
    fprintf('  - Ready for Phase 6 testing\n');
    
end
