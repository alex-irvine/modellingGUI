%> @file setDimensions.m
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
%> Includes some input checking to ensure that the bounds and the initial population are still correct.
%> If not, these variables are reset to their default values without warning!
% ======================================================================
function this = setDimensions(this,inDim,outDim)
    this.nvars = inDim;
    this.nobjectives = outDim;

    % update bounds/initpoint
    if(length(this.LB) ~= this.nvars)
        this.LB = -ones( 1, this.nvars );
    end

    if(length(this.UB) ~= this.nvars)
        this.UB = ones( 1, this.nvars );
    end

    if(size(this.initialPopulation,2) ~= this.nvars)
        this.initialPopulation = zeros( this.getPopulationSize(), this.nvars );
    end
end