%> @file LocalPatternSearch.m
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
%>	Optimizer which generates quasi-latin hypercubes through genetic
%>	algorithm optimization.
% ======================================================================
classdef LocalPatternSearch < Optimizer


% private members
	properties (SetAccess = 'private', GetAccess = 'private')
		inDim;
		deviation;
		cornerPointsLeft = 2;
	end
	
	methods
		% constructor
		% Description:
		%     Creates an LHD Optimizer
		function s = LocalPatternSearch(varargin)
			
			% call superclass
			s = s@Optimizer(varargin{:});
			
			% get input dimension
			s.inDim = s.getInputDimension();
			
			% get the fidelity
			config = varargin{1};
			s.deviation = config.self.getDoubleOption('deviation', 0.1);
			
			% unfortunately, this one does not support weights, because of
			% the problems with scaling maximin back to [-1,1], this is
			% highly problematic
			for i = 0 : config.input.getInputDimension() - 1
				if config.input.getInputDescription(i).hasWeight()
					error('Weights are not supported by this component!');
				end
			end
			
			% constraints are not supported
			c = Singleton('ConstraintManager');
			if c.hasConstraints()
				error('Constraints are not supported by this component!');
			end
			
		end
		
		
		function [c, ceq] = unitCircleConstraint(s, x)
			c = sqrt(sum(x.^2, 2)) - 1;
			ceq = [];
		end
		
	end
	
end
