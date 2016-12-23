%> @brief Dummy sample point replacement class for the original SUMO java class.
classdef SamplePoint
	
	properties
		sample;
	end
	
	methods
		
		%> @brief Convert one sample to this object.
		function [this] = SamplePoint(sample)
			this.sample = sample;
		end
			
		
		%> @brief Return the input dimension of this sample point.
		function inDim = getInputDimension(this)
			inDim = length(this.sample);
		end
		
		%> @brief Return the actual sample again.
		function sample = getInputParameters(this)
			sample = this.sample';
		end
		
		%> @brief Return a random id.
		function id = getId(this)
			id = floor(rand(1,1) * bitmax);
		end
		
	end
	
end

