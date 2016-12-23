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
%> Optimises the infill sampling criterion
%>
%> Filters the resulting samples and return them.
% ======================================================================
function [this, newsamples, priorities] = selectSamples(this, state)

%% Apply constraints
% check for input constraints

for i=1:length(this.constraints)
    this.constraints{i} = this.constraints{i}.initNewSamples(state);
end

c = Singleton('ConstraintManager');
c = c.initNewSamples(state);

constraints = [this.constraints c.getConstraints()];
if ~isempty( constraints )
    this.funcOptimizer = setInputConstraints( this.funcOptimizer, constraints );
end

%% Get optimizer
inDim = size(state.samples,2);
outDim = size(state.values,2);
this.funcOptimizer = this.funcOptimizer.setDimensions(inDim,outDim);

% if there is a candidate generator, use it to set the initial population
if ~isempty(this.candidateGenerator)
	
	% generate the candidates
	[this.candidateGenerator, state, initialPopulation] = this.candidateGenerator.generateCandidates(state);
	
	% check if the number does not exceed the allowed number
	if size(initialPopulation,1) > this.funcOptimizer.getPopulationSize()
		this.logger.warning(sprintf('Optimizer %s only allows %d samples for the initial population, while candidate generator %s produced %d. Ignoring initial population.', class(this.funcOptimizer), this.funcOptimizer.getPopulationSize(), class(this.candidateGenerator), size(initialPopulation,1)));
	else
		this.funcOptimizer = this.funcOptimizer.setInitialPopulation(initialPopulation);
	end
	
end

% give the state to the optimizer - might contain useful info such as # samples
this.funcOptimizer = this.funcOptimizer.setState(state);

% the new samples
newsamples = zeros(0,inDim);

%% as long as no samples are found, move on to the next criterion
for k = 1 : length(this.candidateRankers)
	
	if k > 1
		this.logger.warning(sprintf('Criterion %s could not find any samples, now trying next criterion %s', this.candidateRankers{k-1}.getType(), this.candidateRankers{k}.getType()));
	end
	
	% init the sample ranker
	this.candidateRankers{k} = this.candidateRankers{k}.initNewSamples(state);
	
	% get the sample ranker
	candidateRanker = this.candidateRankers{k};
	
	% turn into a criterion
	criterion = @(x)(-candidateRanker.score(x, state));
	
	% optimize
	[this.funcOptimizer, foundsamples, foundvalues] = this.funcOptimizer.optimize(criterion);
	
	% remove duplicates
	dups = buildDistanceMatrix( foundsamples, [state.samples ; state.samplesFailed], 1 );
	index = find(all(dups > 2.*eps, 2));
	newsamples = foundsamples(index,:);
	newvalues = foundvalues(index,:);
    
    % we found samples - we're done
    if ~isempty(newsamples)
        break;
    end
end


%% no criteria managed to find any samples - generate random samples
if isempty(newsamples) && this.randomSamples
	newsamples = -1 + 2.*rand(state.numNewSamples,size(state.samples,2));
	newvalues = (1:state.numNewSamples)';

	% Solely needed for debug plots
	foundsamples = newsamples;
	foundvalues = newvalues;

	this.logger.warning( 'No unique samples found, falling back to random samples' );
end


%% no priorities here
priorities = zeros(size(newsamples,1), 1);


%% try to uphold the wishes of the modeller, return best ones
nNew = min( state.numNewSamples, size( newsamples, 1 ) );

[dummy, index] = sort(newvalues, 1);
newsamples = newsamples(index(1:nNew), :);
priorities = priorities(index(1:nNew), :);

%% debug, plots
if this.debug

	density = 50;
	if size( state.samples, 2) == 1 
		x = linspace(-1,1,density )';
	elseif size( state.samples, 2) == 2
		
		x = linspace(-1,1,density )';
		[x1, x2] = meshgrid( x, x );
		x = [x1(:), x2(:)];
    else
        % nD debug plot not supported
        return;
	end
		
	isc = this.candidateRankers{k}.score(x, state);
    this.debugPlot = debugPlot(this.debugPlot, x, isc, state);
	
	if size( state.samples, 2) == 1 
		% candidate samples
		plot(foundsamples, foundvalues, 'ko', 'MarkerEdgeColor', 'r');

		% selected samples
		plot(newsamples, newvalues, '*', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
	elseif size( state.samples, 2) == 2

		% candidate samples
		plot(foundsamples(:,1), foundsamples(:,2), 'ko','Markerfacecolor','r');

		% selected samples
		plot(newsamples(:,1), newsamples(:,2), '*', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
		
        % constraints
        for i=1:length(constraints)
        	cdata = reshape( evaluate( constraints{i}, x ), size(x1) );
        	contour(x1,x2,cdata,[0,0], 'w--');
        end
	end
	%legend( {'Infill criterion' 'Samples' 'Candidates', 'Selected'}, 'Location', 'NorthOutside', 'Orientation', 'horizontal' );
    xlabel('x1', 'FontSize', 14);
    ylabel('x2', 'FontSize', 14);
    set(gca, 'FontSize', 14 );
    hold off;

    if this.debugSave
        colorbar('hide');
        savePlot( gcf, sprintf( 'optim_contour%i_total', size(state.samples,1) ) );
    end
    
    % multiobjective
    if outDim > 1
        
        %> @todo find a good way to refactor this to AdaptiveModelBuilder::setData (where the minimum profiler is located),
        %> so all other components of sumo can take advantage of it
        if isempty( this.debugParetoPlot )
            this.debugParetoPlot = figure;
        else
            figure( this.debugParetoPlot );
        end

        [idx idxdom] = nonDominatedSort(state.values);

        % find intermediate Pareto front
        pf = state.values(idxdom == 0,:);

        hold on;
        if outDim == 2
            plot( state.values(:,1), state.values(:,2),'ko','Markerfacecolor','c');
            plot( pf(:,1), pf(:,2), 'ko','Markerfacecolor','r' );
            %plot( foundvalues(:,1), foundvalues(:,2), '*', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g' );
            legend( {'Output values' 'Intermediate pareto front'}, 'Location', 'SouthWest', 'FontSize', 14 );
            xlabel('y1', 'FontSize', 14);
            ylabel('y2', 'FontSize', 14);
        elseif outDim == 3;
            %> @todo debug surfc/scatter3d/plot3 plot
            plot3( state.values(:,1), state.values(:,2), state.values(:,3), 'ko','Markerfacecolor','c');
            plot3( pf(:,1), pf(:,2), pf(:,3), 'ko','Markerfacecolor','r' );
            legend( {'Output values' 'Intermediate pareto front'}, 'Location', 'SouthWest', 'FontSize', 14 );
            xlabel('y1', 'FontSize', 14);
            ylabel('y2', 'FontSize', 14);
            zlabel('y3', 'FontSize', 14);
        else
            % not supported
        end
        set(gca, 'FontSize', 14 );
        hold off;

        if this.debugSave
            savePlot( gcf, sprintf( 'optim_pareto%i', size(state.samples,1) ) );
        end
    end
end
