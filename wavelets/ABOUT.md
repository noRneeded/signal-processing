# Wavelet structure explaining

| w. |               |                                           |
|----|:-------------:|:-----------------------------------------:|
|    | name          |                                           |
|    | freqThreshold |                                           |
|    | maxDecLevel   |                                           |
|    | decomp.	     | (wavedec function result)                 |
|    |               | coef                                      |
|    |               | ind                                       |
|    | approx.       | (contains one last wavedec level)         |
|    |               | energy                                    |
|    |               | function                                  |
|    |               | fft                                       |
|    |               | harmonic                                  |
|    |               | iPassband                                 |
|    |               | iCentralFreq                              |
|    |               | coef                                      |
|    |               | reconstruct                               |
|    |               | norm                                      |
|    | detail.       |(same as approx. but contains maxDecLevel) |
|    |               | energy                                    |
|    |               | function                                  |
|    |               | fft                                       |
|    |               | harmonic                                  |
|    |               | iPassband                                 |
|    |               | iCentralFreq                              |
|    |               | coef                                      |
|    |               | reconstruct                               |
|    |               | norm                                      |
