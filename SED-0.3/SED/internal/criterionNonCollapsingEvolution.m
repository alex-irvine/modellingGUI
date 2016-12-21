function [out] = criterionNonCollapsingEvolution(allSamples, inDim)
%CRITERIONMAXIMIN Summary of this function goes here
%   Detailed explanation goes here

range = 2 : 1 : size(allSamples,1);

if ~exist('inDim', 'var')
	out = range;
	return;
end

out = [];
for i = range

	% cut samples
	samples = allSamples(1:i,1:inDim);

	% sort the samples in their own dimension
	samples = sort(samples);

	% substract subsequent values in each dimension
	diff = samples(2:end,:) - samples(1:end-1,:);

	%diff(diff == 0) = Inf;

	% flatten
	diff = diff(:);
	
	% do not take the absolute minimum, but a weighted version of the smallest
	% values
	out = [out min(diff)];

end

end

