%> @file getAICInfo.m
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
%>	Return metrics related to Akaike's Information Criteria:
%>	The Akaike weights wi, the relative differences between the AIC scores,
%>	the likelihood of each model and its evidence ratio.
%>	Theory comes from the book: Model Selection and Multimodal Inference
%>	by Kenneth P Burnham and David R Anderson
% ======================================================================
function [deltai wi likelihood evidenceRatios] = getAICInfo(models);


n = length(models);

[numInputs numOutputs] = models{1}.getDimensions();

aic = zeros(length(models),numOutputs);
for i=1:n
	%Get all the AIC values
	aic(i,:) = calculateAIC(models{i});
end
 
%Find AICmin
[smallestAic smallestIndex] = min(aic,[],1);

%Calculate the deltas
deltai = aic - repmat(smallestAic,n,1);

%Calculate the likelihoods
likelihood = exp(-0.5 .* deltai);

%Calculate the Akaike weights
likelihoodSum = sum(likelihood,1);
wi = likelihood ./ repmat(likelihoodSum,size(likelihood,1),1);

%Calculate the evidence ratios vs the best wi
bestwi = wi(smallestIndex,:);
evidenceRatios = wi ./ repmat(bestwi,size(likelihood,1),1);
