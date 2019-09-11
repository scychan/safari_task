global INPUTS

% draw question 
switch stimlist.questions_biggersmaller{isess}(itr)
    case 1
        DrawFormattedText(INPUTS.window,'Which of these two sectors is MORE likely?','center','center',INPUTS.textcolor);
    case 2
        DrawFormattedText(INPUTS.window,'Which of these two sectors is LESS likely?','center','center',INPUTS.textcolor);
end

% draw options
for i = 1:2
    option = stimlist.questions_sectors{isess}(itr,i);
    DrawFormattedText(INPUTS.window,upper(stim_to_use.sector_names{option}),...
        trialq_options_posx(i) - 3*INPUTS.textsize,...
        trialq_options_posy - INPUTS.textsize/2,...
        stim_to_use.sector_colors{option});
end

% draw smallmap
smallmap = true; mapqmark = false; draw_map;