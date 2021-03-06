classdef VisualisationHelper
    
    properties
    end
    
    methods (Static = true)
        function CreatePlot(samplesWrapper,dimensions,dimReductionMethod)
            if dimensions ~= 3 && dimensions ~= 2
                error('2 or 3 dimensions only');
            end
            if length(samplesWrapper) < 1
                error('Must have some samples to plot');
            end
            if ~isa(samplesWrapper{1},'Sample')
                error('SamplesWrapper must contain type Sample');
            end
            if ~strcmp(dimReductionMethod,'pca')&&~strcmp(dimReductionMethod,'sammon')
                error('Only PCA and Sammon mapping supported in this toolbox');
            end
            
            samples = zeros(length(samplesWrapper),length(samplesWrapper{1}.HyperParameters));
            for i=1:length(samplesWrapper)
                samples(i,:) = samplesWrapper{i}.HyperParameters;
            end
            mappedSamples = [];
            switch dimReductionMethod
                case 'pca'
                    mappedSamples = pca(samples,dimensions);
                case 'sammon'
                    mappedSamples = sammon(samples,dimensions);
                otherwise
                    error('Only PCA and Sammon reduction methods supported');
            end
            
            if size(mappedSamples,2) == 3
                plot3(mappedSamples(:,1),mappedSamples(:,2),mappedSamples(:,3),'.');
                grid on;
            else
                plot(mappedSamples(:,1),mappedSamples(:,1),'.');
                grid on;
            end
        end
    end
    
end

