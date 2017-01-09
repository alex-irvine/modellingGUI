% test script uses ackley to evaluate
% see ackley here: http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/TestGO_files/Page295.htm
% dimensions are -15 -> 30 for any number of dimensions
% this script will be 5d

% first create hyper params
upperBounds = [30,30,30,30,30];
lowerBounds = [-15,-15,-15,-15,-15];
% store in model if you want to and for use in LOLA later
doe = DesignOfExperimentSettings();
doe.UpperBound = upperBounds;
doe.LowerBound = lowerBounds;
% use LHC to get a good distribution of initial samples, we'll get 50 for
% now. LHCHelper will return a cell array of the Sample model of size 50
samples = LHCHelper.GetSamplePoints(50,upperBounds,lowerBounds);
% now we have a sample we can evaluate to get the objective values
% evaluator helper returns the same sample array as LHC helper but this
% time with individual values for each member inserted. Send the string
% name of the function to use for evaluating. This function must be on the
% matlab working path. 
samples = EvaluatorHelper.EvaluateSamples(samples,'ackley');
% now we have a wrapped up list of samples with objective values we can
% create a model.
model = ModelHelper.CreateGPModel(samples,[]);
% now we have a model we can predict new values we have not evaluated. all
% 0 is the optimum we can see how close this coarse model is.
newValue = ModelHelper.Predict([0,0,0,0,0],model)
% if we want to improve the model we will have to get some new samples to
% evaluate
seq = LOLAHelper.SetupLOLA(samples,doe);
% now we can generate some points
[seq,points] = LOLAHelper.GenerateNewPoint(seq);
% print the point and predict it for illustration
points
val = ModelHelper.Predict(points,model)
% now we can evaluate it and add it to the model
newSample = {Sample()};
newSample{end}.HyperParameters = points;
% then evaluate it
newSample = EvaluatorHelper.EvaluateSamples(newSample,'ackley');
% now add it to evaluated pop and create new model
samples{end+1} = newSample{end};
model = ModelHelper.CreateGPModel(samples,[]);
% try to predict our optimum again see if it is any better
newValue = ModelHelper.Predict([0,0,0,0,0],model)

