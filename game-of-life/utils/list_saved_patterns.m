function files = list_saved_patterns()
  % LIST_SAVED_PATTERNS List all saved pattern files
  %
  % Usage:
  %   files = list_saved_patterns()
  %
  % Output:
  %   files - Cell array of filenames (without path) in saved_patterns directory
  %
  % Example:
  %   files = list_saved_patterns();
  %   if ~isempty(files)
  %     disp('Available patterns:');
  %     for i = 1:length(files)
  %       fprintf('  %d. %s\n', i, files{i});
  %     endfor
  %   endif
  
  files = {};
  
  % Get the directory where this script is located
  script_dir = fileparts(mfilename('fullpath'));
  
  % Create saved_patterns directory path (one level up from utils/)
  patterns_dir = fullfile(fileparts(script_dir), 'saved_patterns');
  
  % Check if directory exists
  if ~exist(patterns_dir, 'dir')
    return;
  endif
  
  % Get list of .txt files in the directory
  pattern_files = dir(fullfile(patterns_dir, '*.txt'));
  
  % Extract just the filenames
  if ~isempty(pattern_files)
    files = {pattern_files.name};
  endif
  
  % Sort alphabetically
  if ~isempty(files)
    files = sort(files);
  endif
  
endfunction
