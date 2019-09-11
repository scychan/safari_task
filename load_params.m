%% parse inputs

if subjnum < 100
    fmri = 0;
    behavioral = 1;
    dataloc = fullfile('data_behavioral',sprintf('subj%i',subjnum));
else
    fmri = 1;
    behavioral = 0;
    dataloc = fullfile('data_fmri',sprintf('subj%i',subjnum));
end

switch phase
    case 1
        day1 = true;
    case {2,3,4}
        day1 = false;
end

%% set random seed

seed = sum(100*clock);
fprintf('Random seed is: %f\n',seed)
rand('twister', seed)

%% load stim list

stimlist_filename = dir_filenames(fullfile(dataloc,'stimlist*'));
fullfile(dataloc,stimlist_filename)
load(fullfile(dataloc,stimlist_filename))

nanimals = stim_to_use.nanimals;
nsectors = stim_to_use.nsectors;
animal_names = stim_to_use.animal_names;
sector_names = stim_to_use.sector_names;
sector_colors = stim_to_use.sector_colors;
likelihood_diffs_cell = stim_to_use.likelihood_diffs;

%% key inputs

% unify across Mac and Windows
KbName('UnifyKeyNames');

% disable 'sticky' key on laptop
if ispc
    DisableKeysForKbCheck(233);
end

% keys
if scanning
    one = KbName('1!');
    two = KbName('2@');
    three = KbName('3#');
    four = KbName('4$');
    five = KbName('5%');
else
    one = KbName('b');
    two = KbName('u');
    three = KbName('i');
    four = KbName('o');
    five = KbName('p');
    six = KbName('Return');
    six = six(1);
end

keysets.onlytwo = [two three];
keysets.allfive = [one two three four five];
% keysets.allsix = [one two three four five six];
keysets.g = KbName('g');

devices.keyboard = PniKbGetDeviceNamed;
if scanning
%     devices.scanner = 8;
    devices.scanner = PniKbGetDeviceNamed('Xkeys');
%     devices.scanner = PniKbGetDeviceNamed('932');
else
    devices.scanner = devices.keyboard; % to test out the fMRI on the keyboard
end

%% sound and music

missTone = sin(linspace(0,.125*500*2*pi,round(.125*2000))); % 1/8 second for a Fs of 2000
missTone_Fs = 2000;
% missTone = sin(linspace(0,.125*400*2*pi,round(.125*2000))); %1/8 second
% startTone = sin(linspace(0,.125*550*2*pi,round(.125*2000))); %1/8 second

% load background music for touring
% (based on BasicSoundOutputDemo.m)
nsongs = stim_to_use.nsectors;
songs = cell(1,nsongs);
song_freqs = nan(1,nsongs);
for isector = 1:nsectors
    sector_name = sector_names{isector};
    wavfilename = fullfile('stimuli',dir_filenames(sprintf('stimuli/song%s*',sector_name)));
    [y, song_freqs(isector)] = audioread(wavfilename);
    wavedata = y';
    nrchannels = size(wavedata,1);
    if nrchannels < 2
        wavedata = [wavedata ; wavedata];
        nrchannels = 2;
    end
    songs{isector} = wavedata;
    assert(song_freqs(isector) == song_freqs(1));
end

InitializePsychSound;
try
    freq = song_freqs(1);
    % Try with the 'freq'uency we wanted:
    pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels)
catch
    % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq);
    fprintf('Sound may sound a bit out of tune, ...\n\n');

    psychlasterror('reset');
    pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
end

%% load image textures

% animals
textures.images = nan(1,nanimals);
for i = 1:nanimals
    animalnum = stim_to_use.animals(i);
    filename = fullfile('stimuli',dir_filenames(sprintf('stimuli/animal%i*',animalnum)));
    textures.animals(i) = Screen(INPUTS.window, 'MakeTexture', imread(filename));
end

% background items (grass, clouds, etc)
textures.backgrounds = nan(1,nsectors);
for i = 1:nsectors
    sector_name = sector_names{i};
    filename = fullfile('stimuli',dir_filenames(sprintf('stimuli/sector%s*',sector_name)));
    textures.backgrounds(i) = Screen(INPUTS.window, 'MakeTexture', imread(filename));
end

% arrows
filename = fullfile('stimuli','arrow_right.png');
textures.arrow_right = Screen(INPUTS.window, 'MakeTexture', imread(filename));
filename = fullfile('stimuli','arrow_left.png');
textures.arrow_left = Screen(INPUTS.window, 'MakeTexture', imread(filename));

% gold coin
filename = fullfile('stimuli','goldcoin.png');
textures.goldcoin = Screen(INPUTS.window, 'MakeTexture', imread(filename));

% question mark
filename = fullfile('stimuli','questionmark.png');
textures.questionmark = Screen(INPUTS.window, 'MakeTexture', imread(filename));

% photo frame
filename = fullfile('stimuli','photo_frame.jpg');
textures.photoframe = Screen(INPUTS.window, 'MakeTexture', imread(filename));

%% text params - shared

white = [255 255 255];
gray = [50 50 50];
green = [182 255 158];

% font for instructions
for font = {'Arial', 'Helvetica', 'sans-serif'} % try them until one works
    Screen('TextFont', INPUTS.window, char(font));
    match = streq(font, Screen('TextFont', INPUTS.window));
    if match
        INPUTS.instrfont = font;
    end
end
INPUTS.instrcolor = white;

INPUTS.specialcolor = green;

INPUTS.textcolor = white;
INPUTS.textfont = 'Geneva';
INPUTS.textsize = 30; 
Screen('TextFont',INPUTS.window,INPUTS.textfont);
Screen('TextSize',INPUTS.window,INPUTS.textsize);
    
if scanning
    wrapat = 50;
else
    wrapat = 80;
end
wrapat_short = 50;
vSpacing = 1.3; % spacing between lines of text

% for titles at the top of the screen
title_pos = 100;

% for continuation:
text_cont = '[Press any key to continue...]';
text_cont_pos = screen_height - 100;

%% timing

% fixation (between animals)
if touring
    secs.mean_iti = 0.3; % note that this isn't the true mean, because of the cutoffs
    secs.min_iti = 0.2;
    secs.max_iti = 0.8;
else
    secs.mean_iti = 0.5; % no jitter
end

if touring
    secs.animal_alone = 2.5;
    secs.pre_tour = 2;
    secs.response = 2;
    secs.feedback_display = 1;
else
    secs.animal_alone = 3.5;
    secs.response = 2.5;
    secs.feedback_display = 1.5;
end

%% task params / rewards

% feedback type for tours (used in compute_tour_feedback)
tours_feedback_type = 'percent_optimal';

% cash bonus
cents_reward = 10;

% hourly rate
if fmri
    hourly_rate = 20;
elseif behavioral
    hourly_rate = 12;
end

%% task params - graphics

% position of animal images
animal_height = screen_height/2.5;
animal_width = screen_height/2.5;
animal_posx = screen_width/2;
animal_posy = screen_height/2;
animal_pos = make_rectangle(animal_posx, animal_posy, animal_width, animal_height);

% position of photo frame (for trials)
frame_height = 1.2 * animal_height;
frame_width = 859/591*frame_height;
frame_posx = animal_posx;
frame_posy = animal_posy;
frame_pos = make_rectangle(frame_posx, frame_posy, frame_width, frame_height);

% position of map
map_width = screen_width/2;
map_height = screen_height/2;

% position of smallmap
smallmap_posx = screen_width*5/6;
smallmap_posy = screen_height*1/6;
smallmap_width = screen_width/5;
smallmap_height = screen_height/5;
if scanning
    smallmap_posy = smallmap_posy + screen_height/5;
end

% size of "choice" animals on tours
choiceanimals_scaling = 0.8;

% position of options on questions during tours
tourq_question_posy = screen_height/3;
tourq_options_posx = screen_width/2 + screen_width/6*[-1 1];
tourq_options_posy = screen_height/2;
tourq_options_box_width = 7*INPUTS.textsize; %1.1*choiceanimals_scaling*animal_width;
tourq_options_box_height = 2.5*INPUTS.textsize; %1.1*choiceanimals_scaling*animal_height;

% position of options on questions during trials
trialq_options_posx = screen_width/2 + screen_width/10*[-1 1];
trialq_options_posy = screen_height/2 + 100;
trialq_options_box_width = 7*INPUTS.textsize;
trialq_options_box_height = 5*INPUTS.textsize;

% position of sector pointers (arrow)
arrow_width = 2.64/20*screen_height;
arrow_height = 2.46/20*screen_height;

% position of question mark (on map)
questionmark_width = 3.8/20*screen_height;
questionmark_height = 4.8/20*screen_height;
questionmark_pos = make_rectangle(screen_width/2,screen_height/2,...
    questionmark_width,questionmark_height);

% position of gold coin (during trials feedback)
goldcoin_posx = screen_width/2;
goldcoin_posy = 1/3*screen_height;
goldcoin_width = 10.5/50*screen_height;
goldcoin_height = 12/50*screen_height;
goldcoin_pos = make_rectangle(goldcoin_posx,goldcoin_posy,goldcoin_width,goldcoin_height);

% positions of gold coins and question marks during "SAFARI DETECTIVE"
% title screen
trials_titlescreen_goldcoin_posx = [screen_width/8 screen_width*0.4 screen_width*0.8];
trials_titlescreen_goldcoin_posy = [screen_height*0.45 screen_height*0.25 screen_height*0.8];
trials_titlescreen_questionmark_posx = [screen_width*0.4 screen_width*0.9 screen_width*0.55];
trials_titlescreen_questionmark_posy = [screen_height*0.75 screen_height*0.7 screen_height*0.2];

%% params for weighted percent optimal feedback on tours

slope = .6; %slope and intercept for weighted response
intercept = .8; %adjustment

%% save a copy of this file for record-keeping

copyfile('load_params.m',fullfile(dataloc,sprintf('params_%s.txt',datestr(now,'yymmdd_HHMM'))))
