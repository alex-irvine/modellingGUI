%> @file calculateTransformationFunctions.m
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
%> @brief Calculate input transformation functions from transformation values
%> @retval inFunc simulator -> model space
%> @retval outFunc model -> simulator space
% ======================================================================
function [inFunc, outFunc] = calculateTransformationFunctions(transf)

translate = transf(1,:);
scale = transf(2,:);

% model space -> simulator space
outFunc = @(y)(y .* scale(ones(size(y,1),1),:) + translate(ones(size(y,1),1),:)); % transform 'normal' inputs to simulator space

% simulator space -> model space
inFunc = @(x)((x - translate(ones(size(x,1),1),:)) ./ scale(ones(size(x,1),1),:));

end
