%> @file plotPoints.m
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
%> TODO
% ======================================================================
function h = plotPoints(p, varargin)


n = nargin - 1;
if mod(n,2) ~= 0
	% no options, need pairs
else
	while (n > 0)
		option = varargin{n-1};
		value = varargin{n};
		options.(option) = value;
		n = n - 2;
	end
end

%% normalize the input data to [-1,1]
pmin = min(p(:, 1:end-1), [], 1);
pmax = max(p(:, 1:end-1), [], 1);
if options.normalize
	p(:, 1:end-1) = bsxfun(@minus, p(:, 1:end-1), pmin);
	p(:, 1:end-1) = bsxfun(@times, p(:, 1:end-1), 1 ./ (pmax - pmin));
	p(:, 1:end-1) = p(:, 1:end-1) .* 2 - 1;
end

%% Option 1: color_map
color_map = options.color_map;

if strcmp(color_map, 'plain')
	out = zeros(size(p,1), 1);
elseif strcmp(color_map, 'voronoi')
	if options.normalize
		[s] = approximateVoronoi(p(:, 1:end-1));
	else
		[s] = approximateVoronoi(p(:, 1:end-1), pmin, pmax);
	end
	out = 1 ./ s.areas;
elseif strcmp(color_map, 'minavg')
	% don't just use the minimum, but use the average of the 5 closest points
	d=buildDistanceMatrix(p(:,1:2));
	d = sort(d + diag(repmat(Inf, size(p,1), 1)), 2);
	
	% get mean of best values
	out = 1 ./ mean(d(:, 1:ceil(size(p,1)/5)), 2);
	
elseif strcmp(color_map, 'min')
	% pairwise distance vector
	d=buildDistanceMatrix(p(:,1:2));
	out = 1 ./ min(d + diag(repmat(Inf, size(p,1), 1)), [], 2);
elseif strcmp(color_map, 'crowdedness')
	out = crowdedness( p, p );
elseif strcmp(color_map, 'crowdednessinput')
	out = crowdedness( p(:,1:end-1), p(:,1:end-1) );
else
	out = repmat(0, size(p,1), 1);
end

%% Option 2: point size
psize = options.psize;

% two values, specifies point size range
if length(psize) == 2
	ratio = (out - min(out)) ./ (max(out) - min(out));
	psize = min(psize) + ratio .* (max(psize) - min(psize));
end


%% scale the out-values to the current color axis values
% this makes sure the current colors in the plot are preserved
range = options.range;
if strcmp(range, 'preserve')
	range = caxis;
end


%% option 3: out value range
if ~isempty(range)
	% transform out to correct range, if there is some variance in the values
	if max(out) - min(out) > eps
		out = (out - min(out)) .* (range(2) - range(1)) ./ (max(out) - min(out)) + range(1);
	else
		out = repmat(range(1), size(p,1), 1);
	end
end



%% plot everything
if size(p,2) == 2
	h = scatter(p(:,1), p(:,2), psize, out, 'filled');
elseif size(p,2) == 3
	h = scatter3(p(:,1), p(:,2), p(:,3), psize, out, 'filled');
end

