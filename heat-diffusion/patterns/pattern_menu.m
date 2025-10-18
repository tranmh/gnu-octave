function [pattern_name, params] = pattern_menu(dimension)
    % PATTERN_MENU - Interactive pattern selector with preview
    %
    % Usage:
    %   [pattern_name, params] = pattern_menu(dimension)
    %
    % Inputs:
    %   dimension - 1 for 1D patterns, 2 for 2D patterns
    %
    % Outputs:
    %   pattern_name - String identifier for selected pattern
    %   params       - Structure with customized parameters
    %
    % Description:
    %   Displays a menu of available patterns with descriptions.
    %   Allows user to select pattern and customize parameters.
    %   Shows preview of the selected pattern before returning.
    %
    % Examples:
    %   % Select 1D pattern
    %   [name, params] = pattern_menu(1);
    %
    %   % Select 2D pattern
    %   [name, params] = pattern_menu(2);
    
    % Validate input
    if ~ismember(dimension, [1, 2])
        error('Dimension must be 1 or 2');
    end
    
    % Define available patterns based on dimension
    if dimension == 1
        patterns = {
            'gaussian',    'Single Gaussian peak (smooth, localized heat)';
            'step',        'Step function (sharp hot/cold interface)';
            'double_peak', 'Two separated Gaussians (multiple heat sources)';
            'sine',        'Sinusoidal distribution (periodic pattern)';
            'random',      'Random temperature field (noise)'
        };
    else  % dimension == 2
        patterns = {
            'center_hot',   'Hot spot at center (single source)';
            'corner_hot',   'Hot corners, cold center (multiple sources)';
            'gaussian',     '2D Gaussian peak (radially symmetric)';
            'ring',         'Hot ring, cold interior/exterior (annular)';
            'checkerboard', 'Alternating hot/cold patches (periodic 2D)';
            'radial',       'Radially symmetric gradient (cooling from center)';
            'random',       'Random 2D temperature field (noise)'
        };
    end
    
    % Display menu
    fprintf('\n==============================================\n');
    fprintf('     PATTERN LIBRARY - %dD Initial Conditions\n', dimension);
    fprintf('==============================================\n\n');
    
    for i = 1:size(patterns, 1)
        fprintf('  %d. %-15s - %s\n', i, patterns{i,1}, patterns{i,2});
    end
    fprintf('\n');
    
    % Get user selection
    valid_choice = false;
    while ~valid_choice
        choice = input(sprintf('Select pattern (1-%d): ', size(patterns, 1)), 's');
        choice_num = str2double(choice);
        
        if ~isnan(choice_num) && choice_num >= 1 && choice_num <= size(patterns, 1)
            valid_choice = true;
            pattern_name = patterns{choice_num, 1};
        else
            fprintf('Invalid choice. Please enter a number between 1 and %d.\n', size(patterns, 1));
        end
    end
    
    fprintf('\nSelected pattern: %s\n', pattern_name);
    
    % Ask if user wants to customize parameters
    fprintf('\nDefault parameters:\n');
    fprintf('  amplitude: 100\n');
    fprintf('  width: 0.1\n');
    
    if dimension == 1
        fprintf('  center: 0.5\n');
    else
        fprintf('  center_x: 0.5, center_y: 0.5\n');
    end
    
    fprintf('\n');
    customize = input('Customize parameters? (y/n) [n]: ', 's');
    
    % Initialize default parameters
    params = struct();
    params.amplitude = 100;
    params.width = 0.1;
    
    if dimension == 1
        params.center = 0.5;
        params.center1 = 0.3;
        params.center2 = 0.7;
        params.frequency = 2;
        params.noise_level = 50;
    else
        params.center_x = 0.5;
        params.center_y = 0.5;
        params.ring_radius = 0.3;
        params.num_checks = 4;
        params.noise_level = 50;
    end
    
    % Customize parameters if requested
    if strcmpi(customize, 'y')
        fprintf('\nEnter new values (press Enter to keep default):\n');
        
        % Amplitude
        new_val = input(sprintf('  amplitude [%g]: ', params.amplitude), 's');
        if ~isempty(new_val)
            params.amplitude = str2double(new_val);
        end
        
        % Width
        new_val = input(sprintf('  width [%g]: ', params.width), 's');
        if ~isempty(new_val)
            params.width = str2double(new_val);
        end
        
        % Dimension-specific parameters
        if dimension == 1
            if strcmp(pattern_name, 'gaussian') || strcmp(pattern_name, 'step')
                new_val = input(sprintf('  center [%g]: ', params.center), 's');
                if ~isempty(new_val)
                    params.center = str2double(new_val);
                end
            elseif strcmp(pattern_name, 'double_peak')
                new_val = input(sprintf('  center1 [%g]: ', params.center1), 's');
                if ~isempty(new_val)
                    params.center1 = str2double(new_val);
                end
                new_val = input(sprintf('  center2 [%g]: ', params.center2), 's');
                if ~isempty(new_val)
                    params.center2 = str2double(new_val);
                end
            elseif strcmp(pattern_name, 'sine')
                new_val = input(sprintf('  frequency [%g]: ', params.frequency), 's');
                if ~isempty(new_val)
                    params.frequency = str2double(new_val);
                end
            elseif strcmp(pattern_name, 'random')
                new_val = input(sprintf('  noise_level [%g]: ', params.noise_level), 's');
                if ~isempty(new_val)
                    params.noise_level = str2double(new_val);
                end
            end
        else  % dimension == 2
            if strcmp(pattern_name, 'gaussian') || strcmp(pattern_name, 'center_hot') || ...
               strcmp(pattern_name, 'ring') || strcmp(pattern_name, 'radial')
                new_val = input(sprintf('  center_x [%g]: ', params.center_x), 's');
                if ~isempty(new_val)
                    params.center_x = str2double(new_val);
                end
                new_val = input(sprintf('  center_y [%g]: ', params.center_y), 's');
                if ~isempty(new_val)
                    params.center_y = str2double(new_val);
                end
            end
            
            if strcmp(pattern_name, 'ring')
                new_val = input(sprintf('  ring_radius [%g]: ', params.ring_radius), 's');
                if ~isempty(new_val)
                    params.ring_radius = str2double(new_val);
                end
            elseif strcmp(pattern_name, 'checkerboard')
                new_val = input(sprintf('  num_checks [%g]: ', params.num_checks), 's');
                if ~isempty(new_val)
                    params.num_checks = str2double(new_val);
                end
            elseif strcmp(pattern_name, 'random')
                new_val = input(sprintf('  noise_level [%g]: ', params.noise_level), 's');
                if ~isempty(new_val)
                    params.noise_level = str2double(new_val);
                end
            end
        end
    end
    
    % Show preview
    fprintf('\nGenerating preview...\n');
    
    if dimension == 1
        % Generate and plot 1D preview
        nx_preview = 100;
        u0 = get_pattern_1d(pattern_name, nx_preview, ...
                           'amplitude', params.amplitude, ...
                           'width', params.width, ...
                           'center', params.center, ...
                           'center1', params.center1, ...
                           'center2', params.center2, ...
                           'frequency', params.frequency, ...
                           'noise_level', params.noise_level);
        
        figure('Name', 'Pattern Preview', 'NumberTitle', 'off');
        x = linspace(0, 1, nx_preview+2)(2:end-1);
        plot(x, u0, 'b-', 'LineWidth', 2);
        grid on;
        xlabel('Position x');
        ylabel('Temperature u');
        title(sprintf('1D Pattern: %s', strrep(pattern_name, '_', ' ')));
        ylim([min(u0)-5, max(u0)+5]);
        
    else  % dimension == 2
        % Generate and plot 2D preview
        nx_preview = 50;
        ny_preview = 50;
        u0 = get_pattern_2d(pattern_name, nx_preview, ny_preview, ...
                           'amplitude', params.amplitude, ...
                           'width', params.width, ...
                           'center_x', params.center_x, ...
                           'center_y', params.center_y, ...
                           'ring_radius', params.ring_radius, ...
                           'num_checks', params.num_checks, ...
                           'noise_level', params.noise_level);
        
        figure('Name', 'Pattern Preview', 'NumberTitle', 'off');
        imagesc(u0);
        colorbar;
        axis equal tight;
        xlabel('x direction');
        ylabel('y direction');
        title(sprintf('2D Pattern: %s', strrep(pattern_name, '_', ' ')));
        colormap('jet');
    end
    
    fprintf('\nPattern ready to use!\n');
    fprintf('Close preview window to continue...\n');
    
    % Wait for user to close preview
    waitfor(gcf);
    
end
