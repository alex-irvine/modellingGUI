
% define a constraint
function y = problemConstraint(x)
	% x is an [n x d] array where n is a number of points > 1
	% and d is the input dimension.
	
	% y must be a real value. If y > 0, the points will be
	% discarded. If y <= 0, the points will pass the constraint.
	
	% example: block every point outside of 1.5 * the unit circle
	distances = sqrt(dot(x,x,2)); % euclidean distance from origin
	y(distances <= 1.5) = -1;
	y(distances > 1.5) = 1;
end