%> @file OptimizeCriterion.m
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
%> @brief This sample selector selects one or more samples that optimizes a certain candidateRanker
%>
%> A candidateRanker is also known as a sample infill criterion, figure of merit, (utility) function, etc.
%> Any CandidateRanker can be used as a criterion. If more than one CandidateRanker is defined they will
%> be used as fallback criterions
% ======================================================================
classdef OptimizeCriterion < SampleSelector

	properties ( Access = 'private' )
		funcOptimizer = [];
		logger = [];
		candidateRankers;
		candidateGenerator = [];
		randomSamples;
        debug; % show debug plots
        debugSave; % save debug plots
        debugPlot = []; % internal handle to plot
        debugParetoPlot = [];
        
        constraints = []; % locally defined constraints (for this component)
	end

	methods( Access = 'public')

		% CTor
		function this = OptimizeCriterion(config)

			import java.util.logging.*
			this.logger = Logger.getLogger('Matlab.OptimizeCriterion');
			
			% random samples if the criteria fail, or not?
			this.randomSamples = config.self.getBooleanOption('randomSamples', true);

			% first get the candidate generator
			subs = config.self.selectNodes('CandidateGenerator');
			
			% need one candidate generator
			if subs.size() > 1
				msg = sprintf('You need to specify one or no CandidateGenerator objects.');
				this.logger.severe(msg);
				error(msg);
			end

			% instantiate the candidate generator
			if subs.size() == 1
				sub = subs.get(0);
				this.candidateGenerator = instantiateClassOrFunction(sub, config, 'CandidateGenerator');
				this.logger.info(sprintf('Constructed candidate generator %s', this.candidateGenerator.getType()));
            end
            
            % instantiate constraints (if any)
            subs = config.self.selectNodes('Constraint');
            this.constraints = cell(1,subs.size());
            for i=0:subs.size()-1
                this.constraints{i+1} = instantiate(subs.get(i), config);
            end
            
			% instantiate optimization method
			optimizer = config.self.selectSingleNode('Optimizer');
			if isempty( optimizer )
				msg = sprintf('You must specify the optimization method for the OptimizeCriterion sample selector.');
				this.logger.severe(msg);
				error(msg);
			end

			this.funcOptimizer = instantiate(optimizer,  config);
    
            %multiobjective config.self.getBooleanOption( 'multiobjective', false ), ...

			% find the candidate rankers used for optimizing
			subs = config.self.selectNodes('CandidateRanker');

			% need at least one candidate ranker
			if subs.size() == 0
				msg = sprintf('You need to specify at least one candidateRanker for scoring the candidates.');
				this.logger.severe(msg);
				error(msg);
			end

			% instantiate all subobjects as defined in the config file
			this.candidateRankers = cell(subs.size(), 1);
			for k=1:subs.size()

				% first instantiate the ranker
				sub = subs.get(k-1);
				obj = instantiateClassOrFunction(sub, config, 'CandidateRanker');
				this.candidateRankers{k} = obj;

				% all done
				this.logger.info(['Registered candidate ranker of type ' obj.getType()]);
			end

			% debug
			this.debug = config.self.getBooleanOption('debug', false);
            this.debugSave = config.self.getBooleanOption('debugSave', false);
		end

		% selectSamples (SUMO)
		% Description:
		%     Optimises the infill sampling criterion
		%     Filter the samples and return them
		[this, newsamples, priorities] = selectSamples(this, state);
	end
end
