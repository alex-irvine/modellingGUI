% ======================================================================
%> @brief Manages several constraint classes
%>
%> Parses configuration and creates the constraints objects.
%> Accesible by all components of SED that need constraints.
% ======================================================================
classdef ConstraintManager < handle
    
   properties
	   constraints = {};
	   autoSampledInputs = [];
	   toSimulatorFunction;
	   inDim;
   end

   methods (Access=public)
	   
	   % ======================================================================
       %> @brief Class constructor
       %>
       %> @param config NodeConfig object
       %>
       %> @return Instance of the ConstraintManager class
       % ======================================================================
	   function this = ConstraintManager(config, toSimulatorFunction)
			import java.util.logging.*
			logger = Logger.getLogger('Matlab.ConstraintManager');
			
			% default constructor for the constraint manager
			if isnumeric(config)
				this.inDim = config;
				return;
			end
		   
            % check inputs for auto-sampling - might be used later before
            % passing to the sample manager
            inputs = config.input.getInputDescriptions();
			this.inDim = length(inputs);
            for i = 1:this.inDim
                if inputs(i).isSampledAutomatically()
                    this.autoSampledInputs = [this.autoSampledInputs i];
                end
            end
		   
			% input constraint handling
			% read xml-data from config file
			subs = config.input.getConstraints();
			
			% instantiate all subobjects as defined in the config file
			c=cell(1,subs.size());
			for i=0:subs.size()-1
				c{i+1}=Constraint(NodeConfig(subs.get(i)));
			end

			% output
			if ~isempty(c)
				msg = sprintf( '%i constraints specified and parsed', subs.size() );
				logger.info(msg);
			end
			
			% set constraints
			this.constraints = c;
			
			% set simulator translation function
			this.toSimulatorFunction = toSimulatorFunction;
       end
	   
       % ======================================================================
       %> @brief checks if one sample satisfies all constraints
       %>
       %> @param sample one sample
       %> @retval success boolean
       % ======================================================================
	   function success = satisfySample(this, sample)
		   success = ~isempty(satisfySamples(this, sample));
	   end
	   
	   % ======================================================================
       %> @brief checks if a set of samples satisfies all constraints
       %>
       %> @param samples sample matrix
       %> @retval indices indices to the samples that satisfy all constraints
       % ======================================================================
	   function indices = satisfySamples(this, samples)
		   
		   % no constraints
			if isempty(this.constraints)
				indices = (1:size(samples,1))';	
			
			% else get them
			else
				constraintValues = this.evaluateSamples(samples);
				indices = find(constraintValues <= 0);
			end
		   
	   end
	   
       % ======================================================================
       %> @brief Evaluate the samples on all the constraints and return the largest violation.
       %>
       %> @param samples samples
       %> @retval out amount of violation
       % ==================================================================
	   function constraintValues = evaluateSamples(this, samples)
		   
		   % see if the samples have their auto sampled inputs missing
		   % in this case, the constraint is being called from within a
		   % sample selector - add zero-columns for every auto sampled
		   % input
		   if size(samples,2) < this.inDim
			  for i = this.autoSampledInputs
				  samples(:, i:end) = samples(:, (i+1):(end+1));
				  samples(:, i) = zeros(size(samples,1), 1);
			  end
		   end
		   
			% transform to simulator space
			samples = this.toSimulatorFunction(samples);
			
			% evaluate every constraint
			constraintValues = zeros( size(samples,1), length(this.constraints) );
			for i=1:length(this.constraints)
				constraintValues(:,i) = this.constraints{i}.evaluate(samples);
			end

			% return good samples
			constraintValues = max(constraintValues, [], 2);
		   
	   end
	   
	   
       % ======================================================================
       %> @brief calculates the maximum violation of the constraints for one sample
       %>
       %> @param x one sample
       %> @retval out amount of violation
       % ======================================================================
	   function out = returnHighestViolation(this, x)
			y = zeros(size(x,1), length(this.constraints));
			for i=1:length(this.constraints)
				x = this.toSimulatorFunction(x);
				y(:,i) = this.constraints{i}.evaluate(x);
			end

			out = max(y,[],2);
	   end
	   
	   % ======================================================================
       %> @brief returns all constraint classes
       %>
       %> @retval c cell array of constraint objects
       % ======================================================================
	   function c = getConstraints(this)
		   c = this.constraints;
	   end
	   
	   
       % ======================================================================
       %> @brief Called when the number of samples changes
       %>
       %> Forwarded to all constraints
       % ======================================================================
       function this = initNewSamples(this, state)
           % not supported, don't do anything
       end
	   
	   % ==================================================================
       %> @brief returns all non-linear constraints
       %>
       %> @retval c cell array of nonlinear constraints
       % ==================================================================
	   function [c, ceq] = nonlcon(this, samples)
		   
		   % no constraints
			if isempty(this.constraints)
				c = -ones(size(samples,1), 1);
			
			% else get them
			else
				constraintValues = this.evaluateSamples(samples);
				c = constraintValues;
			end
			
			ceq = zeros(size(samples,1),1);
	   end
	   
       % ======================================================================
       %> @brief returns whether there are constraints or not
       %>
       %> @retval yes boolean
       % ======================================================================
	   function yes = hasConstraints(this)
		   yes = ~isempty(this.constraints);
	   end
   end
end 
