classdef Minerva
    %MINERVA memory model
    %   Implements Hintzman's MINERVA 2 (1984) memory model
    %   Not restricted to binary vectors
    
    properties
        memory = 0;
        n = 0;
        m = 0;
        power = 3;
        name = 'minerva';
        labels = 0;
    end
    
    methods
        % construct MINERVA model
        function obj = Minerva(matrix,power,name,labels)
            obj.memory = matrix;
            [obj.m,obj.n] = size(matrix);
            
            if nargin > 1
                obj.power = power;
            end
            if nargin > 2
                obj.name = name;
            end
            if nargin > 3
                obj.labels = labels;
            end
        end
        
        % compute MINERVA echo
        function echo = Retrieve(obj,probe)
            echo = zeros(1,obj.n);
            for t=1:obj.m
                trace = obj.memory(t,:);
                similarity = vectorCosine(trace,probe);
                echo = echo + (similarity^obj.power)*trace;
            end
        end
        
        % add a memory trace to the model
        function obj = Add(obj,vector,label)
            obj.m = obj.m + 1;
            obj.memory(obj.m,:) = vector;
            if nargin > 2
                obj.labels(obj.m) = label;
            end
        end
        
        % get the similarity between the probe and indexed memory vector
        function similarity = GetSimilarity(obj,index,probe)
            item = obj.memory(index,:);
            if all(item==0)
                similarity = 0;
            else
                similarity = vectorCosine(item,probe);
            end
        end
    end
    
end

