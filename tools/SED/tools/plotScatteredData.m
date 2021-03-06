%> @file plotScatteredData.m
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
%> @brief A nice, easy way to create a surf plot of scatterd data
% ======================================================================
function h = plotScatteredData(varargin)

defaults = struct(...
	'plotPoints',	0,...
	'lighting',	0,...
	'lowerBounds',	[],...
	'upperBounds',	[],...
	'axisLabels',	{{}},...
	'title',	{''},...
	'grayScale',	0,...
	'meshSize',	50,...
	'colorbar',	0,...
	'contourLines',	-1,...
	'pointsColormap', 'plain', ...
	'contour',	[0],...
    'wireframe', false ...
);

if(nargin == 0)
	h = defaults;
	return;
elseif(nargin == 1)
	d = varargin{1};
	x = d(:,1);
	y = d(:,2);
	z = d(:,3);
	options = defaults;
elseif(nargin == 2)
	d = varargin{1};
	x = d(:,1);
	y = d(:,2);
	z = d(:,3);
	options = mergeStruct(defaults, varargin{2});
elseif(nargin == 3)
	x = varargin{1};
	y = varargin{2};
	z = varargin{3};
	options = defaults;
elseif(nargin == 4)
	x = varargin{1};
	y = varargin{2};
	z = varargin{3};
	options = mergeStruct(defaults, varargin{4});
else
	error('Invalid parameters given');
end

if(length(options.lowerBounds) < 1 || length(options.upperBounds) < 1)
	options.lowerBounds = [min(x) min(y)];
	options.upperBounds = [max(x) max(y)];
end

if(length(options.axisLabels) < 1)
	options.axisLabels = {'x','y','z'};
end

lb = options.lowerBounds;
ub = options.upperBounds;

[X,Y] = meshgrid(linspace(lb(1),ub(1),options.meshSize),linspace(lb(2),ub(2),options.meshSize));
Z = griddata(x,y,z,X,Y,'cubic');

if(options.grayScale)
	colormap(gray);
else 
	colormap(jet);
end

if(options.contour)
	if(options.contourLines > 0)
		[h f] = contourf(X,Y,Z,options.contourLines);
	else
		[h f] = contourf(X,Y,Z);
	end
	clabel( h, f );
else
    if options.wireframe
        h = mesh(X,Y,Z)
    else
		h = surfc(X,Y,Z);
    end
end

if(options.colorbar)
	colorbar('EastOutside');
end

%Another way
%Triangulate the data
%tri = delaunay(x,y);
%Plot the triangles with TRISURF
%h = trisurf(tri, x, y, z);

title(options.title,'FontSize',14);
xlabel(options.axisLabels{1},'FontSize',14);
ylabel(options.axisLabels{2},'FontSize',14);

if(~options.contour)
    zlabel(options.axisLabels{3},'FontSize',14);
end

set(gca,'FontSize',14);

if(options.lighting)
	% Add some fancy lighting
	l = light('Position',[-50 -15 29]);
	lighting phong
	shading interp
end

if(options.plotPoints)
	hold on;
	if(options.contour)
		h = plotPoints([x y], 'color_map', options.pointsColormap, 'psize', 30, 'range', [min(z), max(z)], 'normalize', false);
		%plot(x(1:end-1),y(1:end-1),'o','MarkerSize',6, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 	'g');
		%plot the last point
		%plot(x(end),y(end),'o', 'MarkerSize',6, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
		%plot the point with the minimum value
		%[y i] = min(z);
		%plot(x(i(1,1)),y(i(1,1)),'*', 'MarkerSize',6, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
	else
		h = plotPoints([x y z], 'color_map', options.pointsColormap, 'psize', 30, 'range', [min(z), max(z)], 'normalize', false);
		%plot3(x(1:end-1),y(1:end-1),z(1:end-1),'o','MarkerSize',6, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 	'g');
		%plot the last point
		%plot3(x(end),y(end),z(end),'o', 'MarkerSize',6, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
		%plot the point with the minimum value
		%[y i] = min(z);
		%plot3(x(i(1,1)),y(i(1,1)),z(i(1,1)),'*', 'MarkerSize',9, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
	end
	set(h, 'markerEdgeColor', 'w');
	hold off;
end

%Allow for drawing
%pause(0.01);
drawnow;
