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
