function download_data()
    % DOWNLOAD_DATA Download polling data from various sources
    %
    % This function downloads polling data from FiveThirtyEight and other sources
    % for the 2024 US Presidential election
    %
    % Sources:
    %   - FiveThirtyEight: Current polls CSV
    %   - FiveThirtyEight: Historical polls CSV (if needed)
    %
    % Output:
    %   - data/raw/fivethirtyeight_polls.csv
    %
    % Usage:
    %   download_data()
    
    fprintf('=== Election Polling Data Download ===\n\n');
    
    % Get the script directory
    script_dir = fileparts(mfilename('fullpath'));
    raw_dir = fullfile(script_dir, 'raw');
    
    % Create raw directory if it doesn't exist
    if ~exist(raw_dir, 'dir')
        mkdir(raw_dir);
        fprintf('Created directory: %s\n', raw_dir);
    end
    
    % FiveThirtyEight URLs
    url_current = 'https://projects.fivethirtyeight.com/polls/data/president_polls.csv';
    url_historical = 'https://projects.fivethirtyeight.com/polls-page/data/president_polls_historical.csv';
    
    % Output files
    file_current = fullfile(raw_dir, 'fivethirtyeight_polls.csv');
    file_historical = fullfile(raw_dir, 'fivethirtyeight_polls_historical.csv');
    
    % Download current polls
    fprintf('Downloading FiveThirtyEight current polls...\n');
    fprintf('URL: %s\n', url_current);
    
    try
        urlwrite(url_current, file_current);
        fprintf('✓ Downloaded to: %s\n', file_current);
        
        % Check file size
        info = dir(file_current);
        fprintf('  File size: %.2f MB\n', info.bytes / 1024 / 1024);
    catch err
        fprintf('✗ Error downloading current polls: %s\n', err.message);
        fprintf('  Please download manually from:\n');
        fprintf('  %s\n', url_current);
    end
    
    fprintf('\n');
    
    % Download historical polls (optional, for extended analysis)
    fprintf('Downloading FiveThirtyEight historical polls...\n');
    fprintf('URL: %s\n', url_historical);
    
    try
        urlwrite(url_historical, file_historical);
        fprintf('✓ Downloaded to: %s\n', file_historical);
        
        % Check file size
        info = dir(file_historical);
        fprintf('  File size: %.2f MB\n', info.bytes / 1024 / 1024);
    catch err
        fprintf('✗ Error downloading historical polls: %s\n', err.message);
        fprintf('  Please download manually from:\n');
        fprintf('  %s\n', url_historical);
    end
    
    fprintf('\n');
    fprintf('=== Download Complete ===\n');
    fprintf('Next step: Run parse_polls.m to process the downloaded data\n');
    
end
