%> @file gProbabilityImprovement.m
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
%> @brief generalized probability of improvement
%>
%> Calculates the probability that the function value of samples lies between
%> bounds of interest [T1, T2]
% ======================================================================
classdef gProbabilityImprovement < CandidateRanker
    
	properties
		outputRange = [];
        
        percentage = false;
        regression = false;
	end
	
	methods (Access = public)
		
		function this = gProbabilityImprovement(varargin)
			this = this@CandidateRanker(varargin{:});
			
			if nargin == 1
				config = varargin{1};

				this.outputRange = str2num(char(config.self.getOption('outputRange', '[-Inf +Inf]')));
                this.regression = config.self.getBooleanOption('regression', false);
                this.percentage = config.self.getBooleanOption('percentage', false);
			elseif nargin >= 5
				this.outputRange = varargin{3};
                this.regression = varargin{4};
                this.percentage = varargin{5};
			else
				error('Invalid number of parameters (1 or 3).');
            end
            
            if size( this.outputRange, 2 ) ~= 2
				error('outputRange should be an 1x2 vector.');                
            end
		end
		
		function [this] = initNewSamples(this, state)
		end

		function [Pi dPi] = scoreCandidates(this, points, state)

			% probabilityImprovement (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			% Revision: $Rev: 6439 $
			%
			% Description:
			%     Calculates the probability of improvement for a point


			%% singleobjective:
            model = state.lastModels{1}{1};

            [y mse] = evaluateInModelSpace( model, points );
            mse = sqrt( abs( mse ) );
            values = getValues(model);
            fmin = min( values );
            
            a = this.outputRange(1,1); % lower
            b = this.outputRange(1,2); % upper
            
            if this.percentage
                a = a.*fmin;
                b = b.*fmin;
            end
            
            % add noise factor
            if this.regression
                model = model.getNestedModel();
                lambda = 10.^model.getLambda();
                sigma2 = model.getProcessVariance();
                tau2 = sigma2 .* lambda; % weight [0, 1] = sigma2_error
                tau = sqrt(tau2); % = sigma_error

                b = b + 2.*tau;
            end
            
            % other possibilities
            %prc = mean(values); mean
            %prc = prctile( values, 25 ); % 25% percentile = MEDIAN
            %prc = prctile( values, 50 ); % 50% percentile = MEDIAN
            %prc = prctile( values, 75 ); % 75% percentile
            %T = fmin + prc.*this.outputRange; % lower

            %T = prctile( values, this.outputRange );

            z1 = (a - y) ./ mse;
            z2 = (b - y) ./ mse;
            Pi = normcdfWrapper(z2) - normcdfWrapper(z1);

            % TODO: derivatives
            if nargout > 1
                idx = ones(1,size(points,2));
                [dy dmse] = evaluateDerivativeInModelSpace( model, points, 1 );
                dmse = dmse ./ (2.*mse(:,idx)); % take sqrt of derivative
                
                p1 = normpdfWrapper(z1);
                p2 = normpdfWrapper(z2);
                
                dz1 = -dy .* mse(:,idx) - (a - y(:,idx)) .* dmse;
                dz1 = dz1 ./ mse(:,idx).^2;
                
                dz2 = -dy .* mse(:,idx) - (b - y(:,idx)) .* dmse;
                dz2 = dz2 ./ mse(:,idx).^2;
                
                dPi = p2(:,idx) .* dz2 - p1(:,idx) .* dz1;
			end
        end
    end
end
