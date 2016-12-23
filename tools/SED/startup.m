
% add path
addpath(genpath(cd));

% check version
minVersion = '7.7';
if(verLessThan('matlab', minVersion))
	disp(['[WARNING] The SED Toolbox needs at least MATLAB version ' minVersion ' or higher, which you don''t appear to have! Depending on what you need, it may or may not work...']);
end
