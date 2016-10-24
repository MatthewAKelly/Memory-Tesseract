function [ results ] = intersectorPExp(f)
%INTERSECTOR P EXP runs an experiment on the intersector
%   Generates data for Figure 3 in Kelly, Mewhort, and West, "The Memory
%   Tesseract: Mathematical Equivalence Between Composite and Separate 
%   Storage Memory Models", Journal of Mathematical Psychology.

% PARAMETERS
N = 64;
M = 3;
CONDITIONS = [25,50,100,200,400,800];
NUM_COND = length(CONDITIONS);
ITERATIONS = 10;
RUNS = 1;

results = zeros(NUM_COND,ITERATIONS,RUNS);

for c=1:NUM_COND
    perms = CONDITIONS(c);
    for r=1:RUNS
        items = multiVector(M,N);
        memory = items(1:2,:);
        probe  = vecNorm(items(1,:) + 0.8*items(2,:) + items(3,:));
        target = items(1,:);
        model = Intersector(memory,perms);
        for i=1:ITERATIONS
            echo = model.Retrieve(probe);
            results(c,i,r) = vectorCosine(target,echo);
            probe = vecNorm(echo);
        end
    end
end

avResults = sum(results,3) / RUNS;

% display average results
figure(f)

plot(avResults')
title('Varying number of memory vectors (p) in Levy & Gayler (2009) model');

s = cell(1,NUM_COND);
for c = 1:NUM_COND
    s{c} = num2str(CONDITIONS(c));
end
legend(s)

% avoid displaying from iteration 0
xlim([1 ITERATIONS])

% range of cosine values shown
ylim([-1.1 1.1])

set(gca,'XTick',1:ITERATIONS)

% label axes
xlabel('iteration')
ylabel('cosine between echo and target')

end

