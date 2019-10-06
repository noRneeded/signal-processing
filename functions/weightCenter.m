% Evaluates index of normalized vector

function index = weightCenter(vector, normalizedThreshold)

% Check if it`s a vector
if (min(size(vector)) > 1)
    error('Not a vector');
end

% Normalizing
vector = abs(vector);
vector = vector ./ max(vector);

% Index evaluating
index = find(vector > normalizedThreshold);
index = ceil((index(1) + index(end)) / 2);