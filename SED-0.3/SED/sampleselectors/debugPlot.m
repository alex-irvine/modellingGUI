%> @file debugPlot.m
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
function h = debugPlot(h, x, isc, state)
    if isempty(h)
        h = figure;
    else
        h = figure( h );
        hold off;
    end

    %title( 'Debug plot' );

    if size( state.samples, 2) == 1 
        plot(x,y);
        hold on;

        % samples
        plot(state.samples, mean(isc,2), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');

    elseif size( state.samples, 2) == 2
        density = sqrt( size(x,1) );
        x = x(1:density,2);
        isc = reshape( isc, density, density );

        [C, f] = contourf( x,x,isc );
        clabel( C, f );
        colorbar
        hold on

        % samples
        plot(state.samples(:,1), state.samples(:,2),'ko','Markerfacecolor','c');
        
        % optimums
        %mi = [-pi, 12.275;pi, 2.275;9.42478, 2.475] + repmat([-2.5,-7.5],3,1); % BRANIN
        %mi = mi ./ 7.5;

        %mi = ([1.2279713, 4.2453733]-5)/5; % conG8

        %mi = [0,-1]/2; % Goldstein Price
        %mi = [-0.0898,0.7127;0.0898,-0.7127] ./ repmat([2,1],2,1); % Six Hump Camelback
        %mi = ([0.2316,0.1216;0.2017,0.8332] - 0.5) .* 2.0; % superEGO_Test2
        %plot( mi(:,1), mi(:,2), 'x', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');

        %{
        temp = 1./sqrt(2);
        mop = [-temp -temp ; temp temp];
        mop = mop ./ 2;
        plot( mop(:,1), mop(:,2), 'k-', 'LineWidth',2 );
        %}

        % VLMOP2
        %temp = 1./sqrt(2);
        %mop = [-temp -temp ; temp temp];
        %mop = mop ./ 2;
        %plot( mop(:,1), mop(:,2), 'k-', 'LineWidth',2 );
			
        % OKA1
        %x1 = linspace( 0, 2*pi, 20 );
        %x2 = 3.*cos(x1) + 3;
        %x1 = (x1 - 4.5874) / 3.0345;
        %plot( x1, x2, 'k-', 'LineWidth',2 );
        % LB: [1.5529 -1.6262]
        % UB: [7.6220 5.7956]
        % transl: 4.5874    2.0847
        % scale: 3.0345    3.7109
    end
end
