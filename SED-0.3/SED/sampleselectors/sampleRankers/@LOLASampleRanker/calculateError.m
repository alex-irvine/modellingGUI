%> @file calculateError.m
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
%>	Calculate error is overridden to produce the true gradient error.
% ======================================================================
function [s, error, failedError] = calculateError(s, state)


s.logger.fine('Starting LOLA sample ranking...');
samples = state.samples;
values = state.values;


% see if there are new samples to be added and processed
s = addNewSamples(s, samples, values);
% now every sample must have his own neighbourhood (might be empty)

% if there is only one sample, we can't do anything meaningful - just
% return zero as error
if size(values,1) < 2
	error = zeros(size(values,1),1);
	return;
end


if s.debug
	
	% plot the gradients & neighbours (only in 1D and in debug mode)
	if s.dimension == 1
		for A = 1 : size(values,1)
			x = max(-1, samples(A) - .2) : .01 : min(1, samples(A) + .2);
			y = values(A) + s.gradients{A} .* (x - samples(A));
			hold on;
			plot(x, y, 'g');
		end

		% plot neighbours
		cols = 'rgbcmykw';
		lines = {'-.','--','-', ':'};
		for A = 1 : size(values,1)
			col = cols(mod(A-1,8)+1);
			line = lines{mod(A-1,4)+1};
			for P = s.neighbourhoods{A}
				hold on;
				plot(samples([A P]), values([A P]), [line col]);
			end
		end

	end
end

% calculate the total error
totalError = 0;
for A = 1 : s.sampleSize
	totalError = totalError + s.gradientErrors{A};
end

% fix for very small values - only happens if we are modeling an entirely flat surface
if totalError < 0.01
	totalError = 0.01;
end

% look for the sample with the largest average distance from its neighbours
error = zeros(size(values,1),1);
for A = 1 : size(values,1)
	
	% calculate average error compared to errors of other neighbourhoods
	error(A) = s.gradientErrors{A} / totalError;
end

% failed error set to 0
failedError = zeros(size(state.samplesFailed,1), 1);

%{
% draw everything
close all;
figure;
plot3(samples(:,1), samples(:,2), values, 'ob');
hold on;
for A = 1 : size(samples,1)
	
	% this point
	p = samples(A,:);
	v = values(A);
	
	% gradient
	G = s.gradients{A}(1,:);
	
	% generate interpolation points
	data = makeEvalGrid({[(p(1) - .2) (p(1) + .2)], [(p(2) - .2) (p(2) + .2)]});
	L = bsxfun(@minus, data, p);
	gv = v + sum(bsxfun(@times, L, G),2);
	plotScatteredSurface(data, gv);
	hold on;
end
%}