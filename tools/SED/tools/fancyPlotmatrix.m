%> @file fancyPlotmatrix.m
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
%>	A nice way of showing failed and succeeded sample evaluations using plotmatrix
%>	samplesFailed can be empty, inputnames is optional
% ======================================================================
function [h,ax,bigax] = fancyPlotmatrix(samples,samplesFailed,inputnames)

if(~exist('inputnames','var') || isempty(inputnames))
    inputnames = cell(1,size(samples,2));
    for i=1:size(samples,2)
        inputnames{i} = ['x' num2str(i)];
    end
end


% plot the data
[h,ax,bigax] = gplotmatrix([samples ; samplesFailed],[],...
                    [repmat({'Successful'},size(samples,1),1) ; repmat({'Failed'},size(samplesFailed,1),1)],...
                    'br','+o',[],'on','hist',inputnames,{});
