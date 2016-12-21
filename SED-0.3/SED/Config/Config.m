%> @file Config.m
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
%> Config class for the Sequential Design Toolbox.
% ======================================================================
classdef Config
	
	
	properties
		inputDimension;
		outputDimension;
		options;
	end
	
	
	methods
		
		%> Create a new Config by defining the input dimension.
		function config = Config(inputDimension)
			config.inputDimension = inputDimension;
			config.outputDimension = 1;
			config.options = struct;
		end
		
		%> Create a new Config by defining the input- and output dimension.
		function config = Config(inputDimension, outputDimension)
			config.inputDimension = inputDimension;
			config.outputDimension = outputDimension;
			config.options = struct;
		end
		
		%> @brief set an option
		%> @param name The name of the option
		%> @param value the value of the option
		function this = setOption(this, name, value)
			this.options.(name) = value;
		end
		
		
		%> get options
		function value = getOption(this, name, defaultValue)
			
			% see if this option exists
			if ~isfield(this.options, name)
				if exist('defaultValue', 'var')
					value = defaultValue;
				else
					error(sprintf('Option %s does not exist in this object and no default value as given, aborting...', name);
				end
			
			% it does exist, return it
			else
				value = this.options.(name);
			end
			
		end
		
		
		
		
	end
	
end

