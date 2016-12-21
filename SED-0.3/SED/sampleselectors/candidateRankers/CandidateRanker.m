%> @file CandidateRanker.m
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
%> @brief An interface that allows the object to score a set of candidates
%>	according to its own system.
%>
%> This is used in the
%> PipelineSampleSelector to score a set of externally generated
%> candidate samples according to some criterion.
%> Note: when a candidate ranker gives a HIGHER score to a candidate, the
%> sample selector will prefer this candidate above one with a LOWER
%> score.
% ======================================================================
classdef CandidateRanker

properties
	inDim;
	scalingFunction;
    sortOrder = 'max';
    
    debug = false;
    debugSave = false;
    debugPlot = [];
end

methods (Access = public, Abstract = true)
    [scores] = scoreCandidates(this, candidates, state);
end

methods (Access = public)
	
	function [this] = initNewSamples(this, state)
		% does nothing by default
	end
	
	function [this] = CandidateRanker(varargin)
		% Description:
		%	This constructor will look for an option specifying a generator
		%	function to call. If such an option is found, the samples are
		%	generated from this function. Otherwise it is left to the
		%	subclass.
		
		% nothing specified - right now, an invalid object
		if nargin == 0
			return;
		
		% subclassed
		elseif nargin == 1
			config = varargin{1};
			
			this.inDim = config.input.getInputDimension();
            this.debug = config.self.getBooleanOption('debug', false );
            this.debugSave = config.self.getBooleanOption('debugSave', false );
		
			% get the scaling function
			this.scalingFunction = char(config.self.getAttrValue('scaling', 'onetozero'));
		elseif nargin >= 2 % assume individual parameters
			this.inDim = varargin{1};
			this.scalingFunction = varargin{2};
			% rest of parameters is for inherited classes
		end
		
		this.scalingFunction = constructScalingFunction(this.scalingFunction);
	end
end


methods (Access = public, Sealed = true)
	
    % This function will call the subclass score function, and then
    % transfom the raw scores through a number of transformations
    % (inversion, scaling).
	function [scores dscores] = score(this, candidates, state)
		
        dscores = [];
        
        % get the raw scores
        if nargout == 1
            scores = this.scoreCandidates(candidates, state);
        else
            [scores dscores] = this.scoreCandidates(candidates, state);
        end
        
        % invert the scores if the sort order is not 'max'
        % this is done because users of CandidateRanker assume that samples
        % with a HIGH score (or error) are the ones that are to be above
        % the ones with a LOW score.
        if ~strcmp(this.sortOrder, 'max')
            scores = -scores;
            dscores = -dscores;
		end
		
		% scale the scores
		scores = this.scalingFunction(scores);
    end
    
    

    function [this] = setOrder(this, order)
        this.sortOrder = order;
    end
    
    
    function [typeName] = getType(this)
        typeName = class(this);
	end
	
	function [this] = instantiate(this, inDim, varargin)
		% Description:
		%	This function sets some members of a subclass through dynamic
		%	indexation.
		nargin
		for i = 1 : 2 : nargin - 2
			this.(varargin{i}) = varargin{i+1};
		end
		this.inDim = inDim;
		this.scalingFunction = constructScalingFunction('none');
    end
    
    function [this scores] = exeDebug(this, candidates, state )
        
        % empty out indices
        state.candidatesToTriangles = [];
        
        scores = this.score(candidates, state);
        %[scores] = this.scoreCandidates(candidates, state);
        
        if this.debug
            this.debugPlot = debugPlot( this.debugPlot, candidates, scores, state );
            
            if this.debugSave
               savePlot( this.debugPlot, sprintf( '%s_%iSamples', class(this), size(state.samples,1) ) );
            end
        end
    end
	
end
	
end
