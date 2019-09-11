function run_SAFARI(subjnum, phase, scanning, debug)
% run_SAFARI(subjnum, phase, scanning, [debug])
%
% INPUTS:
% - subjnum < 100 for behavioral subject
%           >=100 for fMRI subject
% - phase = 1 for training day 1 - outside the scanner
%         = 2 for training day 2 - outside the scanner
%         = 3 for training inside the scanner
%         = 4 for trials - inside the scanner
% - scanning = 1 if scanning, using "PST" at Skyra
%            = 0 for testing fMRI code using keyboard

global INPUTS % keeps track of the settings for: PTB window, KbQueue

% try
    
    %% sound check
    
    if ismember(phase,1:4)
        didsoundcheck = input('Did you do sound check? (y/n) ','s');
        if ~strcmp(didsoundcheck,'y')
            error('Need to do sound check first.')
        end
    end
    
    %% skip sync tests?
    
    skipsynctests = input('Skip sync tests? (y/n) ','s');
    if strcmp(skipsynctests,'y')
        Screen('Preference', 'SkipSyncTests', 1)
    else
        Screen('Preference', 'SkipSyncTests', 0)        
    end
    
    %% miscellaneous
    
    if ~exist('debug','var')
        debug = 0;
    end
    
    addpath('helpers')
    
    %% set up screen etc
    
    if isunix
        screenNumber = 0;
    elseif ispc
        screenNumber = 0;
    end
    backgroundColor = [0 0 0];
    [INPUTS.window windowRectangle] = Screen('OpenWindow',screenNumber,backgroundColor);
    screen_width = windowRectangle(3);
    screen_height = windowRectangle(4);
    INPUTS.screen_width = screen_width;
    INPUTS.screen_height = screen_height;
    
    %% load params, misc setup
    
    addpath('helpers') % helper functions and scripts
    
    touring = false;
    load_params; % a separate script
    % save a copy of the params file for record-keeping
    copyfile('load_params.m',fullfile(dataloc,sprintf('params_%s.txt',datestr(now,'yymmdd_HHMM'))))

    timeStamp = datestr(now,'yymmdd_HHMM'); % start of the phase
    t.phase_start = GetSecs;
    
    if ~debug
        HideCursor;
    end
    
    %% set up inputs
    
    if phase > 2
        INPUTS.device = devices.scanner;
    else
        INPUTS.device = devices.keyboard;
    end
    INPUTS.buttons = keysets.allfive;
    set_up_keys;
    
    %% show experiment instructions
    
    %     XX show_instructions; % a separate script
    
        
    %% Initialize/load things to save
    
    t_master = t; clear t
    if phase == 1 % initialize tours from scratch
        stimlist_master = stimlist; clear stimlist
        nsess = stimlist_master.nsess;
        
        % initialize for tours
        t.start_music = nan(nsess,nsectors);
        t.showmap = nan(nsess,nsectors);
        t.fixation1 = cell(nsess,nsectors);
        t.question = cell(nsess,nsectors);
        t.response = cell(nsess,nsectors);
        t.timeoutmsg = cell(nsess,nsectors);
        t.fixation2 = cell(nsess,nsectors);
        t.stim_onset = cell(nsess,nsectors);
        t.break = nan(nsess,nsectors);
        b.response = cell(nsess,nsectors);
        t_tours = t; b_tours = b; clear t b
        
        % initialize for trials
        t.showmap        = cell(1,nsess);
        t.startlistening = cell(1,nsess);
        t.trigger        = cell(1,nsess);
        t.fake_trigger   = cell(1,nsess);
        t.stim_onset = cell(1,nsess);
        t.fixation = cell(1,nsess);
        t.question = cell(1,nsess);
        t.response = cell(1,nsess);
        t.feedback = cell(1,nsess);
        t.startscan_trigger = nan(nsess,1);
        t.break = nan(1,nsess);
        b.response = cell(1,nsess);
        t_trials = t; b_trials = b; clear t b
                
    else % load data from before
        filename = dir_filenames(fullfile(dataloc,sprintf('phase%i_complete*',phase-1)));
        if isempty(filename)
            error('Phase%i file not found',phase-1)
        elseif iscell(filename)
            error('More than one phase%i file for this subject',phase-1)
        end
        load(fullfile(dataloc,filename));
        t_tours = tours.t; b_tours = tours.b;
        t_trials = trials.t; b_trials = trials.b;
        stimlist_master = stimlist; clear stimlist
        nsess = stimlist_master.nsess;
    end
    
    %% RUN THE GAME
    
    sessions_thisphase = find(stimlist_master.phase == phase);
    for isess = sessions_thisphase
        
        %% session properties
        
        switch stimlist_master.tour_or_trials(isess)
            case 1
                touring = true;
            case 2
                touring = false;
        end        
                        
        %% RUN TOURS
        
        if touring
            
            %%=====================%%
            %        RUN TOURS      %
            %%=====================%%
            
            %% Sort out params
            
            load_params;
            
            stimlist = stimlist_master.tours;
            t = t_tours;
            b = b_tours;
            
            %% START TOURS
            
            INPUTS.buttons = keysets.onlytwo;
            INPUTS.device = devices.keyboard;
            set_up_keys;
            
            % start screen for tours
            text = 'SAFARI TOURS';
            text = [text '\n\n\nPress any key when you are ready to begin.'];
            DrawFormattedText(INPUTS.window,text,'center','center',INPUTS.textcolor);
            Screen(INPUTS.window,'Flip');
            qwait
            
            for itour = 1:nsectors
                tour_length = length(stimlist.animals{isess,itour});
                sector = stimlist.sectors(isess,itour);
                
                % initialize things to NaN
                t.fixation1{isess,itour} = nan(1,tour_length);
                t.question{isess,itour} = nan(1,tour_length);
                t.response{isess,itour} = nan(1,tour_length);
                t.timeoutmsg{isess,itour} = nan(1,tour_length);
                t.fixation2{isess,itour} = nan(1,tour_length);
                t.stim_onset{isess,itour} = nan(1,tour_length);
                b.response{isess,itour} = nan(1,tour_length);
                
                % pause before start of tour
                Screen(INPUTS.window,'Flip')
                WaitSecs(secs.pre_tour);
                
                % start music
                Screen(INPUTS.window,'Flip');
                PsychPortAudio('FillBuffer', pahandle, songs{sector});
                t.start_music(isess,itour) = PsychPortAudio('Start', pahandle, 0, 0, 1);
                
                % show NEW DAY screen (including map)
                DrawFormattedText(INPUTS.window,'NEW DAY','center',title_pos,INPUTS.textcolor);
                sector_name = sector_names{sector};
                DrawFormattedText(INPUTS.window,['SECTOR ' sector_name],'center',title_pos+INPUTS.textsize*1.5,sector_colors{sector});
                smallmap = false; draw_map;
                DrawFormattedText(INPUTS.window,'Press any key to begin','center',text_cont_pos,INPUTS.textcolor);
                t.showmap(isess,itour) = Screen(INPUTS.window,'Flip');
                qwait
                
                % pause a little while
                Screen(INPUTS.window,'Flip')
                WaitSecs(1);
                
                for ianimal = 1:tour_length
                    
                    % get stim info for this animal
                    animal = stimlist.animals{isess,itour}(ianimal);
                    
                    % display fixation
                    show_sector_name;
                    [t.fixation1{isess,itour}(ianimal), temp] = display_cross(secs.mean_iti,secs.min_iti,secs.max_iti);
                    
                    % display question + options
                    show_sector_name;
                    tours_draw_question_prompt;
                    t.question{isess,itour}(ianimal) = Screen(INPUTS.window,'Flip');
                    
                    % get response
                    [b.response{isess,itour}(ianimal), t.response{isess,itour}(ianimal)] = WaitForKeypress(secs.response);
                    
                    if isnan(b.response{isess,itour}(ianimal))
                        DrawFormattedText(INPUTS.window,'Time out!','center','center',INPUTS.textcolor);
                        t.timeoutmsg{isess,itour}(ianimal) = Screen(INPUTS.window,'Flip');
                        sound(missTone,missTone_Fs); % play tone
                        WaitSecs(secs.feedback_display)
                    else
                        % highlight the rating / acknowledge input
                        show_sector_name;
                        tours_draw_question_prompt;
                        rect_pos = make_rectangle(tourq_options_posx(b.response{isess,itour}(ianimal)), tourq_options_posy + INPUTS.textsize/2, tourq_options_box_width, tourq_options_box_height);
                        Screen('FrameRect',INPUTS.window,INPUTS.textcolor,rect_pos);
                        Screen(INPUTS.window,'Flip');
                        
                        % wait till timeout for the item
                        WaitSecs(secs.response - (GetSecs-t.question{isess,itour}(ianimal)));
                    end
                    
                    % display fixation
                    show_sector_name;
                    [t.fixation2{isess,itour}(ianimal), temp] = display_cross(secs.mean_iti,secs.min_iti,secs.max_iti);
                    
                    % display animal + background
                    show_sector_name;
                    Screen('DrawTexture',INPUTS.window,textures.animals(animal),[],animal_pos)
                    tempsector = sector;
                    tempwindow = [0,0,screen_width,screen_height];
                    draw_sector_background;
                    t.stim_onset{isess,itour}(ianimal) = Screen(INPUTS.window,'Flip');
                    WaitSecs(secs.animal_alone);
                end
                                
                % end of tour
                Screen(INPUTS.window,'Flip');  
                
                % stop music
                WaitSecs(1)
                PsychPortAudio('Stop', pahandle);             
                
                % save intermediate data
                t.savedata = GetSecs;
                save(fullfile(dataloc,sprintf('phase%i_sess%i_tour%i_%s',phase,isess,itour,timeStamp)),...
                    'stimlist','t','b')
                
                % compute tour feedback 
                compute_tour_feedback; % (=> current_tour_feedback)
                
                if isess == sessions_thisphase(end) && itour == nsectors % last tour of the last session
                    % show performance (don't give break)
                    WaitSecs(1)
                    text = sprintf('Performance for this session: %3.0f%%',current_tour_feedback);
                    text = [text '\n\n\n\n\nPress any key when you are ready to continue.'];
                    DrawFormattedText(INPUTS.window,text,'center','center',INPUTS.textcolor);
                    Screen(INPUTS.window,'Flip');
                    qwait
                elseif phase==1 && isess==1 && itour==1
                    % give break and show performance 
                    % (wait for experimenter to explain)
                    WaitSecs(1)
                    text = 'It is time for a break.';
                    text = [text sprintf('\n\nPerformance for this session: %3.0f%%',current_tour_feedback)];
                    text = [text '\n\n\n\n\nWaiting for experimenter...'];
                    DrawFormattedText(INPUTS.window,text,'center','center',INPUTS.textcolor);
                    t.break(isess,itour) = Screen(INPUTS.window,'Flip');
                    qwait_experimenter
                    text = 'It is time for a break.';
                    text = [text sprintf('\n\nPerformance for this session: %3.0f%%',current_tour_feedback)];
                    text = [text '\n\n\n\n\nPress any key when you are ready to continue.'];
                    DrawFormattedText(INPUTS.window,text,'center','center',INPUTS.textcolor);
                    Screen(INPUTS.window,'Flip');
                    qwait
                else
                    % give break and show performance
                    WaitSecs(1)
                    text = 'It is time for a break.';
                    text = [text sprintf('\n\nPerformance for this session: %3.0f%%',current_tour_feedback)];
                    text = [text '\n\n\n\n\nPress any key when you are ready to continue.'];
                    DrawFormattedText(INPUTS.window,text,'center','center',INPUTS.textcolor);
                    t.break(isess,itour) = Screen(INPUTS.window,'Flip');
                    qwait
                end
            end
            
            % end of session
            Screen(INPUTS.window,'Flip');
            t_tours = t; b_tours = b; clear t b
        end
        
        %% RUN TRIALS
        
        if ~touring
            
            %%================%%
            %    RUN TRIALS    %
            %%================%%
            
            %% Sort out params
            
            load_params;
            
            stimlist = stimlist_master.trials;
            t = t_trials;
            b = b_trials;
            
            ntrials_sess = length(stimlist.sectors{isess});
            
            %% START TRIALS
            
            INPUTS.buttons = keysets.allfive;
            INPUTS.device = devices.scanner;
            set_up_keys;
            
            % start screen for trials
            if phase==1
                text = 'SAFARI DETECTIVE';
                text = [text '\n\n\nWaiting for experimenter...'];
                DrawFormattedText(INPUTS.window,text,'center','center',INPUTS.textcolor);
                draw_trials_titlescreen;
                Screen(INPUTS.window,'Flip');
                qwait_experimenter
            end
            text = 'SAFARI DETECTIVE';
            text = [text '\n\n\nPress any key when you are ready to begin.'];
            DrawFormattedText(INPUTS.window,text,'center','center',INPUTS.textcolor);
            draw_trials_titlescreen;
            Screen(INPUTS.window,'Flip');
            qwait
            
            % start new recording session
            if scanning
                t.startscan_trigger(isess) = StartScan(keysets,devices);
            end
            INPUTS.buttons = keysets.onlytwo;
            INPUTS.device = devices.scanner;
            set_up_keys; %XX
            
            % initialize things to NaN for this session
            t.showmap{isess}        = nan(1,ntrials_sess);
            t.startlistening{isess} = nan(1,ntrials_sess);
            t.trigger{isess}        = nan(1,ntrials_sess);
            t.fake_trigger{isess}   = nan(1,ntrials_sess);
            t.stim_onset{isess}     = cell(1,ntrials_sess);
            t.fixation{isess}       = cell(1,ntrials_sess);
            t.question{isess}       = nan(1,ntrials_sess);
            t.response{isess}       = nan(1,ntrials_sess);
            t.feedback{isess}       = nan(1,ntrials_sess);
            b.response{isess}       = nan(1,ntrials_sess);
            
            for itr = 1:ntrials_sess
                trial_length = stimlist.lengths{isess}(itr);
                
                % initialize things to NaN
                t.fixation{isess}{itr} = nan(1,trial_length);
                t.stim_onset{isess}{itr} = nan(1,trial_length);
                
                % show NEW DAY screen (including map)
                DrawFormattedText(INPUTS.window,'NEW DAY','center',title_pos,INPUTS.textcolor);
                smallmap = false; mapqmark = true; draw_map;
                DrawFormattedText(INPUTS.window,'Press any key to begin','center',text_cont_pos,INPUTS.textcolor);
                t.showmap{isess}(itr) = Screen(INPUTS.window,'Flip');
                
                % wait for subject to press a key, then wait 1 sec
                qwait
                Screen(INPUTS.window,'Flip');
                WaitSecs(1)
                
                % re-align timing with triggers
                if scanning
                    % try to get a trigger
                    t.startlistening{isess}(itr) = GetSecs;
                    t.trigger{isess}(itr) = WaitForSkyraTrigger(devices,2.1);
                    
                    % if trigger-listener times out,
                    % wait till the next multiple of 2s since the last collected trigger
                    if isnan(t.trigger{isess}(itr))
                        fprintf('Missed trigger on session %i trial %i.',isess,itr)
                        
                        all_triggers = [t.startscan_trigger(isess) t.trigger{isess}];
                        last_trigger = all_triggers(find(~isnan(all_triggers),1,'last'));
                        timer_start = GetSecs;
                        timer_wait(timer_start, 2-mod(timer_start-last_trigger,2))
                        t.fake_trigger{isess}(itr) = timer_start + 2-mod(timer_start-last_trigger,2);
                    end
                else
                    WaitSecs(1)
                end
                
                % set reference time for all items in the trial
                if scanning
                    if isnan(t.trigger{isess}(itr))
                        t.trial_start{isess}(itr) = t.fake_trigger{isess}(itr);
                    else
                        t.trial_start{isess}(itr) = t.trigger{isess}(itr);
                    end
                else
                    t.trial_start{isess}(itr) = GetSecs;
                end
                
                for ianimal = 1:trial_length
                    
                    % get stim info for this animal
                    animal = stimlist.animals{isess}{itr}(ianimal);
                    
                    % wait till timer hits appropiate num of secs since trial start
                    secs_animal_plus_fixation = secs.animal_alone + secs.mean_iti;
                    timer_wait(t.trial_start{isess}(itr), (ianimal-1)*secs_animal_plus_fixation);
                    
                    % display animal
                    smallmap = true; mapqmark = false; draw_map;
                    Screen('DrawTexture',INPUTS.window,textures.photoframe,[],frame_pos)
                    Screen('DrawTexture',INPUTS.window,textures.animals(animal),[],animal_pos)
                    t.stim_onset{isess}{itr}(ianimal) = Screen(INPUTS.window,'Flip');
                    WaitSecs(secs.animal_alone);
                    
                    % display fixation
                    %smallmap = false; mapqmark = false; draw_map;
                    %t.fixation{isess}{itr} = Screen(INPUTS.window,'Flip');
                    %WaitSecs(secs.mean_iti);
                    smallmap = true; mapqmark = false; draw_map;
                    DrawFormattedText(INPUTS.window,'+','center','center', INPUTS.textcolor);
                    t.fixation{isess}{itr}(ianimal) = Screen(INPUTS.window,'Flip');
                end
                
                % display question + options
                trials_draw_question_prompt;
                t.question{isess}(itr) = Screen(INPUTS.window,'Flip');
                
                % get response
                [b.response{isess}(itr), t.response{isess}(itr)] = WaitForKeypress(secs.response);
                
                if isnan(b.response{isess}(itr))
                    DrawFormattedText(INPUTS.window,'Time out!','center','center',INPUTS.textcolor);
                    t.feedback{isess}(itr) = Screen(INPUTS.window,'Flip');
                    sound(missTone,missTone_Fs); % play tone
                    WaitSecs(secs.feedback_display)
                else
                    % highlight the chosen option / acknowledge input
                    trials_draw_question_prompt;
                    rect_pos = make_rectangle(trialq_options_posx(b.response{isess}(itr)), trialq_options_posy, trialq_options_box_width, trialq_options_box_height);
                    Screen('FrameRect',INPUTS.window,INPUTS.textcolor,rect_pos);
                    Screen(INPUTS.window,'Flip');
                    
                    % wait till timeout for the item
                    WaitSecs(secs.response - (GetSecs-t.question{isess}(itr)));
                    
                    % show feedback
                    if b.response{isess}(itr) == stimlist.answers{isess}(itr)
                        DrawFormattedText(INPUTS.window,'You win one safari dollar!','center','center',INPUTS.textcolor);
                        Screen('DrawTexture',INPUTS.window,textures.goldcoin,[],goldcoin_pos);
                    else
                        DrawFormattedText(INPUTS.window,'INCORRECT','center','center',INPUTS.textcolor);
                    end
                    t.feedback{isess}(itr) = Screen(INPUTS.window,'Flip');
                    WaitSecs(secs.feedback_display);
                end
                
                % save intermediate data
                t.savedata = GetSecs;
                save(fullfile(dataloc,sprintf('phase%i_sess%i_trials_%s',phase,isess,timeStamp)),...
                    'stimlist','t','b')
            end
            
            % end of session
            Screen(INPUTS.window,'Flip');
            ncorrect_thissess = sum(b.response{isess} == stimlist.answers{isess});
            disp(ncorrect_thissess)
            
            if isess < sessions_thisphase(end)   % give break and show performance
                WaitSecs(1)
                text = 'It is time for a break.';
                text = [text sprintf('\n\nSafari-dollars earned this session: %i',ncorrect_thissess)];
                text = [text '\n\n\n\n\nPress any key when you are ready to continue.'];
                DrawFormattedText(INPUTS.window,text,'center','center',INPUTS.textcolor);
                t.break(isess) = Screen(INPUTS.window,'Flip');
                qwait
                
                if phase == 4
                    % wait for experimenter
                    text = 'It is time for a break.';
                    text = [text sprintf('\n\nSafari-dollars earned this session: %i',ncorrect_thissess)];
                    text = [text '\n\n\n\n\nWaiting for experimenter...'];
                    DrawFormattedText(INPUTS.window,text,'center','center',INPUTS.textcolor);
                    Screen(INPUTS.window,'Flip');
                    qwait_experimenter
                end
            else      % last session - just show performance
                text = sprintf('\n\nSafari-dollars earned this session: %i',ncorrect_thissess);
                text = [text '\n\n\n\n\nPress any key to continue.'];
                DrawFormattedText(INPUTS.window,text,'center','center',INPUTS.textcolor);
                Screen(INPUTS.window,'Flip');
                qwait
                if phase == 4
                    % wait for experimenter
                    text = sprintf('\n\nSafari-dollars earned this session: %i',ncorrect_thissess);
                    text = [text '\n\n\n\n\nWaiting for experimenter...'];
                    DrawFormattedText(INPUTS.window,text,'center','center',INPUTS.textcolor);
                    Screen(INPUTS.window,'Flip');
                    qwait_experimenter
                end
            end
            t_trials = t; b_trials = b; clear t b
        end
    end
    
    %% PHASE FINISHED!
    
    % save data
    stimlist = stimlist_master;
    tours.t = t_tours; tours.b = b_tours;
    trials.t = t_trials; trials.b = b_trials;
    t = t_master;
    t.savedata = GetSecs;
    
    save(fullfile(dataloc,sprintf('phase%i_complete_%s',phase,timeStamp)),...
        'stimlist','t','tours','trials')
    
    % show "end" message
    switch phase
        case 1
            DrawFormattedText(INPUTS.window,'END OF EXPERIMENT FOR TODAY\n\n\nPlease let the experimenter know that you are finished.','Center','Center',INPUTS.textcolor);
        case 2
            DrawFormattedText(INPUTS.window,'END OF SESSION\n\n\nLet the experimenter know if you have any questions.\n\nOtherwise, let''s go on!','Center','Center',INPUTS.textcolor);
        case 3
            if fmri
                DrawFormattedText(INPUTS.window,'END OF TRAINING\n\n\nLet the experimenter know if you have any questions.','Center','Center',INPUTS.textcolor);
            else
                DrawFormattedText(INPUTS.window,'END OF TRAINING\n\n\nLet the experimenter know if you have any questions.','Center','Center',INPUTS.textcolor);
            end
        case 4
            if fmri
                DrawFormattedText(INPUTS.window,'CONGRATULATIONS! You have finished the in-scanner part of the experiment!','center','center',INPUTS.textcolor);
            else
                DrawFormattedText(INPUTS.window,'CONGRATULATIONS! You have finished the experiment. \n\nPlease get the experimenter. Thanks!','center','center',INPUTS.textcolor);
            end
    end
    Screen(INPUTS.window,'Flip');
    
    % wait for key to close PTB
    qwait_experimenter
    
    
    %% Close PTB
    
    PsychPortAudio('Close', pahandle);
    ListenChar(0);
    sca;
    fclose('all');
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    
    % catch %#ok<CTCH>
    %
    %     Screen('CloseAll');
    %     ShowCursor;
    %     Priority(0);
    %     PsychPortAudio('Close')
    %     psychrethrow(psychlasterror);
    % end
end


function [cross_time duration] = display_cross(secs_mean_iti,secs_min_iti,secs_max_iti)
global INPUTS
white = [255 255 255];
DrawFormattedText(INPUTS.window, '+', 'center', 'center', white);
if ~exist('secs_min_iti')
    duration = secs_mean_iti;
else
    while ~exist('duration','var') || duration < secs_min_iti || duration > secs_max_iti
        duration = exprnd(secs_mean_iti);
    end
end
cross_time = Screen('Flip', INPUTS.window);
WaitSecs(duration);
cross_end_time = Screen('Flip', INPUTS.window);
duration = cross_end_time - cross_time;
end
