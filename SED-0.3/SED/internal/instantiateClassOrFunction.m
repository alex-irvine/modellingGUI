%>	This function is responsible for instantiating an object based on a
%>	node from the config. If the type specified in the node corresponds to
%>	a function, the defaultType is instantiated instead, and the
%>	defaultType should use the function internally. If it is a class, the
%>	type is instantiated using instantiate().
function [object] = instantiateClassOrFunction(node, oldConfig, defaultType)

logger = Logger.getLogger('Matlab.instantiateClassOrFunction');

% Wrap in a NodeConfig object
if ~isa( node, 'NodeConfig' )
	node = NodeConfig(node);
end

% get type field - must point to subclass of defaultType
type = node.getAttrValue('type');

% see if this is a class or function
if isempty(meta.class.fromName(type))
    
    % create copy of config
    config = oldConfig;
    config.self = node;
	
	try
		% create default type... this will internally use the function for
		% performing the action instead of a subclass of the default type
		object = eval([defaultType '(config)']);
	catch err
		msg = sprintf('Failed to create object of type %s, error is "%s', type, err.message);
		printStackTrace(err.stack, logger);
		logger.severe(msg);
	end
	

	
% class - instantiate it normally
else
	object = instantiate(node, oldConfig);
end


% make sure the subclass matches
if ~isa(object, defaultType)
	msg = sprintf('Object of type %s is not a subclass of %s', type, defaultType);
	printStackTrace(err.stack, logger);
	logger.severe(msg);
end


end

