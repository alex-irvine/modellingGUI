%> @file matchString.m
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
%>	Looks through the rows of the char array or cell array of strings
%>	strarray to find the string str. If it is not found, it will be added
%>	at the end of the array. The array and the matching row indices of
%>	str in that array are returned.
%>	Example:
%>	[list index] = matchString('world', {'hello','world'})
%>	list =
%>	     'hello'    'world'
%>	index =
%>	     2
%>
%>	[list index] = matchString('planet', {'hello','world'})
%>	list =
%>	     'hello'    'world'    'planet'
%>	index =
%>	     3
% ======================================================================
function [strarray index] = matchString(str, strarray)


index = strmatch(str, strarray, 'exact');
if isempty(index)
	% appending depends on array type
	if iscellstr(strarray)
		strarray{end+1} = str;
	else
		strarray = strvcat(strarray, str);
	end
	index = size(strarray,1);
end
