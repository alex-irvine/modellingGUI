classdef LOLAHelper
    
    properties
    end
    
    methods (Static = true)
        function seq = SetupLOLA(samplesWrapper,does)
            if length(samplesWrapper) < 1
                error('Must have some samples');
            end
            if ~isa(samplesWrapper{1},'Sample')
                error('samplesWrapper must contain type Sample');
            end
            if ~isa(does,'DesignOfExperimentSettings')
                error('does needs to be a DesignOfExperiemtnSettings type');
            end
           % define problem
            problem = struct;
            problem.inputs.nInputs = length(samplesWrapper{1}.HyperParameters);
            problem.inputs.minima = does.LowerBound;
            problem.inputs.maxima = does.UpperBound;
            problem.outputs.nOutputs = 1;

            % create sequential design
            seq = SequentialDesign(problem, 'lola-voronoi.xml');

            % get initial design and evaluate them
            newPoints = zeros(length(samplesWrapper),length(samplesWrapper{1}.HyperParameters));
            out = zeros(length(samplesWrapper),1);
            for i=1:length(samplesWrapper)
                newPoints(i,:) = samplesWrapper{i}.HyperParameters;
                out(i) = samplesWrapper{i}.Value;
            end

            % return the outputs to the sequential design for processing
            seq = seq.updatePoints(newPoints, out); 
        end
        
        function [seq, points] = GenerateNewPoint(seq)
            % generate a new point
            [seq, points] = seq.generatePoints(1);
        end
    end
    
end

