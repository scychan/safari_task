%% welcome

if phase = 1
    text = 'WELCOME to this experiment!\n\nPress any key to see what''s in store for you today...';
    DrawFormattedText(INPUTS.window,text,'Center','Center',INPUTS.instrcolor);
    Screen(INPUTS.window,'Flip');
    qwait;
    Screen(INPUTS.window,'Flip');
    WaitSecs(0.6);
end

%% Instructions for training

if phase == 1
    
    % new section
    wrapat = 30;
    
    Screen('TextFont',INPUTS.window,char(INPUTS.instrfont));
    text = 'Each round of the experiment will begin with an image, like this:';
    DrawFormattedText(INPUTS.window,text,0.1*screen_width,0.1*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    % display cue + box + bowl
    Screen('TextFont',INPUTS.window,char(INPUTS.instrfont));
    text = 'Each round of the experiment will begin with an image, like this:';
    DrawFormattedText(INPUTS.window,text,0.1*screen_width,0.1*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    Screen('DrawTexture',INPUTS.window,textures.sample_cue,[],cue_pos);
    draw_box('closed',box_pos,box_width);
    Screen('DrawTexture',INPUTS.window,textures.bowl,[],bowl_pos);
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    Screen('DrawTexture',INPUTS.window,textures.sample_cue,[],cue_pos);
    draw_box('closed',box_pos,box_width);
    Screen('DrawTexture',INPUTS.window,textures.bowl,[],bowl_pos);
    text = 'Each round of the experiment will begin with an image, like this:\n\nThen, the box around the image will open, and some M&Ms will fall into your bowl.';
    DrawFormattedText(INPUTS.window,text,0.1*screen_width,0.1*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    % first flap of box opens
    DrawFormattedText(INPUTS.window,text,0.1*screen_width,0.1*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    Screen('DrawTexture',INPUTS.window,textures.sample_cue,[],cue_pos)
    draw_box('open1',box_pos,box_width)
    Screen('DrawTexture',INPUTS.window,textures.bowl,[],bowl_pos)
    Screen(INPUTS.window,'Flip');
    WaitSecs(0.2)
    
    % second flap of box opens + MMs drop into bowl
    numdropsteps = secs.droptime/0.005;
    ystepsize = (MM_endposy - MM_startposy)/numdropsteps;
    MMs_posx = MM_startposx;
    MMs_posy = MM_startposy;
    for dropstep = 0:numdropsteps
        allMMs_posx = MMs_posx + [-MM_width/2, MM_width/2];
        allMMs_posy = MMs_posy + [0 0];
        for iMM = 1:2
            MMpos = make_rectangle(allMMs_posx(iMM), allMMs_posy(iMM), MM_width, MM_height);
            Screen('DrawTexture',INPUTS.window,textures.sampleMMs(2),[],MMpos);
        end
        DrawFormattedText(INPUTS.window,text,0.1*screen_width,0.1*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
        Screen('DrawTexture',INPUTS.window,textures.sample_cue,[],cue_pos);
        draw_box('open2',box_pos,box_width);
        Screen('DrawTexture',INPUTS.window,textures.bowl,[],bowl_pos);
        
        Screen(INPUTS.window,'Flip');
        WaitSecs(0.005);
        
        MMs_posy = MMs_posy + ystepsize;
    end
    for iclink = 1:2
        sound(INPUTS.clink,INPUTS.fs);
    end
    
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    DrawFormattedText(INPUTS.window,text,0.1*screen_width,0.1*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    Screen('DrawTexture',INPUTS.window,textures.sample_cue,[],cue_pos);
    draw_box('open2',box_pos,box_width);
    Screen('DrawTexture',INPUTS.window,textures.bowl,[],bowl_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    
    % Explain the image-MM association
    text = 'Each round of the experiment will begin with an image, like this:';
    text = [text '\n\n' 'Then, the box around the image will open, and some M&Ms will fall into your bowl'];
    DrawFormattedText(INPUTS.window,text,0.1*screen_width,0.1*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    text = 'You will see different images on different rounds.';
    text = [text '\n\n\nEach image is most likely to produce a certain NUMBER and COLOR of M&Ms.'];
    DrawFormattedText(INPUTS.window,text,0.7*screen_width,0.1*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    Screen('DrawTexture',INPUTS.window,textures.sample_cue,[],cue_pos);
    draw_box('open2',box_pos,box_width);
    Screen('DrawTexture',INPUTS.window,textures.bowl,[],bowl_pos);
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    % Explain tally
    text = 'Each round of the experiment will begin with an image, like this:';
    text = [text '\n\n' 'Then, the box around the image will open, and some M&Ms will fall into your bowl'];
    DrawFormattedText(INPUTS.window,text,0.1*screen_width,0.1*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    text = 'You will see different images on different rounds.';
    text = [text '\n\n\nEach image is most likely to produce a certain NUMBER and COLOR of M&Ms.'];
    text = [text '\n\n\n\n\n\nTo keep track of the M&Ms you have collected, we will keep a tally for you.'];
    DrawFormattedText(INPUTS.window,text,0.7*screen_width,0.1*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    Screen('DrawTexture',INPUTS.window,textures.sample_cue,[],cue_pos);
    draw_box('open2',box_pos,box_width);
    Screen('DrawTexture',INPUTS.window,textures.bowl,[],bowl_pos);
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    % draw the two tallies
    sampleMM_tally = [0 2];
    for j = 1:2
        tally_pic_location = [screen_width/2 + tally_pic_width*(j-3), tally_posy, ...
            screen_width/2 + tally_pic_width*(j-2), tally_posy + tally_pic_height];
        % draw the MM
        Screen('DrawTexture',INPUTS.window,textures.sampleMMs_clean(j),[],tally_pic_location);
        % draw number on the MM
        DrawFormattedText(INPUTS.window, sprintf('%d',sampleMM_tally(j)), screen_width/2+tally_pic_width*(j-2.5)-0.3*INPUTS.textsize, tally_posy + tally_pic_height/2 -0.3*INPUTS.textsize, white);
    end
    % draw line under the bowl
    Screen('DrawLine', INPUTS.window, [255 255 255], 0, bowl_posy + bowl_height/2, screen_width, bowl_posy + bowl_height/2, 1);
    % draw the other stuff
    text = 'Each round of the experiment will begin with an image, like this:';
    text = [text '\n\n' 'Then, the box around the image will open, and some M&Ms will fall into your bowl'];
    DrawFormattedText(INPUTS.window,text,0.1*screen_width,0.1*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    text = 'You will see different images on different rounds.';
    text = [text '\n\n\nEach image is most likely to produce a certain NUMBER and COLOR of M&Ms.'];
    text = [text '\n\n\n\n\n\nTo keep track of the M&Ms you have collected, we will keep a tally for you.'];
    DrawFormattedText(INPUTS.window,text,0.7*screen_width,0.1*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    Screen('DrawTexture',INPUTS.window,textures.sample_cue,[],cue_pos);
    draw_box('open2',box_pos,box_width);
    Screen('DrawTexture',INPUTS.window,textures.bowl,[],bowl_pos);
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    
    % new section
    Screen(INPUTS.window,'Flip')
    WaitSecs(0.6)
    
    
    text = sprintf('Every time you collect %i M&Ms of a given color, you will earn 1 real M&M.',virtualMMratio);
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.1*screen_height);
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    % show the screen that asks them to eat.
    text = sprintf('Every time you collect %i M&Ms of a given color, you will earn 1 real M&M.',virtualMMratio);
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.1*screen_height,INPUTS.instrcolor,130,[],[],1.2);
    if fmri
        text = '\n\nDuring the training session, you will be able to immediately eat the M&Ms that you earn.\nYou will see a screen that looks like this:';
    elseif behavioral
        text = '\n\nDuring the first session, you will be able to immediately eat the M&Ms that you earn.\nYou will see a screen that looks like this:';
    end
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.1*screen_height,INPUTS.instrcolor,130,[],[],1.2);
    Screen('TextFont',INPUTS.window,INPUTS.textfont);
    DrawFormattedText(INPUTS.window,'\nYou have an earned an M&M!\n\nYou may eat one M&M of this color:','center',pleaseeat_posy,INPUTS.textcolor);
    MMpos = make_rectangle(screen_width/2,screen_height/2,MM_height,MM_width);
    Screen('DrawTexture',INPUTS.window,textures.sampleMMs(2),[],MMpos);
    Screen('TextFont',INPUTS.window,char(INPUTS.instrfont));
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos,INPUTS.instrcolor);
    Screen(INPUTS.window,'Flip');
    qwait;    
    
    text = sprintf('Every time you collect %i M&Ms of a given color, you will earn 1 real M&M.',virtualMMratio);
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.1*screen_height);
    if fmri
        text = '\n\nDuring the training session, you will be able to immediately eat the M&Ms that you earn.\nYou will see a screen that looks like this:';
    elseif behavioral
        text = '\n\nDuring the first session, you will be able to immediately eat the M&Ms that you earn.\nYou will see a screen that looks like this:';
    end
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.1*screen_height,INPUTS.instrcolor,130,[],[],1.2);
    Screen('TextFont',INPUTS.window,INPUTS.textfont);
    DrawFormattedText(INPUTS.window,'\nYou have an earned an M&M!\n\nYou may eat one M&M of this color:','center',pleaseeat_posy,INPUTS.textcolor);
    MMpos = make_rectangle(screen_width/2,screen_height/2,MM_height,MM_width);
    Screen('DrawTexture',INPUTS.window,textures.sampleMMs(2),[],MMpos);
    Screen('TextFont',INPUTS.window,char(INPUTS.instrfont));
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos,INPUTS.instrcolor);
    
    if fmri
        text = 'While you are in the scanner, we will keep count for you and give you the M&Ms at the end.';
        DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.7*screen_height,INPUTS.instrcolor,130,[],[],1.2);
        DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
        Screen(INPUTS.window,'Flip');
        qwait
    elseif behavioral
        text = 'For the rest of the sessions, we will keep count for you and give you the M&Ms at the end.';
        DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.7*screen_height,INPUTS.instrcolor,130,[],[],1.2);
        DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
        Screen(INPUTS.window,'Flip');
        qwait
    end
    
    
    % new section - set wrapat
    Screen(INPUTS.window,'Flip')
    WaitSecs(0.6)
    wrapat = 90;
    
    % explain the prediction trials
    text = 'Every once in a while, after seeing the image, the M&Ms will not appear, and you will instead be asked to guess either the number or color of M&Ms that *would have* been produced by the image.';
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.2*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    
    text = 'Every once in a while, after seeing the image, the M&Ms will not appear, and you will instead be asked to guess either the number or color of M&Ms that *would have* been produced by the image.';
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.2*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    text = '\n\n\n\nThe image will disappear, and you will see a screen that looks like this:';
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.2*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    DrawFormattedText(INPUTS.window,'Guess: NUMBER','center','center',INPUTS.textcolor);
    for i = 1:4
        DrawFormattedText(INPUTS.window,num2str(i),options_posx(i)-INPUTS.textsize/2,options_posy-INPUTS.textsize/2,INPUTS.textcolor);
    end
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    
    text = 'Every once in a while, after seeing the image, the M&Ms will not appear, and you will instead be asked to guess either the number or color of M&Ms that *would have* been produced by the image.';
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.2*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    text = '\n\n\n\nOr this:';
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.2*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    DrawFormattedText(INPUTS.window,'Guess: COLOR','center','center',INPUTS.textcolor);
    for i = 1:4
        MMoption_pos = [options_posx(i) - MM_width/2, options_posy - MM_height/2, options_posx(i) + MM_width/2, options_posy + MM_height/2];
        Screen('DrawTexture', INPUTS.window, textures.MMs(i), [], MMoption_pos)
    end
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    
    text = 'Every once in a while, after seeing the image, the N&Ms will not appear, and you will instead be asked to guess either the number or color of M&Ms that *would have* been produced by the image.';
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.2*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    text = '\n\n\n\nOr this:';
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.2*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    DrawFormattedText(INPUTS.window,'Guess: COLOR','center','center',INPUTS.textcolor);
    for i = 1:4
        MMoption_pos = [options_posx(i) - MM_width/2, options_posy - MM_height/2, options_posx(i) + MM_width/2, options_posy + MM_height/2];
        Screen('DrawTexture', INPUTS.window, textures.MMs(i), [], MMoption_pos)
    end
    text = sprintf('Instead of receiving the M&Ms, you will receive a bonus of %i cents, but only if you guess correctly. If you guess correctly every time, you will receive a total bonus of $%2.2f, in addition to the $%i hourly rate.',cents_reward,cents_reward/100*sum(stimlist.PTtype>0),hourly_rate); 
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.7*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    text = 'Every once in a while, after seeing the image, the N&Ms will not appear, and you will instead be asked to guess either the number or color of M&Ms that *would have* been produced by the image.';
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.2*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    text = '\n\n\n\nOr this:';
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.2*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    DrawFormattedText(INPUTS.window,'Guess: COLOR','center','center',INPUTS.textcolor);
    for i = 1:4
        MMoption_pos = [options_posx(i) - MM_width/2, options_posy - MM_height/2, options_posx(i) + MM_width/2, options_posy + MM_height/2];
        Screen('DrawTexture', INPUTS.window, textures.MMs(i), [], MMoption_pos)
    end
    text = sprintf('Instead of receiving the M&Ms, you will receive a bonus of %i cents, but only if you guess correctly. If you guess correctly every time, you will receive a total bonus of $%2.2f, in addition to the $%i hourly rate.',cents_reward,cents_reward/100*sum(stimlist.PTtype>0),hourly_rate); 
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.7*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    text = '\n\n\n\nYou will only have 1 second to respond, so be sure to prepare your answer before the "Guess" prompt appears.';
    DrawFormattedText(INPUTS.window,text,0.2*screen_width,0.7*screen_height,INPUTS.instrcolor,wrapat,[],[],1.2);
    DrawFormattedText(INPUTS.window,text_cont,'Center',text_cont_pos);
    Screen(INPUTS.window,'Flip');
    qwait
    
    % new section - set wrapat
    Screen(INPUTS.window,'Flip');
    WaitSecs(0.6);
    wrapat = 60;
    
    if fmri
        text = 'You will now play the game for a few minutes outside of the scanner, before continuing to play the same game inside the scanner.';
        DrawFormattedText(INPUTS.window,text,0.3*screen_width,screen_height/3,INPUTS.instrcolor,wrapat,[],[],1.2);
        Screen(INPUTS.window,'Flip');
        qwait
        
        text = 'You will now play the game for a few minutes outside of the scanner, before continuing to play the same game inside the scanner.\n\n\nLet the experimenter know if you have any questions.\n\nOtherwise, we can get started!';
        DrawFormattedText(INPUTS.window,text,0.3*screen_width,screen_height/3,INPUTS.instrcolor,wrapat,[],[],1.2);
        Screen(INPUTS.window,'Flip');
        qwait
    else
        text = 'Let the experimenter know if you have any questions.\n\nOtherwise, we can get started!';
        DrawFormattedText(INPUTS.window,text,'center','center',INPUTS.instrcolor);
        Screen(INPUTS.window,'Flip');
        qwait
    end
    
    % return the font to the regular font
    Screen('TextFont',INPUTS.window,INPUTS.textfont);
end

%% Instructions for fMRI

if phase == 1 && fmri
    
    text{1} = 'While you are in the scanner, it is paramount that you not move your head, which can lead to artifacts in the data.';
    text{2} = 'PHASE 1\n\nYou will continue with the task you did in the training, while we record your brain activity.';
    text{3} = 'Let''s begin.';
    
    for itext = 1:length(text)
        DrawFormattedText(INPUTS.window,text{itext},'center','center',INPUTS.textcolor,wrapat,[],[],vSpacing);
        DrawFormattedText(INPUTS.window,text_cont,'center',text_cont_pos,INPUTS.textcolor);
        Screen(INPUTS.window,'Flip');
        qwait;
    end
    
    str = 'Please wait for the experimenter to set up the next part of the experiment.';
    DrawFormattedText(INPUTS.window,str,'center','center',INPUTS.textcolor,wrapat,[],[],vSpacing);
    Screen(INPUTS.window,'Flip');
    INPUTS.buttons = KbName('g');
    INPUTS.device = devices.keyboard;
    set_up_keys;
    qwait;
    
end

%% other way to write it
%
% for i = 1:length(text)
%     for j = 1:length(text{i})
%         for k = 1:j
%             if ischar(text{i}{k})
%                 DrawFormattedText(INPUTS.window,text{i}{k},tposx(1,k),tposy(1,k))
%             else
%                 instr_texture_index = text{i}{k};
%                 load_instr_texture; % loads temp_texture + temp_pos
%                 Screen('DrawTexture',INPUTS.window,temp_texture,[],temp_pos)
%             end
%         end
%         DrawFormattedText(INPUTS.window,text_cont,'center',text_cont_pos,INPUTS.textcolor);
%         Screen(INPUTS.window,'Flip');
%         qwait
%     end
% end