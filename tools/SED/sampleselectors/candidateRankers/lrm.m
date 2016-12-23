%> @file lrm.m
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
%> @brief The LRM candidate ranker
%>
%> Compares the current best model with a 
%> linear interpolation (based on a Delaunay triangulation). The 
%> candidates samples are ranked based on the deviation of the model and
%> the interpolation at their location. If there are several outputs, 
%> the average deviation of these outputs is taken.
% ======================================================================
classdef lrm < CandidateRanker

    methods (Access = public)
		
        % ======================================================================
        %> @brief Class constructor
        %>
        %> @return instance of the class
        % ======================================================================
		function this = lrm(config)
			this = this@CandidateRanker(config);
        end

        % ======================================================================
        %> @brief Scores candidate samples
        %>
        %> @param points matrix of candidate samples to score
        %> @param state struct
        %> @retval d vector of scores
        % ======================================================================
		function d = scoreCandidates(this, points, state) 
        
            % getting previously selected samples + their values
            samples = state.samples;
            values = state.values;
            
            % get latest (and best) model
            mod = state.lastModels{1}{1};

            % get the triangulation
            to = state.triangulation;
            T = to.getTriangulation();

            % take into account failed samples
            [failedSamples failedIdx] = to.getFailedPoints();
            failedValues = mod.evaluateInModelSpace( failedSamples );

            % NOTE: failedSamples/Values from triangulation should be the same as the state ?
            % assert( state.failedSamples == failedSamples )
            % assert( state.failedValues == failedValues )
            
            samples = [samples ; failedSamples];
            values = [values ; failedValues];

            % evaluate candidate samples with model (to be used later when
            % comparing to linear interpolation
            y = evaluateInModelSpace(mod, points );

            % number of dimensions
            inDim =  size(state.samples,2);
            outDim = size(state.values,2);

            % for every convex hull (line, triangle, tetraeder, ...),
            % calculate the hyperplane
            coeffList = cell(size(T,1));
            for i=1:size(T,1)
                % get the points of the hull
                p = samples(T(i,:), :);

                % get the values corresponding to the points of the hull
                v = values(T(i,:), :);

                % Calculate hyperplane coefficients
                coeff = zeros( inDim+2, outDim );
                for j=1:outDim

                    % setup matrix for this output
                    A = [p v(:,j) ones( size(p,1), 1)];
                    N = size(A,2);

                    % Calculate hyperplane coefficients for output k
                    sign_coeff = 1;
                    for k=1:N
                        idx = [1:k-1 k+1:N];
                        coeff(k,j) = sign_coeff .* det(A(:,idx));
                        sign_coeff = -sign_coeff;
                    end
                end
                
                % Store all coefficients of the hyperplane they define)
                coeffList{i} = coeff;
            end

            % calculate distance of candidate samples (=points to the
            % hyperplanes):

            % mapping of candidate samples to triangulation
            if isfield( state, 'candidatesToTriangles' ) && ...
                    ~isempty( state.candidatesToTriangles )
                % reuse existing mapping
                mapping = state.candidatesToTriangles;
            else
                % create mapping
                mapping = tsearchn([state.samples;state.samplesFailed], T, points);
            end

            % candidate samples and their output(s) predicted by the model
            fpoints = [points y];
            % vector with the LRM score for each candidate sample
            d=zeros(size(fpoints,1),1);

            % for every candidate sample do
            for i=1:size(fpoints,1)
                % get the right coeff, mapIndex contains the index of the
                % corresponding tesselation
                mapIndex = mapping(i);
                coeff = coeffList{mapIndex};

                % distance of the evaluated centroid to the plane
                d_temp=0;
                for k=1:outDim
                    % get coefficients and evaluated values for output k
                    coeff_mat = coeff(:,k)';
                    cpoints = fpoints(i,:);

                    % Distance point-plane formula
                    d_temp = d_temp + abs( sum(coeff_mat(:,1:N-1) .* cpoints, 2) + coeff_mat(:,N)) ./ sqrt(sum(coeff(1:N-1) .^ 2));
                end
                d(i) = d_temp/outDim;
            end % for
        end % scoreCandidates 
    end % methods
end % classdef

