%> @file modelDifference.m
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
classdef modelDifference < CandidateRanker


	properties
		nrModels = 2;
	end
	
	methods (Access = public)
		
		function this = modelDifference(varargin)
            this = this@CandidateRanker(varargin{:});

			if nargin == 1
				config = varargin{1};
				this.nrModels = config.self.getIntOption('nrModels', 2);
            elseif nargin >= 3
                this.nrModels = varargin{3};
            end
		end
		
		
		function scores = scoreCandidates(this, points, state)

			% modelDifference (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			% Revision: $Rev: 6806 $
			%
			% Description:
			%   Calculates the difference between the last nLastModels models on the
			%   given points
			
			nLastModels = this.nrModels; % 2; % Number of models to use 
			
			% number of outputs
			nOutputs = length(state.lastModels);
			
			% Construct differences
			scores = zeros(size(points,1), nOutputs);
			for l=1:nOutputs
				
				% get best models
				nModels = min(nLastModels, length(state.lastModels{l}));
				models = state.lastModels{l}(1:nModels);
				
				% evaluate best model values
				bestModelValues = evaluateInModelSpace(models{1}, points );
				
				% compare against previously best models
				for k=2:nModels
					modelValues = evaluateInModelSpace(models{k}, points );
					scores(:, l) = scores(:, l) + rootMeanSquareError( bestModelValues', modelValues')';
				end
				
				% if there are not enough models for this output - generate random scores
				if nModels < 2
					scores(:,l) = rand(size(points,1), 1);
				end
            end
            
			% That's all folks
		end
		
	end
	
end
