% MUST SET BEFORE RUNNING: smallmap, [mapqmark for trials]

%% set map positions

if smallmap
    rectangles_posx = smallmap_posx + [-1 +1 +1 -1]*smallmap_width/4;
    rectangles_posy = smallmap_posy + [-1 -1 +1 +1]*smallmap_height/4;
    rectangle_width = smallmap_width/2;
    rectangle_height = smallmap_height/2;
    Screen('TextSize',INPUTS.window,INPUTS.textsize/2);
else
    rectangles_posx = screen_width/2 + [-1 +1 +1 -1]*map_width/4;
    rectangles_posy = screen_height/2 + [-1 -1 +1 +1]*map_height/4;
    rectangle_width = map_width/2;
    rectangle_height = map_height/2;
end

%% draw the map

rect_pos = cell(1,nsectors);
for jsector = 1:nsectors
    rect_pos{jsector} = make_rectangle(rectangles_posx(jsector), rectangles_posy(jsector), rectangle_width, rectangle_height);
    %Screen('FillRect',INPUTS.window,sector_colors{isector},rect_pos{jsector});
    
    % draw rectangle
    Screen('FrameRect',INPUTS.window,INPUTS.textcolor,rect_pos{jsector});
    
    % show sector name
    sector_name = sector_names{jsector};
    temp_textposx(jsector) = rectangles_posx(jsector) - length(sector_name)*0.65*INPUTS.textsize/2;
    temp_textposy(jsector) = rectangles_posy(jsector) - INPUTS.textsize/2;
    DrawFormattedText(INPUTS.window,sector_name,...
        temp_textposx(jsector), temp_textposy(jsector), sector_colors{jsector});
        
    % show sector background
    if ~smallmap
        tempsector = jsector;
        tempwindow = rect_pos{jsector};
        draw_sector_background;
    end
end

%% draw sector pointer (if touring)

if touring && ~smallmap
    
    switch sector
        
        case {1,4} % use arrow_right and point at top left corner
            
%             arrow_pos = make_rectangle(rect_pos{sector}(1)-arrow_width/2+50,...
%                 rect_pos{sector}(2)-arrow_height/2+30,arrow_width,arrow_height);
%                 % arrow in top corner
            arrow_pos = make_rectangle(rect_pos{sector}(1)-0.9*arrow_width/2,...
                rectangles_posy(sector)-0.2*arrow_height,arrow_width,arrow_height);
                % arrow in center of side
%             arrow_pos = make_rectangle(temp_textposx(sector)-0.7*arrow_width,...
%                 temp_textposy(sector),arrow_width,arrow_height); 
%                 % arrow pointing at text
            Screen('DrawTexture',INPUTS.window,textures.arrow_right,[],arrow_pos);
            
            text = 'YOU ARE HERE';
            DrawFormattedText(INPUTS.window, text,...
                arrow_pos(1) - 0.6*INPUTS.textsize*length(text)*1.05, ...
                arrow_pos(2) + INPUTS.textsize/2, ...
                sector_colors{sector});
            
        case {2,3} % use arrow_left and point at top right corner
            
            arrow_pos = make_rectangle(rect_pos{sector}(3)+0.9*arrow_width/2,...
                rectangles_posy(sector)-0.2*arrow_height,arrow_width,arrow_height);
                % arrow in center of side
%             arrow_pos = make_rectangle(rect_pos{sector}(3)+arrow_width/2-50,...
%                 rect_pos{sector}(2)-arrow_height/2+30,arrow_width,arrow_height);
%             arrow_pos = make_rectangle(temp_textposx(sector)+1.2*arrow_width,...
%                 temp_textposy(sector),arrow_width,arrow_height);
            Screen('DrawTexture',INPUTS.window,textures.arrow_left,[],arrow_pos);
            
            text = 'YOU ARE HERE';
            DrawFormattedText(INPUTS.window, text,...
                arrow_pos(3) + 0.6*INPUTS.textsize*length(text)*0.05, ...
                arrow_pos(2) + INPUTS.textsize/2, ...
                sector_colors{sector});
            
    end
end

%% draw question mark (if trials)

if ~touring && mapqmark
    Screen('DrawTexture',INPUTS.window,textures.questionmark,[],questionmark_pos);
end

%% to force you to set these each time
clear smallmap mapqmark

%% reset text size
Screen('TextSize',INPUTS.window,INPUTS.textsize);