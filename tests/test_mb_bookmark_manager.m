function test_suite = test_mb_bookmark_manager
% Unit tests for mandelbrot/utils/bookmark_manager.m
% bookmark_manager works on ./bookmarks, so each test runs in a fresh temp dir.
    try
        test_functions = localfunctions();
    catch
    end
    initTestSuite;
end

function c = in_temp_dir()
    old = pwd();
    d = tempname();
    mkdir(d);
    cd(d);
    c = onCleanup(@() leave_temp_dir(old, d));
end

function leave_temp_dir(old, d)
    cd(old);
    confirm_recursive_rmdir(false, 'local');
    rmdir(d, 's');
end

function s = mandelbrot_state()
    s = struct('fractal_type', 'mandelbrot', 'center', -0.745 + 0.113i, ...
               'width', 0.01, 'height', 0.0075, 'max_iter', 512, ...
               'palette', 'hot', 'zoom_level', 350);
end

function r = bm(varargin)
    [~, r] = evalc('bookmark_manager(varargin{:})');
end

function test_save_writes_mat_file_with_documented_fields
    c = in_temp_dir();
    s = mandelbrot_state();
    assertTrue(bm('save', s, 'seahorse'));
    f = fullfile('bookmarks', 'seahorse.mat');
    assertEqual(exist(f, 'file'), 2);
    data = load(f);
    b = data.bookmark;
    for name = {'fractal_type', 'center', 'width', 'height', 'max_iter', ...
                'palette', 'zoom_level', 'timestamp', 'description'}
        assertTrue(isfield(b, name{1}), name{1});
    end
    assertEqual(b.fractal_type, 'mandelbrot');
    assertEqual(b.center, s.center);
    assertEqual(b.max_iter, 512);
    assertEqual(b.palette, 'hot');
    assertTrue(ischar(b.timestamp) && ~isempty(b.timestamp));
    assertFalse(isempty(strfind(b.description, 'mandelbrot')));
end

function test_save_strips_mat_suffix
    c = in_temp_dir();
    assertTrue(bm('save', mandelbrot_state(), 'view1.mat'));
    assertEqual(exist(fullfile('bookmarks', 'view1.mat'), 'file'), 2);
    assertEqual(exist(fullfile('bookmarks', 'view1.mat.mat'), 'file'), 0);
end

function test_save_ignores_unrelated_state_fields
    c = in_temp_dir();
    s = mandelbrot_state();
    s.figure_handle = 42;
    s.julia_c = 0.1;
    bm('save', s, 'extra');
    data = load(fullfile('bookmarks', 'extra.mat'));
    assertFalse(isfield(data.bookmark, 'figure_handle'));
    assertFalse(isfield(data.bookmark, 'julia_c'));
end

function test_save_and_load_fractal_specific_parameters
    c = in_temp_dir();
    s = mandelbrot_state();
    s.fractal_type = 'julia';
    s.julia_c = -0.7 + 0.27i;
    bm('save', s, 'j');
    assertEqual(bm('load', 'j').julia_c, -0.7 + 0.27i);

    s = mandelbrot_state();
    s.fractal_type = 'multibrot';
    s.multibrot_power = 3;
    bm('save', s, 'm');
    assertEqual(bm('load', 'm').multibrot_power, 3);

    s = mandelbrot_state();
    s.fractal_type = 'phoenix';
    s.phoenix_c = 0.5 - 0.1i;
    s.phoenix_p = -0.5;
    bm('save', s, 'p');
    loaded = bm('load', 'p');
    assertEqual([loaded.phoenix_c, loaded.phoenix_p], [0.5 - 0.1i, -0.5]);
end

function test_load_round_trip
    c = in_temp_dir();
    s = mandelbrot_state();
    bm('save', s, 'rt');
    loaded = bm('load', 'rt.mat');
    assertEqual(loaded.fractal_type, s.fractal_type);
    assertEqual(loaded.center, s.center);
    assertEqual(loaded.width, s.width);
    assertEqual(loaded.height, s.height);
    assertEqual(loaded.max_iter, s.max_iter);
    assertEqual(loaded.palette, s.palette);
    assertEqual(loaded.zoom_level, s.zoom_level);
end

function test_load_missing_bookmark_raises
    c = in_temp_dir();
    try
        bm('load', 'nope');
    catch err
        assertFalse(isempty(strfind(err.message, 'Bookmark not found')));
        return;
    end
    error('expected an error for a missing bookmark');
end

function test_missing_filename_raises
    c = in_temp_dir();
    assertExceptionThrown(@() bm('save', mandelbrot_state(), ''));
    assertExceptionThrown(@() bm('save', mandelbrot_state()));
    assertExceptionThrown(@() bm('load'));
    assertExceptionThrown(@() bm('delete', ''));
end

function test_list_empty_and_populated
    c = in_temp_dir();
    assertTrue(isempty(bm('list')));
    bm('save', mandelbrot_state(), 'a_first');
    s = mandelbrot_state();
    s.center = 0.25;
    bm('save', s, 'b_second');
    list = bm('list');
    assertEqual(numel(list), 2);
    names = sort(cellfun(@(x) x.filename, list, 'UniformOutput', false));
    assertEqual(names(:)', {'a_first', 'b_second'});
end

function test_list_skips_unreadable_files
    c = in_temp_dir();
    bm('save', mandelbrot_state(), 'good');
    other = 1;
    save(fullfile('bookmarks', 'bad.mat'), 'other');
    list = bm('list');
    assertEqual(numel(list), 1);
    assertEqual(list{1}.filename, 'good');
end

function test_delete_existing_and_missing
    c = in_temp_dir();
    bm('save', mandelbrot_state(), 'gone');
    assertTrue(bm('delete', 'gone.mat'));
    assertEqual(exist(fullfile('bookmarks', 'gone.mat'), 'file'), 0);
    assertFalse(bm('delete', 'gone'));
end

function test_unknown_action_raises
    c = in_temp_dir();
    assertExceptionThrown(@() bm('rename', 'x'));
end

function test_bookmark_names_cannot_leave_bookmark_dir
    % A bookmark name must stay inside ./bookmarks: '..' is rejected
    c = in_temp_dir();
    up = ['..', filesep];
    bookmark = struct('fractal_type', 'mandelbrot', 'description', 'outside', ...
                      'timestamp', 'then');
    save('outside.mat', 'bookmark');

    ok = false;
    try
        ok = bm('save', mandelbrot_state(), [up, 'escape']);
    catch
    end
    assertFalse(ok);
    assertEqual(exist('escape.mat', 'file'), 0);

    loaded = [];
    try
        loaded = bm('load', [up, 'outside']);
    catch
    end
    assertTrue(isempty(loaded));

    ok = false;
    try
        ok = bm('delete', [up, 'outside']);
    catch
    end
    assertFalse(ok);
    assertEqual(exist('outside.mat', 'file'), 2);
end

function test_action_is_case_insensitive
    c = in_temp_dir();
    assertTrue(bm('SAVE', mandelbrot_state(), 'upper'));
    assertEqual(bm('Load', 'upper').max_iter, 512);
end
