classdef WeightedAverageSnapToBorder < WeightedAverage

% WeightedAverage (SUMO)
%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
%     Copyright: IBBT - IBCN - UGent
% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
% Revision: $Rev: 5884 $
%
% Signature:
%	WeightedAverage(arg)
%
% Description:
%	WeightedAverage performs a weighted averaged merging of the
%	different scores.

	
	properties
		threshold;
	end
	
	
	methods (Access = public)
		
		
		function [this] = WeightedAverageSnapToBorder(config)
			this@WeightedAverage(config);
			this.threshold = str2num(config.self.getAttrValue('threshold', '0.05'));
		end
		
		function [this, newSamples, priorities] = selectSamples(this, candidates, scores, state)
			
			% forward to subclass
			[this, newSamples, priorities] = selectSamples@WeightedAverage(this, candidates, scores, state);
			
			% snap the selected samples to the border
			newSamples(abs(newSamples - (-1)) < this.threshold) = -1;
			newSamples(abs(newSamples - (1)) < this.threshold) = 1;
		end
	end
end
