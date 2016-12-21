%> @file ClosenessThreshold.m
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
%>	Selects a set of new samples from the candidates by selecting the
%>	best scoring n candidates, but avoiding samples that lie too close
%>	to each other. Also generates a set of random samples to ensure
%>	proper domain coverage.
% ======================================================================
classdef ClosenessThreshold < MergeCriterion


	properties
		dim_in = [];
		closenessThreshold = [];
		randomPercentage = [];
        
        includeSamples = [];
		logger = [];
	end
	
	
	methods (Access = public)
		
		function this = ClosenessThreshold(config)
			import java.util.logging.*
			this.dim_in = config.input.getInputDimension();
			
			% get the closeness threshold
			this.closenessThreshold = config.self.getDoubleOption('closenessThreshold', 0.05); % density factor
			
			% the closeness threshold explains what part of a 1D domain
			% should be "occupied" by one sample, in terms of the size of
			% an interval. This generalizes to a (hyper)cube in higher
			% dimensions, but since the percentage of a cube with this
			% length becomes smaller relative to the total volume, the
			% value has to be scaled relative to the input dimension.
			this.closenessThreshold = this.closenessThreshold ^ (1 / this.dim_in);
			
			this.randomPercentage = config.self.getDoubleOption('randomPercentage', 0);
            
            this.includeSamples = config.self.getBooleanOption('includeSamples', false);
			this.logger = Logger.getLogger('Matlab.ClosenessThreshold');
		end
		
		
		function [this, newsamples, priorities] = selectSamples(this, candidatesamples, scores, state)
			
			% first get the average of all the scores
            scores = sum(scores,2) ./ size(scores,2);
			
			% get the grid points with the highest score (higher = better...)
			[dummy, topScores] = sort(scores, 'descend');

			% select top locations, but filter out samples close to each other
			scoreIndex = 1;
            
			% select a number of random samples first
			nRandomSamples = floor(state.numNewSamples * this.randomPercentage / 100);
			
			% first add the random samples
			newsamples = rand(nRandomSamples,this.dim_in) * 2 - 1;
			priorities = zeros(nRandomSamples, 1);
			
			% now add the selected samples
			sampleCounter = nRandomSamples + 1;
			while (sampleCounter <= state.numNewSamples) && (scoreIndex <= length(topScores))

				% get index of highest scoring sample point
				index = topScores(scoreIndex);
				
				% compare next sample against all previously selected
				% samples for closeness
				% this is not the euclidean distance, but the distance in
				% each dimension separately (corresponds to being in a cube
				% with size closenessThreshold
				minDistance = min(max(abs(bsxfun(@minus, newsamples, candidatesamples(index,:))), [], 2));
				%minDistance = min(buildDistanceMatrix(newsamples,
				%candidatesamples(index,:), false));
				
                if this.includeSamples
                    minDistanceSamples = min(max(abs(bsxfun(@minus, state.samples, candidatesamples(index,:))), [], 2));
                    minDistance = min( minDistance, minDistanceSamples );
                end
                
				% far enough - add!
				if sampleCounter == 1 || minDistance > this.closenessThreshold
					%s.logger.fine(sprintf('Added point %s with distance %d, which was d th on the list, to the list, %d left to select...', arr2str(points(index, 1:end)), distance, scoreIndex, (samplesLeft-1)))
					newsamples(sampleCounter,:) = candidatesamples(index,:);
                    priorities(sampleCounter) = scores(index,:);
					sampleCounter = sampleCounter + 1;
				end

				% go to next point sorted by score
				scoreIndex = scoreIndex + 1;
            end
        end
    end
end
