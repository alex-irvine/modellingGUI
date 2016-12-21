%> @file CombinedDesign.m
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
%> @brief Wrap 2 different Initial Designs Together
%>
%> When one asks this class to select samples, it just glues together
%> the arrays returned by the subobjects...
% ======================================================================
classdef CombinedDesign < InitialDesign

  properties
    logger;
    subObjects;
  end

  methods
      
    % ======================================================================
    %> @brief Class constructor
    %> @return instance of the class
    % ======================================================================
    function this = CombinedDesign(config)
      % construct the base class
      this = this@InitialDesign(config);

      import java.util.logging.*
      this.logger = Logger.getLogger('Matlab.CombinedDesign');

      % read xml-data from config file
      subs = config.self.selectNodes('InitialDesign');

      % instantiate all subobjects as defined in the config file
      this.logger.info('Constructing CombinedDesign');
      objects = cell(subs.size(), 1);
      for k = 1:subs.size()
	   objects{k} = instantiate(subs.get(k-1), config);
	   this.logger.info( ['Registered sub-design of type ' class(objects{k})] );
      end      

      this.subObjects = objects;
    end

    % ======================================================================
    %> @brief Call selectSamples on each subobject and glue them together
    % ======================================================================
    function [initialsamples, evaluatedsamples] = generate(this)
        initialsamples = [];
        evaluatedsamples = [];

        for k=1:length(this.subObjects)
            [newinit, neweval] = generate(this.subObjects{k});
            initialsamples = [initialsamples; newinit];
            evaluatedsamples = [evaluatedsamples; neweval];
        end
    end

  end
end
