%> @file calculateAIC.m
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
%>	Return the value of Akaikes Information Criteria (AIC or AICc) for this model
% ======================================================================
function res = calculateAIC(model)


%Get the number of samples
samples = getSamplesInModelSpace(model);
n = size(samples,1);

%Calculate the mean square error
mserr = meanSquareError(getValues(model),evaluateInModelSpace(model, samples));

%Get the number of free parameters, add one for the variance
K = complexity(model) + 1;

%Calculate the AIC
aic = n*log(mserr) + 2*K;

if (n/K < 40)
	%Adjust for small samples (AICc)
	aic = aic + ( (2*K*(K+1)) / (n-K-1) );
end

res = aic;
