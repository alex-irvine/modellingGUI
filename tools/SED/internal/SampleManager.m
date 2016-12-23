%> @brief Dummy SampleManager class used for constraints.
%> Replaces the real SampleManager from SUMO.
classdef SampleManager
	
	properties
		inputMinima;
		inputMaxima;
	end
	
	methods
		
		%> @brief Constructor.
		function [this] = SampleManager(config)
			
			% get the simulator-to-model space transformation
			this.inputMinima = config.input.getMinima();
			this.inputMaxima = config.input.getMaxima();
			
		end
		
		%> @brief Convert the samples to simulator space.
		function [this, samplePoints] = prepareForEvaluation(this, filteredSamples, priorities)
			samples = bsxfun(@rdivide, bsxfun(@minus, filteredSamples, this.inputMinima), (this.inputMaxima - this.inputMinima)) .* 2 - 1;
			samplePoints = SamplePoint.empty(0,1);
			for i = 1 : size(samples,1)
				samplePoints(i) = SamplePoint(samples(i,:));
			end
		end
		
	end
	
end

