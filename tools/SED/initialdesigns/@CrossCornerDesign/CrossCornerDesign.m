%> @file FactorialDesign.m
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
%> @brief Cross Corner design - just generate 2 points at [-1,...-1] and [1,...,1]
% ======================================================================
classdef CrossCornerDesign < InitialDesign

  properties
	  inDim;
  end

  methods
    % ======================================================================
    %> @brief Class constructor
    %> @return instance of the class
    % ======================================================================
    function this = CrossCornerDesign(varargin)

        if(nargin == 1)
            config = varargin{1};
            superArgs{1} = config;
			inDim = config.input.getInputDimension();
        elseif(nargin == 2)
            inDim = varargin{1};
            superArgs{1} = inDim;
            superArgs{2} = 1;
        else
            error('Invalid number of arguments');
        end

        % construct the base class
        this = this@InitialDesign(superArgs{:});
		this.inDim = inDim;
    end

    % ======================================================================
    %> @brief Generate 2 opposing corner points
    % ======================================================================
	function [initialsamples, evaluatedsamples] = generate(this)
		initialsamples = [-ones(1,this.inDim) ; ones(1,this.inDim)];
		evaluatedsamples = zeros(0,this.inDim);
	end
  end

end
