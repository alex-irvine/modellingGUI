%> @file cfix.m
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
%>	This function ``fixes'' a cell array. Either a constant,
%>	a one element cell array or a length `d' cell array can be
%>	passed to this function. The function will return a length
%>	`d' cell array, duplicating the input if necessary
% ======================================================================
function y = cfix( x,d,err )


if length(x) ~= 1 && ( ~iscell( x ) || length(x) ~= d )
	if nargin == 3
		error( err );
	else
		error( sprintf( '[E] Either single value or list of length %d expected', d ) );
	end
end

if length(x) == 1
	if iscell(x)
		x = x{1};
	end
	y = cell(1,d);
	for i=1:d
		y{i} = x;
	end
else
	y = x;
end
