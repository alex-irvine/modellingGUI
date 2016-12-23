%> @file arr2str.m
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
%> @brief Converts a 2-dimensional array to a printable format.
% ======================================================================
function s = arr2str(arr, precision)

% no precision
if ~exist('precision', 'var')
	precision = '%0.4d';

% precision specified
elseif isnumeric(precision)
	precision = ['%0.' num2str(precision) 'd'];
end

numRows = size(arr,1);
numCols = size(arr,2);

s = '[';

if(iscell(arr))
    if(ischar(arr{1}))
      % cell of strings
      for i = 1 : numRows
	  if i > 1; s = [s '  ;']; end
	  for j = 1 : numCols
	      s = sprintf('%s  %s',s,arr{i,j});
	  end
      end
    else
      % cell of numbers
      for i = 1 : numRows
	  if i > 1; s = [s '  ;']; end
	  for j = 1 : numCols
	      s = sprintf(['%s  ' precision],s,arr{i,j});
	  end
      end
    end
else
    % regular matrix or vector
    for i = 1 : numRows
        if i > 1; s = [s '  ;']; end
        for j = 1 : numCols
            s = sprintf(['%s  ' precision],s,arr(i,j));
        end
    end
end

s = [s '  ]'];
