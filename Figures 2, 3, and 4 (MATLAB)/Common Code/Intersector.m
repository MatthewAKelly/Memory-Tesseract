classdef Intersector
    %INTERSECTOR memory model (Levy & Gayler, 2009; Gayler & Levy, 2009)
    
    properties
        % actual values of these properties are set in the constructor
        memory = 0;
        % n: the dimensionality of an item
        n = 0;
        % m: the number of items
        m = 0;
        
%       p: number of permutations, i.e., the number of lateral inhibition
%          networks operating in parallel. The more networks, the better
%          the system does clean-up. Hundreds of them necessary.
        p = 0;
        
        % the permutations
        p1 = 0;
        p2 = 0;
        p3 = 0;
        % the inverse permutations
        q1 = 0;
        q2 = 0;
        q3 = 0;
        % the approximate inverse
        ainv = 0;
        
        % TRUE  = use MAP encoding (Gayler, 2003)
        % FALSE = use HRRs (Plate, 1995)
        MAP = false;
        HRR = true;
        % ERROR-CORRECTING LEARNING true/false = on/off
        ERROR = false;
    end
    
    methods
        % construct INTERSECTOR model
        function obj = Intersector(items,p,MAP,ERROR)
            [m,n] = size(items);
            obj.n = n;
            obj.p = p;
            
            % flag to use MAP codes instead of HRRs
            if nargin > 2
                obj.MAP = MAP;
                obj.HRR = not(MAP);
            end
            if nargin > 3
                obj.ERROR = ERROR;
            end
            
            % create the network
            obj.memory = zeros(p,n);
            
            % store 3 sets of permutations for each of p parallel circuits
            obj.p1 = zeros(p,n);
            obj.p2 = zeros(p,n);
            obj.p3 = zeros(p,n);
            
            % create permutations
            for k = 1:p
                obj.p1(k,:) = randperm(n);
                obj.p2(k,:) = randperm(n);
                obj.p3(k,:) = randperm(n);
            end
            
            % inverse
            if MAP % inverse for MAP codes is the thing itself, [1,...,N]
                obj.ainv = 1:n;
            else   % the inverse for HRRs is [1,N,...,2]
                obj.ainv = [1,n:-1:2];
            end
            % inverse permutations
            obj.q1 = obj.p1(:,obj.ainv);
            obj.q2 = obj.p2(:,obj.ainv);
            obj.q3 = obj.p3(:,obj.ainv);

            % add items to memory
            for j = 1:m
                obj = obj.Add(items(j,:));
            end
        end
        
        % compute INTERSECTOR echo
        function echo = Retrieve(obj,probe)
            % if using MAP codes, make probe bipolar
            if obj.MAP
                probe = sign(probe);
            end
            
            % intersect state vector with itself
            echo = zeros(1,obj.n);
            
            % average over k units of the model
            for k = 1:obj.p
                % permute probe by inverse p1, p2, and p3 for unit k
                % then compute the fourier transform of each
                probeP1    = probe(obj.q1(k,:));
                probeP2    = probe(obj.q2(k,:));
                probeP3    = probe(obj.q3(k,:));
                if obj.HRR
                    probeP1    = fft(probeP1);
                    probeP2    = fft(probeP2);
                    probeP3    = fft(probeP3);
                end
                % compute the probe
                probeK     = probeP1 .* probeP2 .* probeP3;
                % compute the fourier transform of memory vector k
                if obj.MAP
                    memoryK    = sign(obj.memory(k,:));
                else
                    memoryK    = fft(obj.memory(k,:));
                end
                % echo is circular convolution of probe with memory
                echoK = probeK .* memoryK;
                if obj.HRR
                    echoK = ifft(echoK);
                end
                % sum across all echoes
                echo = echo + echoK;
            end
            % take the mean of the echoes
            if obj.HRR
                echo = echo / obj.p;
            else
                echo = sign(echo);
                % change zeroes in echo to the value in the probe
                echo(echo == 0) = probe(echo == 0);
            end
        end
        
        function vector = MakeBipolar(obj,vector)
            % cast vector to +1, -1, and 0
            vector = sign(vector);
            % replace any zeros with random values
            if any(vector==0)
                r = sign(rand(1,obj.n) - 0.5);
            	vector(vector==0) = r(vector==0);
            end
        end
        
        % add a memory trace to the model
        function obj = Add(obj,x)
            % if using MAP codes, make x bipolar
            if obj.MAP
                x = sign(x);
            end
            % if using prediction error correction
            % then associate x^3 with the error rather than x
            if obj.ERROR
                prediction = obj.Retrieve(x);
                if obj.MAP
                    err = sign(x - prediction);
                else
                    err = vecNorm(x) - vecNorm(prediction);
                end
                x0  = err;
            else % otherwise associate x^3 with x
                x0 = x;
            end
            if obj.HRR
                x0 = fft(x0);
            end
            for k = 1:obj.p
                % compute circular convolution:
                % trace = x * P x * P2 x * P3 x
                x1 = x(obj.p1(k,:));
                x2 = x(obj.p2(k,:));
                x3 = x(obj.p3(k,:));
                if obj.HRR
                    x1 = fft(x1);
                    x2 = fft(x2);
                    x3 = fft(x3);
                end
                trace = x0 .* x1 .* x2 .* x3;
                if obj.HRR
                    trace = ifft(trace);
                end
                % add trace to memory
                obj.memory(k,:) = obj.memory(k,:) + trace;
            end
            obj.m = obj.m + 1;
        end
        
    end % end methods
    
end % end classdef

