classdef LHCHelper
    
    properties
    end
    
    methods (Static = true)
        function samplesWrapper = GetSamplePoints(sampleSize,upperBound,lowerBound)
            if length(upperBound) ~= length(lowerBound)
                error('Upper and lower bound must be the same size');
            end
            if length(sampleSize) ~= 1
                error('Sample size must be a scalar');
            end
            lhsnum=lhsamp(sampleSize,length(upperBound));
            samples = zeros(sampleSize,length(upperBound));
            samplesWrapper = cell(sampleSize,1);
            for i=1:sampleSize
                samples(i,:) = lowerBound + lhsnum(i,:).*(upperBound - lowerBound);
                samplesWrapper{i} = Sample();
                samplesWrapper{i}.HyperParameters = samples(i,:);
            end
        end
    end
    
end

