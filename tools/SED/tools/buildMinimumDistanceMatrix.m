%> @brief TODO
%>
%>	Both `samples' and `targets' give an array of d-dimensional points
%>	If `samples' is N x d and `targets' is M x d, then
%>	this function returns an N x 1 matrix, which contains the minimum
%>  distance of each sample from all of the targets. This computation is done
%>  in a memory-safe manner, in which it is ensured that no memory limitations
%>  of Matlab are hit in the process.
%> 
%>	Example:
%>	>> build_distance_matrix( [ 0 0 ; 1 1 ; 2 2 ], [ 1 0 ; 0 1 ] )
%>	ans =
%>	 1.0000    1.0000
%>	 1.0000    1.0000
%>	 2.2361    2.2361
% ======================================================================
function [minDistances, idx] = buildMinimumDistanceMatrix(samples, targets, doSqrt)
persistent mem;

	if nargin == 1
		targets = samples;
		doSqrt = 1;
	elseif nargin == 2
		doSqrt = 1;
		if isempty(targets); targets = samples; end
	elseif nargin == 3
		if isempty(targets); targets = samples; end
	else
		error('Invalid number of arguments given');
	end
	
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
				distances = buildDistanceMatrix(samples, targets(i:min(i+step-1, sz2), :), doSqrt);
				[mind, minidx] = min(distances, [], 2);
				betterIndices = mind < minDistances;
				idx(betterIndices) = minidx(betterIndices);
				minDistances(betterIndices) = mind(betterIndices);
			end
			
		% split up the samples
		else
			step = floor(maxArraySize / sz2);
			for i = 1 : step : sz1
				distances = buildDistanceMatrix(samples(i:min(i+step-1, sz1), :), targets, doSqrt);
				[minDistances(i:min(i+step-1, sz1)), idx(i:min(i+step-1, sz1))] = min(distances, [], 2);
			end
		end
		
	% no split necessary - just compute it
	else
		distances = buildDistanceMatrix(samples, targets, doSqrt);
		[minDistances, idx] = min(distances, [], 2);
	end


end

