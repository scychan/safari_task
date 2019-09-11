switch tours_feedback_type
    
    case 'percent_optimal'
        
        tour_responses = [b.response{isess,itour}];
        tour_optima = [stimlist.optima{isess,itour}];
        noptimal = sum(tour_responses==tour_optima);
        poptimal = 100 * noptimal / length(tour_responses);
        
        current_tour_feedback = poptimal;
        
    case 'percent_optimal_difficulty_weighted'
        
        % load the diff_matrix
        disp(num2str(sector));
        diff_matrix_current = likelihood_diffs_cell{sector};
        
        %calculate diffs from cells that have animal questions
        animals_total = stimlist.questions{isess,itour};
        [m,n] = size(animals_total);
        sess_differences = zeros(1,m);
        for i = 1:m
            question_animals = animals_total(i,:);
            sess_differences(i) = diff_matrix_current(question_animals(1),question_animals(2));
        end
        
        %convert differences to weights
        sess_weights = 1 - (sess_differences * slope + intercept);
        
        %calculate weighted percentage
        optimal_sess_i = b.response{isess,itour} - stimlist.optima{isess,itour};
        ncorrect_optimal = 0;
        for i = 1:length(optimal_sess_i)
            if isnan(optimal_sess_i(i))
                optimal_sess_i(i) = 0;
            elseif optimal_sess_i(i) == -1
                optimal_sess_i(i) = 1;
            elseif optimal_sess_i(i) == 0
                ncorrect_optimal = ncorrect_optimal + 1;
            end
        end
        weighted_values = optimal_sess_i .* sess_weights;
        weighted_percentage = (ncorrect_optimal + sum(weighted_values))/length(weighted_values);
        weighted_percent_optimal = 100 * weighted_percentage;
        
        current_tour_feedback = weighted_percent_optimal;
        
end