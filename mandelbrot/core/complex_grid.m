function [X, Y, C] = complex_grid(center, width, height, nx, ny)
  % COMPLEX_GRID Generate a grid of complex numbers for fractal computation
  %
  % Usage:
  %   [X, Y, C] = complex_grid(center, width, height, nx, ny)
  %
  % Inputs:
  %   center - Complex number for center of view (e.g., -0.5 + 0i)
  %   width  - Width of the view in complex plane
  %   height - Height of the view in complex plane
  %   nx     - Number of pixels horizontally
  %   ny     - Number of pixels vertically
  %
  % Outputs:
  %   X - Real part grid (nx × ny matrix)
  %   Y - Imaginary part grid (nx × ny matrix)
  %   C - Complex grid (nx × ny matrix of complex numbers)
  %
  % Example:
  %   % Default Mandelbrot view
  %   [X, Y, C] = complex_grid(-0.5+0i, 3.5, 2.5, 800, 600);
  %
  % Phase: 1 - Core 2D Fractals

  % Extract center coordinates
  cx = real(center);
  cy = imag(center);

  % Calculate bounds
  x_min = cx - width / 2;
  x_max = cx + width / 2;
  y_min = cy - height / 2;
  y_max = cy + height / 2;

  % Create coordinate vectors
  x = linspace(x_min, x_max, nx);
  y = linspace(y_min, y_max, ny);

  % Create meshgrid
  [X, Y] = meshgrid(x, y);

  % Combine into complex grid
  C = X + 1i * Y;

end
