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

%% 2. Wavelet block

WAVELET_LIST = waveletList('d'); % load library
resultTable = cell2table(cell(0,8), 'VariableNames', ...
            {'n', 'Wavelet', 'decLevel', 'energyW', 'norm', 'difOfFreq', 'cfreqW', 'passFreqsW'});

% Визначення центральних частот; смуг пропускання МВ; і похибкок реконструкції (ПР)
for iWavelet = 1 : length(WAVELET_LIST)
    maxDecompLevel(iWavelet, 1) = wmaxlev(N_SAMPLES, char(WAVELET_LIST(iWavelet)));
    [CL{iWavelet, 1}, CL{iWavelet, 2}] = wavedec(signal, maxDecompLevel(iWavelet), char(WAVELET_LIST(iWavelet))); % коефіцієнти розкладу DWT
    [energyW{iWavelet, 1}, energyW{iWavelet, 2}] = wenergy(CL{iWavelet, 1}, CL{iWavelet, 2}); % відсоток енергії в коефіцієнтах апроксимації і деталізації
    
    % Detail coefficients processing
    for iDetail = 1 : maxDecompLevel(iWavelet)
        [phi{iWavelet, iDetail},  psi{iWavelet, iDetail}] = wavefun(char(WAVELET_LIST(iWavelet)), iDetail); % scaling & wavelet functions
        fftWavelet{iWavelet, 2}{iDetail} = fft(psi{iWavelet, iDetail});
        lenHalfFftW{iWavelet, 2}(iDetail) = ceil(length(fftWavelet{iWavelet, 2}{iDetail})/2); % довжина половини вектора частот МВ
        halfFftW = abs(fftWavelet{iWavelet, 2}{iDetail}(1 : lenHalfFftW{iWavelet, 2}(iDetail))); % половина спектру МВ (тимчасова змінна)
        
        % Визначення центральної частоти (ЦЧ)
        iFrWall{iWavelet, 2}{iDetail} = find(halfFftW == max(halfFftW)); % всі індекси максимальних значень спектру МВ
        iFrW{iWavelet, 2}(iDetail) = iFrWall{iWavelet, 2}{iDetail}(ceil(length(iFrWall{iWavelet, 2}{iDetail})/2)); % центральний max індекс ...
        cfreqW{iWavelet, 2}(iDetail) = (iFrW{iWavelet, 2}(iDetail))/(lenHalfFftW{iWavelet, 2}(iDetail)); % нормоване значення центральної частоти МВ
        
        % Визначення смуги пропускання
        iFreqsW = find(halfFftW >= max(halfFftW)*THRESHOLD_NORMED); % індекси частот що більше порогу (тимчасова змінна)
        iPassFreqsW{iWavelet, 2}(iDetail, :) = [iFreqsW(1) iFreqsW(end)]; % індекси частот смуги пропускання МВ
        passFreqsW{iWavelet, 2}(iDetail, :) = iPassFreqsW{iWavelet, 2}(iDetail, :)/(lenHalfFftW{iWavelet, 2}(iDetail)); % нормовані частоти смуги пропускання МВ
        
        % Реконструкція кожного рівня деталізації
        levelW{iWavelet, 2}{iDetail} = zeros(size(CL{iWavelet, 1}));
        levelW{iWavelet, 2}{iDetail}(sum(CL{iWavelet, 2}(1 : end-iDetail-1))+1 : sum(CL{iWavelet, 2}(1 : end-iDetail-1))+CL{iWavelet, 2}(end-iDetail)) = ...
            CL{iWavelet, 1}(sum(CL{iWavelet, 2}(1 : end-iDetail-1))+1 : sum(CL{iWavelet, 2}(1 : end-iDetail-1))+CL{iWavelet, 2}(end-iDetail));
        Srec{iWavelet, 2}{iDetail} = waverec(levelW{iWavelet, 2}{iDetail}, CL{iWavelet, 2}, char(WAVELET_LIST(iWavelet))); % реконструйований сигнал
        normPsi(iWavelet, iDetail) = norm(signal-Srec{iWavelet, 2}{iDetail}); % похибка при реконструкції за обраним рівнем
        
        % Таблиця з результатами
        resultTable = [resultTable; {iWavelet, char(WAVELET_LIST(iWavelet)), iDetail, energyW{iWavelet, 2}(iDetail), normPsi(iWavelet, iDetail), abs(cfreqW{iWavelet, 2}(iDetail)-iCentralFreq/(SAMPLE_HALF-1)), cfreqW{iWavelet, 2}(iDetail), passFreqsW{iWavelet, 2}(iDetail, :)}];
    end
    
    % Обробка коефіцієнтів апроксимації
    fftWavelet{iWavelet, 1}{1} = fft(phi{iWavelet, iDetail}); % спектр МВ
    lenHalfFftW{iWavelet, 1}(1) = ceil(length(fftWavelet{iWavelet, 1}{1})/2); % довжина половини вектора частот МВ
    halfFftW = abs(fftWavelet{iWavelet, 1}{1}(1 : lenHalfFftW{iWavelet, 1}(1))); % половина спектру МВ (тимчасова змінна)
    
    % Визначення центральної частоти (ЦЧ)
    iFrWall{iWavelet, 1}{1} = find(halfFftW == max(halfFftW)); % всі індекси максимальних значень спектру МВ
    iFrW{iWavelet, 1}{1} = iFrWall{iWavelet, 1}{1}(ceil(length(iFrWall{iWavelet, 1}{1})/2)); % центральний max індекс ...
    cfreqW{iWavelet, 1}{1} = (iFrW{iWavelet, 1}{1})/(lenHalfFftW{iWavelet, 1}(1)); % нормоване значення центральної частоти МВ
    
    % Визначення смуги пропускання
    iFreqsW = find(halfFftW >= max(halfFftW)*THRESHOLD_NORMED); % індекси частот що більше порогу (тимчасова змінна)
    iPassFreqsW{iWavelet, 1}(1, :) = [iFreqsW(1) iFreqsW(end)]; % індекси частот смуги пропускання МВ
    passFreqsW{iWavelet, 1}(1, :) = iPassFreqsW{iWavelet, 1}(1, :)/(lenHalfFftW{iWavelet, 1}(1)); % нормовані частоти смуги пропускання МВ
    
    % Реконструкція за коефіцієнтами апроксимації
    levelW{iWavelet, 1}{1} = zeros(size(CL{iWavelet, 1}));
    levelW{iWavelet, 1}{1}(1 : CL{iWavelet, 2}(1)) = CL{iWavelet, 1}(1 : CL{iWavelet, 2}(1));
    Srec{iWavelet, 1}{1} = waverec(levelW{iWavelet, 1}{1}, CL{iWavelet, 2}, char(WAVELET_LIST(iWavelet)));
    normPhi(iWavelet, 1) = norm(signal-Srec{iWavelet, 1}{1});
    
    % Таблиця з результатами
    resultTable = [resultTable; {iWavelet, char(WAVELET_LIST(iWavelet)), -1, energyW{iWavelet, 1}, normPhi(iWavelet, 1), abs(cfreqW{iWavelet, 1}{1}-iCentralFreq/(SAMPLE_HALF-1)), cfreqW{iWavelet, 1}{1}, passFreqsW{iWavelet, 1}(1, :)}];
end

nResults = 3; % кількість результатів що буде відображено

bestByCentralF = sortrows(resultTable,'difOfFreq');
for iResult = 1 : nResults
    foo = [table2array(bestByCentralF(iResult, 1)) sign(table2array(bestByCentralF(iResult, 3)))/2+1.5 abs(table2array(bestByCentralF(iResult, 3)))];
    figure(4), subplot(nResults, 1, iResult) % спектрограми
    specgram(Srec{foo(1), foo(2)}{foo(3)})
    title(([char(table2array(bestByCentralF(iResult, 2))) ' lev' num2str(table2array(bestByCentralF(iResult, 3))) ' метод ЦЧ']));
    
    figure(3) % спектри
    plot([1 : lenHalfFftW{foo(1), foo(2)}(foo(3))]./lenHalfFftW{foo(1), foo(2)}(foo(3)),...
        abs(fftWavelet{foo(1), foo(2)}{foo(3)}(1 : lenHalfFftW{foo(1), foo(2)}(foo(3))))./ ...
        max(abs(fftWavelet{foo(1), foo(2)}{foo(3)}(1 : lenHalfFftW{foo(1), foo(2)}(foo(3))))), '--')
    
    figure(2); % часова область
        plot(Srec{foo(1), foo(2)}{foo(3)}, '--')
        
    legendW{end+1} = [char(table2array(bestByCentralF(iResult, 2))) ' lev' num2str(table2array(bestByCentralF(iResult, 3))) ' метод ЦЧ'];
end
figure(2), legend(legendW{[1 3:end]}); % додаємо назви кривих
figure(3), legend(legendW);


bestByNorm = sortrows(resultTable,'norm');
for iResult = 1 : nResults
    foo = [table2array(bestByNorm(iResult, 1)) sign(table2array(bestByNorm(iResult, 3)))/2+1.5 abs(table2array(bestByNorm(iResult, 3)))];
    figure(5), subplot(nResults, 1, iResult) % спектрограми
    specgram(Srec{foo(1), foo(2)}{foo(3)})
    title(([char(table2array(bestByNorm(iResult, 2))) ' lev' num2str(table2array(bestByNorm(iResult, 3))) ' метод ПР']));
    
    figure(3) % спектри
    plot([1 : lenHalfFftW{foo(1), foo(2)}(foo(3))]./lenHalfFftW{foo(1), foo(2)}(foo(3)),...
        abs(fftWavelet{foo(1), foo(2)}{foo(3)}(1 : lenHalfFftW{foo(1), foo(2)}(foo(3))))./ ...
        max(abs(fftWavelet{foo(1), foo(2)}{foo(3)}(1 : lenHalfFftW{foo(1), foo(2)}(foo(3))))))
    
    figure(2); % часова область
        plot(Srec{foo(1), foo(2)}{foo(3)})
        
    legendW{end+1} = [char(table2array(bestByNorm(iResult, 2))) ' lev' num2str(table2array(bestByNorm(iResult, 3))) ' метод ПР'];
end
figure(2), legend(legendW{[1 3:end]}); % додаємо назви кривих
figure(3), legend(legendW);
