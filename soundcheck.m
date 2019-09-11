%% add helpers to path
addpath(genpath('helpers'))

%% load song

wavfilename = fullfile('stimuli',dir_filenames('stimuli/songPINK*'));
[y, song_freqs(1)] = audioread(wavfilename);
wavedata = y';
nrchannels = size(wavedata,1);
songs{1} = wavedata;

%% initialize PsychPortAudio

InitializePsychSound;

freq = song_freqs(1);
pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels)

%% play the song

PsychPortAudio('FillBuffer', pahandle, songs{1});
PsychPortAudio('Start', pahandle, 0, 0, 1);

%% shut down PsychPortAudio

PsychPortAudio('Close');
