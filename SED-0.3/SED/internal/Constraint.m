%> @brief A constraint class. Parses the constraint function and evaluates it.
classdef Constraint
	
	properties
		func;
	end
	
	methods
		
		%> @brief Constructor.
		function this = Constraint(config)
			try
				this.func = str2func(config.getOption('file'));
			catch ME
				error('You need to specify a ''file'' option for each constraint, pointing to a function file on the Matlab path.');
			end
		end
		
		%> @brief Evaluate the constraint.
		function out = evaluate(this, samples)
			out = this.func(samples);
		end
		
		
       %> @brief Called when the number of samples changes
       function this = initNewSamples(this, state)
           % not supported, don't do anything
       end
	end
	
end

