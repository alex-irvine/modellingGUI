%> @file approximateVoronoi.m
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
%>	An approximate (monte carlo) version of Matlab's voronoi command.  The samples are assumed to lie within
%>	the LB and UB bounds (=vectors, one lower and upper bound per dimension).  If LB,UB are not given [-1 1] is assumed.
%>	Returns an approximation of the voronoi cells and their areas.  Also returns the size of the largest voronoi
%>	cell as a percentage of the total domain delimited by the bounds LB and UB.
%>	A final argument is a set of constraints that have to be satisfied.
%>	Voronoi cells which partly violate constraints are estimated at their
%>	size within the allowed area.
% ======================================================================
function [s perc] = approximateVoronoi( samples, LB, UB, constraints )


dim = size(samples,2);

if(~exist('LB','var') || ~exist('UB','var'))
	LB = [];
	UB = [];
end

if(isempty(LB) || isempty(UB))
	LB = -ones(1,dim);
	UB = ones(1,dim);
end

if ~exist('constraints', 'var')
	constraints = [];
end

% we generate 100 random points in the domain for each sample
nPoints = 100 * size(samples,1);

% generate random points to estimate the voronoi decomposition
points = rand(nPoints, dim);

% scale each column to the correct range
for i=1:dim
	points(:,i) = scaleColumns(points(:,i),LB(i),UB(i));
end

% enforce the constraints
if ~isempty(constraints)
	indices = constraints.satisfySamples(points);
	points = points(indices,:);
	nPoints = size(points,1);
end

% calculate the nearest sample to each point
s.areas = zeros(size(samples,1), 1);
s.closestPoints = cell(size(samples,1), 1);
%{
% faster version
d = buildDistanceMatrix(points, samples, false);
[~, minIndices] = min(d, [], 2);
s.areas = accumarray(minIndices, 1) ./ nPoints;
for i = 1 : size(samples,1)
	s.closestPoints{i} = points(minIndices == i,:);
end
%}

for i = 1 : nPoints
	% calculate the minimum distance
	distances = buildDistanceMatrixPoint(samples, points(i,:), false);
	[minDistance, closestSample] = min(distances);
	
	% add to the voronoi list of the closest sample
	%disp(sprintf('Point %s found to be closest to sample %s', arr2str(points(i,:)), arr2str(samples(closestSample,:))));
	s.areas(closestSample) = s.areas(closestSample) + 1;
	s.closestPoints{closestSample} = [s.closestPoints{closestSample} ; points(i,:)];
end

% divide by the amount of points to get the estimated volume of each
% voronoi cell
s.areas = s.areas ./ nPoints;



perc = max(s.areas .* 100);
