%> @file scaleColumns.m
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
%>	Scale all columns of X to [c,d], defaults to [-1,1]
%>	If mn and mx are given they are used as the original range of each column of x
% ======================================================================
function res = scaleColumns(x,c,d,mn,mx)


if(~exist('c','var') || ~exist('d','var'))
	c = -1;
	d = 1;
end

n = size(x,1);

if(~exist('mn','var') || ~exist('mx','var'))
	mn = min(x);
	mx = max(x);
else
	mn = repmat(mn,1,size(x,2));
	mx = repmat(mx,1,size(x,2));
end

res = (x - repmat( mn,n,1 )) ./ repmat(mx-mn,n,1) * (d-c) + c;
