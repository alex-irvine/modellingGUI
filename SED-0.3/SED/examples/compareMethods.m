
% NOTE: EXECUTE THIS EXAMPLE FROM THIS DIRECTORY. RELATIVE PATHS ARE USED
% IN THE EXAMPLES.

% This example will generate 150 points using the different algorithms
% available, and will show the difference in results. It will also, for the
% best (and slowest) algorithm, update the selection of points live on the
% screen using the plotLive option of the SED Toolbox.

% the problem
problem = struct;
problem.inputs.nInputs = 2;

% mc-intersite-projected
figure;
seq = SequentialDesign(problem, '../methods/mc-intersite-projected.xml');
seq = seq.generateTotalPoints(50);
seq.plot();
m1 = seq.getMetrics()

% mc-intersite-projected-threshold
figure;
seq = SequentialDesign(problem, '../methods/mc-intersite-projected-threshold.xml');
seq = seq.generateTotalPoints(50);
seq.plot();
m2 = seq.getMetrics()

% optimizer-projected
figure;
seq = SequentialDesign(problem, '../methods/optimizer-projected.xml');
seq = seq.generateTotalPoints(50);
seq.plot();
m3 = seq.getMetrics()

% optimizer-intersite
figure;
seq = SequentialDesign(problem, '../methods/optimizer-intersite.xml');
seq = seq.setPlotLive(true);
seq = seq.generateTotalPoints(50);
m4 = seq.getMetrics()
