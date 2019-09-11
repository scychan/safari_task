function output = makeRSAmatrix(sequence,distmeasure,maxdist)
% sequence    - T timepoints x N dimensions
% distmeasure - 'corrdist'[default]
%               'eucdist'
%               'dotprod'
%               'nrmcorr'
%               'kldiv'
% NOTE: outputs are always scaled so that maximal similarity = 1

if ~exist('distmeasure','var')
    warning('distmeasure not provided. Using default of ''corrdist''')
    distmeasure = 'corrdist'; % set the default
end

if strcmp('distmeasure','kldiv')
    warning('Forcing symmetry for kldiv matrix')
end

if ~exist('maxdist','var')
    if ismember(distmeasure,{'eucdist','dotprod'})
        error('Input ''maxdist'' required for distmeasure %s',distmeasure)
    else
        maxdist = 1;
    end
end

[T N] = size(sequence);
if N == 1
    assert(strcmp(distmeasure,'eucdist'))
end

output = nan(T);
for i = 1:T
    for j = i:T
        sldist = slmetric_pw(vert(sequence(i,:)),vert(sequence(j,:)),distmeasure);
        if ismember(distmeasure,{'dotprod','nrmcorr'})
            output(i,j) = sldist/maxdist;
        else
            output(i,j) = 1 - sldist/maxdist;
        end
        output(j,i) = output(i,j);
    end
end

% % scale the output
% output = output/maxdist;