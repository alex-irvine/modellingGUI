function [out] = criterionMaximinEvolution(allSamples, inDim)
%CRITERIONMAXIMIN Summary of this function goes here
%   Detailed explanation goes here

range = 2 : 1 : size(allSamples,1);

if ~exist('inDim', 'var')
	out = range;
	return;
end

out = [];
for i = range;
	
	% take part of the samples
	samples = allSamples(1:i, 1:inDim);

	% calculate maximin distance
	distances = buildDistanceMatrix(samples, samples, true);

	% set the diagonal to inf
	distances(eye(length(distances)) == 1) = Inf;

	% minimum distance from all other points
	out = [out min(min(distances))];
end

end

