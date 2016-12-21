%> @file complexFix.m
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
%>	Convert a complex value to a real value according to returnType
%>	1 = real part; 2 = imaginary part; 3 = modulus; 4 = angle in ]-Pi,Pi]
%>	if the value isn't complex the real part is always returned
% ======================================================================
function y = complexFix(x,returnType)


	if ~exist( 'returnType', 'var' )
		returnType = 'abs';
	end
	
	if ~isreal(x)
		switch(returnType)
			case 'real'
				y = real(x);
			case 'imaginary'
				y = imag(x);
			case {'abs', 'modulus'}
				y = abs(x);
			case 'angle'
				y = angle(x);
			otherwise
				warning('complexFix:UnknownReturnType',...
						'Unknown return type (%s), assuming real.', returnType);
				y = real(x); 
		end
	else
		y = x;
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

