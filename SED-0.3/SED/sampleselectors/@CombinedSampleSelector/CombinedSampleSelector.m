%> @file CombinedSampleSelector.m
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
%>	Just a class to wrap together 2 different sample selectors
%>	When one asks this class to select samples, it just glues together
%>	the arrays returned by the subobjects...
% ======================================================================
classdef CombinedSampleSelector < SampleSelector


properties (Access = private)
	dimension = [];
	subObjects = [];
	ratios = [];
	logger = [];
    mergeCriterion;
end

methods (Access = public)

	% CTor
	function this = CombinedSampleSelector(config)
		import java.util.logging.*;
		import ibbt.sumo.config.*;

		this.logger = Logger.getLogger('Matlab.CombinedSampleSelector');

		% read xml-data from config file
		subs = config.self.selectNodes('SampleSelector');

		% instantiate all subobjects as defined in the config file
		this.logger.info(sprintf('Constructing CombinedSampleSelector with %d nested sample selectors',subs.size()));
		objects = cell(subs.size(), 1);
		ratios = zeros(subs.size(), 1);
		for k=1:subs.size()
			sub = subs.get(k-1);
			objects{k} = instantiate(sub, config);
			subNode = NodeConfig.newInstance(sub);
			ratios(k) = subNode.getDoubleAttrValue('weight', num2str(1/subs.size()));
			if ratios(k) > 0
				this.logger.info(['Registered sub-SampleSelector of type ' class(objects{k}) ' with weight ' num2str(ratios(k))]);
			else
				this.logger.info(['Registered sub-SampleSelector of type ' class(objects{k})]);
			end
		end

		if sum(ratios) > eps
			ratios = ratios ./ sum(ratios);
			this.logger.info('Weighted sampling enabled, weights normalized...');
        end
        
		this.dimension = config.input.getInputDimension();
		this.subObjects = objects;
		this.ratios = ratios;
		
		% read xml-data from config file
		subs = config.self.selectNodes('MergeCriterion');

		% no merge criterion specified, just create the default one
		if subs.size() ~= 1
			this.mergeCriterion = [];

		% instantiate the merge criterion
		else
			sub = subs.get(0);
			this.mergeCriterion = instantiateClassOrFunction(sub, config, 'MergeCriterion');
			this.logger.info(sprintf('Constructed merge criterion %s', this.mergeCriterion.getType()));
		end
	end
	
	% selectSamples (SUMO)
	% Description:
	%     Call selectSamples on each subobject and glue them together
	[this, newsamples, priorities] = selectSamples( this, state );

end

end
