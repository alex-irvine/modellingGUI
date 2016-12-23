%> @file RandomDesign.m
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
%> @brief Choose samples randomly
% ======================================================================
classdef RandomDesign < InitialDesign

  properties
    points;
  end

  methods
    % ======================================================================
    %> @brief Class constructor
    %> @return instance of the class
    % ======================================================================
    function this = RandomDesign(varargin)

        if(nargin == 1)
            config = varargin{1};
            points = config.self.getIntOption('points',50);
            superArgs{1} = config;
        elseif(nargin == 2)
            inDim = varargin{1};
            points = varargin{2};
            superArgs{1} = inDim;
            superArgs{2} = 1;
        else
            error('Invalid number of arguments');
        end

        % construct the base class
        this = this@InitialDesign(superArgs{:});
        this.points = points;
	end
	
	% ======================================================================
    %> @brief Randomly choose an initial sample set using an uniform distribution
    % ======================================================================
    function [initialsamples, evaluatedsamples] = generate(this)
      [inDim outDim] = getDimensions(this);

      % randomly generate a set of points
      initialsamples = rand(this.points, inDim);

      % transform from 0->1 to -1->1
      initialsamples = initialsamples * 2 - 1;

      evaluatedsamples = [];
    end

  end
end
