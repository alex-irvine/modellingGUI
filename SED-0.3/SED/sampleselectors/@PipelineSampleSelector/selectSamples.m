%> @file selectSamples.m
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
%>	Call selectSamples on each subobject and glue them together
% ======================================================================
function [s, newsamples, priorities] = selectSamples(s, state)


s.logger.fine('Starting combined sample selection...');


% generate initial set of candidates
[s.candidateGenerator, state, candidates] = s.candidateGenerator.generateCandidates(state);
s.logger.fine(sprintf('Generated %d candidate samples using %s', size(candidates,1), class(s.candidateGenerator)));

% filter out the samples that do not satisfy the constraints
if s.constraints
	c = Singleton('ConstraintManager');
	indices = c.satisfySamples(candidates);
	if length(indices) ~= size(candidates,1)
		s.logger.fine(sprintf('Filtered out %d candidates because they did not satisfy the constraints', size(candidates,1) - length(indices)));
	end
	candidates = candidates(indices,:);
end

% initialize score set
scores = zeros(size(candidates,1), length(s.candidateRankers));

% now walk over all the scorers, and add their rankings
for k=1:length(s.candidateRankers)
	
	% call init function
	s.candidateRankers{k} = s.candidateRankers{k}.initNewSamples(state);
	
	% rank the candidates
	[ranking] = s.candidateRankers{k}.score(candidates, state);
	scores(:,k) = ranking;
	s.logger.fine(sprintf('Finished ranking candidates with %s', class(s.candidateRankers{k})));
end

% now select samples out of the candidate-set based on some criterion
[s.mergeCriterion, newsamples, priorities] = s.mergeCriterion.selectSamples(candidates, scores, state);

% debug plot of candidateRankers
if s.debug
	density = 50;
	if size( state.samples, 2) == 1 
		x = linspace(-1,1,density )';
	elseif size( state.samples, 2) == 2
		x = linspace(-1,1,density )';
		[x1, x2] = meshgrid( x, x );
		x = [x1(:), x2(:)];
    end
		
    
	isc = zeros(density.^size( state.samples, 2),length(s.candidateRankers));
	for k=1:length(s.candidateRankers)
        [s.candidateRankers{k} isc(:,k)] = s.candidateRankers{k}.exeDebug(x,state);
    end
	
	[isc_total] = s.mergeCriterion.processScores(isc);
	
	s.debugPlot = debugPlot( s.debugPlot, x, isc_total, state );
    
	if size( state.samples, 2) == 1 
		% candidate samples
		candidateScores = s.mergeCriterion.processScores(scores);
		plot(candidates, candidateScores, 'ko', 'MarkerEdgeColor', 'r');		
		
		% new samples
		plot(newsamples, priorities, '*', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
	else
		% candidate samples
        numCandidates = min( size(candidates,1), 10000 ); % avoid clutter :-)
        plot(candidates(1:numCandidates,1), candidates(1:numCandidates,2), 'ko', 'MarkerEdgeColor', 'r');
		if size(candidates,1) > numCandidates
			s.logger.warning('Not all candidate points are shown in the contour plot.');
		end
		
		% new samples
		plot(newsamples(:,1), newsamples(:,2), '*', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
		
		% hack to plot delaunay overlay
		if isfield( state, 'candidatesToTriangles' )
			state.triangulation.plotTriangulation();
		end
    end
    
    %legend( {'Priority' 'Samples' 'Candidates', 'Selected'}, 'Location', 'NorthOutside', 'Orientation', 'horizontal' );
    hold off;		
    
    if s.debugSave
        savePlot( gcf, sprintf( 'mergedContour%i_total', size(state.samples,1) ) );
    end
end

%{
samples = [state.samples ; newsamples];
plot(samples(:,1), samples(:,2), 'or');
hold on;
colors = 'ymcrgbwk';
for i = 1 : size(samples,1)
	plot([samples(i,1) samples(i,1)], [-1 1], 'g');
	plot([-1 1], [samples(i,2) samples(i,2)], 'b');
end
%}
