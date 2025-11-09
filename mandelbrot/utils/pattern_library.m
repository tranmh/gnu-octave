function patterns = pattern_library(fractal_type)
  % PATTERN_LIBRARY Database of famous fractal locations
  %
  % Usage:
  %   patterns = pattern_library()         % Get all patterns
  %   patterns = pattern_library('mandelbrot')  % Get Mandelbrot patterns
  %
  % Inputs:
  %   fractal_type - Optional filter by fractal type
  %
  % Outputs:
  %   patterns - Cell array of pattern structures
  %              Each pattern has: name, fractal_type, center, width,
  %              height, max_iter, description
  %
  % Example:
  %   patterns = pattern_library('mandelbrot');
  %   pattern = patterns{1};  % Get first Mandelbrot pattern
  %   fprintf('%s: %s\n', pattern.name, pattern.description);
  %
  % Phase: 6 - Advanced Features

  % Initialize patterns database
  all_patterns = {};

  %% Mandelbrot Set Locations

  % 1. Classic Full View
  p = struct();
  p.name = 'Classic Full View';
  p.fractal_type = 'mandelbrot';
  p.center = -0.5 + 0i;
  p.width = 3.5;
  p.height = 2.5;
  p.max_iter = 256;
  p.description = 'The complete Mandelbrot set';
  all_patterns{end+1} = p;

  % 2. Seahorse Valley
  p = struct();
  p.name = 'Seahorse Valley';
  p.fractal_type = 'mandelbrot';
  p.center = -0.745 + 0.113i;
  p.width = 0.01;
  p.height = 0.01;
  p.max_iter = 512;
  p.description = 'Delicate seahorse-shaped features';
  all_patterns{end+1} = p;

  % 3. Elephant Valley
  p = struct();
  p.name = 'Elephant Valley';
  p.fractal_type = 'mandelbrot';
  p.center = 0.28 + 0.008i;
  p.width = 0.005;
  p.height = 0.005;
  p.max_iter = 512;
  p.description = 'Elephant trunk spirals';
  all_patterns{end+1} = p;

  % 4. Scepter Valley
  p = struct();
  p.name = 'Scepter Valley';
  p.fractal_type = 'mandelbrot';
  p.center = -0.1 + 0.84i;
  p.width = 0.002;
  p.height = 0.002;
  p.max_iter = 512;
  p.description = 'Ornate scepter structures';
  all_patterns{end+1} = p;

  % 5. Double Spiral
  p = struct();
  p.name = 'Double Spiral';
  p.fractal_type = 'mandelbrot';
  p.center = -0.761574 + 0.0847596i;
  p.width = 0.00005;
  p.height = 0.00005;
  p.max_iter = 1024;
  p.description = 'Perfect double spiral - very deep zoom';
  all_patterns{end+1} = p;

  % 6. Mini Mandelbrot
  p = struct();
  p.name = 'Mini Mandelbrot';
  p.fractal_type = 'mandelbrot';
  p.center = -0.1592 + 1.0317i;
  p.width = 0.001;
  p.height = 0.001;
  p.max_iter = 512;
  p.description = 'Tiny perfect copy of the set';
  all_patterns{end+1} = p;

  % 7. Satellite
  p = struct();
  p.name = 'Satellite';
  p.fractal_type = 'mandelbrot';
  p.center = -1.25 + 0i;
  p.width = 0.1;
  p.height = 0.1;
  p.max_iter = 256;
  p.description = 'Large circular satellite region';
  all_patterns{end+1} = p;

  % 8. Triple Spiral
  p = struct();
  p.name = 'Triple Spiral';
  p.fractal_type = 'mandelbrot';
  p.center = -0.088 + 0.654i;
  p.width = 0.0001;
  p.height = 0.0001;
  p.max_iter = 1024;
  p.description = 'Three spirals meeting';
  all_patterns{end+1} = p;

  %% Julia Set Locations

  % 9. Classic Julia
  p = struct();
  p.name = 'Classic Julia';
  p.fractal_type = 'julia';
  p.julia_c = -0.7 + 0.27i;
  p.center = 0 + 0i;
  p.width = 4.0;
  p.height = 3.0;
  p.max_iter = 256;
  p.description = 'Beautiful spiral pattern';
  all_patterns{end+1} = p;

  % 10. Dendrite Julia
  p = struct();
  p.name = 'Dendrite Julia';
  p.fractal_type = 'julia';
  p.julia_c = 0 + 1i;
  p.center = 0 + 0i;
  p.width = 4.0;
  p.height = 3.0;
  p.max_iter = 256;
  p.description = 'Tree-like structures (dendrites)';
  all_patterns{end+1} = p;

  % 11. Rabbit Julia
  p = struct();
  p.name = 'Rabbit Julia';
  p.fractal_type = 'julia';
  p.julia_c = -0.123 + 0.745i;
  p.center = 0 + 0i;
  p.width = 4.0;
  p.height = 3.0;
  p.max_iter = 256;
  p.description = 'Rabbit-shaped features';
  all_patterns{end+1} = p;

  % 12. Dragon Julia
  p = struct();
  p.name = 'Dragon Julia';
  p.fractal_type = 'julia';
  p.julia_c = -0.8 + 0.156i;
  p.center = 0 + 0i;
  p.width = 4.0;
  p.height = 3.0;
  p.max_iter = 256;
  p.description = 'Dragon-like curves';
  all_patterns{end+1} = p;

  % 13. Douady Rabbit
  p = struct();
  p.name = 'Douady Rabbit';
  p.fractal_type = 'julia';
  p.julia_c = -0.12 + 0.75i;
  p.center = 0 + 0i;
  p.width = 3.5;
  p.height = 3.0;
  p.max_iter = 256;
  p.description = 'Famous Douady rabbit fractal';
  all_patterns{end+1} = p;

  %% Burning Ship Locations

  % 14. Ship Full View
  p = struct();
  p.name = 'Ship Full View';
  p.fractal_type = 'burning_ship';
  p.center = -0.5 - 0.5i;
  p.width = 4.0;
  p.height = 3.0;
  p.max_iter = 256;
  p.description = 'Complete burning ship fractal';
  all_patterns{end+1} = p;

  % 15. Ship Bow
  p = struct();
  p.name = 'Ship Bow';
  p.fractal_type = 'burning_ship';
  p.center = -1.75 + 0.05i;
  p.width = 0.1;
  p.height = 0.1;
  p.max_iter = 512;
  p.description = 'Front of the burning ship';
  all_patterns{end+1} = p;

  % 16. Ship Masts
  p = struct();
  p.name = 'Ship Masts';
  p.fractal_type = 'burning_ship';
  p.center = -1.625 + 0.02i;
  p.width = 0.01;
  p.height = 0.01;
  p.max_iter = 512;
  p.description = 'Vertical mast structures';
  all_patterns{end+1} = p;

  %% Tricorn Locations

  % 17. Tricorn Full View
  p = struct();
  p.name = 'Tricorn Full View';
  p.fractal_type = 'tricorn';
  p.center = 0 + 0i;
  p.width = 4.0;
  p.height = 3.0;
  p.max_iter = 256;
  p.description = 'Complete Tricorn (Mandelbar) fractal';
  all_patterns{end+1} = p;

  % 18. Tricorn Detail
  p = struct();
  p.name = 'Tricorn Detail';
  p.fractal_type = 'tricorn';
  p.center = -0.2 + 0.65i;
  p.width = 0.01;
  p.height = 0.01;
  p.max_iter = 512;
  p.description = 'Intricate Tricorn details';
  all_patterns{end+1} = p;

  %% Multibrot Locations

  % 19. Multibrot Power 3
  p = struct();
  p.name = 'Multibrot Power 3';
  p.fractal_type = 'multibrot';
  p.multibrot_power = 3;
  p.center = 0 + 0i;
  p.width = 4.0;
  p.height = 3.0;
  p.max_iter = 256;
  p.description = 'Three-fold symmetric Multibrot';
  all_patterns{end+1} = p;

  % 20. Multibrot Power 4
  p = struct();
  p.name = 'Multibrot Power 4';
  p.fractal_type = 'multibrot';
  p.multibrot_power = 4;
  p.center = 0 + 0i;
  p.width = 4.0;
  p.height = 3.0;
  p.max_iter = 256;
  p.description = 'Four-fold symmetric Multibrot';
  all_patterns{end+1} = p;

  % 21. Multibrot Power 8
  p = struct();
  p.name = 'Multibrot Power 8';
  p.fractal_type = 'multibrot';
  p.multibrot_power = 8;
  p.center = 0 + 0i;
  p.width = 4.0;
  p.height = 3.0;
  p.max_iter = 256;
  p.description = 'Eight-fold star-like Multibrot';
  all_patterns{end+1} = p;

  %% Phoenix Locations

  % 22. Phoenix Classic
  p = struct();
  p.name = 'Phoenix Classic';
  p.fractal_type = 'phoenix';
  p.phoenix_c = 0.5 - 0.1i;
  p.phoenix_p = -0.5 + 0i;
  p.center = 0 + 0i;
  p.width = 4.0;
  p.height = 3.0;
  p.max_iter = 256;
  p.description = 'Classic Phoenix fractal parameters';
  all_patterns{end+1} = p;

  %% 3D Fractal Locations

  % 23. Mandelbulb Power 8
  p = struct();
  p.name = 'Mandelbulb Power 8';
  p.fractal_type = 'mandelbulb';
  p.mandelbulb_power = 8;
  p.center = 0 + 0i;
  p.width = 4.0;
  p.height = 3.0;
  p.max_iter = 16;
  p.description = 'Classic 3D Mandelbulb';
  all_patterns{end+1} = p;

  % 24. Mandelbox
  p = struct();
  p.name = 'Mandelbox';
  p.fractal_type = 'mandelbox';
  p.mandelbox_scale = 2.5;
  p.center = 0 + 0i;
  p.width = 4.0;
  p.height = 3.0;
  p.max_iter = 16;
  p.description = 'Intricate 3D Mandelbox structure';
  all_patterns{end+1} = p;

  % Filter by fractal type if requested
  if nargin > 0 && ~isempty(fractal_type)
    patterns = {};
    for i = 1:length(all_patterns)
      if strcmp(all_patterns{i}.fractal_type, fractal_type)
        patterns{end+1} = all_patterns{i};
      end
    end
  else
    patterns = all_patterns;
  end

  % Sort patterns by fractal type for organized display
  [~, idx] = sort(cellfun(@(x) x.fractal_type, patterns, 'UniformOutput', false));
  patterns = patterns(idx);

end
