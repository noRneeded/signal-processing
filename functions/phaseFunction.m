% Evaluates phase function and its derivatives
% in - struct
%      .nHarmonic = N [1x1]
%      .amplitudeList [Nx1]
%      .freqList      [Nx1]
%      .phaseList     [Nx1]
%      .derivative    [1x1]
% time - vector

function result = phaseFunction(in, time)

% Unify time dimmension
dimension = size(time);
if (length(dimension) > 2 || min(dimension) > 2 || max(dimension) < 2)
    error('Not a vector')
elseif (dimension(2) == 1)
    time = time';
end
clear dimension

% Doubling time for further calculatings
time = ones(in.nHarmonic, 1) * time;

% Evaluating phase function
harmonicArray = (in.freqList .* time + in.phaseList) * 2 * pi;
switch in.derivative
    case 0
        result =   in.amplitudeList ./ in.freqList .* sin(harmonicArray);
    case 1
        result =   in.amplitudeList .* cos(harmonicArray);
    case 2
        result = - in.amplitudeList .* in.freqList .* sin(harmonicArray);
end
result = sum(result);