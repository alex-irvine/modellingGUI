
% define a constraint
function y = nonlinearConstraint(x)
	% x is an [n x d] array where n is a number of points > 1
	% and d is the input dimension.
	
	% y must be a real value. If y > 0, the points will be
	% discarded. If y <= 0, the points will pass the constraint.
	
	% example: block every point too close to the origin
	distances = sqrt(dot(x,x,2)); % euclidean distance from origin
	y(distances <= 0.5) = 1;
	y(distances > 0.5) = -1;
end