function [out] = criterionMaximin(samples, inDim, nSamples, nDistances)
%CRITERIONMAXIMIN Summary of this function goes here
%   Detailed explanation goes here

% default = all samples
if ~exist('nSamples', 'var')
	nSamples = size(samples,1);
end
if ~exist('nDistances', 'var')
	nDistances = 1;
end

% cut samples
samples = samples(1:min(nSamples, size(samples,1)),1:inDim);

% calculate maximin distance
distances = buildDistanceMatrix(samples, samples, true);

% set the diagonal to inf
distances(eye(length(distances)) == 1) = Inf;

% sort the distances
distances = distances(:);
[dummy, indices] = sort(distances);

% return the average of the nDistances smallest distances
out = mean(distances(indices(1:nDistances)));

end

