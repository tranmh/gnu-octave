function test_suite = test_mb_views
% Unit tests for mandelbrot/utils/zoom_calculator.m, coordinate_converter.m,
% pattern_library.m and mandelbrot/core/mandelbrot_2d.m
    try
        test_functions = localfunctions();
    catch
    end
    initTestSuite;
end

% ---- coordinate_converter (t10, mb-3) ----

function test_converter_centre_pixel_maps_to_view_centre
    c = coordinate_converter([400, 300], -0.5 + 0.25i, 3.5, 2.5, 800, 600);
    assertElementsAlmostEqual(c, -0.5 + 0.25i, 'absolute', 1e-12);
end

function test_converter_corners_and_inverted_y
    c = coordinate_converter([0, 0], -0.5 + 0i, 3.5, 2.5, 800, 600);
    assertElementsAlmostEqual(c, -2.25 + 1.25i, 'absolute', 1e-12);
    c = coordinate_converter([800, 600], -0.5 + 0i, 3.5, 2.5, 800, 600);
    assertElementsAlmostEqual(c, 1.25 - 1.25i, 'absolute', 1e-12);
    c = coordinate_converter([200, 450], 1 + 1i, 4, 2, 800, 600);
    assertElementsAlmostEqual(c, -0.0 + 0.5i, 'absolute', 1e-12);
end

function test_converter_round_trip
    center = 0.3 - 0.7i; w = 0.02; h = 0.015; W = 640; H = 480;
    pixels = [0 0; 13 470; 320 240; 639 1; 100.5 200.25];
    for k = 1:rows(pixels)
        c = coordinate_converter(pixels(k, :), center, w, h, W, H);
        px = ((real(c) - real(center)) / w + 0.5) * W;
        py = (0.5 - (imag(c) - imag(center)) / h) * H;
        assertElementsAlmostEqual([px, py], pixels(k, :), 'absolute', 1e-6);
    end
end

% ---- zoom_calculator (t9, mb-5) ----

function test_zoom_in_at_centre_halves_view
    [c, w, h] = zoom_calculator([400, 300], -0.5 + 0i, 3.5, 2.5, 2.0, 800, 600);
    assertElementsAlmostEqual(c, -0.5 + 0i, 'absolute', 1e-12);
    assertElementsAlmostEqual([w, h], [1.75, 1.25], 'absolute', 1e-12);
end

function test_zoom_out_doubles_view
    [c, w, h] = zoom_calculator([400, 300], -0.5 + 0i, 3.5, 2.5, 0.5, 800, 600);
    assertElementsAlmostEqual(c, -0.5 + 0i, 'absolute', 1e-12);
    assertElementsAlmostEqual([w, h], [7, 5], 'absolute', 1e-12);
end

function test_zoom_recentres_on_clicked_point
    [c, w, h] = zoom_calculator([0, 0], -0.5 + 0i, 3.5, 2.5, 2.0, 800, 600);
    assertElementsAlmostEqual(c, -2.25 + 1.25i, 'absolute', 1e-12);
    assertElementsAlmostEqual([w, h], [1.75, 1.25], 'absolute', 1e-12);
    [c2] = zoom_calculator([800, 600], -0.5 + 0i, 3.5, 2.5, 2.0, 800, 600);
    assertElementsAlmostEqual(c2, 1.25 - 1.25i, 'absolute', 1e-12);
end

function test_zoom_centre_agrees_with_converter
    pix = [123, 456];
    c_conv = coordinate_converter(pix, 0.1 + 0.2i, 0.5, 0.4, 800, 600);
    c_zoom = zoom_calculator(pix, 0.1 + 0.2i, 0.5, 0.4, 4.0, 800, 600);
    assertElementsAlmostEqual(c_zoom, c_conv, 'absolute', 1e-12);
end

function test_zoom_factor_one_keeps_size
    [~, w, h] = zoom_calculator([10, 10], 0, 1e-10, 2e-10, 1, 800, 600);
    assertEqual([w, h], [1e-10, 2e-10]);
end

function test_repeated_zoom_in_then_out_restores_size
    c = -0.5; w = 3.5; h = 2.5;
    for k = 1:10
        [c, w, h] = zoom_calculator([400, 300], c, w, h, 2.0, 800, 600);
    end
    assertElementsAlmostEqual([w, h], [3.5, 2.5] / 1024, 'relative', 1e-12);
    for k = 1:10
        [c, w, h] = zoom_calculator([400, 300], c, w, h, 0.5, 800, 600);
    end
    assertElementsAlmostEqual([w, h], [3.5, 2.5], 'relative', 1e-12);
end

% ---- pattern_library (t8, mb-6, mb-8) ----

function pats = mb_pattern_library(varargin)
    % game-of-life/patterns/pattern_library.m shadows the Mandelbrot one on the
    % whole-tree path, so call it from mandelbrot/utils (cwd takes precedence).
    old = pwd();
    c = onCleanup(@() cd(old));
    cd(fileparts(which('bookmark_manager')));
    rehash();
    pats = feval('pattern_library', varargin{:});
end

function test_library_has_24_complete_patterns
    pats = mb_pattern_library();
    assertTrue(iscell(pats));
    assertEqual(numel(pats), 24);
    fields = {'name', 'fractal_type', 'center', 'width', 'height', 'max_iter', 'description'};
    for k = 1:numel(pats)
        p = pats{k};
        for f = fields
            assertTrue(isfield(p, f{1}), sprintf('pattern %d lacks %s', k, f{1}));
        end
        assertTrue(ischar(p.name) && ~isempty(p.name));
        assertTrue(isnumeric(p.center) && isscalar(p.center));
        assertTrue(p.width > 0 && p.height > 0);
        assertTrue(p.max_iter >= 1 && p.max_iter == round(p.max_iter));
    end
end

function test_library_sorted_by_fractal_type
    pats = mb_pattern_library();
    types = cellfun(@(p) p.fractal_type, pats, 'UniformOutput', false);
    assertEqual(types(:), sort(types(:)));
end

function test_library_names_are_unique
    pats = mb_pattern_library();
    names = cellfun(@(p) p.name, pats, 'UniformOutput', false);
    assertEqual(numel(unique(names)), numel(names));
end

function p = find_pattern(name)
    pats = mb_pattern_library();
    p = [];
    for k = 1:numel(pats)
        if strcmp(pats{k}.name, name)
            p = pats{k};
        end
    end
    assertFalse(isempty(p), sprintf('pattern %s not found', name));
end

function test_seahorse_valley_preset
    p = find_pattern('Seahorse Valley');
    assertEqual(p.fractal_type, 'mandelbrot');
    assertElementsAlmostEqual(p.center, -0.745 + 0.113i, 'absolute', 1e-12);
    assertElementsAlmostEqual(p.width, 0.01, 'absolute', 1e-12);
end

function test_classic_julia_preset
    p = find_pattern('Classic Julia');
    assertEqual(p.fractal_type, 'julia');
    assertElementsAlmostEqual(p.julia_c, -0.7 + 0.27i, 'absolute', 1e-12);
end

function test_type_specific_parameters_present
    pats = mb_pattern_library();
    for k = 1:numel(pats)
        p = pats{k};
        switch p.fractal_type
            case 'julia'
                assertTrue(isfield(p, 'julia_c'));
            case 'multibrot'
                assertTrue(isfield(p, 'multibrot_power'));
            case 'phoenix'
                assertTrue(isfield(p, 'phoenix_c') && isfield(p, 'phoenix_p'));
        end
    end
end

function test_filter_by_type
    pats = mb_pattern_library('julia');
    assertEqual(numel(pats), 5);
    assertTrue(all(cellfun(@(p) strcmp(p.fractal_type, 'julia'), pats)));
    assertEqual(numel(mb_pattern_library('mandelbrot')), 8);
end

function test_unknown_type_and_empty_filter
    assertTrue(isempty(mb_pattern_library('no_such_fractal')));
    assertEqual(numel(mb_pattern_library('')), 24);
end

% ---- mandelbrot_2d (t11, mb-1, mb-2) ----

function test_known_points_escape_counts
    % 3x3 grid over [-1,1]x[-1,1]: rows are imag = -1, 0, 1
    [iter, ~, X, Y] = mandelbrot_2d(0, 2, 2, 3, 3, 50);
    assertEqual(X, repmat([-1 0 1], 3, 1));
    assertEqual(Y, repmat([-1; 0; 1], 1, 3));
    expected = [3 0 2;    % -1-i, -i, 1-i
                0 0 3;    % -1, 0, 1
                3 0 2];   % -1+i, i, 1+i
    assertEqual(iter, expected);
end

function test_far_point_escapes_on_first_iteration
    [iter, final_z] = mandelbrot_2d(2 + 2i, 0, 0, 1, 1, 100);
    assertEqual(iter, 1);
    assertElementsAlmostEqual(final_z, 2 + 2i, 'absolute', 1e-12);
end

function test_points_in_set_never_escape
    [iter, final_z] = mandelbrot_2d(-1, 0, 0, 1, 1, 500);
    assertEqual(iter, 0);
    assertTrue(abs(final_z) <= 2);
    iter0 = mandelbrot_2d(0, 0, 0, 1, 1, 500);
    assertEqual(iter0, 0);
end

function test_max_iter_boundary
    % c = 1: z = 1, 2, 5 -> escapes at iteration 3
    assertEqual(mandelbrot_2d(1, 0, 0, 1, 1, 2), 0);
    assertEqual(mandelbrot_2d(1, 0, 0, 1, 1, 3), 3);
end

function test_escape_radius_parameter
    % c = 1 with radius 1.5: |z2| = 2 > 1.5
    assertEqual(mandelbrot_2d(1, 0, 0, 1, 1, 10, 1.5), 2);
end

function test_default_view_extent
    [iter, final_z, X, Y] = mandelbrot_2d([], [], [], 5, 4, 20);
    assertEqual(size(iter), [4, 5]);
    assertEqual(size(final_z), [4, 5]);
    assertElementsAlmostEqual([min(X(:)), max(X(:))], [-2.25, 1.25], 'absolute', 1e-12);
    assertElementsAlmostEqual([min(Y(:)), max(Y(:))], [-1.25, 1.25], 'absolute', 1e-12);
end

function test_final_z_of_escaped_points_exceeds_radius
    [iter, final_z] = mandelbrot_2d(-0.5, 3.5, 2.5, 40, 30, 64);
    escaped = iter > 0;
    assertTrue(any(escaped(:)) && any(~escaped(:)));
    assertTrue(all(abs(final_z(escaped)) > 2));
    assertTrue(all(abs(final_z(~escaped)) <= 2));
    assertTrue(all(iter(:) >= 0 & iter(:) <= 64));
end
