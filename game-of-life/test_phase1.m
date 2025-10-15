% TEST_PHASE1.m - Test script for Phase 1: Core Game Logic
%
% This script tests the fundamental Game of Life algorithms:
% - Neighbor counting with toroidal boundaries
% - Game of Life rules application
% - Known pattern verification

clear all;
close all;
clc;

fprintf('=== Testing Phase 1: Core Game Logic ===\n\n');

% Add core directory to path
addpath('core');

%% Test 1: Neighbor Counting
fprintf('Test 1: Neighbor Counting\n');
fprintf('-------------------------\n');

% Create a simple 5x5 grid with a pattern
test_grid = zeros(5, 5);
test_grid(3, 3) = 1;  % Center cell alive
test_grid(2, 3) = 1;  % Top neighbor alive
test_grid(4, 3) = 1;  % Bottom neighbor alive

fprintf('Test grid:\n');
disp(test_grid);

neighbors = count_neighbors(test_grid);
fprintf('Neighbor count:\n');
disp(neighbors);

% Center cell should have 2 neighbors
assert(neighbors(3, 3) == 2, 'Center cell should have 2 neighbors');
fprintf('✓ Center cell has correct neighbor count\n\n');

%% Test 2: Toroidal Boundary
fprintf('Test 2: Toroidal Boundary Wrapping\n');
fprintf('-----------------------------------\n');

% Test wrapping at edges
test_grid = zeros(5, 5);
test_grid(1, 1) = 1;  % Top-left corner
test_grid(5, 5) = 1;  % Bottom-right corner (wraps to be neighbor)

neighbors = count_neighbors(test_grid);
% Due to toroidal boundary, these should be neighbors through wrapping
fprintf('Top-left corner neighbors: %d\n', neighbors(1, 1));
fprintf('Bottom-right corner neighbors: %d\n', neighbors(5, 5));

% They should each have 1 neighbor (each other through wrapping)
assert(neighbors(1, 1) == 1, 'Top-left corner should have 1 neighbor');
assert(neighbors(5, 5) == 1, 'Bottom-right corner should have 1 neighbor');
fprintf('✓ Toroidal boundary wrapping works correctly\n\n');

%% Test 3: Game of Life Rules - Blinker Pattern
fprintf('Test 3: Game of Life Rules - Blinker (Oscillator)\n');
fprintf('-------------------------------------------------\n');

% Create a blinker pattern (period-2 oscillator)
% Generation 0: Horizontal line
blinker1 = zeros(5, 5);
blinker1(3, 2:4) = 1;  % Horizontal: [0 1 1 1 0]

fprintf('Generation 0 (horizontal):\n');
disp(blinker1);

% Apply rules to get next generation
blinker2 = gameoflife_rules(blinker1);

fprintf('Generation 1 (should be vertical):\n');
disp(blinker2);

% Generation 1 should be vertical line
expected_blinker2 = zeros(5, 5);
expected_blinker2(2:4, 3) = 1;  % Vertical: column 3, rows 2-4

assert(isequal(blinker2, expected_blinker2), 'Blinker should oscillate to vertical');
fprintf('✓ Blinker oscillates correctly\n');

% Apply rules again - should return to horizontal
blinker3 = gameoflife_rules(blinker2);
fprintf('Generation 2 (should be horizontal again):\n');
disp(blinker3);

assert(isequal(blinker3, blinker1), 'Blinker should return to original state');
fprintf('✓ Blinker completes full period-2 cycle\n\n');

%% Test 4: Game of Life Rules - Block Pattern (Still Life)
fprintf('Test 4: Game of Life Rules - Block (Still Life)\n');
fprintf('-----------------------------------------------\n');

% Create a block pattern (2x2 square - should remain stable)
block = zeros(5, 5);
block(2:3, 2:3) = 1;

fprintf('Block (generation 0):\n');
disp(block);

% Apply rules - should remain unchanged
next_block = gameoflife_rules(block);

fprintf('Block (generation 1):\n');
disp(next_block);

assert(isequal(block, next_block), 'Block should remain stable');
fprintf('✓ Block (still life) remains unchanged\n\n');

%% Test 5: Game of Life Rules - Death by Underpopulation
fprintf('Test 5: Death by Underpopulation\n');
fprintf('--------------------------------\n');

% Single cell should die (no neighbors)
single_cell = zeros(5, 5);
single_cell(3, 3) = 1;

fprintf('Single cell:\n');
disp(single_cell);

next_gen = gameoflife_rules(single_cell);
fprintf('Next generation (should be empty):\n');
disp(next_gen);

assert(sum(next_gen(:)) == 0, 'Single cell should die');
fprintf('✓ Cell dies from underpopulation\n\n');

%% Test 6: Birth with Exactly 3 Neighbors
fprintf('Test 6: Birth with Exactly 3 Neighbors\n');
fprintf('--------------------------------------\n');

% Create pattern where dead cell has exactly 3 neighbors
birth_test = zeros(5, 5);
birth_test(2, 3) = 1;  % Top
birth_test(3, 2) = 1;  % Left
birth_test(3, 4) = 1;  % Right
% Center cell (3,3) is dead but has 3 neighbors

fprintf('Before (center cell is dead with 3 neighbors):\n');
disp(birth_test);

next_gen = gameoflife_rules(birth_test);
fprintf('After (center cell should be born):\n');
disp(next_gen);

assert(next_gen(3, 3) == 1, 'Dead cell with 3 neighbors should be born');
fprintf('✓ Cell born with exactly 3 neighbors\n\n');

%% Test Summary
fprintf('====================================\n');
fprintf('All Phase 1 Tests PASSED!\n');
fprintf('====================================\n');
fprintf('\nCore Game Logic is working correctly:\n');
fprintf('  ✓ Neighbor counting with toroidal boundaries\n');
fprintf('  ✓ Conway\'s rules applied correctly\n');
fprintf('  ✓ Known patterns behave as expected\n');
fprintf('\nPhase 1 is ready for integration!\n');
