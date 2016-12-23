%> @file EmptySampleSelector.m
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
%>	This sample selector always return an empty selection. Use this sample selector
%>	if you want to have an output which isn't used to select new samples.
% ======================================================================
classdef EmptySampleSelector < SampleSelector


    
    properties (Access = private)
        dimension = [];
    end
    
    methods (Access = public)
        
        % CTor
        function this = EmptySampleSelector(config)
            this.dimension = config.input.getInputDimension();
        end
        
        % selectSamples (SUMO)
        % Description:
        %     Simply don't select any samples, return empty array
        function [this, newSamples, priorities] = selectSamples( this, state );
            newSamples = zeros(0, this.dimension);
            priorities = zeros(0, this.dimension);
        end
    end
    
end
