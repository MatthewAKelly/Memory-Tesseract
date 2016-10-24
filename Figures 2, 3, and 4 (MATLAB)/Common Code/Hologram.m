classdef Hologram
    %HOLOGRAM memory model
    %   Implements a simple holographic vector memory
    %   Auto-associative
    
    properties
        memory = 0;
        n = 0;
        m = 0;
    end
    
    methods
        % construct HOLOGRAM model
        function obj = Hologram(items)
            [obj.m,obj.n] = size(items);
            
            obj.memory = zeros(1,obj.n);
            
            % add memories
            for i=1:obj.m
                obj = obj.Add(items(i,:));
            end
        end
        
        % compute HOLOGRAM echo
        function echo = Retrieve(obj,probe)
            echo = ccorr(probe,obj.memory);
        end
        
        % add a memory trace to the model
        function obj = Add(obj,item)
            obj.m = obj.m + 1;
            % construct trace
            trace = cconv(item,item,obj.n);
            obj.memory = obj.memory + trace;
        end % function Add
        
    end % methods
        
end %classdef

