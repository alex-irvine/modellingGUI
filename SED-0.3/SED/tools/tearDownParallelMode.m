%> @file tearDownParallelMode.m
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
%>	Make sure all parallel resources are freed
% ======================================================================
function tearDownParallelMode()


logger = java.util.logging.Logger.getLogger('Matlab.tearDownParallelMode');

minVersion = '4.0';
maxVersion = '4.3';

% Check if the parallel computing toolbox is installed
v = ver('distcomp');
if(length(v) == 0)
  % no it is not available, nothing to do
else
  % it is available, but test the version
   if( verLessThan('distcomp',minVersion) || ~verLessThan('distcomp',maxVersion))
      logger.warning(sprintf('The SUMO Toolbox has only been tested with the parallel computing toolbox version %s and %s, you are using %s, trying to continue anyway...',minVersion,maxVersion,v.Version));
    end

    try
      % close any open pools
      numWorkers = matlabpool('size');

      if(numWorkers > 0)
	% ok a pool is available, close it
	matlabpool('close');
	logger.info(sprintf('Parallel computing resources released (%d workers)',numWorkers));
      else
	% no pool is available, nothing to do
      end
    
    catch ME
      logger.severe(sprintf('Failed to close Matlab pool cleanly, error is %s',ME.message));
    end
end
