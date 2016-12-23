%> @file calculateDistortedDistance.m
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
%>	This function calculates the distance between two points in a distorted
%>	space in which points perpendicular to the gradient are treated as
%>	closer while points parallel to the gradient are treated as farther
%>	away.
%>	This approach penalizes points which do not seem to lay on the plane
%>	that is fitted through the entire neighbourhood of the other point.
% ======================================================================
function distance = calculateDistortedDistance(p1, p2, gradientError)


% calculate the distorted distance
distance = mag(p1-p2) * (1+ gradientError);
%distance = mag(p1-p2);

%distance = sqrt(mag(p1-p2)^2 + dot(p1-p2,gradient)^2);
