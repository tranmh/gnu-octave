function test_suite = test_ek_data_pipeline
% Unit tests for election-kalman-filter/data/parse_polls.m and aggregate_weekly.m
% Both functions locate their raw/ and processed/ folders next to their own
% file, so each test copies the function into a temp sandbox with fixture CSVs
% and runs it from there (the repository data is never touched).
    try
        test_functions = localfunctions();
    catch
    end
    initTestSuite;
end

function [d, c] = sandbox_with(func_name)
    src = which(func_name);
    old = pwd();
    d = tempname();
    mkdir(d);
    copyfile(src, fullfile(d, [func_name '.m']));
    cd(d);
    rehash();
    c = onCleanup(@() leave_sandbox(old, d));
end

function leave_sandbox(old, d)
    cd(old);
    rehash();
    confirm_recursive_rmdir(false, 'local');
    rmdir(d, 's');
end

function write_text(path, lines)
    folder = fileparts(path);
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    fid = fopen(path, 'w');
    fprintf(fid, '%s\n', lines{:});
    fclose(fid);
end

function lines = read_lines(path)
    lines = strsplit(strtrim(fileread(path)), "\n");
end

function line = poll_row(qid, date, cand, party, pct)
    line = sprintf('%s,P%s,Acme Research,NewsCo,%s,%s,1000,lv,%s,%s,%s,National', ...
                   qid, qid, date, date, cand, party, pct);
end

function lines = raw_fixture()
    lines = {'question_id,poll_id,pollster,sponsor,start_date,end_date,sample_size,population,candidate_name,candidate_party,pct,state', ...
             poll_row('q2', '2024-08-15', 'Kamala Harris', 'DEM', '47'), ...
             poll_row('q2', '2024-08-15', 'Donald Trump', 'REP', '48'), ...
             poll_row('q1', '2024-03-01', 'Joe Biden', 'DEM', '45'), ...
             poll_row('q1', '2024-03-01', 'Donald Trump', 'REP', '47'), ...
             poll_row('q1', '2024-03-01', 'Robert F. Kennedy', 'IND', '9'), ...
             poll_row('q3', '2023-01-10', 'Joe Biden', 'DEM', '44'), ...
             poll_row('q3', '2023-01-10', 'Donald Trump', 'REP', '46'), ...
             poll_row('q4', '2024-02-01', 'Joe Biden', 'DEM', '150'), ...
             poll_row('q4', '2024-02-01', 'Donald Trump', 'REP', '46'), ...
             poll_row('q5', '2024-02-02', 'Donald Trump', 'REP', '44'), ...
             poll_row('q5', '2024-02-02', 'Robert F. Kennedy', 'IND', '10'), ...
             'q6,P6,Short Line,2024-02-03', ...
             poll_row('q7', '2024-07-30', 'Kamala Harris', 'DEM', '46'), ...
             poll_row('q7', '2024-07-30', 'Donald Trump', 'REP', '45'), ...
             poll_row('q8', '2024-11-05', 'Kamala Harris', 'DEM', '48'), ...
             poll_row('q8', '2024-11-05', 'Donald Trump', 'REP', '49'), ...
             poll_row('q9', '2023-11-04', 'Joe Biden', 'DEM', '43'), ...
             poll_row('q9', '2023-11-04', 'Donald Trump', 'REP', '45')};
end

function polls = run_parse()
    [~, polls] = evalc('parse_polls()');
end

function weekly = run_aggregate()
    % aggregate_weekly preallocates weekly_data without the week_start_str/
    % week_end_str fields that each wk struct carries, so [weekly_data; wk]
    % fails with 'field names mismatch' for any input
    [~, weekly] = evalc('aggregate_weekly()');
end

% ---- parse_polls (t2) ----

function test_parse_polls_filters_and_pairs_matchups
    [d, c] = sandbox_with('parse_polls');
    write_text(fullfile(d, 'raw', 'fivethirtyeight_polls.csv'), raw_fixture());
    polls = run_parse();
    assertEqual(numel(polls), 4);
    assertEqual({polls.question_id}, {'q1', 'q7', 'q2', 'q8'});   % sorted by date
    assertEqual({polls.dem_candidate}, {'Biden', 'Harris', 'Harris', 'Harris'});
    assertEqual({polls.rep_candidate}, {'Trump', 'Trump', 'Trump', 'Trump'});
    assertEqual([polls.dem_pct], [45 46 47 48]);
    assertEqual([polls.rep_pct], [47 45 48 49]);
    assertEqual(polls(1).date, datenum(2024, 3, 1));
    assertEqual(polls(4).date, datenum(2024, 11, 5));
    assertEqual(polls(1).pollster, 'Acme Research');
    assertEqual(polls(1).sample_size, 1000);
    assertEqual(polls(1).population, 'lv');
    assertEqual(polls(1).state, 'National');
end

function test_parse_polls_writes_processed_csv
    [d, c] = sandbox_with('parse_polls');
    write_text(fullfile(d, 'raw', 'fivethirtyeight_polls.csv'), raw_fixture());
    run_parse();
    out = fullfile(d, 'processed', 'parsed_polls.csv');
    assertEqual(exist(out, 'file'), 2);
    lines = read_lines(out);
    assertEqual(numel(lines), 5);
    assertEqual(lines{1}, 'date,date_str,pollster,sample_size,population,state,dem_candidate,rep_candidate,dem_pct,rep_pct');
    parts = strsplit(lines{2}, ',');
    assertEqual(str2double(parts{1}), datenum(2024, 3, 1));
    assertEqual(parts(7:10), {'Biden', 'Trump', '45.0', '47.0'});
end

function test_parse_polls_missing_input_raises
    [d, c] = sandbox_with('parse_polls');
    try
        run_parse();
    catch err
        assertFalse(isempty(strfind(err.message, 'Input file not found')));
        return;
    end
    error('expected an error for the missing raw CSV');
end

% ---- aggregate_weekly (t3) ----

function line = parsed_row(day_offset, cand, dem, rep)
    start = datenum(2023, 11, 5);
    dn = start + day_offset;
    line = sprintf('%.0f,%s,Acme,800,lv,National,%s,Trump,%.1f,%.1f', ...
                   dn, datestr(dn, 'yyyy-mm-dd'), cand, dem, rep);
end

function weekly = aggregate_fixture(d)
    lines = {'date,date_str,pollster,sample_size,population,state,dem_candidate,rep_candidate,dem_pct,rep_pct', ...
             parsed_row(-1, 'Biden', 10, 90), ...      % before week 1: ignored
             parsed_row(0, 'Biden', 44, 48), ...       % week 1
             parsed_row(6, 'Biden', 46, 50), ...       % week 1 (last day)
             parsed_row(14, 'Biden', 47, 47), ...      % week 3
             parsed_row(357, 'Harris', 50, 46), ...    % week 52
             parsed_row(358, 'Harris', 48, 46), ...    % week 52
             parsed_row(363, 'Biden', 49, 46), ...     % week 52 (last day)
             parsed_row(364, 'Harris', 90, 10)};       % after week 52: ignored
    write_text(fullfile(d, 'processed', 'parsed_polls.csv'), lines);
    weekly = run_aggregate();
end

function test_aggregate_weekly_produces_52_weeks
    [d, c] = sandbox_with('aggregate_weekly');
    weekly = aggregate_fixture(d);
    assertEqual(numel(weekly), 52);
    assertEqual([weekly.week_number], 1:52);
    start = datenum(2023, 11, 5);
    assertEqual([weekly.week_start], start + 7 * (0:51));
    assertEqual([weekly.week_end], start + 7 * (0:51) + 6);
    assertEqual(sum([weekly.num_polls]), 6);
end

function test_aggregate_weekly_means_and_std
    [d, c] = sandbox_with('aggregate_weekly');
    weekly = aggregate_fixture(d);
    assertEqual(weekly(1).num_polls, 2);
    assertElementsAlmostEqual([weekly(1).dem_avg, weekly(1).rep_avg], [45, 49], 'absolute', 1e-12);
    assertElementsAlmostEqual([weekly(1).dem_std, weekly(1).rep_std], [sqrt(2), sqrt(2)], 'absolute', 1e-12);
    assertEqual(weekly(3).num_polls, 1);
    assertElementsAlmostEqual(weekly(3).dem_std, 0, 'absolute', 1e-12);
    assertEqual(weekly(52).num_polls, 3);
    assertElementsAlmostEqual([weekly(52).dem_avg, weekly(52).rep_avg], [49, 46], 'absolute', 1e-12);
    assertEqual(weekly(52).dem_candidate, 'Harris');   % majority of the week
end

function test_aggregate_weekly_interpolates_empty_weeks
    [d, c] = sandbox_with('aggregate_weekly');
    weekly = aggregate_fixture(d);
    assertEqual(weekly(2).num_polls, 0);
    assertElementsAlmostEqual([weekly(2).dem_avg, weekly(2).rep_avg], [46, 48], 'absolute', 1e-9);
    assertEqual([weekly(2).dem_std, weekly(2).rep_std], [2, 2]);
    k = 27;
    assertElementsAlmostEqual(weekly(k).dem_avg, 47 + (k - 3) * 2 / 49, 'absolute', 1e-9);
    assertElementsAlmostEqual(weekly(k).rep_avg, 47 - (k - 3) * 1 / 49, 'absolute', 1e-9);
    assertFalse(any(isnan([weekly.dem_avg])));
end

function test_aggregate_weekly_candidate_for_empty_weeks_by_date
    [d, c] = sandbox_with('aggregate_weekly');
    weekly = aggregate_fixture(d);
    % week 38 starts on 2024-07-21, the Biden -> Harris switch date
    assertEqual(weekly(37).dem_candidate, 'Biden');
    assertEqual(weekly(38).dem_candidate, 'Harris');
    assertEqual(weekly(2).dem_candidate, 'Biden');
    assertEqual(weekly(51).dem_candidate, 'Harris');
end

function test_aggregate_weekly_writes_csv
    [d, c] = sandbox_with('aggregate_weekly');
    aggregate_fixture(d);
    lines = read_lines(fullfile(d, 'processed', 'weekly_polls.csv'));
    assertEqual(numel(lines), 53);
    assertEqual(lines{1}, 'week_number,week_start,week_end,dem_avg,rep_avg,dem_std,rep_std,num_polls,dem_candidate');
    assertEqual(lines{2}, '1,2023-11-05,2023-11-11,45.00,49.00,1.41,1.41,2,Biden');
end

function test_aggregate_weekly_missing_input_raises
    [d, c] = sandbox_with('aggregate_weekly');
    try
        run_aggregate();
    catch err
        assertFalse(isempty(strfind(err.message, 'Input file not found')));
        return;
    end
    error('expected an error for the missing parsed CSV');
end
