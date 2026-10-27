function [grid, success] = load_pattern(filename, target_rows, target_cols)
  % LOAD_PATTERN Load a pattern from a file
  %
  % Usage:
  %   [grid, success] = load_pattern(filename)
  %   [grid, success] = load_pattern(filename, target_rows, target_cols)
  %
  % Inputs:
  %   filename    - Name of the file to load (without path)
  %   target_rows - (Optional) Target grid height. If provided, pattern will be
  %                 centered on a grid of this size
  %   target_cols - (Optional) Target grid width
  %
  % Outputs:
  %   grid        - Loaded grid state (matrix of 0s and 1s)
  %   success     - True if load was successful, false otherwise
  %
  % File Format:
  %   Simple text format with 0 for dead cells and 1 for alive cells
  %   Lines starting with % are treated as comments
  %   Each row of the grid is one line in the file
  %
  % Example:
  %   [grid, success] = load_pattern('my_pattern.txt');
  %   [grid, success] = load_pattern('my_pattern.txt', 50, 50);
  
  grid = [];
  success = false;
  
  % Validate inputs
  if nargin < 1
    error('load_pattern:NotEnoughArgs', 'Usage: load_pattern(filename, [target_rows, target_cols])');
  endif
  
  if isempty(filename) || ~ischar(filename)
    error('load_pattern:InvalidFilename', 'Filename must be a non-empty string');
  endif

  % Filename must not contain a path (keeps the file inside saved_patterns)
  if any(filename == '/' | filename == '\' | filename == ':')
    warning('load_pattern:InvalidFilename', 'Filename must not contain a path: %s', filename);
    return;
  endif

  % Ensure filename has .txt extension
  if length(filename) < 4 || ~strcmp(filename(end-3:end), '.txt')
    filename = [filename, '.txt'];
  endif
  
  % Get the directory where this script is located
  script_dir = fileparts(mfilename('fullpath'));
  
  % Create saved_patterns directory path (one level up from utils/)
  patterns_dir = fullfile(fileparts(script_dir), 'saved_patterns');
  
  % Full path to load file
  filepath = fullfile(patterns_dir, filename);
  
  % Check if file exists
  if ~exist(filepath, 'file')
    warning('load_pattern:FileNotFound', 'Pattern file not found: %s', filepath);
    return;
  endif
  
  try
    % Open file for reading
    fid = fopen(filepath, 'r');
    if fid == -1
      error('load_pattern:OpenFailed', 'Could not open file for reading: %s', filepath);
    endif
    
    % Read file line by line
    pattern_lines = {};
    while ~feof(fid)
      line = fgetl(fid);
      
      % Skip comment lines and empty lines
      if ischar(line) && ~isempty(line) && line(1) ~= '%'
        pattern_lines{end+1} = line;
      endif
    endwhile
    
    % Close file
    fclose(fid);
    
    % Check if we got any data
    if isempty(pattern_lines)
      warning('load_pattern:EmptyFile', 'No pattern data found in file: %s', filepath);
      return;
    endif
    
    % Parse pattern lines into a grid
    rows = length(pattern_lines);
    
    % Determine number of columns from first line
    first_line_nums = str2num(pattern_lines{1});
    if isempty(first_line_nums)
      warning('load_pattern:ParseError', 'Could not parse pattern data');
      return;
    endif
    cols = length(first_line_nums);
    
    % Create grid
    loaded_grid = zeros(rows, cols);
    
    % Fill grid with pattern data
    for i = 1:rows
      nums = str2num(pattern_lines{i});
      if isempty(nums) || length(nums) ~= cols
        warning('load_pattern:InconsistentData', 'Inconsistent row length at line %d', i);
        return;
      endif
      loaded_grid(i, :) = (nums > 0);  % Convert to binary
    endfor
    
    % If target size is specified, center the pattern on a larger grid
    if nargin >= 3 && ~isempty(target_rows) && ~isempty(target_cols)
      % Create empty target grid
      grid = zeros(target_rows, target_cols);
      
      % Calculate centering offsets
      start_row = floor((target_rows - rows) / 2) + 1;
      start_col = floor((target_cols - cols) / 2) + 1;
      
      % Handle cases where pattern is larger than target
      if start_row < 1
        start_row = 1;
      endif
      if start_col < 1
        start_col = 1;
      endif
      
      % Calculate how much of the pattern fits
      end_row = min(start_row + rows - 1, target_rows);
      end_col = min(start_col + cols - 1, target_cols);
      
      % Copy pattern to centered position
      pattern_rows = end_row - start_row + 1;
      pattern_cols = end_col - start_col + 1;
      grid(start_row:end_row, start_col:end_col) = loaded_grid(1:pattern_rows, 1:pattern_cols);
    else
      % Return pattern as-is
      grid = loaded_grid;
    endif
    
    % Success!
    success = true;
    fprintf('Pattern loaded successfully from: %s (size: %dx%d)\n', filepath, rows, cols);
    
  catch err
    % Clean up file handle if still open
    if exist('fid', 'var') && fid ~= -1
      fclose(fid);
    endif
    
    % Report error
    warning('load_pattern:LoadFailed', 'Failed to load pattern: %s', err.message);
    grid = [];
    success = false;
  end_try_catch
  
endfunction
