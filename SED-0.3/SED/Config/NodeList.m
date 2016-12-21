%> @brief This mimics a List object from Java.
classdef NodeList
	
	properties
		nodes;
	end
	
	methods
		
		%> @brief The constructor. Takes a NodeList object.
		function this = NodeList(nodes)
			this.nodes = nodes;
		end
		
		
		%> @brief Get the number of nodes in the list.
		function size = size(this)
			size = this.nodes.getLength();
		end
		
		%> @brief Return the i-th item. Starting index is 0.
		function node = get(this, i)
			node = this.nodes.item(i);
		end
	end
	
end

