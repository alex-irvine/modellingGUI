%> @file LOLAVoronoiSampleSelector.m
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
classdef LOLAVoronoiSampleSelector < SampleSelector & CandidateRanker


	
	properties
		LOLA;
		Voronoi;
		logger;
        frequency;
        frequencies;
        frequencySlices;
		inputWeights;
		dataset;
	end
	
	methods (Access = public)
		
		function s = LOLAVoronoiSampleSelector(config)
            s@CandidateRanker(config);
            
			import java.util.logging.*
			s.logger = Logger.getLogger('Matlab.LOLAVoronoiSampleSelector');
            
            % dimensions
            inDim = config.input.getInputDimension();
            outDim = config.output.getOutputDimension();
            
			% get the weights
			s.inputWeights = zeros(1, config.input.getInputDimension());
			for i = 0 : config.input.getInputDimension() - 1
				s.inputWeights(i+1) = config.input.getInputDescription(i).getWeight();
			end

            % check inputs for auto-sampling (not supported by this sample selector)
            frequencyDim = [];
            inputs = config.input.getInputDescriptions();
            for i = 1:length(inputs)
                if inputs(i).isSampledAutomatically()
                    frequencyDim = [frequencyDim i];
                end
            end
            s.frequency = frequencyDim;
            s.frequencySlices = str2num(char(config.self.getOption('frequencySlices', '[]')));
            s.frequencies = config.self.getIntOption('frequencies', 0);
            
			% get the input weights
			
            % modify the dimensions based on the frequency variable
            if isempty(s.frequency)
                % do nothing
			else
				
				% fix the input weights
				s.inputWeights(s.frequency) = [];
                
                % make sure frequencies is specified
                if s.frequencies == 0
                    msg = 'If there is a auto-sampled input, the number of auto-sampled points must be specified with a ''frequencies'' option for LOLA-Voronoi.';
                    s.logger.severe(msg);
                    error(msg);
                end

                % frequency dim is not sampled
                inDim = inDim - length(s.frequency);

                % if no frequency slices are defined, use them all
                if isempty(s.frequencySlices)
                    s.frequencySlices = 1 : s.frequencies;
                end

                % for each frequency slice, we generate a new output dim
                outDim  = outDim * length(s.frequencySlices);

            end
            
			% get stuff
			options = struct;
			options.neighbourhoodSize = config.self.getIntOption('neighbourhoodSize', 2);
			options.gradientMethod = char(config.self.getOption('gradientMethod', 'direct'));
			options.debug = config.self.getBooleanOption('debug', false);
			options.combineOutputs = char(config.self.getOption('combineOutputs', 'max'));
            options.inDim = inDim;
			options.outDim = outDim;
			
            % create sample rankers
			s.LOLA = LOLASampleRanker(config, options);
			s.Voronoi = VoronoiSampleRanker(config, inDim, outDim);
			
			
			% see if a dataset was specified - in that case, we only select
			% samples on this dataset directly and integrate it into the
			% algorithm
			datasetName = char(config.self.getOption('dataset', ''));
			if length(datasetName) > 0
				try
					
					% get dataset
					s.dataset = load(datasetName);
					
					% extract the inputs only
					s.dataset = s.dataset(:, 1:inDim);
					
					s.logger.info('LOLA-Voronoi dataset detected and loaded, selecting samples directly from dataset...');
				catch err
					s.logger.warning(sprintf('Failed to load LOLA-Voronoi dataset ''%s''', datasetName));
					s.dataset = [];
				end
			else
				s.dataset = [];
			end
		end
		
		[this, newSamples, priorities] = selectSamples(this, state);
		[this, scores] = scoreCandidates(this, candidates, state);
		
	end
	
end
