
% NOTE: EXECUTE THIS EXAMPLE FROM THIS DIRECTORY. RELATIVE PATHS ARE USED
% IN THE EXAMPLES.

% This example demonstrates the powerful LOLA-Voronoi algorithm, and how it
% distributes its samples according to the nonlinearity of the function.
% This method requires that users provide SequentialDesign with the outputs
% of the experiments, so that future design points can be selected based on
% this additional information.
% For this example, we model the built-in Matlab peaks function on the
% [-5,5] domain. Peaks is a sum of some random gaussians near the origin.

% define problem
problem = struct;
problem.inputs.nInputs = 2;
problem.inputs.minima = [-5 -5];
problem.inputs.maxima = [5 5];
problem.outputs.nOutputs = 1;

% create sequential design
seq = SequentialDesign(problem, '../methods/lola-voronoi.xml');

% get initial design and evaluate them
newPoints = seq.getInitialDesign();

% get the output of the initial design (simulation)
out = peaks(newPoints(:,1), newPoints(:,2));

% return the outputs to the sequential design for processing
seq = seq.updatePoints(newPoints, out);

% generate some additional points
for i = 1 : 48
	
	% generate one point
	[seq, newPoints] = seq.generatePoints(1);
	
	% produce the output of the point (simulation)
	out = peaks(newPoints(1), newPoints(2));
	
	% give the output to the sequential design for processing
	seq = seq.updatePoints(newPoints, out);
end

% plot the entire design
seq.plot();


% Also plot the surface so that it can be seen how points are distributed
% according to the nonlinearity of the function.
figure;
range = [-5 : .2 : 5];
grid = makeEvalGrid({range, range}); % generate a dense 2D grid
out = peaks(grid(:,1), grid(:,2)); % evaluate this grid
surfc(range, range, reshape(out, length(range), length(range))); % plot the surface
[points, values] = seq.getAllPoints();
hold on;
plot3(points(:,1), points(:,2), values, 'ob', 'MarkerFaceColor','b');
xlabel('x1'); ylabel('x2'); zlabel('out');
% It can now clearly be seen that points are distributed much more densely
% around the three hills near the center. These regions are also more
% difficult to approximate than the flat regions near the borders, so this
% is a sensible sample distribution.