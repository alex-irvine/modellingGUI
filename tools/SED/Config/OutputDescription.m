%> @brief This class contains all the data for one particular output dimension.
classdef OutputDescription
	
	properties
		name;
	end
	
	methods
		
		%> @brief The constructor. Extracts everything from a NodeConfig.
		function this = OutputDescription(config, i)
			if ~exist('i', 'var')
				this.name = config.getAttrValue('name');
			else
				if isfield(config, 'names')
					this.name = config.names{i};
				else
					this.name = sprintf('out%d', i);
				end
			end
		end
		
		
		%> @brief Get the name of the input.
		function name = getName(this)
			name = this.name;
		end
		
	end
	
end

