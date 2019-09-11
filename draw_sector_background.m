
% NEED TO SET BEFORE CALLING THIS SCRIPT:
% tempsector + tempwindow = [left top right bottom]

tempwindow_height = tempwindow(4) - tempwindow(2);
tempwindow_width = tempwindow(3) - tempwindow(1);


%% draw "ground"

ground_posy = tempwindow(2) + animal_pos(4)/screen_height*tempwindow_height;

if tempwindow_height == screen_height
    Screen('DrawLine',INPUTS.window,INPUTS.textcolor,tempwindow(1),ground_posy,tempwindow(3),ground_posy,2);
end

%% draw background items

switch sector_name
    
    case 'GREEN'
        
        itemwidth = 4.95/30*tempwindow_height;
        itemheight = 5.8/30*tempwindow_height;
        itempos = make_rectangle(tempwindow(1)+tempwindow_width*0.15,ground_posy - 1 - itemheight/2,...
            itemwidth,itemheight);
        Screen('DrawTexture',INPUTS.window,textures.backgrounds(tempsector),[],itempos)
        itempos = make_rectangle(tempwindow(1)+tempwindow_width*0.75,ground_posy - 1 - itemheight/2,...
            itemwidth,itemheight);
        Screen('DrawTexture',INPUTS.window,textures.backgrounds(tempsector),[],itempos)
        itempos = make_rectangle(tempwindow(1)+tempwindow_width*0.9,ground_posy - 1 - itemheight/2,...
            itemwidth,itemheight);
        Screen('DrawTexture',INPUTS.window,textures.backgrounds(tempsector),[],itempos)
        
    case 'BLUE'
        
        itemwidth = 6.09/20*tempwindow_height;
        itemheight = 2.74/20*tempwindow_height;
        itempos = make_rectangle(tempwindow(1)+tempwindow_width*0.2, tempwindow(2)+tempwindow_height*0.2,...
            itemwidth,itemheight);
        Screen('DrawTexture',INPUTS.window,textures.backgrounds(tempsector),[],itempos)
        itempos = make_rectangle(tempwindow(1)+tempwindow_width*0.8, tempwindow(2)+tempwindow_height*0.25,...
            itemwidth,itemheight);
        Screen('DrawTexture',INPUTS.window,textures.backgrounds(tempsector),[],itempos)
        
    case 'YELLOW'
        
        itemwidth = 6.1/15*tempwindow_height;
        itemheight = 2.9/15*tempwindow_height;
        switch jsector
            case {1,4}
                itempos = make_rectangle(tempwindow(1)+tempwindow_width*0.2,ground_posy - 1 - itemheight/2,...
                    itemwidth,itemheight);
            case {2,3}
                itempos = make_rectangle(tempwindow(3)-tempwindow_width*0.2,ground_posy - 1 - itemheight/2,...
                    itemwidth,itemheight);
        end
        Screen('DrawTexture',INPUTS.window,textures.backgrounds(tempsector),[],itempos)
        
    case 'PINK'
        
        itemwidth = 2.3/20*tempwindow_height;
        itemheight = 4.5/20*tempwindow_height;
        itempos = make_rectangle(tempwindow(1)+tempwindow_width*0.1,ground_posy - 1 - itemheight/2,...
            itemwidth,itemheight);
        Screen('DrawTexture',INPUTS.window,textures.backgrounds(tempsector),[],itempos)
        itempos = make_rectangle(tempwindow(1)+tempwindow_width*0.3,ground_posy - 1 - itemheight/2,...
            itemwidth,itemheight);
        Screen('DrawTexture',INPUTS.window,textures.backgrounds(tempsector),[],itempos)
        itempos = make_rectangle(tempwindow(1)+tempwindow_width*0.75,ground_posy - 1 - itemheight/2,...
            itemwidth,itemheight);
        Screen('DrawTexture',INPUTS.window,textures.backgrounds(tempsector),[],itempos)
        itempos = make_rectangle(tempwindow(1)+tempwindow_width*0.85,ground_posy - 1 - itemheight/2,...
            itemwidth,itemheight);
        Screen('DrawTexture',INPUTS.window,textures.backgrounds(tempsector),[],itempos)
        itempos = make_rectangle(tempwindow(1)+tempwindow_width*0.95,ground_posy - 1 - itemheight/2,...
            itemwidth,itemheight);
        Screen('DrawTexture',INPUTS.window,textures.backgrounds(tempsector),[],itempos)
end