%> @file expectedImprovement.m
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
%> @brief Calculates the expected improvement statistical infill criterion
% ======================================================================
classdef expectedImprovement < CandidateRanker

    properties
		outputValue = [];
        
		multiobjective = false;
		paretoFront = [];
		nValues;
    end
    
	methods (Access = public)
		
		function this = expectedImprovement(varargin)
			this = this@CandidateRanker(varargin{:});
            
            if nargin == 1
				config = varargin{1};

				this.outputValue = str2num( config.self.getOption('outputValue', '[]') );
				this.multiobjective = config.self.getBooleanOption('multiobjective', false);
			elseif nargin >= 3
				this.outputValue = varargin{3};
				this.multiobjective = varargin{4};
			else
				error('Invalid number of parameters (1 or 3).');
			end
        end

        function [this] = initNewSamples(this, state)
			
			% multi objective
			if this.multiobjective
				
				% pareto front is empty, or new samples have arrived
				if isempty(this.paretoFront) || (this.nValues ~= size(state.samples,1))
					this.nValues = size(state.samples,1);
					[idx idxdom] = nonDominatedSort(state.values);
                    
                    % find intermediate Pareto front
					this.paretoFront = sortrows(state.values(idxdom == 0,:));

                    if 1
                        % code of book
                        [a,b]=sort(state.values(:,1));
                        PX(1,:)=state.samples(b(1),:);
                        Py1(1)=state.values(b(1),1);
                        Py2(1)=state.values(b(1),2);
                        Pnum=1;
                        for i=2:length(state.values(:,1))
                            if state.values(b(i),2)<=Py2(end)
                                Pnum=Pnum+1;
                                PX(Pnum,:)=state.samples(b(i),:);
                                Py1(Pnum)=state.values(b(i),1);
                                Py2(Pnum)=state.values(b(i),2);
                            end
                        end

                        pf = this.paretoFront
                        %pfsamples = state.samples(idxdom == 0,:)
                        pf2 = [Py1' Py2']
                    end
				end
				
			end
        end
        
		function [ei dei] = scoreCandidates(this, points, state)
            
            %% Multiobjective
			% Keane (2006), Forrester book
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
                
                %> @todo replace repmat's by ones/zeros statements
				zero = zeros(nrPoints, 1);
				one = ones(nrPoints, 1);

				%% Precalculate pdf's
				z1 = ( repmat(this.paretoFront(:,1)', nrPoints, 1) - repmat( y(:,1), 1, nrPareto) ) ./ repmat( mse(:,1), 1, nrPareto);
				phi1 = normcdfWrapper(z1);
                psi1 = normpdfWrapper(z1);

				z2 = ( repmat(this.paretoFront(:,2)', nrPoints, 1) - repmat( y(:,2), 1, nrPareto) ) ./ repmat( mse(:,2), 1, nrPareto);
				phi2 = normcdfWrapper(z2);
                psi2 = normpdfWrapper(z2);
                
                %z = ( repmat(reshape(this.paretoFront, 1, nrPareto, 2), nrPoints, 1) - repmat( y, 1, nrPareto) ) ./ repmat( mse, 1, nrPareto);
                %phi = normcdfWrapper(z);
                
                %phi = [phi1 phi2];
                
                % and y .* phi & s .* phi
                yphi1 = repmat( y(:,1), 1, nrPareto) .* phi1;
                spsi1 = repmat( mse(:,1), 1, nrPareto) .* psi1;
                
                yphi2 = repmat( y(:,2), 1, nrPareto) .* phi2;
                spsi2 = repmat( mse(:,2), 1, nrPareto) .* psi2;
                
				%% Calculate Pi_k
				% chance of improvement over k pareto points
				%{
                if isempty( this.levelsOfImprovement )
					k = 0; % default to 0
				else
					k = this.levelsOfImprovement;
				end
                %}
                
				Pi = phi1(:,1);
                Y1 = yphi1(:,1) - spsi1(:,1);
                Y2 = yphi2(:,end) - spsi2(:,end);
                for i=1:(nrPareto-1)
                    % dominating
                    Pi = Pi + (phi1(:,i+1) - phi1(:,i)) .* phi2(:,i);
                    
                    Y1 = Y1 + ( (yphi1(:,i+1) - spsi1(:,i+1)) - (yphi1(:,i) - spsi1(:,i)) ) .* phi2(:,i);
                    
                    j = nrPareto - i + 1;
                    Y2 = Y2 + ( (yphi2(:,j-1) - spsi2(:,j-1)) - (yphi2(:,j) - spsi2(:,j)) ) .* phi1(:,j);
                end
                Pi = Pi + (1 - phi1(:,end)) .* phi2(:,end);
                Y1 = Y1 + (yphi1(:,end) + spsi1(:,end)) .* phi2(:,end);
                Y2 = Y2 + (yphi2(:,1) + spsi2(:,1)) .* phi1(:,1);
                
                Y1 = Y1 ./ Pi;
                Y2 = Y2 ./ Pi;
                
                %% Euclidean distance to pareto points
                dist = buildDistanceMatrix([Y1 Y2], this.paretoFront, true);
                [mindist idx] = min( dist, [], 2 );
                
                ei = zeros( nrPoints, 1 );
                idx = Pi > 0;
                ei(idx,:) = Pi(idx,:) .* mindist(idx,:);
                
                %ei = log10( ei + eps );
                %a = 5

			%% singleobjective:
			else
                model = state.lastModels{1}{1};

                [y mse] = evaluateInModelSpace( model, points );
                mse = sqrt( abs( mse ) );

                if isempty( this.outputValue )
                    T = min( getValues(model) ); % fmin
                else
                    T = this.outputValue;
                end

                if mse == 0
                    ei = zeros( size(points,1), 1 );
                else
                    z  = (T-y)./mse;
                    ei = (T-y) .* normcdfWrapper(z) + mse .* normpdfWrapper(z);
                end

                % derivatives
                if nargout > 1
                    % TODO: not ok yet
                    idx = ones(1,size(points,2));
                    [dy dmse] = evaluateDerivativeInModelSpace( model, points, 1 );
                    dmse = dmse ./ (2.*mse(:,idx)); % take sqrt of derivative

                    dz = -dy .* mse(:,idx) - (T - y(:,idx)) .* dmse;
                    dz = dz ./ mse(:,idx).^2;
                    %dz = -dy + ( (y(:,idx) - T) .* dmse ) ./ mse(:,idx).^2;

                    %
                    cdfz = normcdfWrapper(z);
                    pdfz = normpdfWrapper(z);

                    dei = -dy .* cdfz(:,idx);
                    dei = dei + (T-y(:,idx)) .* pdfz(:,idx) .* dz;
                    dei = dei + dmse .* pdfz(:,idx);
                    dei = dei - mse(:,idx) .* z(:,idx) .* pdfz(:,idx);
                end % derivatives
            end % multiobjective
        end % scoreCandidates
    end
end
