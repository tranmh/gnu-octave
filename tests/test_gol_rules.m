function test_suite = test_gol_rules
% Unit tests for game-of-life/core/gameoflife_rules.m and count_neighbors.m
    try
        test_functions = localfunctions();
    catch
    end
    initTestSuite;
end

function n = reference_neighbors(g)
    % Brute-force Moore-neighbourhood count with toroidal wrap
    [R, C] = size(g);
    n = zeros(R, C);
    for i = 1:R
        for j = 1:C
            for di = -1:1
                for dj = -1:1
                    if di == 0 && dj == 0
                        continue;
                    end
                    n(i, j) = n(i, j) + g(mod(i - 1 + di, R) + 1, mod(j - 1 + dj, C) + 1);
                end
            end
        end
    end
end

function g = evolve(g, steps)
    for k = 1:steps
        g = gameoflife_rules(g);
    end
end

function g = fixed_soup()
    g = double(mod(magic(10), 3) == 0);
end

% ---- count_neighbors (t13, gol-3) ----

function test_count_single_cell_in_corner_wraps
    g = zeros(4, 5);
    g(1, 1) = 1;
    n = count_neighbors(g);
    expected = zeros(4, 5);
    expected([4 1 2], [5 1 2]) = 1;
    expected(1, 1) = 0;
    assertEqual(n, expected);
end

function test_count_all_alive_gives_eight
    assertEqual(count_neighbors(ones(3, 4)), 8 * ones(3, 4));
end

function test_count_all_dead_gives_zero
    assertEqual(count_neighbors(zeros(5, 5)), zeros(5, 5));
end

function test_count_excludes_cell_itself
    g = zeros(5, 5);
    g(3, 3) = 1;
    n = count_neighbors(g);
    assertEqual(n(3, 3), 0);
    assertEqual(sum(n(:)), 8);
end

function test_count_matches_reference_on_soup
    g = fixed_soup();
    assertEqual(count_neighbors(g), reference_neighbors(g));
end

function test_count_non_square_and_edge_columns
    g = zeros(3, 6);
    g(:, 6) = 1;
    n = count_neighbors(g);
    assertEqual(n(:, 1), 3 * ones(3, 1));   % column 6 wraps onto column 1
    assertEqual(n(:, 5), 3 * ones(3, 1));
    assertEqual(n(:, 6), 2 * ones(3, 1));
    assertEqual(n(:, 3), zeros(3, 1));
end

% ---- gameoflife_rules (t12, gol-1/2/4) ----

function test_output_is_double_same_size
    g = logical(fixed_soup());
    next = gameoflife_rules(g);
    assertEqual(class(next), 'double');
    assertEqual(size(next), size(g));
    assertTrue(all(next(:) == 0 | next(:) == 1));
end

function test_rules_match_reference_on_soup
    g = fixed_soup();
    n = reference_neighbors(g);
    expected = double((g == 1 & (n == 2 | n == 3)) | (g == 0 & n == 3));
    assertEqual(gameoflife_rules(g), expected);
end

function test_isolated_cell_dies
    g = zeros(5);
    g(3, 3) = 1;
    assertEqual(gameoflife_rules(g), zeros(5));
end

function test_overcrowded_cell_dies
    g = zeros(5);
    g(2:4, 3) = 1;
    g(3, [2 4]) = 1;          % plus shape: centre has 4 neighbours
    next = gameoflife_rules(g);
    assertEqual(next(3, 3), 0);
end

function test_dead_cell_with_three_neighbours_is_born
    g = zeros(5);
    g(2, 2) = 1; g(2, 4) = 1; g(4, 3) = 1;
    next = gameoflife_rules(g);
    assertEqual(next(3, 3), 1);
end

function test_block_is_still_life
    g = zeros(6);
    g(3:4, 3:4) = 1;
    assertEqual(gameoflife_rules(g), g);
end

function test_beehive_is_still_life
    g = zeros(6);
    g(2, 3:4) = 1; g(3, [2 5]) = 1; g(4, 3:4) = 1;
    assertEqual(gameoflife_rules(g), g);
end

function test_blinker_has_period_two
    g = zeros(5);
    g(3, 2:4) = 1;
    g1 = gameoflife_rules(g);
    expected = zeros(5);
    expected(2:4, 3) = 1;
    assertEqual(g1, expected);
    assertEqual(gameoflife_rules(g1), g);
end

function test_toad_has_period_two
    g = zeros(6);
    g(3, 3:5) = 1; g(4, 2:4) = 1;
    g1 = gameoflife_rules(g);
    assertFalse(isequal(g1, g));
    assertEqual(gameoflife_rules(g1), g);
end

function test_glider_translates_diagonally_every_four_generations
    g = zeros(10);
    g(2, 3) = 1; g(3, 4) = 1; g(4, 2:4) = 1;
    assertEqual(evolve(g, 4), circshift(g, [1 1]));
end

function test_blinker_across_edge_wraps
    g = zeros(5);
    g(1, [5 1 2]) = 1;        % horizontal blinker straddling the left/right edge
    expected = zeros(5);
    expected([5 1 2], 1) = 1;
    assertEqual(gameoflife_rules(g), expected);
end

function test_glider_crosses_border_and_returns
    n = 8;
    g = zeros(n);
    g(1, 2) = 1; g(2, 3) = 1; g(3, 1:3) = 1;
    assertEqual(evolve(g, 4 * n), g);
    assertEqual(sum(sum(evolve(g, 4 * n - 2))), 5);
end
