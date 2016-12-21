%> @file buildMinimumNonCollapsingDistanceMatrix.m
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
%>	Calculate the minimum projected distance of the samples from all the
%>  targets, and make sure no memory problems occur with very large matrices.
% ======================================================================
function [minDistances, idx] = buildMinimumNonCollapsingDistanceMatrix(samples, targets)
persistent mem;

	% dimensions of the problem
	[sz1,d] = size(samples);
	[sz2,d] = size(targets);

	% calculate the memory limit for one array (in # of samples)
	try
		if isempty(mem)
			mem = memory;
		end
		maxArraySize = min(mem.MaxPossibleArrayBytes, mem.MemAvailableAllArrays) / 8 - 10;
	catch err
		maxArraySize = 155e6 - 10;
	end
	
	% since in the buildDistanceMatrix calculation, 4 intermediate arrays are
	% computed and stored, we divide max size by 4
	maxArraySize = floor(maxArraySize / 6);

	% see how much we actually need and split up if necessary
	minDistances = inf(size(samples,1), 1);
	idx = zeros(size(samples,1), 1);
	if sz1 * sz2 > maxArraySize
		
		% split up the targets
		if sz1 < sz2
			step = floor(maxArraySize / sz1);
			for i = 1 : step : sz2
				distances = buildNonCollapsingDistanceMatrix(samples, targets(i:min(i+step-1, sz2), :));
				[mind, minidx] = min(distances, [], 2);
				betterIndices = mind < minDistances;
				idx(betterIndices) = minidx(betterIndices);
				minDistances(betterIndices) = mind(betterIndices);
			end
			
		% split up the samples
		else
			step = floor(maxArraySize / sz2);
			for i = 1 : step : sz1
				distances = buildNonCollapsingDistanceMatrix(samples(i:min(i+step-1, sz1), :), targets);
				[minDistances(i:min(i+step-1, sz1)), idx(i:min(i+step-1, sz1))] = min(distances, [], 2);
			end
		end
		
	% no split necessary - just compute it
	else
		distances = buildNonCollapsingDistanceMatrix(samples, targets);
		[minDistances, idx] = min(distances, [], 2);
	end
