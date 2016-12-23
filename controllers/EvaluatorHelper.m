classdef EvaluatorHelper
    
    properties
    end
    
    methods (Static = true)
        function samplesWrapper = EvaluateSamples(samplesWrapper,fname)
            if length(samplesWrapper) < 1
                error('samplesWrapper must have at least one element');
            end
            func = str2func(fname);
            for i=1:length(samplesWrapper)
                if ~isa(samplesWrapper{i},'Sample')
                    error('samplesWrapper must wrap model Sample only');
                end
                samplesWrapper{i}.Value = func(samplesWrapper{i}.HyperParameters);
            end
        end
    end
    
end

