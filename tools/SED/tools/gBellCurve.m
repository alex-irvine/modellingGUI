%> @file gBellCurve.m
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
%>	A generalized bell curve function
% ======================================================================
function y = gBellCurve( x, a, b, c )


if ~(exist('a', 'var') && exist('b', 'var') && exist('c', 'var'))
	a = 0.19921;
	b = 2.08;
	c = 6.94e-18;
end

tmp = ((x - c)./a).^2;
if (tmp == 0 & b == 0)
    y = 0.5;
elseif (tmp == 0 & b < 0)
    y = 0;
else
    tmp = tmp.^b;
    y = 1./(1 + tmp);
end
