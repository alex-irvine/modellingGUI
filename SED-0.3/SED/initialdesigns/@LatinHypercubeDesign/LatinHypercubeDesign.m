%> @file LatinHypercubeDesign.m
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
%> @brief Choose an initial sampleset in such a way that they form a latin
%>	hypercube
%>
%>	Arguments: LatinHypercubeDesign(config object) or LatinHypercubeDesign(dimension, npoints)
% ======================================================================
classdef LatinHypercubeDesign < InitialDesign

  properties
    prefabDir = 'src/matlab/contrib/prefab_designs/';
    points;
    prefab;
	prefabInternet;
	statisticsToolbox;
    p;
    weight;
    initialTemperature;
    coolingFactor;
    maxtime;
    logger;
  end

  methods
    % ======================================================================
    %> @brief Class constructor
    %> @return instance of the class
    % ======================================================================
    function this = LatinHypercubeDesign(varargin)
        import java.util.logging.*;

        % we first have to ensure we can construct the base class
        if(nargin == 1)
            config = varargin{1};
            superArgs{1} = config;
        elseif(nargin == 2)
            inDim = varargin{1};
            points = varargin{2};
            superArgs{1} = inDim;
            superArgs{2} = 1;
        else
            error('Invalid number of parameters given');
        end

        % construct the base class
        this = this@InitialDesign(superArgs{:});

        this.logger = Logger.getLogger( 'Matlab.LatinHypercubeDesign' );

        % only now can we start using the object
        [inDim outDim] = this.getDimensions();

        if(nargin == 1)
            config = varargin{1};

            this.points = config.self.getIntOption('points',10*inDim+1);
            this.p = config.self.getDoubleOption('p',5.0);
            this.weight = config.self.getDoubleOption('weight',0.5); % 0 is maximin, 1 is correlation
            this.initialTemperature = config.self.getIntOption('temperature', 1000 );
            this.coolingFactor = config.self.getDoubleOption('coolingFactor',0.9);
            this.maxtime = config.self.getIntOption('maxtime',10);
            this.prefabInternet = config.self.getBooleanOption('prefabInternet', true);
            this.prefabDir = char(config.self.getOption('prefabDir', this.prefabDir));
            this.prefab = config.self.getBooleanOption('prefab',true);
            this.statisticsToolbox = config.self.getBooleanOption('statisticsToolbox', false);
        elseif(nargin == 2)
            this.points = varargin{2};
            this.p = 5.0;
            this.weight = 0.5; % 0 is maximin, 1 is correlation
            this.initialTemperature = 1000;
            this.coolingFactor = 0.9;
            this.maxtime = 10;
            this.prefabInternet = true;
            this.prefab = true;
        else
            error('Invalid number of parameters given');
        end
    end

    % ======================================================================
    %> @brief Choose an initial sampleset in such a way that they form a latin
    %> hypercube
    % ======================================================================
    [initialsamples, evaluatedsamples] = generate(this);

  end
end
