%> @file ProjectedDistanceThreshold.m
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
%> A criterion that ranks all points according to their projected distance
%> score. If the projected distance is below a particular threshold, a huge
%> penalty score is given so that these points are never picked.
% ======================================================================
classdef ProjectedDistanceThreshold < CandidateRanker


	properties
		alpha = 0.5;
		minDistance = 0;
	end
	
	methods (Access = public)
		
		function this = ProjectedDistanceThreshold(varargin)
			this = this@CandidateRanker(varargin{:});
			if nargin == 0
				return;
			end
			config = varargin{1};
			this.alpha = config.self.getDoubleOption('alpha', 0.5);
			this.minDistance = config.self.getDoubleOption('minDistance', 0);
		end
		
		
		function ranking = scoreCandidates(this, points, state)
			% Description:
			%	Calculate the non-collapsing factor of the candidates.
			%	From: Chen (2009)
			
			% samples
			samples = state.samples;
			
			% first transform the samples to the weighted space
			%samples = bsxfun(@times, samples, this.inputWeights);
			
			% get dimension/n samples
			inDim = size(samples,2);
			nSamples = size(samples, 1);
			
			% calculate min distance from each other point - based on the
			% alpha value
			dMin = max(2 ./ size(samples, 1) .* this.alpha, this.minDistance);
			
			% by default, no penalty
			ranking = zeros(size(points,1),1);
			
			% calculate the non collapsing distance matrix
			minDistances = buildMinimumNonCollapsingDistanceMatrix(points, samples);
			ranking(minDistances < dMin) = -10^3 + minDistances(minDistances < dMin);
			minMaximinDistances = buildMinimumDistanceMatrix(points(minDistances >= dMin,:), samples, false);
			ranking(minDistances >= dMin) = minMaximinDistances;
			
			return;
			% calculate for each point the non collapsing distance matrix
			% for each dimension separately
			for i = 1 : inDim
				
				% take only one dimension
				filteredSamples = samples(:,i);
				filteredPoints = points(:,i);
				
				% calculate the non collapsing distance matrix
				minDistances = buildMinimumNonCollapsingDistanceMatrix(filteredPoints, filteredSamples);
				
				% penalize all points that lie too close
				% make sure that more severe penalties from previous
				% dimensions are not overwritten by this dimension
				%ranking(minDistances < dMin) = min(ranking(minDistances < dMin), -dMin + minDistances(minDistances < dMin));
				ranking(minDistances < dMin(i)) = min(ranking(minDistances < dMin(i)), -10^3 + minDistances(minDistances < dMin(i)));
				
			end
		end
		
	end
	
end
