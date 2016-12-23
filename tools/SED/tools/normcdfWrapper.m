%> @file normcdfWrapper.m
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
%> @brief normcdf wrapper
%>
%> If the Statistics toolbox is not available a custom implementation
%> will be used. When override is given (value doesn't matter) it will
%> always use the own implementation
% ======================================================================
function p = normcdfWrapper( x, mu, sigma, override )

	if nargin < 2
		mu = 0;
	end
	if nargin < 3
		sigma = 1;
	end
		
	if checkLicense('Statistics Toolbox') && (nargin < 4)
	  p = normcdf( x, mu, sigma );
	else
	  p = 0.5.*(1+erf( (x-mu)./(sigma.*sqrt(2)) ) );
	end

end
