%> @file buildShapeGrid.m
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
%>	Return a grid of all possible plotting shapes/styles
% ======================================================================
function res = buildShapeGrid( co, sh, li );


% all possible colors
if ~exist( 'co', 'var' )
	co = {'b','g','r','c','m','k'};
end

% all possible shapes
if ~exist( 'sh', 'var' )
	sh = {'d','.','s','o','x','*','v','+'};
end

% all possible line styles
if ~exist( 'li', 'var' )
	li = {'-',':','-.','--'};
end

if isempty( co ); co = {''}; end;
if isempty( sh ); sh = {''}; end;
if isempty( li ); li = {''}; end;

shapeGrid = makeEvalGrid({1:length(co), 1:length(li), 1:length(sh)});

res = cell(size(shapeGrid,1),1);

for i=1:size(shapeGrid,1)
	res{i} = [co{shapeGrid(i,1)},li{shapeGrid(i,2)}, sh{shapeGrid(i,3)}];
end

