%> @file makeMonotonic.m
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
%>	Remove elements from the vector x such that it is monotonically increasing or decreasing
% ======================================================================
function y = makeMonotonic( x, order, keepLength )


assert(size(x,2) == 1)

y = x(1);

j=1;

if(strcmp(order,'descending'))
	for i=2:length(x)
		if(x(i) <= y(j))
			y = [y ; x(i)];
			j = j + 1;
		else
			if(keepLength)
				y = [y ; y(j)];
				j = j + 1;
			end
		end
	end
else
	for i=2:length(x)
		if(x(i) >= y(j))
			y = [y ; x(i)];
			j = j + 1;
		else
			if(keepLength)
				y = [y ; y(j)];
				j = j + 1;
			end
		end
	end
end
