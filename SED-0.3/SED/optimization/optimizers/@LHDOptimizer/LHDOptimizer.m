%> @file LHDOptimizer.m
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
%> @brief A quasi-LHD optimizer.
%>
%> This optimizer starts with a given LHD grid, and at every iteration
%> picks the best point on the grid according to some criterion. When the
%> entire grid is filled, a new grid is generated on the midpoints of the
%> current grid, and these points are then used as new sample locations.
% ======================================================================
classdef LHDOptimizer < Optimizer

% private members
	properties (SetAccess = 'private', GetAccess = 'private')
		options;
		grain = 3;
		range;
		nLeft;
		unoccupiedStrata;
		inDim;
		creationGrid = false;
		cornerPointsLeft = 2;
		localImprovement = false;
		alpha;
	end
	
	methods
		% constructor
		% Description:
		%     Creates an LHD Optimizer
		function s = LHDOptimizer(varargin)
			
			% call superclass
			s = s@Optimizer(varargin{:});
			
			% configure the GA options
			s.options = gaoptimset(@ga);
			
			% get input dimension
			s.inDim = s.getInputDimension();
			
			% if the maximum size is already given in advance, use this information
			if nargin == 1
				config = varargin{1};
				s.grain = config.self.getIntOption('grain', 3);
				s.creationGrid = config.self.getBooleanOption('creationGrid', false);
				s.alpha = config.self.getDoubleOption('alpha', 0.5); % only used with hill climber
				s.localImprovement = config.self.getBooleanOption('localImprovement', false);
			end
			
			% in the first case, the number of samples left is all but the corner points
			s.nLeft = s.grain - 2;
			
			% also, the range is slightly different - it is [-1,1] now,
			% while it is [-1 + 1/2g, 1 - 1/2g] later
			s.range = 0;
			
			% strata for first grain
			% corner points are already evaluated before - so don't try them again!
			s.unoccupiedStrata = repmat([2:s.grain-1]', 1, s.inDim);
			
		end
		
		function gain = getStrataSplitScore(s, x)
			% Description:
			%	Rates, from 0 to 1, a candidate new sample based on how
			%	many groups of consecutive strata are split into 2 groups,
			%	which is an indication of space-filling potential.
			
			% first count the number of splits in the current set of
			% unoccupied strata
			currentSplits = sum(s.unoccupiedStrata(2:end) > s.unoccupiedStrata(1:end-1) + 1);

			% then remove the strata, and check again
			newStrata = s.unoccupiedStrata;
			newStrata(sub2ind(size(newStrata), x, 1:s.inDim)) = [];

			% new splits
			newSplits = sum(newStrata(2:end) > newStrata(1:end-1) + 1);

			% count how many we gained - compared to the maximum win/loss
			gain = newSplits - currentSplits;

			% scale from [-inDim,inDim] to [0,1]
			gain = (gain + s.inDim) / (2 * s.inDim);
			%disp(sprintf('Split gain for %s: %d', arr2str(x), gain));
		end
		
		function x = convertToModelCoordinates(s, x)
			% Description:
			%	Convert from [1,nLeft] to [-1,1]
			
			% first, convert from [1,nLeft] to [1,grain]
			x = s.unoccupiedStrata(sub2ind(size(s.unoccupiedStrata), x, 1:s.inDim));
			
			% first scale everything to [0,1]
			x = (x-1) / (s.grain - 1);
			
			% divide to have the values in [1/range, (range-1)/range]
			x = x .* (1 - 2*s.range) + s.range;
			
			% convert to [-1,1]
			x = x .* 2 - 1;
			
		end
		
		function population = creationFunction(s, genomeLength, fitnessFcn, options)
			% Description:
			%	return a random Latin hypercube as the initial population.
			
			% just everything
			if s.creationGrid
				population = makeEvalGrid(repmat({1:s.nLeft}, genomeLength, 1));
				
			else
				
				% cap the max number for the initial population
				popSize = s.getPopulationSize();
				population = zeros(popSize,genomeLength);

				% generate a random permutation for each genome of size grain
				for i = 1 : genomeLength
					grainPerm = randperm(s.nLeft);
					population(:,i) = grainPerm(1:popSize);
				end
			end

			disp(sprintf('Created following initial population: %s', arr2str(population)));
		end
		
		
		function children = mutationFunction(s, parents, options, nvars, fitnessFcn, state, thisScore, thisPopulation)
			%disp('--- MUTATION ---');
			
			% get the real parents by indexing
			%parents = thisPopulation(parents,:);
			parents = thisPopulation(parents,:);
			
			%disp(sprintf('Mutating following parents: %s', arr2str(parents)));
			% go over each parent
			children = zeros(size(parents));
			for i = 1 : size(parents,1)
				
				% add a child that moves slightly over the grain grid
				% compared to its parent
				children(i,:) = parents(i,:) + round(randn(1, nvars));
			end
			
			% don't go out of bounds
			children(children < 1) = 1;
			children(children > s.nLeft) = s.nLeft;
			
			%disp(sprintf('Mutated children: %s', arr2str(children)));
		end
		
		
		function children = crossoverFunction(s, parentsIndices, options, nvars, fitnessFcn, unused, thisPopulation)
			%disp('--- CROSSOVER ---');
			
			children = zeros(0, nvars);
			%disp(sprintf('Crossing following parents: %s', arr2str(thisPopulation(parentsIndices,:))));
			for i = 1 : 2 : length(parentsIndices)
				
				% get the next 2 parents
				parents = thisPopulation(parentsIndices([i i+1]), :);
				
				% randomly combine genes from both parents
				assert(size(parents,1) == 2);
				selection = round(rand(1,nvars)) + 1;
				children = [children ; diag(parents(selection,:))'];
				
			end
			%disp(sprintf('Crossed children: %s', arr2str(children)));
		end
		
	end
	
end
