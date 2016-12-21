%>	This function is responsible for instantiating an object based on a
%>	node from the config. This node is then used to fetch data about this
%>	object from the config, and to instantiate the object with the
%>	appropriate settings and data.
function [object] = instantiate(node, parentConfig)

logger = Logger.getLogger('Matlab.instantiate');

% Wrap in a NodeConfig object
if ~isa( node, 'NodeConfig' )
	node = NodeConfig(node);
end

% get type and id fields
type = node.getAttrValue('type');

% create a copy of the parent config
config = parentConfig;

% set self in config
config.self = node;

% create the object
try
    % do the actual instantiation
    object = eval([type '(config)']);

catch err
    msg = sprintf('Failed to create object of type %s, error is "%s', type, err.message );
    printStackTrace(err.stack, logger);
	logger.severe(msg);
end

end

