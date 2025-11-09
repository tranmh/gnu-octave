function palette = create_palette(palette_name, num_colors)
  % CREATE_PALETTE Generate a color palette for fractal visualization
  %
  % Usage:
  %   palette = create_palette(palette_name, num_colors)
  %
  % Inputs:
  %   palette_name - Name of palette: 'deep_ocean', 'sunset_fire',
  %                  'electric_dream', 'monochrome', 'northern_lights'
  %   num_colors   - Number of colors in palette (default: 256)
  %
  % Outputs:
  %   palette - num_colors × 3 matrix of RGB values [0,1]
  %
  % Palettes:
  %   1. Deep Ocean: Deep blues → cyan → white
  %   2. Sunset Fire: Black → red → orange → yellow → white
  %   3. Electric Dream: Purple → magenta → cyan → green → yellow
  %   4. Monochrome: Black → gray → white
  %   5. Northern Lights: Dark blue → green → light blue → pink
  %
  % Example:
  %   palette = create_palette('sunset_fire', 256);
  %   imagesc(magic(100));
  %   colormap(palette);
  %
  % Phase: 2 - Visualization & Color Palettes

  if nargin < 2 || isempty(num_colors)
    num_colors = 256;
  end

  switch lower(palette_name)
    case 'deep_ocean'
      % Deep Ocean: #000033 → #0066CC → #00CCFF → #FFFFFF
      key_colors = [
        0.00, 0.00, 0.20;  % Deep dark blue
        0.00, 0.20, 0.50;  % Dark blue
        0.00, 0.40, 0.80;  % Medium blue
        0.00, 0.80, 1.00;  % Cyan
        0.50, 0.90, 1.00;  % Light cyan
        1.00, 1.00, 1.00   % White
      ];

    case 'sunset_fire'
      % Sunset Fire: #000000 → #660000 → #FF6600 → #FFCC00 → #FFFFFF
      key_colors = [
        0.00, 0.00, 0.00;  % Black
        0.40, 0.00, 0.00;  % Deep red
        0.80, 0.00, 0.00;  % Red
        1.00, 0.40, 0.00;  % Orange
        1.00, 0.80, 0.00;  % Yellow-orange
        1.00, 1.00, 0.60;  % Light yellow
        1.00, 1.00, 1.00   % White
      ];

    case 'electric_dream'
      % Electric Dream: #660099 → #CC0099 → #00CCCC → #66FF66 → #FFFF00
      key_colors = [
        0.40, 0.00, 0.60;  % Deep purple
        0.80, 0.00, 0.60;  % Magenta
        0.80, 0.00, 0.80;  % Bright magenta
        0.00, 0.80, 0.80;  % Cyan
        0.40, 1.00, 0.40;  % Light green
        1.00, 1.00, 0.00;  % Yellow
        1.00, 1.00, 0.80   % Light yellow
      ];

    case 'monochrome'
      % Monochrome Elegance: #000000 → #808080 → #FFFFFF
      key_colors = [
        0.00, 0.00, 0.00;  % Black
        0.25, 0.25, 0.25;  % Dark gray
        0.50, 0.50, 0.50;  % Gray
        0.75, 0.75, 0.75;  % Light gray
        1.00, 1.00, 1.00   % White
      ];

    case 'northern_lights'
      % Northern Lights: #001133 → #00AA44 → #0099CC → #CC66AA
      key_colors = [
        0.00, 0.07, 0.20;  % Deep blue-black
        0.00, 0.20, 0.35;  % Dark blue
        0.00, 0.50, 0.40;  % Teal-green
        0.00, 0.67, 0.27;  % Green
        0.00, 0.60, 0.80;  % Light blue
        0.40, 0.40, 0.80;  % Blue-purple
        0.80, 0.40, 0.67;  % Pink
        0.90, 0.70, 0.90   % Light pink
      ];

    otherwise
      error('Unknown palette: %s', palette_name);
  end

  % Interpolate to create full palette
  num_keys = size(key_colors, 1);
  key_positions = linspace(1, num_colors, num_keys);
  color_positions = 1:num_colors;

  % Interpolate each RGB channel
  palette = zeros(num_colors, 3);
  palette(:, 1) = interp1(key_positions, key_colors(:, 1), color_positions, 'linear');
  palette(:, 2) = interp1(key_positions, key_colors(:, 2), color_positions, 'linear');
  palette(:, 3) = interp1(key_positions, key_colors(:, 3), color_positions, 'linear');

  % Ensure values are in [0, 1]
  palette = max(0, min(1, palette));

end
