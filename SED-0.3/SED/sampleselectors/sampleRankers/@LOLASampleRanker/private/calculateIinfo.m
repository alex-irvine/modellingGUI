%> @file calculateIinfo.m
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
%>	Calculate the independent information of candidate neighbour B towards
%>	sample A with already a set of neighbours.
% ======================================================================
function IF = calculateIinfo( A, neighbours, B )


k = 1;

% IF is high when distance between A and B is low
IF = exp(-k * mag(B-A));

% IF is low when distance between B and neighbours is low
maxR = 0;

for i = 1 : size(neighbours,1)
	
	% when 1D, don't use triangle distance metric
	if length(A) == 1
		%R = exp(-k * mag(neighbours(i,:)-B));
		R = 0;
		% FIXME: penalty geven voor maximale afstand tot neighbour, of puur
		% enkel baseren op afstand tot A?
		% ZELFS MET R=0 PAKT HIJ NIET EENS DE 2 DICHTSTE NEIGHBOURS
		% -> zit zeker ergens bug in algoritme
	else
		%R = exp(-k * (mag(A-B) + mag(neighbours(i,:)-B) + mag(neighbours(i,:)-A)) / 2);
		R = 0;
	end
	if R > maxR
		maxR = R;
	end
end
%disp(sprintf('Iinfo calculation, if = %d, maxR = %d', IF, maxR));
IF = IF - maxR;
