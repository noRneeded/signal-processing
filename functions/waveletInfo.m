% Evaluates wavelet decomposition of a signal, and its additional info
% w - wavelet struct
% SIGNAL - numeric vector

function w = waveletInfo(w, SIGNAL)

% Check input data
checkInfo(w.name, SIGNAL);

% Filling up the resulting structure
N_SAMPLES = length(SIGNAL);
w.maxDecLevel = wmaxlev(N_SAMPLES, w.name);

% Evaluate coefficients and their energy
[w.decomp.coef, w.decomp.ind] = wavedec(SIGNAL, w.maxDecLevel, w.name);
[w.approx.energy, w.detail.energy] = wenergy(w.decomp.coef, w.decomp.ind);

% Wavelet (detail) info processing, one level at a time
for iDecLevel = 1 : w.maxDecLevel
    [w.approx.function{iDecLevel},  w.detail.function{iDecLevel}] = wavefun(w.name, iDecLevel);
    w.detail = levelInfo(w, 'd', iDecLevel);
    w.detail.norm(iDecLevel, 1) = norm(SIGNAL - w.detail.reconstruct{iDecLevel});
end

% Not Pretty yet
% One level scaling (approx) info processing
w.approx = levelInfo(w, 'a', 1);
w.approx.norm(1, 1) = norm(SIGNAL - w.approx.reconstruct{1});

end

%% Subfunction for processing coefficients in frequency domain
function level = levelInfo(subW, approxOrDetail ,iLevel)

% Select coefficients type
switch approxOrDetail
    case 'a'
        level = subW.approx;
    case 'd'
        level = subW.detail;
    otherwise
        error('Wrong coefficients type');
end

% Frequency domain
level.fft{iLevel, 1} = fft(level.function{iLevel});
iHalfFft = ceil(length(level.fft{iLevel})/2);
level.harmonic{iLevel, 1} = abs(level.fft{iLevel}(1 : iHalfFft));

% Evaluating indexes
harmonicNormed = level.harmonic{iLevel};
harmonicNormed = harmonicNormed ./ max(harmonicNormed);
iPassband = find(harmonicNormed(2 : end) >= subW.freqThreshold);
level.iPassband(iLevel, :) = [iPassband(1) iPassband(end)] + 1;
level.iCentralFreq(iLevel, 1) = weightCenter(level.harmonic{iLevel}, subW.freqThreshold);

% Reconstruction
iBegin = sum(subW.decomp.ind(1 : end - iLevel - 1)) + 1;
iEnd = iBegin - 1 + subW.decomp.ind(end - iLevel);
level.coef{iLevel} = zeros(size(subW.decomp.coef));
level.coef{iLevel}(iBegin : iEnd) = subW.decomp.coef(iBegin : iEnd);
level.reconstruct{iLevel} = waverec(level.coef{iLevel}, subW.decomp.ind, subW.name);
end

%% Subfunction that checks input data
function checkInfo(NAME, SIGNAL)
% Check wavelet data type
if (class(NAME) ~= 'char')
    error('Wrong wavelet type');
end

% Check wavelet name
WAVELET_LIST = waveletList('a');
k = length(WAVELET_LIST);
isExist = false;
while k > 0
    if (isequal(WAVELET_LIST{k}, NAME))
        isExist = true;
        k = 0;
    else
        k = k - 1;
    end
end
if ~isExist
    error('No such wavelet');
end

% Check signal
if (class(SIGNAL) ~= 'double')
    error('Signal not numeric');
end
if (min(size(SIGNAL)) > 1)
    error('Signal not a vector');
end
end