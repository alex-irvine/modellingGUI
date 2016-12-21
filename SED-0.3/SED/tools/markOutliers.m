%> @file markOutliers.m
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
%>	Does a simple std dev test to mark potential outliers
%>	see: http://mathworld.wolfram.com/Outlier.html
%>
%>	Inputs:
%>	   A : matrix whole columns will be checked for outliers
%>	   coef: optional factor to determine the standard deviation range, defaults to 3
%>	Outputs:
%>	   A : the original matrix A
%>	   B : A with outlier values set to NaN
%>	   I : Indices of the outlier values
%>	   nout: number of outliers in each column
% ======================================================================
function [A B I nout] = markOutliers(A,coef);


if(~exist('coef','var'))
	coef = 3;
end

% Calculate the mean and the standard deviation
% of each data column in the matrix
mu = mean(A);
sigma = std(A);

%An outlier is considered to be more than three standard deviations away from the mean
[n,p] = size(A);

% Create a matrix of mean values by
% replicating the mu vector for n rows
MeanMat = repmat(mu,n,1);

% Create a matrix of standard deviation values by
% replicating the sigma vector for n rows
SigmaMat = repmat(sigma,n,1);

% Create a matrix of zeros and ones, where ones indicate
% the location of outliers
outliers = abs(A - MeanMat) > coef*SigmaMat;

% Calculate the number of outliers in each column
nout = sum(outliers);

% Create a copy of A
B = A;

% Get the indices of all outliers
I = find(outliers == 1);

% Replace all outliers in B by NaN
B(I) = NaN;
