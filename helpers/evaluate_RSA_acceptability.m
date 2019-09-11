function [RSAacceptable, filtered_models, actualcorrs, mediancorrs] = evaluate_RSA_acceptability(likelihoods,trials,sess_to_use)
% used in make_stimlist.m

%% params

model_names = {'posterior','MAP','pMAP','posterior_MAPonly','animals','likelihoods_curr','likelihoods_cumprod'};
corrmedians = [1.0000    0.6882    0.3746    0.8538    0.3698    0.4698    1.0000]; 
% computed using ../3_analyze_pilots/RSA_models/model_RSA_differentiability_simulatedseqs.m
% for pilotgroup1 design, using Spearman correlation, within='sess'

models_to_filter = logical([0 1 0 1 0 0 0]);
filtered_models = model_names(models_to_filter);

%% basics

stimlist = trials;

[nanimals nsectors] = size(likelihoods);

%% compute the sequences of posterior probabilities

posterior_seqs = cell(1,sess_to_use(end));
for sess = sess_to_use
    nseq = length(stimlist.animals{sess});
    for iseq = 1:nseq
        animal_seq = stimlist.animals{sess}{iseq};
        likelihood_seq = cumprod(likelihoods(animal_seq,:),1); % P(animals so far|sector)
        P_animals_so_far = sum(likelihood_seq*1/nsectors,2); % P(animals so far) (marginalize over sectors)
        posterior_seqs{sess}{iseq} = likelihood_seq * (1/nsectors) ./ repmat(P_animals_so_far,1,nsectors);
    end
end

%% create RSA matrices for posterior
% T timepoints x T timepoints

RSmats_posterior = cell(1,sess_to_use(end));
for sess = sess_to_use
    sess_posterior_seqs = vertcat(posterior_seqs{sess}{:});
    RSmats_posterior{sess} = makeRSAmatrix(sess_posterior_seqs,'corrdist');
end

%% create RSA matrices for alternative hypotheses

% three models: MAP, MAPprob, posterior with zero at nonMAP
initcells({'MAP_seqs','pMAP_seq','posteriorvecMAPonly_seqs',...
    'RSmats_MAP','RSmats_pMAP','RSmats_posteriorvecMAPonly'}, ...
    [1 sess_to_use(end)])
for sess = sess_to_use
    
    % load posterior seqs for this session
    sess_posterior_seqs = vertcat(posterior_seqs{sess}{:});
    
    % compute pMAP and MAP for this session
    [pMAP_seqs{sess}, MAPseq_int] = max(sess_posterior_seqs,[],2);
    MAPseq = zeros(size(sess_posterior_seqs));
    for i = 1:length(sess_posterior_seqs)
        MAPseq(i,MAPseq_int(i)) = 1;
    end
    MAP_seqs{sess} = MAPseq;
    
    % compute posteriorvecMAPonly for this session
    posteriorvecMAPonly_seqs{sess} = zeros(size(sess_posterior_seqs));
    for ianimal = 1:length(pMAP_seqs{sess})
        curr_MAP = MAPseq_int(ianimal);
        curr_pMAP = pMAP_seqs{sess}(ianimal);
        posteriorvecMAPonly_seqs{sess}(ianimal,curr_MAP) = curr_pMAP;
    end
    
    % compute the similarity matrices for: MAP, pMAP, posteriorvecMAPonly
    RSmats_MAP{sess} = makeRSAmatrix(MAP_seqs{sess},'corrdist');
    RSmats_pMAP{sess} = makeRSAmatrix(pMAP_seqs{sess},'eucdist',1);
    RSmats_posteriorvecMAPonly{sess} = makeRSAmatrix(posteriorvecMAPonly_seqs{sess},'eucdist',sqrt(2));
end


% which animal
initcells({'animal_seqs','RSmats_animals'},[1,sess_to_use(end)]);
for sess = sess_to_use
    sess_animalseq_int = vertcat(stimlist.animals{sess}{:});
    sesslen = length(sess_animalseq_int);
    animalseq = zeros(sesslen,nanimals);
    for i = 1:sesslen
        animalseq(i,sess_animalseq_int(i)) = 1;
    end
    animal_seqs{sess} = animalseq;
    RSmats_animals{sess} = makeRSAmatrix(animal_seqs{sess},'corrdist');
end

% likelihood-related
%  P(animals so far | sector)
%  P(current animal | sector)
initcells({'likelihoods_animalssofar_seqs','likelihoods_curranimal_seqs',...
    'RSmats_likelihoods_animalssofar','RSmats_likelihoods_curranimal'},...
    [1,sess_to_use(end)]);
for sess = sess_to_use
    
    % load posterior seqs for this session
    sess_posterior_seqs = vertcat(posterior_seqs{sess}{:});
    
    % load animal_seqs for this session
    sess_animal_seq = vertcat(stimlist.animals{sess}{:});
    
    % load likelihoods for current animal
    likelihoods_curranimal_seqs{sess} = likelihoods(sess_animal_seq,:);
    
    % compute likelihoods for "animals so far", within each sequence
    nseq = length(posterior_seqs{sess});
    clear sess_likelihoods_animalssofar_seqs
    for iseq = 1:nseq
        animal_seq = stimlist.animals{sess}{iseq};
        sess_likelihoods_animalssofar_seqs{iseq} = cumprod(likelihoods(animal_seq,:),1);
    end
    likelihoods_animalssofar_seqs{sess} = vertcat(sess_likelihoods_animalssofar_seqs{:});
    
    % make similarity matrices
    RSmats_likelihoods_curranimal{sess} = makeRSAmatrix(likelihoods_curranimal_seqs{sess},'corrdist');
    RSmats_likelihoods_animalssofar{sess} = makeRSAmatrix(likelihoods_animalssofar_seqs{sess},'corrdist');
    
end

%% compile all the alternative models
allRSmats = {RSmats_posterior, RSmats_MAP, RSmats_pMAP, RSmats_posteriorvecMAPonly,...
    RSmats_animals, RSmats_likelihoods_curranimal, RSmats_likelihoods_animalssofar};
nmodels = length(allRSmats);
model_names = {'posterior','MAP','pMAP','posterior_MAPonly','animals','likelihoods_curr','likelihoods_cumprod'};

%% compute RSA similarity of posterior with each alternative hypothesis

interRSmat_corrdist = nan(nmodels);
for imodel = 1:nmodels
    for jmodel = imodel:nmodels
        
        for sess = sess_to_use
            % load the matrices to compare
            tempmat1 = allRSmats{imodel}{sess};
            tempmat2 = allRSmats{jmodel}{sess};
            
            % round off to the nearest 0.001, for better computing ties in the rank correlation
            tempmat1 = roundoff(tempmat1,1e-3);
            tempmat2 = roundoff(tempmat2,1e-3);
            
            % compute the correlation
            allcorrs(sess) = corr(tempmat1(:),tempmat2(:),'type','Spearman');
        end
        interRSmat_corrdist(imodel,jmodel) = nanmean(allcorrs(sess_to_use));
        
    end
end

%% decide if RSAacceptable
% below the median for the three models we wish to filter based on

actualcorrs = interRSmat_corrdist(1,models_to_filter)
mediancorrs = corrmedians(models_to_filter)

abovemedians = actualcorrs > mediancorrs
RSAacceptable = ~any(abovemedians);