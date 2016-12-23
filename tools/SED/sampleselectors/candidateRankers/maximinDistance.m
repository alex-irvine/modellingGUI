%> @file maximinDistance.m
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
%>	Selects the candidates with the highest maximin distance to existing
%>	points.
% ======================================================================
classdef maximinDistance < CandidateRanker


	
	properties
		doSqrt = true;
		scaleToZeroOne = false;
		inputWeights;
	end
	
	methods (Access = public)
		
		function this = maximinDistance(varargin)
			this = this@CandidateRanker(varargin{:});
			
            if nargin == 1
                config = varargin{1};
                this.doSqrt = config.self.getBooleanAttrValue('sqrt', 'true');
                this.scaleToZeroOne = config.self.getBooleanOption('scaleToZeroOne', false);
           
				% get the weights
				this.inputWeights = zeros(1, config.input.getInputDimension());
				for i = 0 : config.input.getInputDimension() - 1
					this.inputWeights(i+1) = config.input.getInputDescription(i).getWeight();
				end
				
			elseif nargin >= 4
                this.doSqrt = varargin{3};
                this.scaleToZeroOne = varargin{4};
				
			else
				error('Invalid number of parameters (1 or 4).');
			end
		end

		function [ranking dranking] = scoreCandidates(this, points, state)
			
			% no samples - just generate random results
			if size(state.samples,1) == 0
				ranking = rand(size(points,1),1);
				if nargout > 1
					dranking = ranking;
				end
				return;
			end
			
			% transform to weighted space
			points = bsxfun(@times, points, this.inputWeights);
			samples = bsxfun(@times, state.samples, this.inputWeights);
			
            % calculate the minimum distance matrix
            [ranking, idx] = buildMinimumDistanceMatrix(points, samples, this.doSqrt);
			
            if nargout > 1
                repidx = ones(1,size(points,2));
                dranking = points - samples(idx,:);
                
                idx = ranking == 0;
                dranking(~idx,:) = dranking(~idx,:) ./ ranking(~idx,repidx);
                
                %dranking( isinf(dranking) | isnan(dranking) ) = 0;
            end
            
			% scale based on dimension & n samples, so that it lies between [0,1]
			if this.scaleToZeroOne
				pointsPerDim = (size(samples,1)+1) .^ (1/size(samples,2));
				maxMaximin = min(this.inputWeights) * 2.0 / (pointsPerDim - 1);
				ranking = ranking ./ maxMaximin;
                
                if nargout > 1
                    dranking = dranking .* maxMaximin;
                end
            end
            
			%disp (sprintf('Maximin distance for %s: %d', arr2str(points), ranking));
        end
        
	end
	
end
