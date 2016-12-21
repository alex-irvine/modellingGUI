%> @file generate.m
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
%> TODO
% ======================================================================
function [initialsamples, evaluatedsamples] = generate(this)

[inDim outDim] = getDimensions(this);

%> @todo check for (statistics) toolbox, how ?
% - 'inuse', sometimes toolbox is available but not 'loaded'
% - 'test', only checks for license (not installation)
% - 'checkout', checks out a license
if checkLicense('Statistics Toolbox')
	translate = (this.levels + 1) ./ 2;
	scale = (this.levels - 1) ./ 2;
	nrSamples = prod(this.levels);
	
	% generate the design and transform to -1,1
	initialsamples = (fullfact( this.levels ) - repmat(translate, nrSamples, 1)) ./ repmat(scale, nrSamples, 1);
else
	% naive but robust implementation
	nrSamples = prod(this.levels);
	nrSamplesLeft = nrSamples;
	initialsamples = zeros(nrSamples, inDim);
	
	for i=1:inDim
		% generate one level (1D)
		x=linspace(-1, 1, this.levels(i) );
		
		% 1D line is to be replicated: Update iteration variables
		nrReps = nrSamples ./ nrSamplesLeft; % number of repeats needed for this dimension
		nrSamplesLeft = nrSamplesLeft ./ this.levels(i); % Current level is 'done', remove it from #samples

		% Replicate
		x = repmat( x, nrReps, 1 );
		x = x(:); % transform to vector
		x = repmat( x, nrSamplesLeft, 1);
		initialsamples(:,i) = x(:);
	end
end

evaluatedsamples = [];
