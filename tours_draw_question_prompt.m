global INPUTS

% draw question
text = 'Which animal will come next?';
DrawFormattedText(INPUTS.window,text,'center',tourq_question_posy,INPUTS.textcolor);

% draw options
for i = 1:2
    option = stimlist.questions{isess,itour}(ianimal,i);
%     option_pos = make_rectangle(tourq_options_posx(i),tourq_options_posy,...
%         choiceanimals_scaling*animal_width,choiceanimals_scaling*animal_height);
%     Screen('DrawTexture',INPUTS.window,textures.animals(option),...
%         [],option_pos);
    
    option_name = stim_to_use.animal_names{option};
    DrawFormattedText(INPUTS.window,option_name,...
        tourq_options_posx(i) - length(option_name)/2*0.7*INPUTS.textsize,...
        tourq_options_posy, INPUTS.textcolor);
end