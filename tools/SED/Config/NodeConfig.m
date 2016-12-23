%> @brief The node config class.
%> Contains all configuration information for a particular object that
%> must be constructed.
classdef NodeConfig
	
	properties
		node;
	end
	
	properties (Constant)
		TrueStrings = {'yes', 'true', 'enable', 'on', '1'};
		FalseStrings = {'no', 'false', 'disable', 'off', '0', 'donotwant'};
	end
	
	methods
		
		%> @brief Constructor. Takes a DOM node.
		function config = NodeConfig(node)
			config.node = node;
		end
		
		%> @brief Return the value of an attribute of the config.
		function res = getAttrValue(this, key, defaultValue)
			res = char(this.node.getAttribute(key));
			if isempty(res) && exist('defaultValue', 'var')
				res = defaultValue;
			end
		end
		
		%> @brief Return a double attribute.
		function res = getDoubleAttrValue(this, key, defaultValue)
			res = this.getAttrValue(key, defaultValue);
			if ischar(res)
				res = str2double(res);
			end
		end
		
		%> @brief Return an integer attribute.
		function res = getIntAttrValue(this, key, defaultValue)
			res = this.getAttrValue(key, defaultValue);
			if ischar(res)
				res = str2double(res);
			end
		end
		
		%> @brief Return a boolean attribute.
		function res = getBooleanAttrValue(this, key, defaultValue)
			
			% get the value
			res = this.getAttrValue(key, defaultValue);
			
			% parse the text to a boolean
			for i = 1 : length(this.TrueStrings)
				if strcmpi(res, this.TrueStrings{i})
					res = true;
				end
			end
			for i = 1 : length(this.FalseStrings)
				if strcmpi(res, this.FalseStrings{i})
					res = false;
				end
			end
		end
		
		%> @brief Return a text option.
		function res = getOption(this, key, defaultValue)
			
			% get all options
			nodes = this.node.getChildNodes();
			
			for i = 0 : nodes.getLength() - 1
				n = nodes.item(i);
				
				% only consider options
				if ~strcmp(n.getNodeName(), 'Option')
					continue;
				end
				
				% make sure we get the right option
				if strcmp(n.getAttribute('key'), key)
					res = n.getAttribute('value');
					if isempty(res) && exist('defaultValue', 'var')
						res = defaultValue;
					end
					res = char(res);
					return;
				end
			end
			
			if exist('defaultValue', 'var')
				res = defaultValue;
			else
				res = [];
			end
		end
		
		%> @brief Return a double option.
		function res = getDoubleOption(this, key, defaultValue)
			if exist('defaultValue', 'var')
				res = this.getOption(key, defaultValue);
			else
				res = this.getOption(key);
			end
			if ischar(res)
				res = str2double(res);
			end
		end
		
		%> @brief Return an integer option.
		function res = getIntOption(this, key, defaultValue)
			if exist('defaultValue', 'var')
				res = this.getOption(key, defaultValue);
			else
				res = this.getOption(key);
			end
			if ischar(res)
				res = str2double(res);
			end
		end
		
		%> @brief Return a long option.
		function res = getLongOption(this, key, defaultValue)
			if exist('defaultValue', 'var')
				res = this.getOption(key, defaultValue);
			else
				res = this.getOption(key);
			end
			if ischar(res)
				res = str2double(res);
			end
		end
		
		%> @brief Return a boolean option.
		function res = getBooleanOption(this, key, defaultValue)
			
			% get the value
			if exist('defaultValue', 'var')
				res = this.getOption(key, defaultValue);
			else
				res = this.getOption(key);
			end
			
			% parse the text to a boolean
			for i = 1 : length(this.TrueStrings)
				if strcmpi(res, this.TrueStrings{i})
					res = true;
				end
			end
			for i = 1 : length(this.FalseStrings)
				if strcmpi(res, this.FalseStrings{i})
					res = false;
				end
			end
		end
		
		
		%> @brief Return a list of child nodes with a particular name.
		function list = selectNodes(this, name)
			nodes = this.node.getElementsByTagName(name);
			list = NodeList(nodes);
		end
		
		%> @brief Return a single node of a particular name. Returns an empty matrix if the node does not exist.
		function node = selectSingleNode(this, name)
			nodes = this.selectNodes(name);
			if nodes.size == 0
				node = [];
			else
				node = nodes.get(0);
			end
		end
	end
	
end

