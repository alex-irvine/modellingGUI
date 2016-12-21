%> @file probabilityImprovement.m
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
%> @brief Calculates the probability of improvement for a point
% ======================================================================
classdef probabilityImprovement < CandidateRanker

	properties        
		multiobjective = false;
        levelsOfImprovement = 0;
		paretoFront = [];
		nValues;
	end
	
	methods (Access = public)
		
		function this = probabilityImprovement(varargin)
			this = this@CandidateRanker(varargin{:});
			
			if nargin == 1
				config = varargin{1};

				this.multiobjective = config.self.getBooleanOption('multiobjective', false);
                
                if this.multiobjective
                    this.levelsOfImprovement = config.self.getIntOption('levelsOfImprovement');
                end
			elseif nargin >= 4
				this.multiobjective = varargin{3};
                
                if this.multiobjective
                    this.levelsOfImprovement = varargin{4};
                end
			else
				error('Invalid number of parameters (1 or 4).');
			end
		end
		
		function [this] = initNewSamples(this, state)
			
			% multi objective
			if this.multiobjective
				
				% pareto front is empty, or new samples have arrived
				if isempty(this.paretoFront) || (this.nValues ~= size(state.samples,1))
					this.nValues = size(state.samples,1);
					[idx idxdom] = nonDominatedSort(state.values);
					this.paretoFront = sortrows(state.values(idxdom == 0,:));
				end
				
			end
		end

		function [Pi dPi] = scoreCandidates(this, points, state)

			%% Multiobjective
			% Keane (2006), Hawe (2008)
			if this.multiobjective

				% TODO: only supports 2 outputs
                
				if length( state.lastModels ) == 2
					model1 = state.lastModels{1}{1}; % output 1
					model2 = state.lastModels{2}{1}; % output 2

					[y1 mse1] = model1.evaluateInModelSpace(points);
					[y2 mse2] = model2.evaluateInModelSpace(points);

					y = [y1 y2];
					mse = [mse1 mse2];
				else
					model = state.lastModels{1}{1};
					[y mse] = model.evaluateInModelSpace(points);

					assert( size( y, 2 ) == 2 ); % need 2 outputs
				end

				nrPareto = size( this.paretoFront, 1 ); % non-dominated, points are in increasing order
				nrPoints = size( points, 1 );

				zero = zeros(nrPoints, 1);
				one = ones(nrPoints, 1);

				%% Precalculate pdf's
				z1 = ( repmat(this.paretoFront(:,1)', nrPoints, 1) - repmat( y(:,1), 1, nrPareto) ) ./ repmat( mse(:,1), 1, nrPareto);
				phi1 = [zero normcdfWrapper(z1) one];

				z2 = ( repmat(this.paretoFront(:,2)', nrPoints, 1) - repmat( y(:,2), 1, nrPareto) ) ./ repmat( mse(:,2), 1, nrPareto);
				phi2 = [one normcdfWrapper(z2) zero];

				%% Calculate Pi_k
				% chance of improvement over k pareto points
				if isempty( this.levelsOfImprovement )
					k = 0; % default to 0
				else
					k = min( this.levelsOfImprovement, nrPareto );
				end
				Pi = 0;
				for j=k:nrPareto
					for i=1:(nrPareto-j+1)
						Pi = Pi + ((phi1(:,i+1)-phi1(:,i)) .* (phi2(:,j+i)-phi2(:,j+i+1)));
					end
				end

			%% singleobjective:
			else
				model = state.lastModels{1}{1};

				[y mse] = evaluateInModelSpace( model, points );
                mse = sqrt( abs( mse ) );
				values = getValues(model);
				fmin = min( values );

                z = (fmin - y) ./ mse;
                Pi = normcdfWrapper(z);
                
                % derivatives
                if nargout > 1
                    idx = ones(1,size(points,2));
                    [dy dmse] = evaluateDerivativeInModelSpace( model, points, 1 );
            
                    p1 = normpdfWrapper(z);
                    dz = -dy .* mse(:,idx) - (T - y(:,idx)) .* dmse;
                    %dz = dz ./ mse(:,idx).^2;
                    %dz = -dy + ( (y(:,idx) - T) .* dmse ) ./ mse(:,idx).^2;

                    dPi = p1(:,idx) .* dz;
                end
			end
        end
    end
end
