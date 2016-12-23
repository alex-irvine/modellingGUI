% ?> @brief Test for the availability of a license on this system.
function [available] = checkLicense(name)

% our persistent variable
persistent prevChecks
if isempty(prevChecks)
	prevChecks = cell(0,2);
end

% check if we've checked for this toolbox before
for i = 1 : size(prevChecks,1)
	if strcmp(prevChecks{i,1}, name)
		available = prevChecks{i,2};
		return;
	end
end

% add to the list of prev checks
n = size(prevChecks,1) + 1;
prevChecks{n,1} = name;

toolboxes = ver;
for i = 1 : length(toolboxes)
	if strcmp(toolboxes(i).Name, name)
		available = true;
		prevChecks{n,2} = available;
		return;
	end
end
available = false;
prevChecks{n,2} = available;
end

