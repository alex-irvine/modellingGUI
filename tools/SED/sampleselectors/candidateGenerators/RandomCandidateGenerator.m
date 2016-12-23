%> @file RandomCandidateGenerator.m
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
%> TODO
% ======================================================================
classdef RandomCandidateGenerator < CandidateGenerator


	
	properties
		candidatesPerSample;
		nCandidates;
		inputWeights;
	end
	
	methods
		
		function this = RandomCandidateGenerator(config)
			this = this@CandidateGenerator(config);
			this.candidatesPerSample = config.self.getIntOption('candidatesPerSample', 100);
			this.nCandidates = config.self.getDoubleOption('nCandidates', +Inf);
		
			% get the weights
			this.inputWeights = zeros(1, config.input.getInputDimension());
			for i = 0 : config.input.getInputDimension() - 1
				this.inputWeights(i+1) = config.input.getInputDescription(i).getWeight();
			end
		end
		
		function [this, state, candidates] = generateCandidates(this, state)

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
		%	Generate a set of random candidate points, based on the number of
		%	samples.
		
			% first transform the samples to the weighted space
			samples = bsxfun(@times, state.samples, this.inputWeights);
			
			% get # samples
			nSamples = size(samples,1);
			if nSamples == 0
				nSamples = 1;
			end
			
			% get the number of candidates
			nCandidates = nSamples*this.candidatesPerSample;
			
			% set the number returned - never larger than max memory allowed
			nReturned = this.nCandidates;
			if nReturned > nCandidates
				nReturned = nCandidates;
			end
			
			% larger than max memory allowed - split up
			inDim = size(samples,2);
			
			n = nCandidates;

			% generate random set of points
			candidates = bsxfun(@times, rand(n, inDim) .* 2 - 1, this.inputWeights);

			% only if we need to filter candidates
			if nCandidates ~= nReturned
			
				% calculate the distance matrix
				distances = buildMinimumDistanceMatrix(candidates, samples, true);

				% return the best ones
				[dummy, indices] = sort(distances, 'descend');

				% return the best ones
				candidates = candidates(indices(1:nReturned), :);
				bestDistances = distances(indices(1:nReturned), :);
				state.maximinDistance = bestDistances;
			end
			
			% set everything
			candidates = bsxfun(@rdivide, candidates, this.inputWeights);
			
			
		end
	end
end
