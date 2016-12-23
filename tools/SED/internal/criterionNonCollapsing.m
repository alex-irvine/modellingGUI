function [out] = criterionNonCollapsing(samples, inDim, nSamples, nDistances)
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
samples = samples(1:nSamples,1:inDim);

% sort the samples in their own dimension
samples = sort(samples);

% substract subsequent values in each dimension
diff = samples(2:end,:) - samples(1:end-1,:);


%diff(diff == 0) = Inf;

% flatten
diff = diff(:);

% calculate the min distance in each dimension
[out,indices] = sort(diff);

% do not take the absolute minimum, but a weighted version of the smallest
% values
out = mean(diff(indices(1:nDistances)));

end

