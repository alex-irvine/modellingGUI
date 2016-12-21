%> @file SeparateCriteria.m
%> @authors: SUMO Lab Team
%> @version 7.0.2 (Revision: 6486)
%> @date 2006-2010
%>
%> This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%> and you can redistribute it and/or modify it under the terms of the
%> GNU Affero General Public License version 3 as published by the
%> Free Software Foundation.  With the additional provision that a commercial
%> license must be purchased if the SUMO Toolbox is used, modified, or extended
%> in a commercial setting. For details see the included LICENSE.txt file.
%> When referring to the SUMO Toolbox please make reference to the corresponding
%> publication:
%>   - A Surrogate Modeling and Adaptive Sampling Toolbox for Computer Based Design
%>   D. Gorissen, K. Crombecq, I. Couckuyt, T. Dhaene, P. Demeester,
%>   Journal of Machine Learning Research,
%>   Vol. 11, pp. 2051-2055, July 2010. 
%>
%> Contact : sumo@sumo.intec.ugent.be - http://sumo.intec.ugent.be

% ======================================================================
%> @brief TODO
%>
%>	Merge criterion that select the top samples for each measure 
%>	independently (work in progress). Todo: emove weights, no point in 
%>  having them.
% ======================================================================
classdef SeparateCriteria < MergeCriterion


	
	properties
		weights;
		reject;
	end
	
	
	methods (Access = public)
		
		
		function [this] = SeparateCriteria(arg)
			if isnumeric(arg)
				this.weights = arg;
			else
				config = arg;
				this.weights = str2num(config.self.getAttrValue('weights', '[]'));
				this.reject = str2num(config.self.getAttrValue('reject', '[]'));
			end
		end
		
		function [this, newSamples, priorities] = selectSamples(this, candidates, scores, state)
			
		
			% if weights is empty, give each score the same weight
			if isempty(this.weights)
				this.weights = ones(1, size(scores,2));
			end
			
			% make sure it's a column vector
			if size(this.weights,1) ~= 1
				this.weights = this.weights';
			end
			
			% reject all points that violate the reject value
			if ~isempty(this.reject)
				indices = any(bsxfun(@le, scores, this.reject), 2);
				%room = (2 - 0.5 * 4 / size(state.samples,1)) / 2;
				%disp(sprintf('%d/%d = %d candidates discarded, average is %d...', sum(indices), size(candidates,1), sum(indices) / size(candidates,1), room));
				candidates(indices,:) = [];
				scores(indices,:) = [];
			end
			
 			% Ranking each scores independently and select best samples for
 			% each score
           
            rankingSort = zeros(size(scores));
            
            for k=1:size(scores,2)
                [~, temp] = sort(scores(:,k),1, 'descend');
                rankingSort(:,k) = temp;
            end            
     
            ranking = zeros(size(scores,2)*size(scores,1), 1);
            counter = 1;
            for k=1:size(scores, 1)
                for l=1:size(scores,2)
                    ranking(counter,1) = rankingSort(k,l);
                    counter = counter + 1;
                end
            end
            
            [~, rankingIndices] = unique(ranking, 'first');
            rankingIndices = sort(rankingIndices);
            ranking = ranking(rankingIndices(1:size(scores,1),1));
            
			% only get the n best ones
			nNew = min( state.numNewSamples, size( candidates, 1 ) );
			
			% we have rejected too many! throw an exception
			if nNew > length(ranking)
				error(sprintf('Too many candidates were rejected! Need to select %d points while only %d candidates are available.', nNew, length(ranking)));
			end
			
			% return the n best candidates
			ranking = ranking(1:nNew);
			newSamples = candidates(ranking,:);
			
            % return their priorities based on the weighted average score
            priorities = scores(ranking,:);
			
		end

		% returns weighted average
		function [priorities] = processScores( this, scores )
			priorities = sum(bsxfun(@times, scores, this.weights),2) ./ size(scores,2);
		end
	end
end
