classdef ModelHelper
    
    properties
    end
    
    methods (Static = true)
        function model = CreateGPModel(samples,opts)
            %for ooDACE model will have model.predict(params) to predict
            %evaluation value of params
            % opts.type = 'Kriging' by default
            
            if length(samples) < 1
                error('need some samples to model');
            end
            if isempty(samples{1}.Value)
                error('Samples need to be evaluated before they can be modelled');
            end
            if isempty(opts)
                opts.type = 'Kriging';
            end
            
            %build matrix of sample hyper params and vec of values
            params = zeros(length(samples),length(samples{1}.HyperParameters));
            vals = zeros(length(samples));
            for i=1:length(samples)
                params(i,:) = samples{i}.HyperParameters;
                vals(i) = samples{i}.Value;
            end
            model = oodacefit(params,vals,opts);
        end
        
        function [values,meanSquaredError] = Predict(params,model)
            % only one for now
            if isa(model, 'Kriging')
                [values,meanSquaredError] = model.predict(params);
                values = values(~isnan(values));
                meanSquaredError = meanSquaredError(~isnan(meanSquaredError));
            end
        end
    end
    
end

