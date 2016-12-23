%> @file BoxBehnkenDesign.m
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
%> @brief Choose an initial sampleset according to a Box-Behnken design
%>
%> Note: relies on the matlab bbdesign command, so the Matlab statistics toolbox is required
% ======================================================================
classdef BoxBehnkenDesign < InitialDesign

  properties
  end

  methods
    % ======================================================================
    %> @brief Class constructor
    %> @return instance of the class
    % ======================================================================
    function this = BoxBehnkenDesign(config)
        % construct the base class
        this = this@InitialDesign(config);

        if(~exist('bbdesign'))
            error('To use Box-Behnken Design, you must have the Statistics toolbox installed')
        end

        [in out] = this.getDimensions();

        if(in < 3)
            error('To use a Box-Behnken design, the design dimension must be greater than 2');
        end
    end
    
    % ======================================================================
    %> @brief Choose an initial sample set based on the Box-Behnken design
    %>
    %> See "help bbdesign" for more information
    % ======================================================================
    function [initialsamples, evaluatedsamples] = generate(this)
        [in out] = this.getDimensions();
        initialsamples = bbdesign(in);

        % scale to -1 1
        initialsamples = scaleColumns(initialsamples);

        evaluatedsamples = [];
    end

  end
end
