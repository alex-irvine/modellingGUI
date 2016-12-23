function size = getPopulationSize(this)

% getPopulationSize (SUMO)
%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
%     Copyright: IBBT - IBCN - UGent
% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
% Revision: $Rev: 5553 $
%
% Signature:
%	size = getPopulationSize(this)
%
% Description:
%	Get the number of individuals in the population
%	 This is the base method: assuming only 1 individual. Population-based
%	 methods should override this

size = +Inf;
