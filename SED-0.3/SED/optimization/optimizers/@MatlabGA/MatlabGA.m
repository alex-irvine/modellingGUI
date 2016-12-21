%> @file MatlabGA.m
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
%>	Wrapper around the matlab optimizers
% ======================================================================
classdef MatlabGA < Optimizer


	
	% private members
	properties (SetAccess = 'private', GetAccess = 'private')
		problem;
	end
	
	methods

		% constructor
		% Description:
		%     Creates an MatlabGA object
		function this = MatlabGA(varargin)
			% call superclass
			this = this@Optimizer(varargin{:});

			% GENETIC ALGORITHM
			opts = ga('defaults');

			% default case
			if(nargin == 1)
				config = varargin{1};

				opts.Generations = config.self.getIntOption( 'Generations', 1000 );
				opts.EliteCount = config.self.getIntOption( 'EliteCount' ,2 );
				opts.CrossoverFraction = config.self.getDoubleOption( 'CrossoverFraction', 0.8 );
				opts.PopInitRange = [-1;1];
				opts.PopulationSize = [ str2num( config.self.getOption( 'PopulationSize', '20' ) ) ];
				opts.MigrationInterval = config.self.getIntOption( 'MigrationInterval', 20 );
				opts.MigrationFraction = config.self.getDoubleOption( 'MigrationFraction', 0.2 );
				opts.Vectorize = char( config.self.getOption( 'Vectorize', 'on' ) );
				%opts.FitnessScalingFcn = @fitscalingprop, ...
				%@fmincon, ...
				opts.HybridFcn = str2func( char( config.self.getOption( 'HybridFcn', '[]' ) ) );
				opts.HybridFcn = [];
				% must change the mutation function so that it respects the boundaries
				% !!! important !!!
				%opts.MutationFcn = {@mutationadaptfeasible, [1], [1]};
				opts.MutationFcn = @mutationuniform;
				
			% custom constructors
			elseif(nargin == 2)
				% no options, take defaults (only options are for base class
			elseif(nargin == 3)
				%First 2 are parsed by base class
				%nvar = varargin{1};
				%nobj = varargin{2};
				opts = gaoptimset( opts, varargin{3} );
			else
				error('Invalid number of arguments given');    
			end

			opts.MigrationDirection = 'both';
			
			% IMPORTANT!!!
			% if this is set to the default value, negative fitness
			% function values are not allowed!!!
			opts.StallGenLimit = inf;

			problem = struct(...
				'fitnessfcn', [], ...	% Fitness function
				'nvars', this.getInputDimension(), ... % Number of design variables
				'options', opts, ... % Options structure created using gaoptimset
				'Aineq', [], ... % A matrix for inequality constraints
				'Bineq', [], ... % b vector for inequality constraints
				'Aeq', [],... % A matrix for equality constraints
				'Beq', [], ... % b vector for equality constraints
				'lb', [], ... % Lower bound on x
				'ub', [], ... % Upper bound on x
				'nonlcon', [] ... % Nonlinear constraint function
				);

			this.problem = problem;
		end % constructor

		% optimize
		% Description:
		%     This function optimizes the given function handle
		[this, x, fval] = optimize(this, arg )

		% getPopulationSize
		% Description:
		%     Get the number of individuals in the population
		size = getPopulationSize(this)
		
		% setInputConstraints
		% Description:
		%     Sets input constraints
		this = setInputConstraints( this, con )

	end % methods
end % classdef
