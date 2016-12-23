%> @file kushner.m
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
classdef kushner < CandidateRanker


	
	properties
		epsilon = 0.1; % percent of fmin
	end
	
	methods (Access = public)
		
		function this = kushner(varargin)
            this = this@CandidateRanker(varargin{:});

			if nargin == 1
				config = varargin{1};
                this.epsilon = config.self.getDoubleOption('epsilon', 0.1);
            elseif nargin >= 3
                this.epsilon = varargin{3};
            end
		end

		function out = scoreCandidates(this, points, state)

			% kushner (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			% Revision: $Rev: 6806 $
			%
			% Description:
			%     Calculates the kushner criterion.
			%     Let y be the predicted value (the surrogate), mse the mean square
			%     root and fmin the minimum of the evaluated samples. Then:

			model = state.lastModels{1}{1};

			[y mse] = evaluateInModelSpace( model, points );

			var = abs( mse );
			fmin = min( model.values );

			b = this.epsilon * fmin; % 0.1% of fmin

			if var == 0
				out = zeros( size(points,1), 1 );
			else
				out = normcdfWrapper( ((fmin-b) - y) ./ var );
			end
		end
		
	end
	
end
