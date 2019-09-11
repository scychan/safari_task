function make_stimlist(subjnum)
% subjnum < 100 = behavioral
% subjnum >=100 = fMRI

addpath('helpers')

%% debug?

if subjnum==100 || subjnum==0
    debug = 1;
else
    debug = 0;
end

if ~exist('initial_ratings','var')
    initial_ratings = 5 * ones(1,20);
end

%% set params

likelihoods = [ 0.1141    0.2617    0.2571    0.4563
                0.1748    0.0778    0.1441    0.2774
                0.0735    0.0677    0.1222    0.0166
                0.3690    0.2181    0.2522    0.0271
                0.2686    0.3747    0.2244    0.2226];  % P(animal|sector)
assert(all(sum(likelihoods,1) == 1))
[nanimals nsectors] = size(likelihoods);

likelihood_diffs = cell(1,4);
for i = 1:4
    diffs = zeros(5);
    for j = 1:5
        for k = 1:5
            diffs(j,k) = abs(likelihoods(j,i) - likelihoods(k,i));
        end
    end
    likelihood_diffs{1,i} = diffs;
end

if ~debug
    
    % experiment params - each sess
    
    tour_or_trials =    [1 1 1 1 1 1 1 2 2 2 2 2 2];
    phase =             [1 1 1 1 2 2 2 3 3 4 4 4 4];
    nsess = length(tour_or_trials);
    
    toursessions = find(tour_or_trials==1);
    trialsessions = find(tour_or_trials==2);
    
    % tour params
    
    tour_lengths = [40 40 20 20 30 10 10 nan nan nan nan nan nan]; % for each sector, within each round (all four sectors are visited in a round)
    ordered_rounds = [1 1 0 0 1 0 0 nan nan nan nan nan nan];
    nrounds = sum(tour_or_trials==1); % number of tours for each sector
    ntours = nrounds * nsectors;
    tours_pseudorandom_blocks = 10;
    
    % trial params
    
    trial_lengths = 1:6;
    trial_length_probabilities = [0.25 0.2 0.2 0.15 0.1 0.1];
    
    trialsesslengths = [nan nan nan nan nan nan nan ...
        20 20 30 30 30 30];
    ntrials_tot = nansum(trialsesslengths);
        
else % DEBUGGING SUBJECT
    
    % experiment params - each sess
    
    tour_or_trials =    [2 2 1 1 2 1 2 2 2];
    phase =             [1 1 1 2 2 3 3 4 4];
    nsess = length(tour_or_trials);
    
    toursessions = find(tour_or_trials==1);
    trialsessions = find(tour_or_trials==2);
    
    % tour params
    
    tour_lengths = [nan nan 1 ...
        1 nan 1 nan nan nan]; % for each sector, within each round (all four sectors are visited in a round)
    ordered_rounds = [nan nan 0 1 nan 0 nan nan nan];
    nrounds = sum(tour_or_trials==1); % number of tours for each sector
    ntours = nrounds * nsectors;
    tours_pseudorandom_blocks = 1;
        
    % trial params
    
    trial_lengths = 1:6;
    trial_length_probabilities = [0.25 0.2 0.2 0.15 0.1 0.1];
    
    trialsesslengths = [2 4 nan ...
        nan 2  nan 2 4 4];
    ntrials_tot = nansum(trialsesslengths);
    
end

%disp([tour_or_trials; tour_lengths; phase; ordered_rounds])

%% set random seed
seed = sum(100*clock);
fprintf('Random seed is: %f\n',seed)
% RandStream.setDefaultStream(RandStream('mt19937ar','seed',seed));
rand('twister', seed)

%% sector names and colors

sector_names = {'GREEN','PINK','YELLOW','BLUE'};

colors{1} = [182 255 158]; % green
colors{2} = [255 168 252]; % pink
colors{3} = [255 252 45]; % yellow
colors{4} = [145 250 250]; % blue
% colors{} = [250 192 145]; % orange

temp_order = randperm(nsectors);
colors_to_use = colors(temp_order);
sector_names = sector_names(temp_order);

%% decide which animals/images to use

nanimals_pool = 7;

not_together = [4 3; % rhino + hippo
    5 7]; % zebra + gazelle    

keep_going = true;
while keep_going
    randorder = randperm(nanimals_pool);
    animals = randorder(1:nanimals);
    keep_going = false;
    for ipair = 1:size(not_together,1)
        if ismember(not_together(ipair,1),animals) && ismember(not_together(ipair,2),animals)
            keep_going = true;
        end
    end
end
animals_to_use = horz(animals);

animal_names = cell(1,nanimals);
for ianimal = 1:nanimals
    animalnum = animals_to_use(ianimal);
    filename = dir_filenames(sprintf('stimuli/animal%i*',animalnum));
    animal_names{ianimal} = upper(filename(length('animal1_')+1:end-length('.jpg')));
end

%% create stimlist for tours - sector order

tours.sectors = nan(nsess,nsectors);
for iround = toursessions
    if ordered_rounds(iround)
        tours.sectors(iround,:) = 1:nsectors;
    else
        keep_trying = true;
        while keep_trying
            tours.sectors(iround,:) = randperm(nsectors);
            if tours.sectors(iround,1)~=tours.sectors(iround-1,4) ...
                    && hammingdist(tours.sectors(iround,:),[1 2 3 4]) > 2
                keep_trying = false;
            end
        end
    end
end

%% create stimlist for tours - which animals

tours.animals = cell(nsess,nsectors);
for iround = toursessions
    for isector = 1:nsectors
        sector = tours.sectors(iround,isector);
        sector_likelihoods = likelihoods(:,sector);
        
        % determine the number of each animal, for this tour
        tour_length = tour_lengths(iround);
        tour_neachanimal = round(tour_length * sector_likelihoods);
        nextras = sum(tour_neachanimal) - tour_length;
        if nextras > 0
            [temp, temp_order] = sort(sector_likelihoods,'descend'); % remove extras from the largest categories
            tour_neachanimal(temp_order(1:nextras)) = tour_neachanimal(temp_order(1:nextras)) - 1;
        else
            nextras = -nextras;
            [temp, temp_order] = sort(sector_likelihoods,'ascend'); % add extras to the smallest categories
            tour_neachanimal(temp_order(1:nextras)) = tour_neachanimal(temp_order(1:nextras)) + 1;
        end
        
        tour_animals = [];
        for ianimal = 1:nanimals
            tour_animals = [tour_animals ianimal*ones(1,tour_neachanimal(ianimal))];
        end
        
        % pseudorandomize in blocks
        nblocks = tour_length/tours_pseudorandom_blocks;
        tour_animals = reshape(tour_animals,nblocks,tours_pseudorandom_blocks);
        tour_animals = tour_animals(randperm(nblocks),:); % randomize the block order
        % randomize within the first block
        keep_shuffling = true; iblock = 1;
        [temp,most_likely] = max(sector_likelihoods);
        while keep_shuffling
            tour_animals(iblock,:) = tour_animals(iblock,randperm(tours_pseudorandom_blocks));
            if length(tour_animals(iblock,:))<2 || ~(tour_animals(iblock,1)==tour_animals(iblock,2) && tour_animals(iblock,1)~=most_likely) % don't allow the first two animals to be repeats
                keep_shuffling = false;
            end
        end
        % randomize within each block
        for iblock = 2:nblocks
            tour_animals(iblock,:) = tour_animals(iblock,randperm(tours_pseudorandom_blocks));
        end
        tours.animals{iround,isector} = reshape(tour_animals',1,tour_length);
    end
end

%% create stimlist for tours - which questions (+ answers)

tours.questions = cell(nsess,nsectors);
tours.answers = cell(nsess,nsectors);

for iround = toursessions
    for isector = 1:nsectors
        tour_length = tour_lengths(iround);
        tours.questions{iround,isector} = nan(tour_length,2);
        
        tourrandperm = randperm(tour_length);
        if rand < 0.5 % half of the time
            for ianimal = 1:floor(tour_length/2)
                animalpos = tourrandperm(ianimal);
                tours.questions{iround,isector}(animalpos,1) = tours.animals{iround,isector}(animalpos);
                other_options = setdiff(1:nanimals,tours.animals{iround,isector}(animalpos));
                tours.questions{iround,isector}(animalpos,2) = other_options(categoricalrnd(1/(nanimals-1)*ones(1,nanimals-1),1));
                tours.answers{iround,isector}(animalpos) = 1;
            end
            for ianimal = floor(tour_length/2)+1:tour_length
                animalpos = tourrandperm(ianimal);
                other_options = setdiff(1:nanimals,tours.animals{iround,isector}(animalpos));
                tours.questions{iround,isector}(animalpos,1) = other_options(categoricalrnd(1/(nanimals-1)*ones(1,nanimals-1),1));
                tours.questions{iround,isector}(animalpos,2) = tours.animals{iround,isector}(animalpos);
                tours.answers{iround,isector}(animalpos) = 2;
            end
        else % the other half of the time
            for ianimal = 1:ceil(tour_length/2)
                animalpos = tourrandperm(ianimal);
                tours.questions{iround,isector}(animalpos,1) = tours.animals{iround,isector}(animalpos);
                other_options = setdiff(1:nanimals,tours.animals{iround,isector}(animalpos));
                tours.questions{iround,isector}(animalpos,2) = other_options(categoricalrnd(1/(nanimals-1)*ones(1,nanimals-1),1));
                tours.answers{iround,isector}(animalpos) = 1;
            end
            for ianimal = ceil(tour_length/2)+1:tour_length
                animalpos = tourrandperm(ianimal);
                other_options = setdiff(1:nanimals,tours.animals{iround,isector}(animalpos));
                tours.questions{iround,isector}(animalpos,1) = other_options(categoricalrnd(1/(nanimals-1)*ones(1,nanimals-1),1));
                tours.questions{iround,isector}(animalpos,2) = tours.animals{iround,isector}(animalpos);
                tours.answers{iround,isector}(animalpos) = 2;
            end
        end
    end
end

%% for tours - what are the optimal responses for the questions?

tours.optima = cell(nsess,nsectors);
for iround = toursessions
    for isector = 1:nsectors
        sector = tours.sectors(iround,isector);
        sector_likelihoods = likelihoods(:,sector);
        questions = tours.questions{iround,isector};
        
        nquestions = size(questions,1);
        tours.optima{iround,isector} = nan(1,nquestions);
        for q = 1:nquestions
            [temp, tours.optima{iround,isector}(q)] = max(sector_likelihoods(questions(q,:)));
        end
    end
end

%% create stimlist for trials - which animals

trial_sequences_RSAacceptable = false;

while ~trial_sequences_RSAacceptable
    disp('Generating and testing stimlist...')
    
    for isess = trialsessions
        ntrials_sess = trialsesslengths(isess);
        sectors_temp = repmat(1:4,1,ceil(ntrials_sess/4));
        trials.sectors{isess} = sectors_temp(randperm(ntrials_sess));
    end
    
    neachtriallength = round(trial_length_probabilities.*ntrials_tot);
    nextras = sum(neachtriallength) - ntrials_tot;
    if nextras > 0
        [temp, temp_order] = sort(trial_length_probabilities,'descend'); % remove extras from the largest categories
        neachtriallength(temp_order(1:nextras)) = neachtriallength(temp_order(1:nextras)) - 1;
    else
        nextras = -nextras;
        [temp, temp_order] = sort(trial_length_probabilities,'ascend'); % add extras to the smallest categories
        neachtriallength(temp_order(1:nextras)) = neachtriallength(temp_order(1:nextras)) + 1;
    end
    
    eachtriallen = [];
    for ilen = 1:length(trial_lengths)
        len = trial_lengths(ilen);
        eachtriallen = [eachtriallen len*ones(1,neachtriallength(len))];
    end
    eachtriallen = eachtriallen(randperm(ntrials_tot));
    trials.lengths = cell(1,nsess);
    lastend = 0;
    for isess = trialsessions
        trialsesslen = trialsesslengths(isess);
        trials.lengths{isess} = eachtriallen(lastend+(1:trialsesslen));
        lastend = lastend + trialsesslen;
    end
    
    trials.animals = cell(1,nsess);
    for isess = trialsessions
        ntrials_sess = trialsesslengths(isess);
        trials.animals{isess} = cell(1,ntrials_sess);
        for itrial = 1:ntrials_sess
            sector = trials.sectors{isess}(itrial);
            sector_likelihoods = likelihoods(:,sector);
            
            trial_length = trials.lengths{isess}(itrial);
            trials.animals{isess}{itrial} = categoricalrnd(sector_likelihoods,trial_length);
        end
    end
    
    if debug
        trial_sequences_RSAacceptable = true;
    else
        [trial_sequences_RSAacceptable, filteredmodels, actualcorrs, mediancorrs] = ...
            evaluate_RSA_acceptability(likelihoods,trials,trialsessions);
        RSAdifferentiabilityinfo.filteredmodels = filteredmodels;
        RSAdifferentiabilityinfo.actualcorrs = actualcorrs;
        RSAdifferentiabilityinfo.mediancorrs = mediancorrs;
    end
end

%% compute posterior after each animal observation

trials.posteriors = cell(1,nsess);

for isess = trialsessions
    ntrials_sess = trialsesslengths(isess);
    trials.posteriors{isess} = cell(1,ntrials_sess);
    for itr = 1:ntrials_sess
        trial_length = trials.lengths{isess}(itr);
        animals = trials.animals{isess}{itr};
        
        unnormalized = cumprod(likelihoods(animals,:),1);
        trials.posteriors{isess}{itr} = normalize1(unnormalized,'r');
    end
end

%% create stimlist for trials - which questions (and answers)

trials.questions_sectors = cell(1,nsess);
trials.questions_biggersmaller = cell(1,nsess);
for isess = trialsessions
    ntrials_sess = trialsesslengths(isess);
    trials.questions_sectors{isess} = nan(ntrials_sess,2);
    for itr = 1:ntrials_sess
        temp = randperm(nsectors);
        trials.questions_sectors{isess}(itr,:) = temp(1:2);
    end
    temp = [ones(1,ntrials_sess/2) 2*ones(1,ntrials_sess/2)];
    trials.questions_biggersmaller{isess} = temp(randperm(ntrials_sess));
end

trials.answers = cell(1,nsess);
for isess = trialsessions
    ntrials_sess = trialsesslengths(isess);
    trials.answers{isess} = nan(1,ntrials_sess);
    for itr = 1:ntrials_sess
        final_posterior = trials.posteriors{isess}{itr}(end,:);
        options_posteriors = final_posterior(trials.questions_sectors{isess}(itr,:));
        switch trials.questions_biggersmaller{isess}(itr)
            case 1
                [temp, trials.answers{isess}(itr)] = max(options_posteriors);
            case 2
                [temp, trials.answers{isess}(itr)] = min(options_posteriors);
        end
    end
end

%% combine into a single struct

stim_to_use.likelihoods = likelihoods;
stim_to_use.nanimals = nanimals;
stim_to_use.nsectors = nsectors;
stim_to_use.sector_names = sector_names;
stim_to_use.sector_colors = colors_to_use;
stim_to_use.animals = animals_to_use;
stim_to_use.animal_names = animal_names;
stim_to_use.likelihood_diffs = likelihood_diffs;
stim_to_use.random_seed = seed;

stimlist.tour_or_trials = tour_or_trials;
stimlist.phase = phase;
stimlist.nsess = nsess;
% stimlist.RSAdifferentiabilityinfo = RSAdifferentiabilityinfo;

tours.ntours = ntours;
stimlist.tours = tours;

stimlist.trials = trials;

if subjnum>=100
    dataloc = fullfile('data_fmri',sprintf('subj%i',subjnum));
else
    dataloc = fullfile('data_behavioral',sprintf('subj%i',subjnum));
end

mkdir(dataloc)
save(fullfile(dataloc,['stimlist_' datestr(now,'yymmdd_HHMM')]),...
    'stim_to_use','stimlist')

end
