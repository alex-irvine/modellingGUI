%> @file lcb.m
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
classdef lcb < CandidateRanker


	
	properties
		lowerBound = [];
	end
	
	methods (Access = public)
		
		function this = lcb(varargin)
			this = this@CandidateRanker(varargin{:});

			if nargin == 1
				config = varargin{1};
				this.lowerBound = str2num(char(config.self.getOption('lowerBound', '[]')));
            elseif nargin >= 3
                this.lowerBound = varargin{3};
			end
		end

		function out = scoreCandidates(this, points, state)

			% lcb (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			% Revision: $Rev: 6806 $
			%
			% Description:
			%     Calculates the lower confidence bound

			model = state.lastModels{1}{1};
			b = this.lowerBound;

			[y v] = evaluateInModelSpace( model, points );

			dev = sqrt( abs( v ) );
			out = y - b .* dev;
		end
		
	end
	
end
