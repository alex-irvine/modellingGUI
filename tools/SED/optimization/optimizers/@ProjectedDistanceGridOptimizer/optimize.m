function [this, bestxMin, bestfMin] = optimize(this, arg)

% optimize (M3)
%     Part of the Multivariate Meta-Modelling Toolbox ("M3-Toolbox")
%     Copyright W. Hendrickx, D. Gorissen, K. Crombecq, I. Cockuyt, W. van Aarle and T. Dhaene, 2005-2007
% Contact : mailto:dirk.gorissen@ua.ac.be
%
% Description:
%     This function optimizes the given function handle

if isa( arg, 'Model' )
    func = @(x) evaluate(arg,x);
else% assume function handle
	func = arg;
end

% get the initial population
pop = this.getInitialPopulation();
inDim = size(pop,2);

% get the intervals
state = this.getState();
nSamples = size(state.samples,1);
intervals = state.intervals;

% cap for pop size - if it is too large, we split the distance matrix up
split = 100000;
if size(pop,1) > split
	distances = zeros(size(pop,1), 1);
	for i = 1 : split : size(pop,1)
		subPop = pop(i:min(end,i+split-1),:);
		d = buildDistanceMatrix(subPop, state.samples, false);
		distances(i:min(end,i+split-1)) = min(d, [], 2);
		clear subPop d
	end
else

	% calculate the maximin score for all the pop points
	distances = buildMinimumDistanceMatrix(pop, state.samples, false);
end

% the number of optimalization iterations lowers exponentially with n
%expFactor = ((2/nSamples)^inDim) / ((2/(nSamples-1))^inDim);
%this.maxIterations = floor(this.maxIterations * expFactor);
%this.maxIterations = floor(this.maxIterations * 0.95);
%this.maxIterations = 0;

% the number of candidates considered rises exponentially
%this.nPop = ceil(this.nPop / expFactor);
%this.nPop = 50;
%this.nPop = ceil(this.nPop / 0.95);
%disp(sprintf('Optimizing %d points for %d interations...', this.nPop, this.maxIterations));
% # to be taken
nPop = min(this.nPop, size(pop,1));
[dummy, indices] = sort(distances, 'descend');

% constraint manager
c = Singleton('ConstraintManager');

% no constraints - just add the n best ones
if ~c.hasConstraints()
	pop = pop(indices(1:nPop), :);
	intervals = intervals(indices(1:nPop, :), :);
	
% there are constraints - check each point against the constraints first
else
	i = 1;
	newPop = [];
	while size(newPop,1) < nPop && i <= size(pop,1)
		if c.satisfySample(pop(indices(i), :))
			pop(indices(i),:)
			newPop = [newPop ; pop(indices(i), :)];
		end
		i = i + 1;
	end
	pop = newPop;
end

% Run it
bestfMin = +Inf;
bestxMin = 0;

% options
options = psoptimset(@patternsearch);
options = psoptimset(options, 'Display', 'off');
options = psoptimset(options, 'MaxIter', this.maxIterations);

% first, filter the population

%options = psoptimset(options, 'Vectorize', 'on');
%options = psoptimset(options, 'CompletePoll', 'on');
%options = psoptimset(options, 'CompleteSearch', 'on');
for i = 1 : size(pop,1)
	
	% define the bounds
	x = pop(i,:);
	f = func(x);
	
	% only perform pattern search when there are > 0 max iterations
	if this.maxIterations > 0
		
		bounds = intervals(i,:);
		LB = max(-ones(1, inDim), x - bounds ./ 2);
		UB = min(ones(1, inDim), x + bounds ./ 2);
		
		% now scale the function so that the viable area lies within [-1,1]
		scaleFunc = @(x)(func(bsxfun(@plus, bsxfun(@times, (x+1)./ 2, UB-LB), LB)));

		%disp(sprintf('Started with %s: %d', arr2str(x), f));
		%disp(sprintf('Searching between %s and %s', arr2str(LB), arr2str(UB)));

		% optimize with pattern search in this cube
		if ~c.hasConstraints()
			%[x, f] = patternsearch(scaleFunc, x, [], [], [], [], -ones(inDim,1), ones(inDim,1), @(x)(s.unitCircleConstraint(x)), options);
			[x, f, exitflag, output] = patternsearch(scaleFunc, zeros(1, inDim), [], [], [], [], -ones(inDim,1), ones(inDim,1), options);
		else
			
			% even though the start point satisfies the constraint, the
			% optimization algorithm must also respect them - create nonlinear
			% constraint function for patternsearch
			nonlcon = @(x)(c.nonlcon((x+1)./ 2 .* (UB-LB) + LB));
			[x, f] = patternsearch(scaleFunc, zeros(1, inDim), [], [], [], [], -ones(inDim,1), ones(inDim,1), nonlcon, options);
		end

		% scale x back to [LB,UB]
		x = (x+1)./ 2 .* (UB-LB) + LB;
	end

	
	if f < bestfMin
		%disp(sprintf('New best choice %s (%d), optimized from %s to %s', arr2str(x), arr2str(LB), arr2str(UB)));
		%disp(sprintf('Original location: %s (%d) with interval %s', arr2str(pop(i,:)), func(pop(i,:)), bounds));
		bestfMin = f;
		bestxMin = x;
		bestPopIndex = indices(i);
	end
end
dMin = (2.0 / size(state.samples, 1)) * 0.5;

% calculate distance to make sure the new point satisfies dMin
dist = min(min(abs(bsxfun(@minus, bestxMin, state.samples))));
%disp(sprintf('minimum distance = %d, distance of new point = %d!', dMin,
%dist));

% no sample found matching the criteria :(
if bestfMin == Inf
	bestxMin = zeros(0, size(state.samples,2));
	bestfMin = 0;
end

%disp(sprintf('Final choice: %s with %d', arr2str(bestxMin), bestfMin));
%{
samples = [state.samples ; bestxMin];
plot(samples(:,1), samples(:,2), 'or');
hold on;
colors = 'ymcrgbwk';
for i = 1 : size(samples,1)
	plot([samples(i,1) samples(i,1)], [-1 1], 'g');
	plot([-1 1], [samples(i,2) samples(i,2)], 'b');
end
%}