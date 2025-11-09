function result = bookmark_manager(action, varargin)
  % BOOKMARK_MANAGER Save, load, and manage fractal view bookmarks
  %
  % Usage:
  %   bookmark_manager('save', state, filename)
  %   state = bookmark_manager('load', filename)
  %   bookmarks = bookmark_manager('list')
  %   bookmark_manager('delete', filename)
  %
  % Actions:
  %   'save'   - Save current state to bookmark file
  %   'load'   - Load state from bookmark file
  %   'list'   - List all saved bookmarks
  %   'delete' - Delete a bookmark file
  %
  % Examples:
  %   % Save current view
  %   bookmark_manager('save', state, 'my_favorite');
  %
  %   % Load bookmark
  %   state = bookmark_manager('load', 'my_favorite');
  %
  %   % List all bookmarks
  %   bookmarks = bookmark_manager('list');
  %
  % Phase: 6 - Advanced Features

  % Bookmark directory
  bookmark_dir = 'bookmarks';

  % Create directory if it doesn't exist
  if ~exist(bookmark_dir, 'dir')
    mkdir(bookmark_dir);
  end

  switch lower(action)
    case 'save'
      result = save_bookmark(bookmark_dir, varargin{:});

    case 'load'
      result = load_bookmark(bookmark_dir, varargin{:});

    case 'list'
      result = list_bookmarks(bookmark_dir);

    case 'delete'
      result = delete_bookmark(bookmark_dir, varargin{:});

    otherwise
      error('Unknown action: %s', action);
  end

end


function success = save_bookmark(bookmark_dir, state, filename)
  % Save state to bookmark file

  if nargin < 3 || isempty(filename)
    error('Filename required for save operation');
  end

  % Remove .mat extension if provided
  if endsWith(filename, '.mat')
    filename = filename(1:end-4);
  end

  % Full path
  filepath = fullfile(bookmark_dir, [filename, '.mat']);

  % Extract relevant fields from state
  bookmark = struct();
  bookmark.fractal_type = state.fractal_type;
  bookmark.center = state.center;
  bookmark.width = state.width;
  bookmark.height = state.height;
  bookmark.max_iter = state.max_iter;
  bookmark.palette = state.palette;
  bookmark.zoom_level = state.zoom_level;

  % Include fractal-specific parameters
  if strcmp(state.fractal_type, 'julia')
    bookmark.julia_c = state.julia_c;
  elseif strcmp(state.fractal_type, 'multibrot')
    bookmark.multibrot_power = state.multibrot_power;
  elseif strcmp(state.fractal_type, 'phoenix')
    bookmark.phoenix_c = state.phoenix_c;
    bookmark.phoenix_p = state.phoenix_p;
  elseif strcmp(state.fractal_type, 'mandelbulb')
    bookmark.mandelbulb_power = state.mandelbulb_power;
  elseif strcmp(state.fractal_type, 'mandelbox')
    bookmark.mandelbox_scale = state.mandelbox_scale;
  end

  % Add metadata
  bookmark.timestamp = datestr(now);
  bookmark.description = sprintf('%s at zoom level %.2e', ...
                                 state.fractal_type, state.zoom_level);

  % Save to file
  try
    save(filepath, 'bookmark');
    fprintf('Bookmark saved: %s\n', filepath);
    success = true;
  catch err
    fprintf('Error saving bookmark: %s\n', err.message);
    success = false;
  end

end


function state = load_bookmark(bookmark_dir, filename)
  % Load state from bookmark file

  if nargin < 2 || isempty(filename)
    error('Filename required for load operation');
  end

  % Remove .mat extension if provided
  if endsWith(filename, '.mat')
    filename = filename(1:end-4);
  end

  % Full path
  filepath = fullfile(bookmark_dir, [filename, '.mat']);

  % Check if file exists
  if ~exist(filepath, 'file')
    error('Bookmark not found: %s', filepath);
  end

  % Load bookmark
  try
    data = load(filepath);
    bookmark = data.bookmark;

    % Convert bookmark to state structure
    state = bookmark;

    fprintf('Bookmark loaded: %s\n', filename);
    fprintf('  %s\n', bookmark.description);
    fprintf('  Saved: %s\n', bookmark.timestamp);

  catch err
    error('Error loading bookmark: %s', err.message);
  end

end


function bookmarks = list_bookmarks(bookmark_dir)
  % List all saved bookmarks

  % Get all .mat files in bookmark directory
  files = dir(fullfile(bookmark_dir, '*.mat'));

  if isempty(files)
    fprintf('No bookmarks found.\n');
    bookmarks = {};
    return;
  end

  fprintf('Saved Bookmarks:\n');
  fprintf('================\n\n');

  bookmarks = cell(length(files), 1);

  for i = 1:length(files)
    filename = files(i).name;
    filepath = fullfile(bookmark_dir, filename);

    try
      data = load(filepath);
      bookmark = data.bookmark;

      % Store bookmark info
      info = struct();
      info.filename = filename(1:end-4);  % Remove .mat
      info.fractal_type = bookmark.fractal_type;
      info.center = bookmark.center;
      info.zoom_level = bookmark.zoom_level;
      info.description = bookmark.description;
      info.timestamp = bookmark.timestamp;

      bookmarks{i} = info;

      % Display bookmark info
      fprintf('%d. %s\n', i, info.filename);
      fprintf('   Type: %s\n', info.fractal_type);
      fprintf('   Center: %.6f%+.6fi\n', real(info.center), imag(info.center));
      fprintf('   Zoom: %.2e\n', info.zoom_level);
      fprintf('   Saved: %s\n\n', info.timestamp);

    catch err
      fprintf('Error loading %s: %s\n\n', filename, err.message);
      bookmarks{i} = [];
    end
  end

  % Remove empty entries
  bookmarks = bookmarks(~cellfun(@isempty, bookmarks));

end


function success = delete_bookmark(bookmark_dir, filename)
  % Delete a bookmark file

  if nargin < 2 || isempty(filename)
    error('Filename required for delete operation');
  end

  % Remove .mat extension if provided
  if endsWith(filename, '.mat')
    filename = filename(1:end-4);
  end

  % Full path
  filepath = fullfile(bookmark_dir, [filename, '.mat']);

  % Check if file exists
  if ~exist(filepath, 'file')
    fprintf('Bookmark not found: %s\n', filepath);
    success = false;
    return;
  end

  % Delete file
  try
    delete(filepath);
    fprintf('Bookmark deleted: %s\n', filename);
    success = true;
  catch err
    fprintf('Error deleting bookmark: %s\n', err.message);
    success = false;
  end

end
