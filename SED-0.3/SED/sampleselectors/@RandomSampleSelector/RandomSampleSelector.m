%> @file RandomSampleSelector.m
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
%>	Chooses datapoints in random locations.
% ======================================================================
classdef RandomSampleSelector < SampleSelector & CandidateRanker


    
    properties ( Access = 'private' )
        dimension = [];
        domain = [];
    end
    
    methods( Access = 'public')
        
        % CTor
        function this = RandomSampleSelector(config)
            this@CandidateRanker(config);
            
            domain = str2num(char(config.self.getOption('domain', '[-1 1]')));
            
            % check inputs for auto-sampling (not supported by this sample selector)
            inputs = config.input.getInputDescriptions();
            for i = 1:length(inputs)
                if inputs(i).isSampledAutomatically()
                    msg = sprintf('This sample selector does not support auto-sampled inputs.');
                    logger.severe(msg);
                    error(msg);
                end
            end
            
            this.dimension = config.input.getInputDimension();
            this.domain = domain;
        end
        
        
        function [this, newsamples, priorities] = selectSamples(this, state)
            
            % number of samples to select
            number = state.numNewSamples;
            
            % range
            range = this.domain(2) - this.domain(1);
            
            % minimum value
            min = this.domain(1);
            
            % create new samples
            newsamples = min + rand( number, this.dimension ) * range;
            
            % no priorities
            priorities = zeros(size(newsamples,1), 1);
        end
        
        function [this, scores] = scoreCandidates(this, candidates, state)
            scores = rand(size(candidates,1),1);
        end
        
    end
end
