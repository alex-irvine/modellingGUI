%> @file updateGradientError.m
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
%>	Update the error estimation on the output(s), based on the gradient
%>	estimation at point A.
% ======================================================================
function [s] = updateGradientError(s, samples, values, A)


% walk over all outputs
outputErrors = zeros(size(values,2),1);
for outputIndex = 1 : size(values,2)

	% update gradient errors for all neighbours
	for i = 1 : length(s.neighbourhoods{A})

		% we consider P
		P = s.neighbourhoods{A}(i);

		% get true value
		v = values(P,outputIndex);

		% L = diff between P and A
		L = samples(P,:) - samples(A,:);

		% calculate value based on gradient
		gv = values(A,outputIndex) + dot(L,s.gradients{A}(outputIndex,:));

		% update gradient error
		outputErrors(outputIndex) = outputErrors(outputIndex) + abs(v - gv);

	end
	
end

% we now have the gradient errors in the different outputs - aggregate
if strcmp(s.combineOutputs, 'max')
	s.gradientErrors{A} = max(outputErrors);
else
	error(sprintf('Invalid option given for combineOutputs in LOLASampleSelector: %s', s.combineOutputs));
end


%s.logger.finer(sprintf('Gradient errors for neighbours of sample %d was found to be %s', A, arr2str(s.gradientErrors{A})));


end
