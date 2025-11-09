% DEMO_PHASE2.m - Demonstration of Phase 2: Beautiful Color Palettes
%
% This script showcases:
% - Smooth, band-free coloring
% - All 5 beautiful color palettes
% - Mandelbrot and Julia sets with different palettes
%
% Usage:
%   cd('C:/Users/tranm/work/gnu-octave/mandelbrot')
%   demo_phase2

clear all;
close all;
clc;

fprintf('========================================\n');
fprintf('  Phase 2 Demo: Color Palette Beauty\n');
fprintf('========================================\n\n');

% Add paths
addpath('core', 'display');

%% Demo 1: Palette Gallery
fprintf('Demo 1: Displaying all 5 color palettes...\n');
colormap_gallery();
fprintf('  ✓ Gallery window shows all palettes side-by-side\n\n');

pause(1);

%% Demo 2: Single Palette Showcase - Sunset Fire
fprintf('Demo 2: Mandelbrot Set with Sunset Fire palette...\n');
[iter, final_z] = mandelbrot_2d(-0.5+0i, 3.5, 2.5, 800, 600, 256);
smooth = smooth_coloring(iter, final_z, 2.0);
rgb = apply_colormap(smooth, 'sunset_fire');

fig1 = init_fractal_window(900, 700, 'Mandelbrot - Sunset Fire');
info.type = 'mandelbrot';
info.center = -0.5 + 0i;
info.width = 3.5;
info.height = 2.5;
info.iterations = 256;
info.palette = 'sunset_fire';
update_display(rgb, info);
fprintf('  ✓ Stunning warm colors from black through red to white\n\n');

pause(1);

%% Demo 3: Julia Set - Electric Dream
fprintf('Demo 3: Julia Set with Electric Dream palette...\n');
[iter, final_z] = julia_2d(-0.7+0.27i, 0+0i, 4.0, 3.0, 800, 600, 256);
smooth = smooth_coloring(iter, final_z, 2.0);
rgb = apply_colormap(smooth, 'electric_dream');

fig2 = init_fractal_window(900, 700, 'Julia Set - Electric Dream');
info.type = 'julia (c=-0.7+0.27i)';
info.center = 0 + 0i;
info.width = 4.0;
info.height = 3.0;
info.iterations = 256;
info.palette = 'electric_dream';
update_display(rgb, info);
fprintf('  ✓ Psychedelic colors: purple → magenta → cyan → green\n\n');

pause(1);

%% Demo 4: Zoom Detail - Northern Lights
fprintf('Demo 4: Seahorse Valley with Northern Lights palette...\n');
[iter, final_z] = mandelbrot_2d(-0.745+0.113i, 0.01, 0.01, 800, 600, 512);
smooth = smooth_coloring(iter, final_z, 2.0);
rgb = apply_colormap(smooth, 'northern_lights');

fig3 = init_fractal_window(900, 700, 'Seahorse Valley - Northern Lights');
info.type = 'mandelbrot';
info.center = -0.745 + 0.113i;
info.width = 0.01;
info.height = 0.01;
info.iterations = 512;
info.palette = 'northern_lights';
update_display(rgb, info);
fprintf('  ✓ Aurora borealis colors reveal intricate seahorse details\n\n');

fprintf('========================================\n');
fprintf('  Phase 2 Demo Complete!\n');
fprintf('  Keep windows open to admire the beauty\n');
fprintf('========================================\n');
