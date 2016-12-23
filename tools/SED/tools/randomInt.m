%> @file randomInt.m
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
%>	   Generates a random integer between min and max (inclusive)
%>	Examples:
%>	> randomInt( 3, 5 )
%>	 4
%>	> randomInt( 3, 5, 3 )
%>	 [ 4 3 5 ]
% ======================================================================
function y = randomInt( varargin );


if(nargin == 1)
    tmp = varargin{1};
    mn = tmp(1);
    mx = tmp(2);
    n  = 1;
elseif(nargin == 2);
    mn = varargin{1};
    mx = varargin{2};
    n  = 1;
elseif(nargin == 3);
    mn = varargin{1};
    mx = varargin{2};
    n  = varargin{3};;
else
    error('Invalid number of arguments, must be "min,max" or "[min max]"');
end

assert( isInteger(mn) & isInteger(mx), 'Bounds should be integers' );

if(mx == mn)
  y = ones(n,1)*mx;
  return;
end

% W: Please leave the -eps there
range = mx-mn+1-eps;

y = floor( mn + rand(n,1) * range );
