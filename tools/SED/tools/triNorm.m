%> @file triNorm.m
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
%>	Computes the normalized normals of the given triangles
% ======================================================================
function tnorm1 = triNorm(p,t)


%Computes normalized normals of triangles

v21=p(t(:,1),:)-p(t(:,2),:);
v31=p(t(:,3),:)-p(t(:,1),:);

tnorm1(:,1)=v21(:,2).*v31(:,3)-v21(:,3).*v31(:,2);
tnorm1(:,2)=v21(:,3).*v31(:,1)-v21(:,1).*v31(:,3);
tnorm1(:,3)=v21(:,1).*v31(:,2)-v21(:,2).*v31(:,1);

L=sqrt(sum(tnorm1.^2,2));

tnorm1(:,1)=tnorm1(:,1)./L;
tnorm1(:,2)=tnorm1(:,2)./L;
tnorm1(:,3)=tnorm1(:,3)./L;
