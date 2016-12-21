
% NOTE: EXECUTE THIS EXAMPLE FROM THIS DIRECTORY. RELATIVE PATHS ARE USED
% IN THE EXAMPLES.

% add the subdir to the path
addpath('constraintsExample');

% first, model the problem without specifying weights
seq = SequentialDesign('constraintsExample/problemNoWeights.xml');
seq = seq.generateTotalPoints(100);
seq.plot();
m1 = seq.getMetrics()

% next, model it using proper weights
figure;
seq = SequentialDesign('constraintsExample/problemWeights.xml');
seq = seq.generateTotalPoints(100);
seq.plot();
m2 = seq.getMetrics()

% Note that in both cases, the corner points are not checked against the
% constraints because they are required for the algorithm to work.
% This might now be a problem, since the corner points can be removed later
% in post-processing and a good design will remain.

% This method does not need the corner points, and will thus guarantee that
% every point satisfies the constraints. We also execute this oncee twice,
% one with weights, and once without.

% no weights
figure;
seq = SequentialDesign('constraintsExample/problemNoWeights.xml', 'mc-intersite-projected.xml');
seq = seq.generateTotalPoints(100);
seq.plot();
m3 = seq.getMetrics()

% weights
figure;
seq = SequentialDesign('constraintsExample/problemWeights.xml', 'mc-intersite-projected.xml');
seq = seq.generateTotalPoints(100);
seq.plot();
m4 = seq.getMetrics()

% Conclusion: mc-intersite-projected produces better results than
% mc-intersite-projected, but does select the corner points (which can
% later be removed manually, or by calling
% getAllPointsWithoutInitialDesign()). When using weights, points are
% distributed more evenly in rectangular spaces.
