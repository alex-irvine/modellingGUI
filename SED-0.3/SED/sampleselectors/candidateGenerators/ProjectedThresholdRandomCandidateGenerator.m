classdef ProjectedThresholdRandomCandidateGenerator < CandidateGenerator

% NonCollapsingGridCandidateGenerator (SUMO)
%
%     This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%     and you can redistribute it and/or modify it under the terms of the
%     GNU Affero General Public License version 3 as published by the
%     Free Software Foundation.  With the additional provision that a commercial
%     license must be purchased if the SUMO Toolbox is used, modified, or extended
%     in a commercial setting. For details see the included LICENSE.txt file.
%     When referring to the SUMO-Toolbox please make reference to the corresponding
%     publication.
%
% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
% Revision: $Rev$
%
% Signature:
%	NonCollapsingGridCandidateGenerator(config)
%
% Description:

	
	properties
		candidatesPerSample;
		alpha;
		minDistance;
		inputWeights;
	end
	
	methods
		
		function s = ProjectedThresholdRandomCandidateGenerator(config)
			
			% config this object
			s = s@CandidateGenerator(config);
			s.alpha = config.self.getDoubleOption('alpha', 0.5);
			s.minDistance = config.self.getDoubleOption('minDistance', Inf);
			s.candidatesPerSample = config.self.getIntOption('candidatesPerSample', 100);
			
			% get the weights
			s.inputWeights = zeros(1, config.input.getInputDimension());
			for i = 0 : config.input.getInputDimension() - 1
				s.inputWeights(i+1) = config.input.getInputDescription(i).getWeight();
			end
			
		end
		
		function [s, state, candidates] = generateCandidates(s, state)

		% RandomCandidateGenerator (SUMO)
		%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
		%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
		%     Copyright: IBBT - IBCN - UGent
		% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
		% Revision: $Rev$
		%
		% Signature:
		%	[state, candidates] = RandomCandidateGenerator(state)
		%
		% Description:
		%	Generate candidates on the optimal non-collapsing grid.
		
			% first transform the samples to the weighted space
			samples = bsxfun(@times, state.samples, s.inputWeights);
			
			% compute the grid points in all dimensions
			% this is the average between two consecutive values - so the
			% middle between all the intervals defined by the points
			sortedSamples = sort(samples, 1);
			intervals = (sortedSamples(2:end,:) - sortedSamples(1:end-1,:));
			
			% calculate the minimum size of an interval
			% this is defined as dmin, the minimum allowed distance of new
			% candidates from the dataset
			dMin = min(((s.inputWeights .* 2) ./ size(samples, 1)) .* s.alpha, s.minDistance);
			
			% make intervals smaller
			intervals = bsxfun(@minus, intervals, 2*dMin);
			
			% filter out all empty intervals
			largeEnough = intervals > 0;
			
			% number of candidates to generate
			nCandidates = size(state.samples,1) * s.candidatesPerSample;
			
			% now generate random points in every dimension
			inDim = size(state.samples,2);
			candidates = zeros(nCandidates, inDim);
			for i = 1 : inDim
				
				% get the filtered intervals
				fIntervals = intervals(largeEnough(:,i), i);
				startPoints = sortedSamples(largeEnough(:,i), i);
				
				% compute the total viable domain
				range = sum(fIntervals);
				
				% generate random numbers in the given range
				numbers = rand(nCandidates,1) * range;
				
				% map the numbers to the appropriate intervals
				total = 0.0;
				for j = 1 : length(fIntervals)
					indices = (numbers >= total) & (numbers < total + fIntervals(j));
					candidates(indices,i) = numbers(indices) - total + startPoints(j) + dMin(i);
					total = total + fIntervals(j);
				end
			end
			
			% re-transform back to [-1,1]
			candidates = bsxfun(@rdivide, candidates, s.inputWeights);
		end
	end
end
