%> @file buildNonCollapsingDistanceMatrix.m
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
%>	Calculate the projected distance matrix.
% ======================================================================
function distances = buildNonCollapsingDistanceMatrix(samples, targets)


% calculate the distance
Xt = permute(samples, [1 3 2]);
Yt = permute(targets, [3 1 2]);
%distances = sqrt(sum(abs( Xt(:,ones(1,size(targets,1)),:) - Yt(ones(1,size(samples,1)),:,:) ).^2, 3))
distances = min(abs( Xt(:,ones(1,size(targets,1)),:) - Yt(ones(1,size(samples,1)),:,:) ), [], 3);
