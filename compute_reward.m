subj = 124;

addpath('helpers')
% filename = dir_filenames(fullfile('data_fmri',sprintf('subj%i',subj),'phase3_complete*'));
filename = dir_filenames(fullfile('data_fmri',sprintf('subj%i',subj),'phase4_complete*'));
load(fullfile('data_fmri',sprintf('subj%i',subj),filename))

%% Set which sessions you want to look at

% sess_to_use = 1:9;
sess_to_use = 1:stimlist.nsess;

dollars_percorrect = .10;

%% Basics

trialsess = intersect(sess_to_use,find(stimlist.tour_or_trials==2));

stimlist = stimlist.trials;
b = trials.b;

%% Count number correct for each session

correct = cellfun(@(x,y) sum(x==y), b.response(sess_to_use), stimlist.answers(sess_to_use), 'UniformOutput',false)

%% Compute total reward (in dollars)

total_reward = sum([correct{trialsess}])*dollars_percorrect