% Test script to verify pattern functions work correctly
% Add patterns directory to path
addpath('patterns');

fprintf('Testing pattern functions...\n\n');

% Test 1D patterns
fprintf('Testing 1D patterns:\n');
try
    u1 = get_pattern_1d('gaussian', 50);
    fprintf('  ✓ gaussian (1D)\n');
catch e
    fprintf('  ✗ gaussian (1D): %s\n', e.message);
end

try
    u2 = get_pattern_1d('step', 50);
    fprintf('  ✓ step (1D)\n');
catch e
    fprintf('  ✗ step (1D): %s\n', e.message);
end

% Test 2D patterns
fprintf('\nTesting 2D patterns:\n');
try
    u3 = get_pattern_2d('center_hot', 50, 50);
    fprintf('  ✓ center_hot (2D)\n');
catch e
    fprintf('  ✗ center_hot (2D): %s\n', e.message);
end

try
    u4 = get_pattern_2d('gaussian', 50, 50);
    fprintf('  ✓ gaussian (2D)\n');
catch e
    fprintf('  ✗ gaussian (2D): %s\n', e.message);
end

try
    u5 = get_pattern_2d('ring', 50, 50);
    fprintf('  ✓ ring (2D)\n');
catch e
    fprintf('  ✗ ring (2D): %s\n', e.message);
end

fprintf('\nAll tests completed!\n');
