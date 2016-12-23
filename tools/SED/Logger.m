%> @file Logger.m
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
%> @brief A Logger class that will log all events happening during execution of the Sequential Design Toolbox.
% ======================================================================
classdef Logger < handle
	
	properties
		verbose;
		index = 1;
		log = {};
		level = 1;
	end
	
	methods
		
		%> @brief The constructor of the class.
		%> @param verbose Whether the log is outputted immediately.
		function logger = Logger(verbose)
			logger.verbose = verbose;
		end
		
		%> @brief Change the verbose status of the logger.
		function this = setVerbose(verbose)
			this.verbose = verbose;
		end
		
		%> @brief Change the verbosity level of the logger.
		function this = setLevel(this, level)
			if strcmp(level, 'all')
				this.level = inf;
			elseif strcmp(level, 'none')
				this.level = 0;
			elseif strcmp(level, 'info')
				this.level = 1;
			elseif strcmp(level, 'fine')
				this.level = 2;
			elseif strcmp(level, 'finer')
				this.level = 3;
			elseif strcmp(level, 'finest')
				this.level = 4;
			end
		end
		
		%> @brief Print out a warning.
		function [] = warning(this, msg)
			
			% construct message
			msg = sprintf('[WARNING] %s', msg);
			
			% add to log
			this.log{this.index} = msg;
			this.index = this.index + 1;
			
			% print if necessary
			if this.verbose && this.level > 0
				disp(msg);
			end
		end
		
		%> @brief Print out an informational message.
		function [] = info(this, msg)
			
			% construct message
			msg = sprintf('[INFO] %s', msg);
			
			% add to log
			this.log{this.index} = msg;
			this.index = this.index + 1;
			
			% print if necessary
			if this.verbose && this.level > 0
				disp(msg);
			end
		end
		
		%> @brief Print out an informational message.
		function [] = fine(this, msg)
			
			% construct message
			msg = sprintf('[FINE] %s', msg);
			
			% add to log
			this.log{this.index} = msg;
			this.index = this.index + 1;
			
			% print if necessary
			if this.verbose && this.level > 1
				disp(msg);
			end
		end
		
		%> @brief Print out an informational message.
		function [] = finer(this, msg)
			
			% construct message
			msg = sprintf('[FINER] %s', msg);
			
			% add to log
			this.log{this.index} = msg;
			this.index = this.index + 1;
			
			% print if necessary
			if this.verbose && this.level > 2
				disp(msg);
			end
		end
		
		%> @brief Print out an informational message.
		function [] = finest(this, msg)
			
			% construct message
			msg = sprintf('[FINEST] %s', msg);
			
			% add to log
			this.log{this.index} = msg;
			this.index = this.index + 1;
			
			% print if necessary
			if this.verbose && this.level > 3
				disp(msg);
			end
		end
		
		%> @brief Print an error message & abort execution.
		function [] = severe(this, msg)
			
			% construct message
			msg = sprintf('[ERROR] %s', msg);
			
			% add to log
			this.log{this.index} = msg;
			this.index = this.index + 1;
			
			% print if necessary
			if this.verbose
				disp(msg);
			end
			
			error(msg);
		end
		
		function [] = dump(this, fileName)
			fid = fopen(fileName, 'w');
			for i = 1 : length(this.log)
				fprintf(fid, '%s\r\n', this.log{i});
			end
			fclose(fid);
		end
		
	end
	
	methods (Static)
		
		%> @brief Get the logger object.
		%> this makes sure only one logger exists in this session.
		function logger = getLogger(type)
			
			% only one logger
			persistent globalLogger;
			
			% see if a logger already exists
			if isempty(globalLogger)
				globalLogger = Logger(true);
			end
			
			logger = globalLogger;
		end
		
	end
end

