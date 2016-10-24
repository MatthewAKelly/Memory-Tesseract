function [ results ] = iterateModelsExp(f)
%INTERSECTOR P EXP runs an experiment on the intersector
%   Generates data for Figure 2 in Kelly, Mewhort, and West, "The Memory
%   Tesseract: Mathematical Equivalence Between Composite and Separate 
%   Storage Memory Models", Journal of Mathematical Psychology.

% PARAMETERS
N = 64;
M = 3;
PERMS = 400;
MINERVA_EXPONENT = 3;
ITERATIONS = 5;
RUNS = 50;
NUM_MODELS = 5;
results = zeros(NUM_MODELS,ITERATIONS,RUNS);

for r=1:RUNS
    % create vectors
    items = multiVector(M,N);
    memory = items(1:2,:);
    %probe  = vecNorm(0.4*items(1,:) + 0.2*items(2,:) + items(3,:));
    probe  = vecNorm(items(1,:) + 0.8*items(2,:));
    target = items(1,:);
    
    % create models
    minerva = Minerva(memory,MINERVA_EXPONENT);
    tesseract = Tesseract(memory,4);
    matrix = Tesseract(memory,2);
    intersector = Intersector(memory,PERMS);
    hologram = Hologram(memory);
    models = {minerva,tesseract,hologram,intersector,matrix};
    
    for m=1:NUM_MODELS
        model = models{m};
        % the state vector is initially the probe
        state = probe;
        for i=1:ITERATIONS
            echo = model.Retrieve(state);
            results(m,i,r) = vectorCosine(target,echo);
            % the echo becomes the new state vector
            state = vecNorm(echo);
        end
    end
end

avResults = sum(results,3) / RUNS;

% display average results
figure(f)

plot(avResults')
title('A comparison of iterative retrieval across memory models');

s = cell(1,NUM_MODELS);
for m = 1:NUM_MODELS
    s{m} = class(models{m});
end
legend(s)

% avoid displaying from iteration 0
xlim([1 ITERATIONS])

% range of cosine values shown
ylim([0 1.1])
%ylim([-1.1 1.1])

set(gca,'XTick',1:ITERATIONS)

% label axes
xlabel('iteration')
ylabel('cosine between echo and target')

end

