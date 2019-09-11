sess = 13;

%%
trials.animals{sess}

%% 4 8 11 12 14 16 17 20 21 22 27 30

trial = 30

animal = trials.animals{sess}{trial}

%%
likelihoods(animal,:)
trials.posteriors{sess}{trial}
trials.questions_sectors{sess}(trial,:)
trials.questions_biggersmaller{sess}(trial)
trials.answers{sess}(trial)

normalize1(likelihoods(animal,:))
trials.posteriors{sess}{trial} = normalize1(likelihoods(animal,:));
%%
trials.answers{sess}(trial) = 2