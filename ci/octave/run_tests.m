function run_tests(junit, coverage)
  % Runs the MOxUnit tests (JUnit XML) with MOcov coverage (Cobertura XML); exits non-zero on a failure.
  % Written by aqaa for the CI pipelines; MOXUNIT_DIR and MOCOV_DIR point at the two toolboxes.
  addpath(genpath(pwd));
  addpath(fullfile(getenv('MOXUNIT_DIR'), 'MOxUnit')); moxunit_set_path();
  addpath(fullfile(getenv('MOCOV_DIR'), 'MOcov'));
  target = 'tests';
  if ~exist(target, 'dir'), target = pwd; end
  ok = moxunit_runtests(target, '-recursive', '-junit_xml_file', junit, '-with_coverage', '-cover', pwd, ...
                        '-cover_exclude', '*test*', '-cover_xml_file', coverage);
  exit(~ok);
end
