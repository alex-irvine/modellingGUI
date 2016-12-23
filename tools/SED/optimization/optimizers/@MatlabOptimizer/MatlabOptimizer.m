%> @file MatlabOptimizer.m
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
%> @brief Wrapper around the matlab optimizers
%>
%> The matlab Optimiation toolbox is required.
%> If no bounds are set 'fmincon' will be used, else 'fminunc'.
% ======================================================================
classdef MatlabOptimizer < Optimizer
    
	% private members
	properties (SetAccess = 'private', GetAccess = 'private')
		opts;
		Aineq;
		Bineq;
		nonlcon;
	end
	
	methods

		% ======================================================================
        %> @brief Creates an MatlabOptimizer object.
        %>
        %> Takes the same option as the base class +
        %> an options structure (see optimset)
        %>
        %> @param nvars Number of dimensions
        %> @param nobjectives Number of cost functions
        %> @param options Option structure
        %> @return instance of the Optimizer class
        % ======================================================================
		function this = MatlabOptimizer(varargin)
			% call superclass
			this = this@Optimizer(varargin{:});
			
            % FMINUNC/FMINCON
            % http://www.mathworks.com/access/helpdesk/help/toolbox/optim/ug/index.html?/access/helpdesk/help/toolbox/optim/ug/f3137.html
                
            % Initialise OPTIMISER opts

			% default case
            if(nargin == 1)
                config = varargin{1};

                % Create custom options structure
                opts.MaxIter = config.self.getIntOption('maxIterations', 100);
                opts.MaxFunEvals = config.self.getIntOption('maxFunEvals', 100);
                opts.LargeScale = char(config.self.getOption('largeScale', 'off'));
                opts.TolFun = config.self.getDoubleOption('functionTolerance', 1e-4);
				opts.GradObj = char(config.self.getOption('gradobj', 'off'));
                opts.Algorithm = char(config.self.getOption('algorithm','active-set'));

                opts.Diagnostics = char(config.self.getOption('diagnostics', 'off'));
				opts.DerivativeCheck = char(config.self.getOption('derivativecheck', 'off'));
            elseif(nargin == 3)
				% First 2 are parsed by base class
				%nvar = varargin{1};
				%nobj = varargin{2};
				opts = varargin{3};
			else
				error('Invalid number of arguments given');
            end

            % Dont show any output
            opts.Display = 'off';
			this.opts = opts;
			this.Aineq = [];
			this.Bineq = [];
			this.nonlcon = [];
		end % constructor

		% ======================================================================
        %> @brief This function optimizes the given function handle,
		%> subject to constraints
        %>
        %> @param arg function handle
        %> @retval x optimal input point(s)
        %> @retval fval optimal function value(s)
        % ======================================================================
		[this, x, fval] = optimize(this, arg )

		% ======================================================================
        %> @brief Sets input constraints
        %>
        %> @param con constraint objects (cell array)
        % ======================================================================
		this = setInputConstraints( this, con )

	end % methods
end % classdef
