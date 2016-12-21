%> @file DelaunayMerger.m
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
%> @brief DelaunaydMerger performs a merging of the candidates for each simplex (generated using a Delaunay triangulation)
%>
%> Selects 1 candidate for each Delaunay simplex based on the merging strategy, which is one of:
%> - 'best': choose the best candidate within the simplex
%> - 'middle': always choose the middle (more space-filling minded)
% ======================================================================
classdef DelaunayMerger < MergeCriterion
	
	properties
		strategy;
		weights;
    end
	
	methods (Access = public)
				
        % ======================================================================
        %> @brief Class constructor
        %>
        %> Options:
        %> - strategy: string ('best', 'middle')
        %> - weights: vector
        %> @return instance of the class
        % ======================================================================
		function [this] = DelaunayMerger(varargin)
			
			if nargin == 1
				config = varargin{1};
				this.strategy = char(config.self.getAttrValue('strategy', 'middle'));

				this.weights = str2num(config.self.getAttrValue('weights', '[]'));
                
			else
				this.strategy = varargin{1};
				this.weights = varargin{2};
			end
        end
		
        % ======================================================================
        %> @brief Merges and orders the candidate samples
        %>
        %> @param candidates candidate samples
        %> @param scores associated priorities
        %> @param state struct
        %> @retval newSamples processed candidates
        %> @retval priorities associated (processed) priorities
        % ======================================================================
		function [this, newSamples, priorities] = selectSamples(this, candidates, scores, state)

            % if weights is empty, give each score the same weight
            if isempty(this.weights)
                this.weights = ones(1, size(scores,2));
            end

            % make sure it's a column vector
            if size(this.weights,1) ~= 1
                this.weights = this.weights';
            end
            
            % mapping of candidate samples to triangulation
            if isfield( state, 'candidatesToTriangles' ) && ...
                    ~isempty( state.candidatesToTriangles )
                % reuse existing mapping
                mapping = state.candidatesToTriangles;
            else
                % create mapping
                T = state.triangulation.getTriangulation();
                mapping = tsearchn([state.samples;state.samplesFailed], T, candidates);
            end
			
			dim_in = size(candidates,2);
			nrTriangles = max(mapping);
			
			newSamples = zeros( nrTriangles, dim_in );
			newScores  = zeros( nrTriangles, size(scores,2) );
			for i=1:nrTriangles
				% find all candidates belonging to simplex i
				idx = find( mapping == i );
				%volumes(mapping)
                % check if simplex has candidate or not
                if size(idx,1) > 0
                    if strcmp( this.strategy, 'middle' )
                        % best point is always the center point
                        % advantage: samples are more spread out (useful for GP based models)
                        % Obviously this only works when the
                        % candidategenerator is the
                        % DelaunayCandidateGenerator
                        newScores(i,:) = mean(scores(idx,:),1);
                        newSamples(i,:) = candidates(idx(1,:), :);
                    else %if strcmp( this.strategy, 'best' )
                        % the best point in the simplex is the one with the greatest score
                        [newScores(i,:) idxTriangle] = max( scores(idx,:), [], 1 );
                        newSamples(i,:) = candidates(idx(idxTriangle(1),:), :);
                    end
                end
			end
		
			% determine the weighted average score
			newScores = sum(bsxfun(@times, newScores, this.weights),2) ./ size(newScores,2);
            
            % get ranking from scores
            [dummy, ranking] = sort(newScores, 1, 'descend');
			
			% only get the n best ones
			nNew = min( state.numNewSamples, size( newSamples, 1 ) );
			ranking = ranking( 1:nNew);
			
			% return the n best candidates
			newSamples = newSamples(ranking,:);
            
            % return their priorities based on the weighted average score
            priorities = newScores(ranking,:);

		end
		
		% returns weighted average
		function [priorities] = processScores( this, scores )
			priorities = sum(bsxfun(@times, scores, this.weights),2) ./ size(scores,2);
		end
		
	end

	
end
