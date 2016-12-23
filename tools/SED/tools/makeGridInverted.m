%> @file makeGridInverted.m
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
%>	Construct a matrix of size ``prod(sizes) by length(sizes)''
%>	where the rows represent all gridpoints on a ``sizes''
%>	sized grid.
%>
%>	Example:
%>	>> makeGrid( [3 1 2 2] )
%>	ans =
%>	  1     1     1     1
%>	  2     1     1     1
%>	  3     1     1     1
%>	  1     1     2     1
%>	  2     1     2     1
%>	  3     1     2     1
%>	  1     1     1     2
%>	  2     1     1     2
%>	  3     1     1     2
%>	  1     1     2     2
%>	  2     1     2     2
%>	  3     1     2     2
% ======================================================================
function g = makeGridInverted( sizes )


if length(sizes) == 1
	g = (1:sizes(1))';
else
	tmp = repmat((1:sizes(end)), prod( sizes(1:end-1) ),1 );
	g = [ repmat( makeGridInverted( sizes(1:end-1) ), sizes(end), 1 ) tmp(:) ];
end
