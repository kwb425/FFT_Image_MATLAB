%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Discrete Fourier Transform
%
%%% Notices:
% 1. S is a global structure (jumping all domain).
% 2. S.ax_fft_spectrum's title will change it's color case to case.
%
%                                                  Written by Kim, Wiback,
%                                                     2016.05.29. Ver 1.1.
%                                                     2016.05.30. Ver 1.2.
%                                                     2016.05.31. Ver 1.3.
%                                                     2016.06.01. Ver 1.4.
%                                                     2016.06.03. Ver 1.5.
%                                                     2016.06.04. Ver 1.6.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FFT_mask_image





%% Main figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spacing between axes, horizontal 50, vertical 50
% spacing between the axes and process bar, vertical 10



%%%%%%%%%%%%%%%%%%%
% Upper most figure
%%%%%%%%%%%%%%%%%%%
screen_size = get(0, 'screensize');
fg_size = [950, 700];
S.fg = figure('units', 'pixels', ...
    'position', ...
    [(screen_size(3) - fg_size(1)) / 2, ... % 1/2*(Screen's x - figure's x)
    (screen_size(4) - fg_size(2)) / 2, ... % 1/2*(Screen's y - figure's y)
    fg_size(1), ... % The figure's x
    fg_size(2)], ... % The figure's y
    'menubar', 'none', ...
    'name','Fourier Analysis', ...
    'numbertitle', 'off', ...
    'resize', 'off');



%%%%%%
% Axes
%%%%%%

%%% Original image
S.ax_img_orig = axes('units', 'pixels', ...
    'position', [50, 375, 400, 275], ...
    'NextPlot', 'replacechildren');
title(S.ax_img_orig, 'Original Image', 'fontsize', 15)

%%% Corresponding FFT spectrum
S.ax_fft_spectrum = axes('units', 'pixels', ...
    'position', [500, 375, 400, 275], ...
    'NextPlot', 'replacechildren');
title(S.ax_fft_spectrum, 'FFT Spectrum', 'fontsize', 15, ...
    'color', 'black') % Black = Not selected

%%% Rebuiled image after user's filtering
S.ax_img_after_filter = axes('units', 'pixels', ...
    'position', [50, 50, 400, 275], ...
    'NextPlot', 'replacechildren');
title(S.ax_img_after_filter, 'Rebuilded After Filtering', 'fontsize', 15)

%%% Rebuiled image from the user's filtering
S.ax_img_from_filter = axes('units', 'pixels', ...
    'position', [500, 50, 400, 275], ...
    'NextPlot', 'replacechildren');
title(S.ax_img_from_filter, 'Rebuilded From Filtering', 'fontsize', 15)



%%%%%%%%%%%%%
% Process bar
%%%%%%%%%%%%%
S.et_process = uicontrol('style', 'edit', ...
    'units', 'pix', ...
    'position', [345, 660, 260, 30], ...
    'string', 'Process bar', ...
    'fontsize', 20, ...
    'ForegroundColor', 'red', ...
    'backgroundcolor', [1, 1, 1], ...
    'horizontalalign', 'center', ...
    'visible', 'off', ...
    'fontweight', 'bold');



%%%%%%%%%%%%%%%
% Action button
%%%%%%%%%%%%%%%
S.pb_action = uicontrol('style', 'pushbutton', ...
    'units', 'pix', ...
    'position', [345, 660, 260, 30], ...
    'string', 'Load Image', ...
    'fontsize', 20, ...
    'ForegroundColor', 'red', ...
    'backgroundcolor', [0.7, 0.7, 0.7], ...
    'horizontalalign', 'center', ...
    'visible', 'on', ...
    'fontweight', 'bold');





%% Updating & Activating %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_and_activate(S)





%% Action button callback %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function pb_action_callback(~, ~, varargin)
        S = varargin{1};
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%
        % Action: initializing
        %%%%%%%%%%%%%%%%%%%%%%
        if strcmp(get(S.pb_action, 'string'), 'Load Image')
            
            %%% Do not motion detect while processing.
            freeze(S)
            
            %%% Image displaying: original image
            [name, path, ~] = uigetfile('*', 'Select Image');
            % Reading
            full_path = [path, name];
            % To gray scale
            S.img = rgb2gray(imread(full_path));
            % Display
            imagesc(flipud(S.img), 'parent', S.ax_img_orig)
            axis(S.ax_img_orig, 'tight')
            % Gray screen, for clear visualization
            colormap(S.ax_img_orig, 'gray')
            
            %%% Image displaying: FFT spectrum
            % Dummy FFT matrix for later rebuilding procedure
            S.img_selected = zeros(size(S.img));
            % FFT
            S.img_fft = fft2(S.img);
            % Shifting for better visualization
            S.img_fft = fftshift(S.img_fft);
            % Absolute + Log (for visibility)
            S.img_fft_mag = log(abs(S.img_fft)+1);
            % Display
            imagesc(S.img_fft_mag, 'parent', S.ax_fft_spectrum, ...
                'x', -size(S.img_fft_mag, 2)/2, ... % x origin to center
                'y', -size(S.img_fft_mag, 1)/2) % y origin to the center
            % Holding for the user's interaction (mouse)
            hold(S.ax_fft_spectrum, 'on')
            axis(S.ax_fft_spectrum, 'tight')
            % Eliminating negative tick labels
            set(S.ax_fft_spectrum, ...
                'xticklabel', ... % 6. setting the positive labels
                cellstr(... % 5. cell(string)
                num2str(... % 4. abs(labels -> double) -> string
                abs(... % 3. abs(labels -> double)
                str2double(... % 2. labels -> double
                get(S.ax_fft_spectrum, 'xticklabel'))))), ... % 1. labels
                'yticklabel', ... % 6. setting the positive labels
                cellstr(... % 5. cell(string)
                num2str(... % 4. abs(labels -> double) -> string
                abs(... % 3. abs(labels -> double)
                str2double(... % 2. labels -> double
                get(S.ax_fft_spectrum, 'yticklabel')))))) % 1. labels
            % Gray screen, for clear visualization
            colormap(S.ax_fft_spectrum, 'gray')
            title(S.ax_fft_spectrum, 'FFT Spectrum', 'fontsize', 15, ...
                'color', 'red') % Red = Selected
            
            %%% Giving instructions
            set(S.pb_action, ...
                'visible', 'off', ...
                'enable', 'off')
            set(S.et_process, ...
                'visible', 'on', ...
                'string', 'Drag FFT Spectrum')
            
            
            
            %%%%%%%%%%%%%%%%%%
            % Action: deleting
            %%%%%%%%%%%%%%%%%%
            % When the user press the button to kill the selected portion,
            % proceed.
        elseif strcmp(get(S.pb_action, 'string'), 'Kill or Re-drag')
            
            %%% Do not motion detect while processing.
            freeze(S)
            
            %%% Extracting all intergers (samples) in the circle
            % Get y coordinates of the samples
            y_ints = ceil(min(S.circle.YData)):floor(max(S.circle.YData));
            % Dummy inner circle shape (indices will be stacked here.)
            inner_sphere = cell(length(y_ints), 1);
            % Main extraction loop
            for extract_x = 1:length(y_ints) % Searching for each y
                % Finding maximum x-wide span in a specific y value (int)
                x_leftmost = ceil(... % 4. Push the min to right.
                    min(... % 3. Then find minimun.
                    S.circle.XData(... % 2. Read x coordinates with those.
                    round(... % 1. Get sample points around specific y.
                    S.circle.YData) == y_ints(extract_x))));
                x_rightmost = floor(... % 4. Push the max to left.
                    max(... % 3. Then find maximum.
                    S.circle.XData(... % 2. Read x coordinates with those.
                    round(... % 1. Get sample points around specific y.
                    S.circle.YData) == y_ints(extract_x))));
                % Extracting (since we have both x, y sample coordinates.)
                inner_sphere{extract_x} = x_leftmost:x_rightmost;
            end
            
            %%% Deletion: main loop starts here.
            for kills = 1:length(inner_sphere)
                left_side_x = abs(inner_sphere{kills}...
                    (inner_sphere{kills} < 0));
                right_side_x = inner_sphere{kills}...
                    (inner_sphere{kills} >= 0);
                
                %%% Deletion: selected + magnitude + left
                S.img_fft_mag(...
                    round(... % 2. rounding
                    size(... % 1. half of y length + y_ints
                    S.img_fft_mag, 1)/2) + ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length - left_side_x
                    S.img_fft_mag, 2)/2) - ...
                    left_side_x) = ...
                    min(min(S.img_fft_mag)); % Eraze the selected part.
                
                %%% Symmetric deletion : selected + magnitude + left
                S.img_fft_mag(...
                    round(... % 2. rounding
                    size(... % 1. half of y length - y_ints
                    S.img_fft_mag, 1)/2) - ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length + left_side_x
                    S.img_fft_mag, 2)/2) + ...
                    left_side_x) = ...
                    min(min(S.img_fft_mag)); % Kill the symmetric part.
                
                %%% Deletion: selected + magnitude + right
                S.img_fft_mag(...
                    round(... % 2. rounding
                    size(... % 1. half of y length + y_ints
                    S.img_fft_mag, 1)/2) + ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length + right_side_x
                    S.img_fft_mag, 2)/2) + ...
                    right_side_x) = ...
                    min(min(S.img_fft_mag)); % Eraze the selected part.
                
                %%% Symmetric deletion : selected + magnitude + right
                S.img_fft_mag(...
                    round(... % 2. rounding
                    size(... % 1. half of y length - y_ints
                    S.img_fft_mag, 1)/2) - ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length - right_side_x
                    S.img_fft_mag, 2)/2) - ...
                    right_side_x) = ...
                    min(min(S.img_fft_mag)); % Kill the symmetric part.
                
                %%% Storing: selected + magnitude + phase + left
                S.img_selected(...
                    round(... % 2. rounding
                    size(... % 1. half of y length + y_ints
                    S.img_fft, 1)/2) + ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length - left_side_x
                    S.img_fft, 2)/2) - ...
                    left_side_x) = ...
                    S.img_fft(...
                    round(... % 2. rounding
                    size(... % 1. half of y length + y_ints
                    S.img_fft, 1)/2) + ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length - left_side_x
                    S.img_fft, 2)/2) - ...
                    left_side_x);
                
                %%% Symmetric storing: selected + magnitude + phase + left
                S.img_selected(...
                    round(... % 2. rounding
                    size(... % 1. half of y length - y_ints
                    S.img_fft, 1)/2) - ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length + left_side_x
                    S.img_fft, 2)/2) + ...
                    left_side_x) = ...
                    S.img_fft(...
                    round(... % 2. rounding
                    size(... % 1. half of y length - y_ints
                    S.img_fft, 1)/2) - ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length + left_side_x
                    S.img_fft, 2)/2) + ...
                    left_side_x);
                
                %%% Storing: selected + magnitude + phase + right
                S.img_selected(...
                    round(... % 2. rounding
                    size(... % 1. half of y length + y_ints
                    S.img_fft, 1)/2) + ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length + right_side_x
                    S.img_fft, 2)/2) + ...
                    right_side_x) = ...
                    S.img_fft(...
                    round(... % 2. rounding
                    size(... % 1. half of y length + y_ints
                    S.img_fft, 1)/2) + ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length + right_side_x
                    S.img_fft, 2)/2) + ...
                    right_side_x);
                
                %%% Symmetric storing: selected + magnitude + phase + right
                S.img_selected(...
                    round(... % 2. rounding
                    size(... % 1. half of y length - y_ints
                    S.img_fft, 1)/2) - ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length - right_side_x
                    S.img_fft, 2)/2) - ...
                    right_side_x) = ...
                    S.img_fft(...
                    round(... % 2. rounding
                    size(... % 1. half of y length - y_ints
                    S.img_fft, 1)/2) - ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length - right_side_x
                    S.img_fft, 2)/2) - ...
                    right_side_x);
                
                %%% Deletion: selected + magnitude + phase + left
                S.img_fft(...
                    round(... % 2. rounding
                    size(... % 1. half of y length + y_ints
                    S.img_fft, 1)/2) + ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length - left_side_x
                    S.img_fft, 2)/2) - ...
                    left_side_x) = 0;
                
                %%% Symmetric deletion : selected + magnitude + phase +
                % left
                S.img_fft(...
                    round(... % 2. rounding
                    size(... % 1. half of y length - y_ints
                    S.img_fft, 1)/2) - ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length + left_side_x
                    S.img_fft, 2)/2) + ...
                    left_side_x) = 0;
                
                %%% Deletion: selected + magnitude + phase + right
                S.img_fft(...
                    round(... % 2. rounding
                    size(... % 1. half of y length + y_ints
                    S.img_fft, 1)/2) + ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length + right_side_x
                    S.img_fft, 2)/2) + ...
                    right_side_x) = 0;
                
                %%% Symmetric deletion : selected + magnitude + phase +
                % right
                S.img_fft(...
                    round(... % 2. rounding
                    size(... % 1. half of y length - y_ints
                    S.img_fft, 1)/2) - ...
                    y_ints(kills), ...
                    round(... % 2. rounding
                    size(... % 1. half of x length - right_side_x
                    S.img_fft, 2)/2) - ...
                    right_side_x) = 0;
                
                %%% Plot every n'th loop (computational efficiency).
                if mod(kills, 3) == 0
                    % Turning hold off,
                    % 1. to switch from 2D to 3D
                    % 2. to show changes vividly
                    hold(S.ax_fft_spectrum, 'off')
                    % Plotting: magnitude (being cut every loop)
                    S.surf = surf(S.ax_fft_spectrum, S.img_fft_mag);
                    title(S.ax_fft_spectrum, '3D Cutting', ...
                        'fontsize', 15, 'color', 'red') % Red = Selected
                    colormap(S.ax_fft_spectrum, 'jet')
                    view(S.ax_fft_spectrum, ...
                        [length(S.img_fft_mag), ...
                        length(S.img_fft_mag), ...
                        length(S.img_fft_mag)/3])
                    % Plotting: magnitude + phase (being cut every loop)
                    imagesc(flipud(abs(ifft2(S.img_fft))), ...
                        'parent', S.ax_img_after_filter)
                    colormap(S.ax_img_after_filter, 'gray')
                    axis(S.ax_img_after_filter, 'tight')
                    % Plotting: selected + magnitude + phase
                    % (being cut every loop)
                    imagesc(flipud(log(abs(ifft2(S.img_selected)))), ...
                        'parent', S.ax_img_from_filter)
                    colormap(S.ax_img_from_filter, 'gray')
                    axis(S.ax_img_from_filter, 'tight')
                    drawnow
                end
            end
            
            %%% Plot when the cutting procedure ends.
            % Plotting: magnitude (3D -> 2D)
            imagesc(S.img_fft_mag, 'parent', ...
                S.ax_fft_spectrum, ...
                'x', -size(S.img_fft_mag, 2)/2, ...
                'y', -size(S.img_fft_mag, 1)/2)
            
            %%% Prepare for next possible cut.
            % Due to the 3D plotting, we have to re-invert the y-axis.
            set(S.ax_fft_spectrum, 'ydir', 'normal')
            % Due to the 3D plotting, we have to re-title the graph.
            title(S.ax_fft_spectrum, 'FFT Spectrum', 'fontsize', 15, ...
                'color', 'red') % Red = Selected
            % We have to re-initialize other settings too.
            hold(S.ax_fft_spectrum, 'on')
            axis(S.ax_fft_spectrum, 'tight')
            % Eliminating negative tick labels
            set(S.ax_fft_spectrum, ...
                'xticklabel', ... % 6. setting the positive labels
                cellstr(... % 5. cell(string)
                num2str(... % 4. abs(labels -> double) -> string
                abs(... % 3. abs(labels -> double)
                str2double(... % 2. labels -> double
                get(S.ax_fft_spectrum, 'xticklabel'))))), ... % 1. labels
                'yticklabel', ... % 6. setting the positive labels
                cellstr(... % 5. cell(string)
                num2str(... % 4. abs(labels -> double) -> string
                abs(... % 3. abs(labels -> double)
                str2double(... % 2. labels -> double
                get(S.ax_fft_spectrum, 'yticklabel')))))) % 1. labels
            % Gray screen, for clear visualization
            colormap(S.ax_fft_spectrum, 'gray')
            
            %%% Giving instructions
            set(S.pb_action, ...
                'visible', 'on', ...
                'enable', 'on', ...
                'string', 'Stop or Re-drag')
            set(S.et_process, ...
                'visible', 'off')
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            % Action: recursive call
            %%%%%%%%%%%%%%%%%%%%%%%%
        elseif strcmp(get(S.pb_action, 'string'), 'Stop or Re-drag')
            
            %%% Do not motion detect while processing.
            freeze(S)
            
            %%% Renewing for a new run
            cla(S.ax_img_orig)
            cla(S.ax_fft_spectrum)
            cla(S.ax_img_after_filter)
            cla(S.ax_img_from_filter)
            set(S.pb_action, 'string', 'Load Image')
            title(S.ax_fft_spectrum, 'FFT Spectrum', 'fontsize', 15, ...
                'color', 'black') % Black = Not selected
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action: updating & activating
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        update_and_activate(S)
    end





%% Motion Detecting Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function mouse_motion_fcn(~, ~, varargin)
        S = varargin{1};
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%
        % When properly pinned
        %%%%%%%%%%%%%%%%%%%%%%
        % Proceed only if the mouse is on upper part of S.ax_fft_spectrum
        curr_pt_fft = get(S.ax_fft_spectrum, 'currentpoint');
        if curr_pt_fft(1) <= max(xlim(S.ax_fft_spectrum)) && ...
                curr_pt_fft(1) >= min(xlim(S.ax_fft_spectrum)) && ...
                curr_pt_fft(3) <= max(ylim(S.ax_fft_spectrum)) && ...
                curr_pt_fft(3) >= 0
            
            %%% Coordinates allocation
            S.x = curr_pt_fft(1);
            S.x_symmetric = -S.x;
            S.y = curr_pt_fft(3);
            S.y_symmetric = -S.y;
            
            
            
            %%%%%%%%%%%%%%
            % When clicked
            %%%%%%%%%%%%%%
            try
                if S.clicked == true
                    
                    %%% Eraze fore-existing circles if any.
                    try
                        if ishandle(S.circle)
                            delete(S.circle)
                            delete(S.circle_symmetric)
                        end
                        % Pass when there are no circles.
                    catch
                    end
                    
                    %%% Drawing the circles (number of angles = samples)
                    % Normal circle
                    S.angle = linspace(0, 2*pi, ...
                        2*length(S.img_fft_mag));
                    S.circle = plot(S.ax_fft_spectrum, ...
                        abs(S.x-S.clicked_x) * ...
                        cos(S.angle) + ... % Weighting radius
                        S.clicked_x, ... % x center movement
                        abs(S.y-S.clicked_y) * ...
                        sin(S.angle) + ... % Weighting radius
                        S.clicked_y, ... % y center movement
                        'r-', 'linewidth', 3);
                    % Symmetric circle
                    S.circle_symmetric = plot(S.ax_fft_spectrum, ...
                        abs(S.x_symmetric-S.clicked_x_symmetric) * ...
                        cos(S.angle) + ... % Weighting radius
                        S.clicked_x_symmetric, ... % x center movement
                        abs(S.y_symmetric-S.clicked_y_symmetric) * ...
                        sin(S.angle) + ... % Weighting radius
                        S.clicked_y_symmetric, ... % y center movement
                        'r-', 'linewidth', 3);
                    title(S.ax_fft_spectrum, 'FFT Spectrum', ...
                        'fontsize', 15, 'color', 'red') % Red = Selected
                    
                    %%% Giving instructions
                    set(S.pb_action, ...
                        'visible', 'off', ...
                        'enable', 'off')
                    set(S.et_process, ...
                        'visible', 'on', ...
                        'string', 'Drag FFT Spectrum')
                end
                % Pass when there is no click.
            catch
            end
            
            
            
            %%%%%%%%%%%%%%%
            % When released
            %%%%%%%%%%%%%%%
            try
                if S.released == true
                    title(S.ax_fft_spectrum, 'FFT Spectrum', ...
                        'fontsize', 15, 'color', 'red') % Red = Selected
                    
                    %%% Giving instructions
                    set(S.pb_action, ...
                        'visible', 'on', ...
                        'enable', 'on', ...
                        'string', 'Kill or Re-drag')
                    set(S.et_process, 'visible', 'off')
                end
                % Pass when there is no release.
            catch
            end
            
            %%% When the mouse pinned on improper position, proceed.
        else
            title(S.ax_fft_spectrum, 'FFT Spectrum', 'fontsize', 15, ...
                'color', 'black') % Black = Not selected
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % Updating & Activating
        %%%%%%%%%%%%%%%%%%%%%%%
        update_and_activate(S)
    end





%% Mouse Clicked Callback %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function mouse_down_fcn(~, ~, varargin)
        S = varargin{1};
        S.clicked = true;
        S.released = false;
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Saving the clicked position
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        S.clicked_x = S.x;
        S.clicked_x_symmetric = -S.clicked_x;
        S.clicked_y = S.y;
        S.clicked_y_symmetric = -S.clicked_y;
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % Updating & Activating
        %%%%%%%%%%%%%%%%%%%%%%%
        update_and_activate(S)
    end





%% Mouse Released Callback %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function mouse_up_fcn(~, ~, varargin)
        S = varargin{1};
        S.clicked = false;
        S.released = true;
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Saving the released position
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        S.released_x = S.x;
        S.release_x_symmetric = -S.released_x;
        S.released_y = S.y;
        S.release_y_symmetric = -S.released_y;
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % Updating & Activating
        %%%%%%%%%%%%%%%%%%%%%%%
        update_and_activate(S)
    end





%% Updating & Freezing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%
% Updating fnc
%%%%%%%%%%%%%%
    function update_and_activate(S)
        set(S.pb_action, 'callback', {@pb_action_callback, S})
        set(S.fg, 'windowbuttondownfcn', {@mouse_down_fcn, S})
        set(S.fg, 'windowbuttonupfcn', {@mouse_up_fcn, S})
        set(S.fg, 'windowbuttonmotionfcn', {@mouse_motion_fcn, S})
    end



%%%%%%%%%%%%%%
% Freezing fnc
%%%%%%%%%%%%%%
    function freeze(S)
        set(S.fg, 'windowbuttonmotionfcn', {})
    end
end