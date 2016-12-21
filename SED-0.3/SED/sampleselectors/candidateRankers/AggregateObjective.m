%> @file AggregateObjective.m
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
%> TODO
% ======================================================================
classdef AggregateObjective < CandidateRanker


	properties
		candidateRankers;
		weights = [];
		logger;
	end
	
	methods (Access = public)
		
		function s = AggregateObjective(varargin)
			
			import java.util.logging.*;
			import ibbt.sumo.config.*;

			% superclass
			s = s@CandidateRanker(varargin{:});
			s.logger = Logger.getLogger('Matlab.AggregateObjective');
			s.logger.info('Configuring Aggregate Objective candidate ranker...');
			
            if nargin == 1
                config = varargin{1};
			
                % read xml-data from config file
                subs = config.self.selectNodes('CandidateRanker');

                % need at least one candidate ranker
                if subs.size() < 2
                    msg = sprintf('You need to specify at least two candidate rankers for scoring the candidates.');
                    s.logger.severe(msg);
                    error(msg);
                end

                % instantiate all subobjects as defined in the config file
                s.candidateRankers = cell(subs.size(), 1);
                for k=1:subs.size()

                    % first instantiate the ranker
                    sub = subs.get(k-1);
                    obj = instantiateClassOrFunction(sub, config, 'CandidateRanker');
                    s.candidateRankers{k} = obj;

                    % get the weight for this objective
                    s.weights(k) = str2double(sub.valueOf('@weight'));

                    % default is 1
                    if isnan(s.weights(k))
                        s.weights(k) = 1.0;
                    end

                    % all done
                    s.logger.info(sprintf('Registered candidate ranker of type %s with weight %d', obj.getType(), s.weights(k)));
                end
            elseif nargin >= 3
                nRankers = nargin - 2;
                s.candidateRankers = cell(1, nRankers);
                s.weights = ones(1, nRankers);
                
                for i=1:nRankers
                   s.candidateRankers{i} = varargin{i+2};
                   s.weights(i) = 1;
                end
            else
				error('Invalid number of parameters (1 or > 2).');
            end
		end
		
		
		function [finalScores dfinalScores] = scoreCandidates(s, points, state)

			% modelDifference (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			% Revision: $Rev: 5887 $
			%
			% Description:
			%   Calculates the difference between the last nLastModels models on the
			%   given points
			
			% score on all the sub-objectives
			finalScores = zeros(size(points,1), 1);
            
            if nargout == 1
                for i = 1 : length(s.candidateRankers)
                    scores = s.candidateRankers{i}.score(points, state);
                    finalScores = finalScores + scores .* s.weights(i);
                end
            else
                dfinalScores = zeros(size(points) );
                
                for i = 1 : length(s.candidateRankers)
                    [scores dscores] = s.candidateRankers{i}.score(points, state);
                    
                    finalScores = finalScores + scores .* s.weights(i);
                    dfinalScores = dfinalScores + dscores .* s.weights(i);
                end
            end
		end
		
	end
	
end
