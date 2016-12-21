%> @brief Output configuration class.
classdef OutputConfig
	
	properties
		outputDescriptions = OutputDescription.empty(1,0);
	end
	
	methods
		
		%> @brief The constructor.
		function config = OutputConfig(prob)

			% right initializer
			if isstruct(prob)
				config = config.parseStruct(prob);
			else
				config = config.parseXML(prob);
			end
		end
		
		%> @brief Parse the struct.
		function config = parseStruct(config, prob)

			% logger
			logger = Logger.getLogger('OutputConfig');
			
			% check if output was specified
			if ~isfield(prob, 'outputs')
				return;
			end
			if ~isfield(prob.outputs, 'nOutputs')
				return;
			end
			nOutputs = prob.outputs.nOutputs;
			
			% construct the input descriptions
			for i = 1 : nOutputs
				config.outputDescriptions(i) = OutputDescription(prob.outputs, i);
			end
		end
		
		%> @brief Parse XML.
		function config = parseXML(config, prob)
			
			% get the input data
			outputParameters = prob.selectNodes('Outputs');
			if outputParameters.size() ~= 1
				return;
			end
			
			outputParameters = NodeConfig(outputParameters.get(0));
			outputs = outputParameters.selectNodes('Output');
			if outputs.size() == 0
				return;
			end
			
			% construct the input descriptions
			for i = 0 : outputs.size() - 1
				output = NodeConfig(outputs.get(i));
				config.outputDescriptions(i+1) = OutputDescription(output);
			end
		end
		
		%> @brief Returns the output dimension.
		function outDim = getOutputDimension(this)
			outDim = length(this.outputDescriptions);
		end
		
		%> @brief Return the ith output description.
		function desc = getOutputDescription(this, i)
			desc = this.outputDescriptions(i+1);
		end
	end
	
end

