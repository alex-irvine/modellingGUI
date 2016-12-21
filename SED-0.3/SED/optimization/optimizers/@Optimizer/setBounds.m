%> @file setBounds.m
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
%> Only needed for optimization methods that support it.
% ======================================================================
function this = setBounds(this, LB, UB)

    if(this.getInputDimension() ~= length(LB))
      error(sprintf('The size of the lower bounds (%d) does not match the expected size of the input dimension (%d)',length(LB),this.getInputDimension()));
    end
    if(this.getInputDimension() ~= length(UB))
      error(sprintf('The size of the upper bounds (%d) does not match the expected size of the input dimension  (%d)',length(UB),this.getInputDimension()));
    end

    this.LB = LB;
    this.UB = UB;
end