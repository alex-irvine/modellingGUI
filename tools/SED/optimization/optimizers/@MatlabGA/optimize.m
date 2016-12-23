%> @file optimize.m
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
%>	This function optimizes the given function handle
% ======================================================================
function [this, x, fval] = optimize(this, arg )


if isa( arg, 'Model' )
    func = @(x) evaluate(arg,x);
else % assume function handle
	func = arg;
end

% some basic settings
this.problem.fitnessfcn = func;
[this.problem.lb, this.problem.ub] = this.getBounds();
this.problem.options.PopInitRange = [this.problem.lb ; this.problem.ub];
this.problem.nvars = this.getInputDimension();

[ga_x, ga_fval, ga_reason, ga_output, ga_pop, ga_scores] = ga( this.problem );
[fval idx]= sort( ga_scores );
x = ga_pop(idx,:);
