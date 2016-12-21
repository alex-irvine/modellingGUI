%> @file DatasetDesign.m
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
%> @brief Read an initial design from a dataset file
% ======================================================================
classdef DatasetDesign < InitialDesign

  properties
    filename;
    hasOutputs;
	ignoreOutputs;
	simulatorInputDimension;
    simulatorOutputDimension;
  end
  
  methods
	  
    % ======================================================================
    %> @brief Class constructor
    %> @return instance of the class
    % ======================================================================
    function this = DatasetDesign(config)
        % construct the base class
        this = this@InitialDesign(config);

        this.filename = char(config.self.getOption('filename',''));

        if(isempty(this.filename))
            error('No filename specified!');
        end

        this.filename = char(config.context.findFileInPath(this.filename));
        this.hasOutputs = config.self.getBooleanOption('hasOutputs', true);
        this.ignoreOutputs = config.self.getBooleanOption('ignoreOutputs', false);
        this.simulatorInputDimension = config.input.getSimulatorInputDimension();
        this.simulatorOutputDimension = config.output.getSimulatorOutputDimension();
    end
    
    % ======================================================================
    %> @brief load raw data from disk, the SampleManager will take care of dimension checking
    %> and possible input/output filtering
    % ======================================================================
    function [initialsamples, evaluatedsamples] = generate(this)
		
		import ibbt.sumo.sampleevaluators.*;
		import java.util.logging.*
		logger = Logger.getLogger( 'Matlab.DatasetDesign' );

		% load & filter samples
		samples = load(this.filename);

		% outputs are in file, but we want to ignore them
		if this.ignoreOutputs
			
			if size(evaluatedsamples,2) ~= this.simulatorInputDimension + this.simulatorOutputDimension
				msg = sprintf('Dataset does not have %d values (%d inputs and %d outputs) for each sample', this.simulatorInputDimension+this.simulatorOutputDimension, this.simulatorInputDimension, this.simulatorOutputDimension);
				logger.severe(msg);
				error(msg);
			end
			
			initialsamples = samples(:, 1:this.simulatorInputDimension);
			evaluatedsamples = [];
			
		% outputs in file - no need to evaluate	
		elseif this.hasOutputs
			initialsamples = [];
			evaluatedsamples = samples;

			if size(evaluatedsamples,2) ~= this.simulatorInputDimension + this.simulatorOutputDimension
				msg = sprintf('Dataset does not have %d values (%d inputs and %d outputs) for each sample', this.simulatorInputDimension+this.simulatorOutputDimension, this.simulatorInputDimension, this.simulatorOutputDimension);
				logger.severe(msg);
				error(msg);
			end

		% no outputs - evaluate them later
		else
			initialsamples = samples; 
			evaluatedsamples = [];	

			if size(initialsamples,2) ~= this.simulatorInputDimension
				msg = sprintf('Dataset does not have %d values (%d inputs) for each sample', this.simulatorInputDimension, this.simulatorInputDimension);
				logger.severe(msg);
				error(msg);
			end
		end

    end

  end
end
