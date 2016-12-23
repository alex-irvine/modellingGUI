%> @file RandomZoomCandidateGenerator.m
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
classdef RandomZoomCandidateGenerator < CandidateGenerator


	
	properties
		candidatesPerSample;
		inputWeights;
	end
	
	methods
		
		function this = RandomZoomCandidateGenerator(config)
			this = this@CandidateGenerator(config);
			this.candidatesPerSample = config.self.getIntOption('candidatesPerSample', 100);

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

			% input dimension
			inDim = size(samples,2);

			% generate random set of points
			candidates = bsxfun(@times, rand(nSamples*this.candidatesPerSample, size(samples,2)) .* 2 - 1, this.inputWeights);

			% only when there are samples
			if size(samples,1) > 0
				
			% take the best 3 maximin samples, and generate additional samples nearby
				distances = buildMinimumDistanceMatrix(candidates, samples, false);
				[dummy, bestCandidates] = sort(distances, 'descend');

				nPoints = 1000 * inDim;
				for i = 1 : 3

					% generate candidates around this candidate
					candidate = candidates(bestCandidates(i), :);

					% distance
					distance = sqrt(distances(bestCandidates(i)));

					% points
					points = rand(nPoints, inDim);

					% scale to distance
					points = points / distance - (distance / 2);

					% translate
					points = bsxfun(@plus, candidate, points);

					% filter out if range out
					points(any(abs(points) > 1,2),:) = [];

					% translate to candidate
					candidates = [candidates ; points];

				end
			end
			
			% transform all candidates back to [-1,1]
			candidates = bsxfun(@rdivide, candidates, this.inputWeights);
			
			% plot all candidates
			%{
			plot(candidates(:,1), candidates(:,2), 'or');
			hold on;
			plot(state.samples(:,1), state.samples(:,2), 'ob');
			%}
		end
	end
end
