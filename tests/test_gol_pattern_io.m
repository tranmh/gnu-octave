function test_suite = test_gol_pattern_io
% Unit tests for game-of-life/utils/save_pattern.m and load_pattern.m
% The functions use the fixed game-of-life/saved_patterns directory, so every
% test uses an aqaa_unit_* file name and removes it afterwards.
    try
        test_functions = localfunctions();
    catch
    end
    initTestSuite;
end

function d = patterns_dir()
    d = fullfile(fileparts(fileparts(which('save_pattern'))), 'saved_patterns');
end

function p = pattern_path(name)
    p = fullfile(patterns_dir(), name);
end

function remove_file(name)
    p = pattern_path(name);
    if exist(p, 'file')
        delete(p);
    end
end

function write_raw(name, text)
    if ~exist(patterns_dir(), 'dir')
        mkdir(patterns_dir());
    end
    fid = fopen(pattern_path(name), 'w');
    fprintf(fid, '%s', text);
    fclose(fid);
end

function ok = save_quiet(grid, name)
    [~, ok] = evalc('save_pattern(grid, name)');
end

function [g, ok, w] = load_quiet(varargin)
    lastwarn('', '');
    [~, g, ok] = evalc('load_pattern(varargin{:})');
    [~, w] = lastwarn();
end

function test_save_writes_header_and_rows
    name = 'aqaa_unit_format.txt';
    c = onCleanup(@() remove_file(name));
    g = [0 1 0; 1 1 0];
    assertTrue(save_quiet(g, name));
    text = fileread(pattern_path(name));
    lines = strsplit(strtrim(text), "\n");
    comments = lines(strncmp(lines, '%', 1));
    data = lines(~strncmp(lines, '%', 1));
    assertTrue(numel(comments) >= 1);
    assertEqual(data, {'0 1 0', '1 1 0'});
end

function test_save_appends_txt_extension
    c = onCleanup(@() remove_file('aqaa_unit_noext.txt'));
    assertTrue(save_quiet([1 0; 0 1], 'aqaa_unit_noext'));
    assertTrue(exist(pattern_path('aqaa_unit_noext.txt'), 'file') == 2);
end

function test_save_binarises_values
    name = 'aqaa_unit_binary.txt';
    c = onCleanup(@() remove_file(name));
    assertTrue(save_quiet([2 -1 0; 0.5 0 7], name));
    [g, ok] = load_quiet(name);
    assertTrue(ok);
    assertEqual(g, [1 0 0; 1 0 1]);
end

function test_round_trip
    name = 'aqaa_unit_roundtrip.txt';
    c = onCleanup(@() remove_file(name));
    g = double(mod(magic(7), 2) == 0);
    g = g(:, 1:5);
    assertTrue(save_quiet(g, name));
    [loaded, ok] = load_quiet('aqaa_unit_roundtrip');
    assertTrue(ok);
    assertEqual(loaded, g);
end

function test_load_centres_on_target_grid
    name = 'aqaa_unit_centre.txt';
    c = onCleanup(@() remove_file(name));
    p = [0 1 0; 0 0 1; 1 1 1];
    assertTrue(save_quiet(p, name));
    [g, ok] = load_quiet(name, 7, 9);
    assertTrue(ok);
    expected = zeros(7, 9);
    expected(3:5, 4:6) = p;
    assertEqual(g, expected);
end

function test_load_crops_when_target_smaller
    name = 'aqaa_unit_crop.txt';
    c = onCleanup(@() remove_file(name));
    p = magic(4) > 8;
    assertTrue(save_quiet(double(p), name));
    [g, ok] = load_quiet(name, 2, 3);
    assertTrue(ok);
    assertEqual(g, double(p(1:2, 1:3)));
end

function test_load_skips_comments_and_blank_lines
    name = 'aqaa_unit_comments.txt';
    c = onCleanup(@() remove_file(name));
    write_raw(name, sprintf('%% header\n\n1 0\n%% middle\n0 1\n\n'));
    [g, ok] = load_quiet(name);
    assertTrue(ok);
    assertEqual(g, [1 0; 0 1]);
end

function test_load_missing_file_returns_failure
    [g, ok, w] = load_quiet('aqaa_unit_does_not_exist');
    assertFalse(ok);
    assertTrue(isempty(g));
    assertEqual(w, 'load_pattern:FileNotFound');
end

function test_load_empty_file_returns_failure
    name = 'aqaa_unit_empty.txt';
    c = onCleanup(@() remove_file(name));
    write_raw(name, sprintf('%% only comments\n%%\n'));
    [g, ok, w] = load_quiet(name);
    assertFalse(ok);
    assertTrue(isempty(g));
    assertEqual(w, 'load_pattern:EmptyFile');
end

function test_load_inconsistent_rows_returns_failure
    name = 'aqaa_unit_ragged.txt';
    c = onCleanup(@() remove_file(name));
    write_raw(name, sprintf('1 0 1\n1 0\n'));
    [g, ok, w] = load_quiet(name);
    assertFalse(ok);
    assertTrue(isempty(g));
    assertEqual(w, 'load_pattern:InconsistentData');
end

function test_save_argument_errors
    assertExceptionThrown(@() save_pattern([1 0]), 'save_pattern:NotEnoughArgs');
    assertExceptionThrown(@() save_pattern('abc', 'aqaa_unit_x'), 'save_pattern:InvalidGrid');
    assertExceptionThrown(@() save_pattern([1 0], ''), 'save_pattern:InvalidFilename');
    assertExceptionThrown(@() save_pattern([1 0], 42), 'save_pattern:InvalidFilename');
end

function test_save_rejects_parent_directory_names
    % The file name is "without path": '..' must not write outside saved_patterns
    outside = fullfile(fileparts(patterns_dir()), 'aqaa_unit_escape.txt');
    c = onCleanup(@() delete_if_exists(outside));
    delete_if_exists(outside);
    ok = false;
    try
        ok = save_quiet(ones(3), ['..', filesep, 'aqaa_unit_escape']);
    catch
    end
    assertFalse(ok);
    assertFalse(exist(outside, 'file') == 2);
end

function delete_if_exists(p)
    if exist(p, 'file')
        delete(p);
    end
end

function test_load_rejects_parent_directory_names
    % The file name is "without path": '..' must not read outside saved_patterns
    outside = fullfile(fileparts(patterns_dir()), 'aqaa_unit_outside.txt');
    c = onCleanup(@() delete_if_exists(outside));
    fid = fopen(outside, 'w');
    fprintf(fid, '1 0\n0 1\n');
    fclose(fid);
    g = [];
    ok = false;
    try
        [g, ok] = load_quiet(['..', filesep, 'aqaa_unit_outside']);
    catch
    end
    assertFalse(ok);
    assertTrue(isempty(g));
end

function test_load_argument_errors
    assertExceptionThrown(@() load_pattern(), 'load_pattern:NotEnoughArgs');
    assertExceptionThrown(@() load_pattern(''), 'load_pattern:InvalidFilename');
    assertExceptionThrown(@() load_pattern(7), 'load_pattern:InvalidFilename');
end
