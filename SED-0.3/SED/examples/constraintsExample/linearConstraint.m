
% define a constraint
function y = linearConstraint(x)
	% example of a linear constraint
	
	% define the line
	p1 = [-1, -0.2];
	p2 = [-0.5, -1];
	A = (p2(2) - p1(2)) / (p2(1) - p1(1));
	b = p1(2) - A * p1(1);
	
	% check the points against the linear constraint
	out = x(:,2) - (x(:,1) .* A + b);
	y(out >= 0) = -1;
	y(out < 0) = 1;
end