function success = save_pattern(grid, filename)
  % SAVE_PATTERN Save the current grid state to a file
  %
  % Usage:
  %   success = save_pattern(grid, filename)
  %
  % Inputs:
  %   grid     - Current grid state (matrix of 0s and 1s)
  %   filename - Name of the file to save (without path)
  %
  % Outputs:
  %   success  - True if save was successful, false otherwise
  %
  % File Format:
  %   Simple text format with 0 for dead cells and 1 for alive cells
  %   Each row of the grid is saved as a line in the file
  %
  % Example:
  %   success = save_pattern(grid, 'my_pattern.txt');
  
  success = false;
  
  % Validate inputs
  if nargin < 2
    error('save_pattern:NotEnoughArgs', 'Usage: save_pattern(grid, filename)');
  endif
  
  if ~ismatrix(grid) || ~isnumeric(grid)
    error('save_pattern:InvalidGrid', 'Grid must be a numeric matrix');
  endif
  
  if isempty(filename) || ~ischar(filename)
    error('save_pattern:InvalidFilename', 'Filename must be a non-empty string');
  endif

  % Filename must not contain a path (keeps the file inside saved_patterns)
  if any(filename == '/' | filename == '\' | filename == ':')
    error('save_pattern:InvalidFilename', 'Filename must not contain a path: %s', filename);
  endif

  % Ensure filename has .txt extension
  if length(filename) < 4 || ~strcmp(filename(end-3:end), '.txt')
    filename = [filename, '.txt'];
  endif
  
  % Get the directory where this script is located
  script_dir = fileparts(mfilename('fullpath'));
  
  % Create saved_patterns directory path (one level up from utils/)
  patterns_dir = fullfile(fileparts(script_dir), 'saved_patterns');
  
  % Create directory if it doesn't exist
  if ~exist(patterns_dir, 'dir')
    [status, msg] = mkdir(patterns_dir);
    if ~status
      warning('save_pattern:DirCreateFailed', 'Failed to create patterns directory: %s', msg);
      return;
    endif
  endif
  
  % Full path to save file
  filepath = fullfile(patterns_dir, filename);
  
  try
    % Open file for writing
    fid = fopen(filepath, 'w');
    if fid == -1
      error('save_pattern:OpenFailed', 'Could not open file for writing: %s', filepath);
    endif
    
    % Write metadata header
    fprintf(fid, '%% Game of Life Pattern\n');
    fprintf(fid, '%% Size: %dx%d\n', size(grid, 1), size(grid, 2));
    fprintf(fid, '%% Saved: %s\n', datestr(now));
    fprintf(fid, '%%\n');
    
    % Write grid data
    % Convert grid to 0s and 1s (in case it has other values)
    grid_binary = (grid > 0);
    
    % Write each row
    [rows, cols] = size(grid_binary);
    for i = 1:rows
      for j = 1:cols
        fprintf(fid, '%d', grid_binary(i, j));
        if j < cols
          fprintf(fid, ' ');  % Space between cells
        endif
      endfor
      fprintf(fid, '\n');  % Newline after each row
    endfor
    
    % Close file
    fclose(fid);
    
    % Success!
    success = true;
    fprintf('Pattern saved successfully to: %s\n', filepath);
    
  catch err
    % Clean up file handle if still open
    if exist('fid', 'var') && fid ~= -1
      fclose(fid);
    endif
    
    % Report error
    warning('save_pattern:SaveFailed', 'Failed to save pattern: %s', err.message);
    success = false;
  end_try_catch
  
endfunction
