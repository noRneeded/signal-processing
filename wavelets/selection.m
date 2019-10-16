% Mother wavelet selection technique

% Initial preparation
close all
clear

%% 1. Signal block

% Environmental constants
FS = 1e6; % sampling frequency
DURATION = 2e-3;
TIME_VECTOR = 0 : 1 / FS : DURATION;
N_SAMPLES = length(TIME_VECTOR);
SAMPLE_HALF = ceil(N_SAMPLES / 2);
FREQUENCY_VECTOR =   (0 : SAMPLE_HALF - 1) * FS / N_SAMPLES;
NORMED_FREQ_VECTOR = (0 : SAMPLE_HALF - 1) / (ceil(N_SAMPLES / 2)-1);

% Modulating signal parameters
parameter.nHarmonic = 3;
parameter.amplitudeList = rand(parameter.nHarmonic, 1) * 40e3;
parameter.freqList = rand(parameter.nHarmonic, 1) * 10/DURATION;
parameter.phaseList = rand(parameter.nHarmonic, 1);
parameter.derivative = 1;

% Creating radio signal
instantFrequency = phaseFunction(parameter, TIME_VECTOR);
CARRIER_FREQ = 0.4 * FS / 2;
DEVIATION = 0.2 * CARRIER_FREQ;
signal = fmmod(instantFrequency / max(abs(instantFrequency)), CARRIER_FREQ, FS, DEVIATION)';

% Frequency domain
THRESHOLD_NORMED = 0.2; % determing signal passband
fftSignal = fft(signal);
signalHarmonics = abs(fftSignal(1 : SAMPLE_HALF));

iPassband = find(signalHarmonics >= max(signalHarmonics)*THRESHOLD_NORMED);
iPassband = [iPassband(1) iPassband(end)];
iCentralFreq = weightCenter(signalHarmonics, THRESHOLD_NORMED);
centralFreqNormed = iCentralFreq / SAMPLE_HALF;

% Signal plots
figure(1), specgram(signal), title('Radio signal spectrogram')

figure(2), title('Radio signal in time domain')
cla, hold on, grid on, axis tight
plot(signal, 'linewidth', 3)

figure(3), title('Frequency domain')
cla, hold on, grid on, axis tight
stem(NORMED_FREQ_VECTOR, signalHarmonics ./ max(signalHarmonics), 'k.')
stem(NORMED_FREQ_VECTOR(iCentralFreq), 1, 'r*', 'linewidth', 5)
legendW = [{'Radio signal'}; {'Central freq.'}];
legend((legendW));

%% 2. Wavelet block
W_NAME = waveletList('d'); % w stands for wavelet

% Here will be sorted data from 'w' struct, might be preferable for user
result = {'number', 'wavelet', 'decLevel', 'energy', 'norm', 'difOfFreq', 'freqNormed', 'passband'};
result = cell2table(cell(0, 8), 'VariableNames', result);

% Evaluating wavelet central frequency; passband; and reconstruction error
for iW = 1 : length(W_NAME)
    
    % Fulfilling wavelet struct with info
    w{iW, 1}.name = W_NAME{iW};
    w{iW}.freqThreshold = THRESHOLD_NORMED;
    w{iW} = waveletInfo(w{iW}, signal);
    
    % Restructuring wavelet info for user
    for iLevel = 1 : w{iW}.maxDecLevel
        harmonicLength = length(w{iW}.detail.harmonic{iLevel});
        freqNormed = w{iW}.detail.iCentralFreq(iLevel) / harmonicLength;
        passband = w{iW}.detail.iPassband(iLevel, :) ./ harmonicLength;
        difOfFreq = abs(centralFreqNormed - freqNormed);
        result = [result; {iW, w{iW}.name, iLevel, w{iW}.detail.energy(iLevel), ...
            w{iW}.detail.norm(iLevel), difOfFreq, freqNormed, passband}];
    end

    % Not pretty yet
    % Approximation part
    harmonicLength = length(w{iW}.approx.harmonic{1});
    freqNormed = w{iW}.approx.iCentralFreq(1) / harmonicLength;
    passband = w{iW}.approx.iPassband(1, :) ./ harmonicLength;
    difOfFreq = abs(centralFreqNormed - freqNormed);
    result = [result; {iW, w{iW}.name, -1, w{iW}.approx.energy(1), ...
        w{iW}.approx.norm(1), difOfFreq, freqNormed, passband}];
end
