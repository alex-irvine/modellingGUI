%> @brief This class contains all the data for one particular input dimension.
classdef InputDescription
	
	properties
		minimum;
		maximum;
		name;
		autoSampling;
		weight;
	end
	
	methods
		
		%> @brief The constructor. Extracts everything from a NodeConfig.
		function this = InputDescription(config, i)
			
			% i doesn't exist, it's an xml config
			if ~exist('i', 'var')
				this.name = config.getAttrValue('name');
				this.minimum = config.getDoubleAttrValue('min', -1);
				if this.minimum == -1
					this.minimum = config.getDoubleAttrValue('minimum', -1);
				end
				this.maximum = config.getDoubleAttrValue('max', 1);
				if this.maximum == 1
					this.maximum = config.getDoubleAttrValue('maximum', 1);
				end
				this.autoSampling = config.getBooleanAttrValue('autoSampling', false);
				this.weight = config.getDoubleAttrValue('weight', 1.0);
			else
				this.name = sprintf('x%d', i);
				if isfield(config, 'minima')
					this.minimum = config.minima(i);
				else
					this.minimum = -1;
				end
				if isfield(config, 'maxima')
					this.maximum = config.maxima(i);
				else
					this.maximum = 1;
				end
				if isfield(config, 'autoSampling') && config.autoSampling == i
					this.autoSampling = true;
				else
					this.autoSampling = false;
				end
				if isfield(config, 'weights')
					this.weight = config.weights(i);
				else
					this.weight = 1.0;
				end
			end
		end
		
		
		%> @brief Get the name of the input.
		function name = getName(this)
			name = this.name;
		end
		
		%> @brief Check whether this input is sampled automatically.
		function auto = isSampledAutomatically(this)
			auto = this.autoSampling;
		end
		
		%> @brief Get the minimum of the input.
		function min = getMinimum(this)
			min = this.minimum;
		end
		
		%> @brief Get the maximum of the input.
		function max = getMaximum(this)
			max = this.maximum;
		end
		
		%> @brief Get the weight of this input.
		function weight = getWeight(this)
			weight = this.weight;
		end
		
		%> @brief Does this description have a weight?
		function ans = hasWeight(this)
			ans = abs(this.weight - 1.0) > 0.00001;
		end
	end
	
end

