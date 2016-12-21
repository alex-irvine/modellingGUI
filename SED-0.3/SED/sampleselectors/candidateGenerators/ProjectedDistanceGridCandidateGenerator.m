%> @file ProjectedDistanceGridCandidateGenerator.m
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
%> Generates all the local optima for the projected distance criterion
%> exactly, by using the inherent properties of the surface. Only the local
%> optima fullfiling certain criteria are returned.
% ======================================================================
classdef ProjectedDistanceGridCandidateGenerator < CandidateGenerator


	
	properties
		alpha;
		minDistance;
		candidates;
		maxIntervals;
		inputWeights;
	end
	
	methods
		
        % =================================================================
        %> @brief Class constructor
        %>
        %> @param config NodeConfig object
        %>
        %> @return Instance of the candidate generator class
        % =================================================================
		function s = ProjectedDistanceGridCandidateGenerator(config)
			
			% config this object
			s = s@CandidateGenerator(config);
			s.alpha = config.self.getDoubleOption('alpha', 0.5);
			s.minDistance = config.self.getDoubleOption('minDistance', Inf);
			s.candidates = config.self.getIntOption('candidates', 10000000);
			s.maxIntervals = config.self.getIntOption('maxIntervals', 0);
			if s.maxIntervals == 0
				s.maxIntervals = Inf;
			end
			
			% get the weights
			s.inputWeights = zeros(1, config.input.getInputDimension());
			for i = 0 : config.input.getInputDimension() - 1
				s.inputWeights(i+1) = config.input.getInputDescription(i).getWeight();
			end
			
		end
		
		

		function [s, state, candidates] = generateCandidates(s, state)
		% RandomCandidateGenerator (SUMO)
		%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
		%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
		%     Copyright: IBBT - IBCN - UGent
		% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
		% Revision: $Rev$
		%
		% Signature:
		%	[state, candidates] = RandomCandidateGenerator(state)
		%
		% Description:
		%	Generate candidates on the optimal non-collapsing grid.
		
			% input dimension
			inDim = size(state.samples,2);
		
			% first transform the samples to the weighted space
			samples = bsxfun(@times, state.samples, s.inputWeights);
			
			% compute the grid points in all dimensions
			% this is the average between two consecutive values - so the
			% middle between all the intervals defined by the points
			sortedSamples = sort(samples, 1);
			averages = (sortedSamples(2:end,:) + sortedSamples(1:end-1,:)) ./ 2;
			intervals = (sortedSamples(2:end,:) - sortedSamples(1:end-1,:));
			
			% now sort the intervals sequentially by size
			[intervals, indices] = sort(intervals, 1, 'descend');
			
			% sort the averages the same way
			for i = 1 : inDim
				averages(:,i) = averages(indices(:,i),i);
			end
			
			% cap the intervals to the max #
			if size(intervals,1) > s.maxIntervals
				averages(s.maxIntervals+1:end,:) = [];
				intervals(s.maxIntervals+1:end,:) = [];
			end
			
			% calculate the minimum size of an interval
			% this is defined as dmin, the minimum allowed distance of new
			% candidates from the dataset
			dMin = min(((s.inputWeights .* 2) ./ size(samples, 1)) .* s.alpha, s.minDistance);
			
			% filter out those intervals that are too small - can't fit a
			% good non-collapsing point in there anyway
			%largeEnough = intervals > dMin*2; % 2 already incorporated in 2.0 / ???
			largeEnough = bsxfun(@gt, intervals, 2 * dMin);
			
			% convert to cell array
			averagesGrid = cell(inDim, 1);
			intervalsGrid = cell(inDim, 1);
			for i = 1 : inDim
				
				% only add the intervals that are large enough
				averagesGrid{i} = averages(largeEnough(:,i),i);
				
				% the allowed interval is defined by dMin
				% so the real interval size is reduced by 2dMin
				intervalsGrid{i} = intervals(largeEnough(:,i),i) - 2 * dMin(i);
			end
			p = 1;
			for i = 1 : size(state.samples,2)
				p = p * length(averagesGrid{i});
			end
			%disp(sprintf('Current candidates matching dMin: %d', p));
			% now generate the entire grid using makeEvalGrid
			candidates = makeEvalGrid(averagesGrid);
			
			% for this grid, define the range that the optimizer is allowed to optimize in
			state.intervals = makeEvalGrid(intervalsGrid);
			
			% transform back to [-1,1]
			candidates = bsxfun(@rdivide, candidates, s.inputWeights);
			state.intervals = bsxfun(@rdivide, state.intervals, s.inputWeights);
			
		end
		
		
		function [s, state, candidates] = generateCandidatesNew(s, state)

		% RandomCandidateGenerator (SUMO)
		%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
		%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
		%     Copyright: IBBT - IBCN - UGent
		% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
		% Revision: $Rev$
		%
		% Signature:
		%	[state, candidates] = RandomCandidateGenerator(state)
		%
		% Description:
		%	Generate candidates on the optimal non-collapsing grid.
		
			% input dimension
			inDim = size(state.samples,2);
			
			% first transform the samples to the weighted space
			samples = bsxfun(@times, state.samples, s.inputWeights);
			
			% calculate the minimum size of an interval
			% this is defined as dmin, the minimum allowed distance of new
			% candidates from the dataset
			dMin = min(((s.inputWeights .* 2) ./ size(samples, 1)) .* s.alpha, s.minDistance);
			
			% compute the grid points in all dimensions
			% this is the average between two consecutive values - so the
			% middle between all the intervals defined by the points
			sortedSamples = sort(state.samples, 1);
			averages = (sortedSamples(2:end,:) + sortedSamples(1:end-1,:)) ./ 2;
			intervals = (sortedSamples(2:end,:) - sortedSamples(1:end-1,:));
			
			% sort the intervals within their own dimension
			[intervals, indices] = sort(intervals, 1, 'descend');
			
			% print total # good intervals
			largeEnough = bsxfun(@gt, intervals, 2 * dMin);
			%validIntervals = prod(sum(largeEnough));
			%disp(sprintf('Total number of center points within intervals large enough: %d', validIntervals));
			
			
			% sort the averages the same way
			for i = 1 : inDim
				averages(:,i) = averages(indices(:,i),i);
			end
			
			% initialize the "top" vector, which indicates which is the
			% deepest interval that was selected so far in each dimension
			top = ones(1, inDim);
			
			% determine the initial pick - the largest interval
			pick = ones(1, inDim);
			
			% the initial volume of the first pick
			pickVolume = prod(diag(intervals(pick, 1:inDim)));
			%pickVolume = 1;
			
			% now keep going until we have the set number of candidates
			k = 1;
			candidates = zeros(s.candidates, inDim);
			pickList = zeros(0, inDim);
			volumeList = zeros(0,1);
			nPickList = 0;
			while true
				
				% check if the current pick actually has an interval large
				% enough for dMin
				pickIntervals = diag(intervals(pick, 1:inDim))' - 2*dMin;
				if any(pickIntervals <= 0)
					k = k - 1;
					k
					pick
					disp('Abort due to bad intervals...');
					error('WTF');
					break;
				end
				
				% add the current pick
				average = diag(averages(pick, 1:inDim))';
				candidates(k,:) = average;
				state.intervals(k,:) = pickIntervals;
				
				% all done
				if k == s.candidates
					disp('Abort due to max candidates...');
					break;
				end
				
				% improve the top
				top = max(top, pick);
				
				% consider all the children for this pick
				for i = 1 : inDim
					
					% create child
					child = pick;
					child(i) = child(i) + 1;
					
					% invalid child - we have reached the end of the interval list
					if child(i) > size(intervals,1)
						continue;
					end
					
					% make sure the new interval is still larger than dMin
					if intervals(child(i),i) <= 2 * dMin
						continue;
					end
					
					% compute its cost compared to the parent
					childVolume = pickVolume * intervals(child(i),i) / intervals(pick(i),i);
					
					% see if the child is viable
					
					% only one parent - just add it to the list
					if sum(child == 1) == inDim - 1
						pickList = [pickList ; child];
						volumeList = [volumeList ; childVolume];
						
					% all parents have been considered
					elseif all(child <= top)
						
						% check if the child has been considered before
						%if ~any(all(bsxfun(@ge, pickList, child), 2))
						if ~any(all(bsxfun(@le, pickList, child), 2))
							pickList = [pickList ; child];
							volumeList = [volumeList ; childVolume];
						end
					end
					
				end
				nPickList = max(nPickList, length(volumeList));
				% we have exhausted ALL possible combinations - abort
				if isempty(volumeList)
					disp('Abort due to empty volume list...');
					break;
				end
				
				% now pick the best new candidate from the list
				[dummy, idx] = max(volumeList);
				pick = pickList(idx,:);
				pickVolume = volumeList(idx);

				% remove it from the list
				pickList(idx,:) = [];
				volumeList(idx) = [];
				
				% next candidate
				k = k + 1;
			end
			
			% remove redundant candidates - only happens if we have less
			% intervals than s.candidates
			candidates(k+1:end,:) = [];
			state.intervals(k+1:end,:) = [];
			disp(sprintf('Max pick list size: %d', nPickList));
			disp(sprintf('Generated %d candidates, max %d', size(candidates,1), s.candidates));
		end
		
		
	end
end
