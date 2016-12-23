
% NOTE: EXECUTE THIS EXAMPLE FROM THIS DIRECTORY. RELATIVE PATHS ARE USED
% IN THE EXAMPLES.

% This examples demonstrates the generation of high-dimensional
% high-quality space-filling designs.
% 
% The produced designs are compared to the highly optimized Latin hypercube
% designs available at www.spacefillingdesigns.nl. These designs have
% sometimes been optimized for hours or days before getting to the result
% available on the website, while our designs are generated in real-time.
% 
% Note that, for higher dimensions, the Latin hypercubes are just not
% available because they are much too time-expensive to generate, while the
% sequential method still generates the designs very quickly.

nPoints = 100;
maxDim = 30;

ourIntersite = zeros(1,maxDim-1);
ourProjected = zeros(1,maxDim-1);
theirIntersite = zeros(1,maxDim-1);
theirProjected = zeros(1,maxDim-1);

for inDim = 2 : maxDim
	
	% generate our design
	problem = struct;
	problem.inputs.nInputs = inDim;
	seq = SequentialDesign(problem);
	seq = seq.generateTotalPoints(nPoints);
	m = seq.getMetrics();
	ourIntersite(inDim-1) = m.intersite_distance;
	ourProjected(inDim-1) = m.projected_distance;
	
	% load the design from spacefillingdesigns.nl IF it exists
	url = sprintf('http://www.spacefillingdesigns.nl/maximin/lhd%snd.php?n=%d&m=%d', 'l2', nPoints, inDim);
	try
		text = urlread(url);

		% read the lines which contain only numbers and spaces (the matrix)
		numbers = regexp(text, '<TD>([0-9]+)</TD>', 'tokens');
		
		% construct an array from these
		samples = zeros(nPoints, inDim);
        counter = 1;
		for i = 1 : nPoints
            for j = 1 : inDim
                samples(i,j) = str2double(numbers{counter}{1});
                counter = counter + 1;
            end
		end
		
		% check for duplicates or other invalid values - if yes, we have an invalid LHD
		%if any(initialsamples(:) == 0) || any(accumarray(initialsamples(:), 1) ~= inDim)
		if any(accumarray(samples(:)+1, 1) ~= inDim)
			msg = sprintf('Prefab LHD design for %i samples in %i dimensions could not be downloaded automatically: invalid file detected', nPoints, inDim);
			error(msg);
			
		% all ok
		else
			
			% rescale them so that they lie in the [-1,1] domain
			samples = samples ./ (nPoints-1) .* 2 - 1;
			
			% get the metric data
			m = seq.getMetrics(samples);
			theirIntersite(inDim-1) = m.intersite_distance;
			theirProjected(inDim-1) = m.projected_distance;
		end
		
	catch ME
		% url not found! they don't have this design
			theirIntersite(inDim-1) = 0;
			theirProjected(inDim-1) = 0;
	end
end

% plot them both
figure;
plot(2:maxDim, ourIntersite, 'r');
hold on;
plot(2:maxDim, theirIntersite, 'b');
legend('mc-intersite-projected-threshold', 'pre-optimized LHD');
xlabel('input dimension');
ylabel('intersite distance');
figure;
plot(2:maxDim, ourProjected, 'r');
hold on;
plot(2:maxDim, theirProjected, 'b');
legend('mc-intersite-projected-threshold', 'pre-optimized LHD');
xlabel('input dimension');
ylabel('projected distance');

