function [s, bestxMin, bestfMin] = optimize(s, arg)

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

% initial 2 samples are always the same - the 2 corner points
inDim = s.inDim;
if s.cornerPointsLeft > 0
	
	% convert [1,2] to [-1,1]
	bestxMin = repmat((s.cornerPointsLeft - 1) .* 2 - 1, 1, inDim);
	bestfMin = func(bestxMin);
	s.cornerPointsLeft = s.cornerPointsLeft - 1;
	
	% all done
	return;
	
% if there is only one option left, we don't need to optimize
elseif s.nLeft == 1
	disp(sprintf('Last option for %d', s.grain));
	s.unoccupiedStrata
	bestxMin = ones(1, inDim);
	bestxMin = s.convertToModelCoordinates(bestxMin);
	bestfMin = func(bestxMin);
	
% real optimization from here
else
	
	disp(sprintf('Optimizing between strata %s', arr2str(s.unoccupiedStrata)));
	
	% now wrap the function in a converter, which converts from our local
	% grid coordinate system to [-1,1]
	%func = @(x)(func(s.convertToModelCoordinates(x)) + s.getStrataSplitScore(x
	strataFunc = @(x)(func(s.convertToModelCoordinates(x)));
	
	% update the options
	s.options = gaoptimset(s.options, 'PopulationSize', s.getPopulationSize());
	s.options = gaoptimset(s.options, 'EliteCount', min(2, s.getPopulationSize()-1));
	s.options = gaoptimset(s.options, 'CreationFcn', @(genomeLength, fitnessFcn, options)(s.creationFunction(genomeLength, fitnessFcn, options)));
	s.options = gaoptimset(s.options, 'MutationFcn', @(parents, options, nvars, fitnessFcn, state, thisScore, thisPopulation)(s.mutationFunction(parents, options, nvars, fitnessFcn, state, thisScore, thisPopulation)));
	s.options = gaoptimset(s.options, 'CrossoverFcn', @(parents, options, nvars, fitnessFcn, unused, thisPopulation)(s.crossoverFunction(parents, options, nvars, fitnessFcn, unused, thisPopulation)));
	s.options = gaoptimset(s.options, 'HybridFcn', []);
	
	% only one generation when the population is made of all possible locations
	if s.creationGrid
		s.options = gaoptimset(s.options, 'Generations', 1);
	end
	
	% run the ga
	[bestxMinInStrata bestfMin,dummy,dummy2,population,scores] ...
		= ga(strataFunc, inDim, [],[],[],[],[],[],[],s.options);
	
	% convert back to model coordinates
	bestxMin = s.convertToModelCoordinates(bestxMinInStrata);
	
	% run a local hill climber on the population of the last generation
	if s.localImprovement
		
		% configure the optimization algorithm
		saoptions = saoptimset('simulannealbnd');
		saoptions = saoptimset(saoptions, 'MaxFunEvals', 500 * inDim);
		saoptions = saoptimset(saoptions, 'Display', 'off');
		
		% create a new func handle, which scales the population so that one
		% strata fits within [-1,1]
		strataWidth = 2/(s.grain) * s.alpha;
		
		%disp(sprintf('Best before optimization: %s = %s : %d', arr2str(bestxMinInStrata), arr2str(bestxMin), bestfMin));
		
		% first, convert the population to [-1,1] again
		%for i = 1 : size(population,1)
		population = bestxMinInStrata;
		for i = 1 : size(population,1)
			
			% the new func is based on the current loc
			loc = s.convertToModelCoordinates(population(i,:));
			hillFunc = @(x)(func(bsxfun(@plus, x .* (strataWidth/2), loc)));
			
			% optimize
			[betterX, betterScore] = simulannealbnd(hillFunc, zeros(1, inDim), -ones(1,inDim), ones(1,inDim), saoptions);
			
			% global improvement
			if betterScore < bestfMin
				bestxMinInStrata = population(i,:);
				bestxMin = betterX .* (strataWidth/2) + loc; % inverse operation of hillFunc
				bestfMin = betterScore;
				
				%disp(sprintf('Improvement to %s, loc %s, score %d', arr2str(bestxMinInStrata), arr2str(bestxMin), bestfMin));
			end
		end
	end
	
	%disp(sprintf('Best after optimization: %s = %s = %s : %d', arr2str(bestxMinInStrata), arr2str(s.convertToModelCoordinates(bestxMinInStrata)), arr2str(bestxMin), bestfMin));
	
	% remove the strata occupied by this new sample from the list
	s.unoccupiedStrata(sub2ind(size(s.unoccupiedStrata), bestxMinInStrata, 1:inDim)) = [];
	
	% reshape back to original version minus one row
	s.unoccupiedStrata = reshape(s.unoccupiedStrata, s.nLeft - 1, inDim);
end

disp(sprintf('Best: %s, distance %d', arr2str(bestxMin), bestfMin));
% one more sample produced
s.nLeft = s.nLeft - 1;

% if we have produced all the samples in this grain, we go to a finer grid
if s.nLeft == 0
	
	% initial grain - just add 1 - SPECIAL CASE
	if s.range == 0
		s.grain = s.grain - 1;
	else
		
		% double the grain
		s.grain = s.grain * 2;
	end
	
	% fix the range
	s.range = 1/(2*s.grain);
	
	% re-add the all the strata
	s.nLeft = s.grain;
	s.unoccupiedStrata = repmat([1:s.grain]', 1, inDim);
end

%disp(sprintf('Final choice: %s with %d', arr2str(bestxMin), bestfMin));
state = s.getState();
samples = [state.samples ; bestxMin];
plot(samples(:,1), samples(:,2), 'or');
hold on;
colors = 'ymcrgbwk';
for i = 1 : size(samples,1)
	plot([samples(i,1) samples(i,1)], [-1 1], 'g');
	plot([-1 1], [samples(i,2) samples(i,2)], 'b');
end

end