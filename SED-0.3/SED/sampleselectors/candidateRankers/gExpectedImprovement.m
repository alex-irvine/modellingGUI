%> @file gExpectedImprovement.m
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
classdef gExpectedImprovement < CandidateRanker


	
	properties
		g = 1;
	end
	
	methods (Access = public)
		
		function this = gExpectedImprovement(varargin)
            this = this@CandidateRanker(varargin{:});

			if nargin == 1
				config = varargin{1};
                this.g = config.self.getDoubleOption('g', 1);
            elseif nargin >= 3
                this.g = varargin{3};
            end
		end

		function ei = scoreCandidates(this, points, state)

		% gExpectedImprovement (SUMO)
		%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
		%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
		%     Copyright: IBBT - IBCN - UGent
		% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
		% Revision: $Rev: 6806 $
		%
		% Description:
		%     Calculates the Generalized Expected Improvement

		model = state.lastModels{1}{1};

		[y mse] = evaluateInModelSpace( model, points );

		var = sqrt( abs( mse ) );
		fmin = min( getValues(model) );

		% FIXME: what about vectorization ?
		if var == 0
			ei = zeros( size(points,1), 1 );
		else
			z  = (fmin-y)./var;

			T = normcdfWrapper(z); % actually T(0)
			T = [T, -normpdfWrapper(z)]; % ... T(1)

			ei = (z .^this.g) .* T(:,1);
			for k=1:this.g
				gk = this.g-k;
				ei = ei + ( (-1).^k .* z.^gk .* T(:,k+1) .* (factorial(this.g) ./ (factorial(k) .* factorial(gk))) );

				T = [T, (-normpdfWrapper(z) .* z.^k + k .* T(:,k))]; % next T(l) = ... .* T(l-2)
			end

			ei = var.^this.g .* ei;
		end
		end
		
	end
	
end
