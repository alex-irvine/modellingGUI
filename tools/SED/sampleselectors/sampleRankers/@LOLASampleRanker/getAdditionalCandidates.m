%> @file getAdditionalCandidates.m
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
%>	Perform some kind of heuristic to generate additional points near point
%>	A so that a better candidate can be selected.
% ======================================================================
function [candidates] = getAdditionalCandidates(s, state, A)


samples = state.samples;

% this is a failed sample - we can't calculate any additional candidates
% based on the neighbourhood because failed samples don't have one
if A > size(samples,1)
	candidates = zeros(0, s.dimension);
	return;
end

% only one sample - we can't do anything with the neighbourhood
if size(samples,1) < 2
	candidates = rand(20 * s.dimension, s.dimension) .* 2 - 1;
	return;
end

% find neighbour farthest away from sample
distances = samples(s.neighbourhoods{A},:) - repmat(samples(A,:), length(s.neighbourhoods{A}),1);
farthestNeighbourDistance = min(sqrt(dot(distances, distances, 2)));
boxRadius = farthestNeighbourDistance / 2;

% generate points in the box, and find those in the voronoi cell of A
nPoints = 20 * s.dimension;

% generate random points in [-1,1]
points = rand(nPoints, s.dimension) .* 2 - 1;

% scale & translate to [A - boxRadius, A + boxRadius]
points = points .* boxRadius + repmat(samples(A,:), size(points,1),1);
points = points(~any(bsxfun(@gt, abs(points), s.inputWeights),2),:);

% now filter the points so that only those that satisfy the constraints are considered
constraints = Singleton('ConstraintManager');
indices = constraints.satisfySamples(points);
points = points(indices,:);

% get final number of points
nPoints = size(points,1);

candidates = zeros(0,s.dimension);
for j = 1 : nPoints

	% calculate the minimum distance
	distances = samples - repmat(points(j,:), size(samples,1), 1);
	distances = dot(distances, distances, 2);
	[minDistance, closestSample] = min(distances);

	% A is closest sample, add to candidates
	if closestSample == A
		candidates = [candidates ; points(j,:)];
	end
end
