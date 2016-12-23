%> @file mergeStruct.m
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
%> @brief Copies field of s2 over to s1
%>
%> @param s1 destination structure
%> @param s2 source structure
%> @param destFieldExist 
%> - -1: always copy
%> - false: only copy when destination field does NOT exist
%> - true: only copy when destination field exist
% ======================================================================
function o = mergeStruct( s1, s2, destFieldExist )

% destFieldExist can be:
% -1: always copy
% false: only copy when destination field does NOT exist
% true: only copy when destination field exist
if ~exist( 'destFieldExist', 'var' )
	destFieldExist = true;
end

fn = fieldnames(s2);
o = s1;

for n = 1:length(fn)
	
	% Always copy the field over, if it exists or not in s1
	if destFieldExist == -1
	    o.(fn{n}) = s2.(fn{n});
	else % copy the field depending on the type
		if isfield(o, fn{n} ) == destFieldExist
			o.(fn{n}) = s2.(fn{n});
		end
	end
end
