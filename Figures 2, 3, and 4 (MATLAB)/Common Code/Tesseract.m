classdef Tesseract
    %TESSERACT memory model
    %   Implements tensor version of MINERVA
    %   Not restricted to binary vectors
    %   Accomodates second (matrix), third, and fourth order tensors
    %   Don't even think about going larger than fourth. Ugh.
    
    properties
        memory = 0;
        n = 0;
        m = 0;
        order = 4;
    end
    
    methods
        % construct TESSERACT model
        function obj = Tesseract(matrix,order)
            [m,n] = size(matrix);
            obj.n = n;

            if nargin > 1
                obj.order = order;
                if not(order==2) && not(order==3) && not(order == 4)
                    error('The memory tesseract must have an order of 2, 3, or 4');
                end
            end
            
            % initialize memory as an n^order data structure
            dimensions = zeros(1,obj.order);
            dimensions(:) = obj.n;
            obj.memory = zeros(dimensions);
            
            % construct tensor memories
            for i=1:m
                obj = obj.Add(matrix(i,:));
            end
        end
        
        % compute TESSERACT echo
        function echo = Retrieve(obj,probe)
            tensor = obj.memory;
            if obj.order == 4 % collapse to a third order tensor
                tensor = etprod('jkl',tensor,'ijkl',probe,'mi');
            end
            if obj.order >= 3 % collapse to a matrix
                tensor = etprod('kl',tensor,'jkl',probe,'mj');
            end
            % collapse to a vector (the echo)
            echo  = etprod('ml',tensor,'kl',probe,'mk');
        end
        
        % add a memory trace to the model
        function obj = Add(obj,item)
            obj.m = obj.m + 1;
            % construct trace
            item2 = item' * item;
            if obj.order >= 3
                item3 = etprod('ijk',item2,'ij',item,'mk');
            end
            if obj.order == 4
                item4 = etprod('ijkl',item3,'ijk',item,'ml');
            end
            
            % sum trace into memory
            if obj.order == 2
                obj.memory = obj.memory + item2;
            elseif obj.order == 3
                obj.memory = obj.memory + item3;
            elseif obj.order == 4
                obj.memory = obj.memory + item4;
            end
        end % function Add
        
    end % methods
        
end %classdef

