%> @file dimensionDistance.m
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
classdef dimensionDistance < CandidateRanker


	properties
		dimension = 0;
		scaleToZeroOne = false;
		transformationFunction = @(x)(x);
		inputWeights;
	end
	
	methods (Access = public)
		
		function this = dimensionDistance(varargin)
			this = this@CandidateRanker(varargin{:});
			if nargin == 0
				return;
			end
			config = varargin{1};
			this.dimension = config.self.getIntAttrValue('dimension', '0');
			this.transformationFunction = str2func(char(config.self.getAttrValue('transformationFunction', '@(x)(x)')));
			this.scaleToZeroOne = config.self.getBooleanOption('scaleToZeroOne', false);
			
			% get the weights
			this.inputWeights = zeros(1, config.input.getInputDimension());
			for i = 0 : config.input.getInputDimension() - 1
				this.inputWeights(i+1) = config.input.getInputDescription(i).getWeight();
			end
			
		end
		
		
		function ranking = scoreCandidates(this, points, state)
			% Description:
			%	Calculate the non-collapsing factor of the candidates.
			
			% no samples - just generate random results
			if size(state.samples,1) == 0
				ranking = rand(size(points,1),1);
				return;
			end
			
			% samples
			samples = state.samples;
			
			% dimension specified - only return for exactly one dimension
			if this.dimension ~= 0
				samples = samples(:,this.dimension);
				points = points(:,this.dimension);
			end
			
			% transform to weighted space
			points = bsxfun(@times, points, this.inputWeights);
			samples = bsxfun(@times, samples, this.inputWeights);
			
            % calculate the distance matrix
            ranking = buildMinimumNonCollapsingDistanceMatrix(points, samples);
			
			
			% too close - return big penalty so that this point is never chosen
			%ranking(ranking < eps) = -Inf;
			%ranking(ranking > eps) = 0;
			
			% scale to [0,1] if asked
			if this.scaleToZeroOne
				maxDimensionDistace = min(this.inputWeights) * 2 / (size(state.samples,1)+1);
				ranking = ranking ./ maxDimensionDistace;
			end
			
			% use transformation function
			ranking = this.transformationFunction(ranking);
			
		end
		
	end
	
end
