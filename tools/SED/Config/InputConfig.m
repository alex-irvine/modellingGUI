%> @brief Input configuration class.
classdef InputConfig
	
	properties
		inputDescriptions = InputDescription.empty(1,0);
		constraints;
		minima;
		maxima;
	end
	
	methods
		
		%> @brief The constructor.
		function config = InputConfig(prob)
			
			% logger
			logger = Logger.getLogger('InputConfig');
			
			% right initializer
			if isstruct(prob)
				config = config.parseStruct(prob);
			else
				config = config.parseXML(prob);
			end
		end
		
		%> @brief Parse struct input.
		function config = parseStruct(config, prob)
			logger = Logger.getLogger('InputConfig');
			
			% check if it exists
			if ~isfield(prob, 'inputs')
				logger.severe('You must specify your inputs.');
			end
			if ~isfield(prob.inputs, 'nInputs')
				logger.severe('You must specify the number of inputs in config.inputs.nInputs.');
			end
			
			% get the input data
			nInputs = prob.inputs.nInputs;
			for i = 1 : nInputs
				config.inputDescriptions(i) = InputDescription(prob.inputs, i);
				config.minima(i) = config.inputDescriptions(i).getMinimum();
				config.maxima(i) = config.inputDescriptions(i).getMaximum();
			end
		end
		
		%> @brief Parse XML input.
		function config = parseXML(config, prob)
			
			% get the input data
			inputParameters = prob.selectNodes('Inputs');
			if inputParameters.size() ~= 1
				logger.severe('No inputs specified for problem!');
			end
			inputParameters = NodeConfig(inputParameters.get(0));
			inputs = inputParameters.selectNodes('Input');
			if inputs.size() == 0
				logger.severe('There must be at least one input!');
			end
			
			% construct the input descriptions
			config.minima = zeros(1,inputs.size());
			config.maxima = zeros(1,inputs.size());
			for i = 0 : inputs.size() - 1
				input = NodeConfig(inputs.get(i));
				config.inputDescriptions(i+1) = InputDescription(input);
				config.minima(i+1) = config.inputDescriptions(i+1).getMinimum();
				config.maxima(i+1) = config.inputDescriptions(i+1).getMaximum();
			end
			
			% get the constraints
			config.constraints = inputParameters.selectNodes('Constraint');
		end
		
		%> @brief Returns the input dimension.
		function inDim = getInputDimension(this)
			inDim = length(this.inputDescriptions);
		end
		
		%> @brief Return the i-th input name.
		function name = getInputName(this, i)
			name = this.inputDescriptions(i+1).getName();
		end
		
		%> @brief Return all the input descriptions
		function descs = getInputDescriptions(this)
			descs = this.inputDescriptions;
		end
		
		%> @brief Return a particular input description.
		function desc = getInputDescription(this, i)
			desc = this.inputDescriptions(i+1);
		end
		
		%> @brief Return all the constraints for this problem.
		function constraints = getConstraints(this)
			constraints = this.constraints;
		end
		
		%> @brief Return the minima for the inputs.
		function min = getMinima(this)
			min = this.minima;
		end
		
		%> @brief Return the maxima for the inputs.
		function max = getMaxima(this)
			max = this.maxima;
		end
		
		%> @brief Get the weights.
		function weights = getWeights(this)
			weights = zeros(1,length(this.inputDescriptions));
			for i = 1 : length(this.inputDescriptions)
				weights(i) = this.inputDescriptions(i).getWeight();
			end
		end
		
	end
	
end

