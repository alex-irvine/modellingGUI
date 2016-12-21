%> An abstract base class for every SampleSelector. This interface must
%> be implemented if the object wants to be a stand-alone sample
%> selector.
classdef SampleSelector

	methods (Access = public, Abstract = true)
        [this, newSamples, priorities] = selectSamples(this, state);
	end

end
