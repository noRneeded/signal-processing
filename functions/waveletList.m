% Wavelet library, as listed in wavemngr('read',1)
% wType = 'a' - all
%         'd' - discrete transform appliable

function list = waveletList(wType)

list={'haar'};
for i = 1 : 10 % till 45
    list(end + 1, 1)={strcat('db', num2str(i))};
end
for i = 2 : 8 % till 45
    list(end + 1)={strcat('sym', num2str(i))};
end
for i = 1 : 5
    list(end + 1) = {strcat('coif', num2str(i))};
end
list(end + 1: end + 15) = {'bior1.1'; 'bior1.3'; 'bior1.5';
                           'bior2.2'; 'bior2.4'; 'bior2.6'; 'bior2.8';
                           'bior3.1'; 'bior3.3'; 'bior3.5'; 'bior3.7'; 'bior3.9';
                           'bior4.4'; 'bior5.5'; 'bior6.8'};
list(end + 1 : end + 15) = {'rbio1.1'; 'rbio1.3'; 'rbio1.5';
                            'rbio2.2'; 'rbio2.4'; 'rbio2.6'; 'rbio2.8';
                            'rbio3.1'; 'rbio3.3'; 'rbio3.5'; 'rbio3.7'; 'rbio3.9';
                            'rbio4.4'; 'rbio5.5'; 'rbio6.8'};
if isequal(wType, 'a')
    list(end + 1) = {'meyr'};
end
list(end + 1) = {'dmey'};
if isequal(wType, 'a')
    for i = 1 : 8
        list(end + 1) = {strcat('gaus', num2str(i))};
    end
    list(end + 1 : end + 2) = {'mexh'; 'morl'};
    for i = 1 : 8
        list(end + 1) = {strcat('cgau', num2str(i))};
    end
    list(end + 1 : end + 5) = {'shan1-1.5'; 'shan1-1'; 'shan1-0.5'; 'shan1-0.1'; 'shan2-3'};
    list(end + 1 : end + 6) = {'fbsp1-1-1.5'; 'fbsp1-1-1'; 'fbsp1-1-0.5';
                               'fbsp2-1-1'; 'fbsp2-1-0.5'; 'fbsp2-1-0.1'};
    list(end + 1 : end + 4) = {'cmor1-1.5'; 'cmor1-1'; 'cmor1-0.5'; 'cmor1-0.1'};
end
list(end + 1 : end + 6) = {'fk4'; 'fk6'; 'fk8'; 'fk14'; 'fk18'; 'fk22'};