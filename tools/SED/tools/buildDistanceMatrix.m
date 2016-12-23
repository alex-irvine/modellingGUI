%> @file buildDistanceMatrix.m
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
%>	Both `samples' and `targets' give an array of d-dimensional points
%>	If `samples' is N x d and `targets' is M x d, then
%>	this function returns an N x M matrix, where the i,j element
%>	is the carthesian distance between samples_i and targets_j
%>	If `targets' is omitted or empty, it is assumed to be equal to `samples',
%>	in that case the returned matrix is square and symmetrical,
%>	and has zeros on its diagonal.
%>  
%>	The parameter doSqrt indicates if the square root should be taken of the final matrix
%>	in order to get 'real' distances.  Set to 0 to save time.  Defaults to 1.
%>
%>	Example:
%>	>> build_distance_matrix( [ 0 0 ; 1 1 ; 2 2 ], [ 1 0 ; 0 1 ] )
%>	ans =
%>	 1.0000    1.0000
%>	 1.0000    1.0000
%>	 2.2361    2.2361
% ======================================================================
function distances = buildDistanceMatrix(samples, targets, doSqrt)

	if nargin == 1
		targets = samples;
		doSqrt = 1;
	elseif nargin == 2
		doSqrt = 1;
		if isempty(targets); targets = samples; end
	elseif nargin == 3
		if isempty(targets); targets = samples; end
	else
		error('Invalid number of arguments given');
	end


	% use replicate index method for M x 1
	if size(targets,1) == 1
		distances = samples - targets(ones(size(samples,1),1), :);
		distances = sum(distances .^ 2, 2);

	% use replicate index method for 1 x N
	elseif size(samples,1) == 1
		distances = targets - samples(ones(size(targets,1),1), :);
		distances = sum(distances .^ 2, 2)';

	% use permute method
	else
		[sz1,d] = size(samples);
		[sz2,d] = size(targets);

		dm = samples * targets.';
		if nargin == 1
			norm1 = diag(dm);
			norm2 = norm1;
		else
			norm1 = sum( samples.^2,2 );
			norm2 = sum( targets.^2,2 );
		end
		
		% make sure there are no negative distances (slightly inaccurate calculations)
		distances = max(0, norm1(:,ones(1,sz2)) + norm2(:,ones(sz1,1))' - 2*dm);
	end

	% do square root?
	if doSqrt
		distances = sqrt(distances);
	end

end

%{
[sz1,d] = size(samples);
[sz2,d] = size(targets);

dm = samples * targets.';
if nargin == 1
	norm1 = diag(dm);
	norm2 = norm1;
else
	norm1 = sum( samples.^2,2 );
	norm2 = sum( targets.^2,2 );
end
dm = norm1(:,ones(1,sz2)) + norm2(:,ones(sz1,1))' - 2*dm;

if(doSqrt)
	dm = sqrt(dm);
end

%}
