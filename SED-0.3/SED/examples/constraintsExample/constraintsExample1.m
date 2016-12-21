
% define a constraint
function y = constraintsExample1(x)
	% x is an [n x d] array where n is a number of points > 1
	% and d is the input dimension.
	
	% y must be a real value. If y > 0, the points will be
	% discarded. If y <= 0, the points will pass the constraint.
	
	% we block the bottom left (linear constraint)
	distances = sqrt(dot(x-(-1),x-(-1),2)); % euclidean distance from origin
	y(distances <= 0.5) = -1;
	y(distances > 0.5) = 1;
end