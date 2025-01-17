clc
close all
clear;

%% Part1
clc;
load('n_422.mat');
load('n_424.mat');
fs = 250;
t = 0.0001:1/fs:10;

%%%%% Normal and arrhythmian epochs
normal_n22 = n_422(1 : 10*fs);
normal_n24 = n_424(1 : 10*fs);
arrhythmia_n22 = n_422(61288 : 61287 + 10*fs);
arrhythmia_n24 = n_424(27249 : 27248 + 10*fs);

%%%%% Pwelch of the signals
pwelch_norm_n22 = fftshift(pwelch(normal_n22));
pwelch_norm_n24 = fftshift(pwelch(normal_n24));
pwelch_arrhythm_n22 = fftshift(pwelch(arrhythmia_n22));
pwelch_arrhythm_n24 = fftshift(pwelch(arrhythmia_n24));

%%%%% Plotting pwelches
N = length(pwelch_norm_n22);
f = fs*(-N/2:N/2-1)/N;

figure('Name',"Part1_n22");
subplot(2,1,1);
plot(f,pwelch_norm_n22);
title("Normal epoch");
xlabel("Frequency(Hz)");
ylabel("Amplitude");
xlim([0,30]);
grid minor
subplot(2,1,2);
plot(f,pwelch_arrhythm_n22);
title("Arrythmia epoch");
xlabel("Frequency(Hz)");
ylabel("Amplitude");
xlim([0,30]);
grid minor
saveas(gcf,"Part1_n22.png");

figure('Name',"Part1_n24");
subplot(2,1,1);
plot(f,pwelch_norm_n24);
title("Normal epoch");
xlabel("Frequency(Hz)");
ylabel("Amplitude");
xlim([0,30]);
grid minor
subplot(2,1,2);
plot(f,pwelch_arrhythm_n24);
title("Arrythmia epoch");
xlabel("Frequency(Hz)");
ylabel("Amplitude");
xlim([0,30]);
grid minor
saveas(gcf,"Part1_n24.png");

%% Part2
%%%%% ffts of signals
normal_n22_fft = fftshift(fft(normal_n22));
normal_n24_fft = fftshift(fft(normal_n24));
arrhythmia_n22_fft = fftshift(fft(arrhythmia_n22));
arrhythmia_n24_fft = fftshift(fft(arrhythmia_n24));

N = length(normal_n22_fft);
f = fs*(-N/2:N/2-1)/N;

%%%%% Time and fourier plots

% n_22
figure('Name',"Part2_n22");
subplot(2,2,1);
plot(t,normal_n22);
title("Normal epoch");
xlabel("Time(s)");
ylabel("Amplitude");
grid minor
subplot(2,2,2);
plot(f,abs(normal_n22_fft));
title("Normal epoch");
xlabel("Frequency(Hz)");
ylabel("Amplitude");
xlim([0,30]);
grid minor
subplot(2,2,3);
plot(t,arrhythmia_n22);
title("Arrythmia epoch");
xlabel("Time(s)");
ylabel("Amplitude");
grid minor
subplot(2,2,4);
plot(f,abs(arrhythmia_n22_fft));
title("Arrythmia epoch");
xlabel("Frequency(Hz)");
ylabel("Amplitude");
xlim([0,30]);
grid minor
saveas(gcf,"Part2_n22.png");

%n_24
figure('Name',"Part2_n24");
subplot(2,2,1);
plot(t,normal_n24);
title("Normal epoch");
xlabel("Time(s)");
ylabel("Amplitude");
grid minor
subplot(2,2,2);
plot(f,abs(normal_n24_fft));
title("Normal epoch");
xlabel("Frequency(Hz)");
ylabel("Amplitude");
xlim([0,30]);
grid minor
subplot(2,2,3);
plot(t,arrhythmia_n24);
title("Arrythmia epoch");
xlabel("Time(s)");
ylabel("Amplitude");
grid minor
subplot(2,2,4);
plot(f,abs(arrhythmia_n24_fft));
title("Arrythmia epoch");
xlabel("Frequency(Hz)");
ylabel("Amplitude");
xlim([0,30]);
grid minor
saveas(gcf,"Part2_n24.png");

%% Part3
clc;
n_422_eventFirstSamps = [1, 10711, 11211, 11442, 59711, 61288]; %Samples in n422 in which the events started
n_422_eventLastSamps = [10710, 11210, 11441, 59710, 61287, 75000]; %Samples in n422 in which the events ended

n_422_events = ["N","VT","N","VT","NOISE","VFIB"]; %Array of events happened in n422


winLen = 10*fs; %The length of each window [samples].
overlap = 50; %Windows overlap, as a percentage of winLen.
totalLen = length(n_422); %Total length of the signal

windows = round((totalLen-winLen)/(winLen*(1-overlap/100)))+1; %Total number of windows
windowsArr = zeros(windows,1); %Array of the corresponding single time for each window

labelsArr = zeros(windows,1); %Final labels for each window
lastSampArr = zeros(windows, 1); %The last sample in each window
firstSampArr =  zeros(windows, 1); %The first sample in each window

for win = 1:windows
    %Computing the array of samples in window number win:
    T = (win-1)*winLen*(1-overlap/100)+1 : ...
        winLen+(win-1)*winLen*(1-overlap/100);
    T = round(T);

    %Determining the first and the last sample of the window:
    lastSampArr(win) = T(end);
    firstSampArr(win) = T(1);

    %Computing the middle sample in the window, as a corresponding time for the window
    windowsArr(win) = mean(T)/fs;
  
    for ev = 1:length(n_422_eventFirstSamps) %For each event in the .txt file
        if firstSampArr(win) >= n_422_eventFirstSamps(ev) && lastSampArr(win) <= n_422_eventLastSamps(ev)
            labelsArr(win) = numLabel(n_422_events(ev)); %Find the corresponding number for the label
        end
    end
end


%% Part4
clc;


freqRange1 = [0, 10]; %First frequency range
freqRange2 = [10, 30]; %Second frequency range

bp_arr1 = zeros(windows,1); %Bandpower array, corresponding to freqRange1
bp_arr2 = zeros(windows,1); %Bandpower array, corresponding to freqRange2

meanfreq_arr =  zeros(windows,1); %meanfreq array.
medianfreq_arr =  zeros(windows,1); %medianfreq array.

for win = 1:windows
    %Computing the array of samples in window number win:
    T = (win-1)*winLen*(1-overlap/100)+1 : ...
        winLen+(win-1)*winLen*(1-overlap/100);
    T = round(T);

    %Computing bandpowers:
    bp_arr1(win) = bandpower(n_422(T),fs,freqRange1);
    bp_arr2(win) = bandpower(n_422(T),fs,freqRange2);

    meanfreq_arr(win) = meanfreq(n_422(T),fs); %Computing mean frequency
    medianfreq_arr(win) = medfreq(n_422(T),fs); %Computing median frequency
end

figure('Name', 'Bandpower');
subplot(211)
plot(windowsArr, bp_arr1);
title("Bandpower for Frequency range ["+freqRange1(1)+" , "+freqRange1(2)+"]");
xlabel('Time [sec]');
ylabel('Bandpower');
subplot(212)
plot(windowsArr, bp_arr2);
title("Bandpower for Frequency range ["+freqRange2(1)+" , "+freqRange2(2)+"]");
xlabel('Time [sec]');
ylabel('Bandpower');

figure('Name', 'Meanfreq & Medianfreq');
subplot(211);
plot(windowsArr, meanfreq_arr);
title("Mean frequeancy");
xlabel('Time [sec]');
ylabel('Mean frequnecy (Hz)');

subplot(212);
plot(windowsArr, medianfreq_arr);
title("Median frequeancy");
xlabel('Time [sec]');
ylabel('Median frequency (Hz)');


%% part5

clc;

nbins = 15; %Number of bins for each histogram

figure;
%Bandpower in freqRange1, for Normal and VFIB:
subplot(221);
histogram(bp_arr1(labelsArr == 1), nbins);
hold on; histogram(bp_arr1(labelsArr == 2), nbins);
title("Bandpower histogram for  Frequency range ["+freqRange1(1)+" , "+freqRange1(2)+"]");
xlabel("Bandpower"); ylabel("Count");
legend("Normal", "VFIB");

%Bandpower in freqRange2, for Normal and VFIB:
subplot(222);
histogram(bp_arr2(labelsArr == 1), nbins);
hold on; histogram(bp_arr2(labelsArr == 2), nbins);
title("Bandpower histogram for  Frequency range ["+freqRange2(1)+" , "+freqRange2(2)+"]");
xlabel("Bandpower"); ylabel("Count");
legend("Normal", "VFIB");

%Meanfreq for Normal and VFIB:
subplot(223);
histogram(meanfreq_arr(labelsArr == 1), nbins);
hold on; histogram(meanfreq_arr(labelsArr == 2), nbins);
title("Mean Frequency histogram");
xlabel("Mean Frequency"); ylabel("Count");
legend("Normal", "VFIB");

%Medianfreq for Normal and VFIB:
subplot(224);
histogram(medianfreq_arr(labelsArr == 1), nbins);
hold on; histogram(medianfreq_arr(labelsArr == 2), nbins);
title("Median Frequency histogram");
xlabel("Median Frequency"); ylabel("Count");
legend("Normal", "VFIB");


%% part 6
clc;

%Setting labels for the windows, based on medfreq:
[alarm_medfreq,t] = va_detect_medfreq(n_422,fs);
alarm_medfreq(alarm_medfreq == 1) = 2; %Same as VFIB label
alarm_medfreq(alarm_medfreq == 0) = 1; %Same as Normal label

%Setting labels for the windows, based on bandpower in the range [10, 30]:
[alarm_bp,t] = va_detect_bandpower(n_422,fs);
alarm_bp(alarm_bp == 1) = 2; %Same as VFIB label
alarm_bp(alarm_bp == 0) = 1; %Same as Normal label

%Computing confusion matrices:
m_medfreq = confusionmat(labelsArr, alarm_medfreq);
m_bp = confusionmat(labelsArr, alarm_bp);

%****************PLotting Confusion matrix*********************
eventNames = ["None","Normal","VFIB","VT"];
pred_eventNames = ["Pred. None","Pred. Normal","Pred. VFIB","Pred. VT"];
figure;
heatmap(pred_eventNames, eventNames, m_medfreq);
title("Confusion Matrix using Median Frequency");

figure;
heatmap(pred_eventNames, eventNames, m_bp);
title("Confusion Matrix using Bandpower Frequency");
%**************************************************************

%Sensitivity: TP/P
sensitivity_medfreq = m_medfreq(3,3)/(m_medfreq(3,3)+m_medfreq(3,2))
sensitivity_bp = m_bp(3,3)/(m_bp(3,3)+m_bp(3,2))

%Specificity: TN/N
specificity_medfreq = m_medfreq(2,2)/(m_medfreq(2,2)+m_medfreq(2,3))
specificity_bp = m_bp(2,2)/(m_bp(2,2)+m_bp(2,3))

%Accuracy: (TP+TN)/TP+TN+FP+FN)
accuracy_medfreq = (m_medfreq(2,2) + m_medfreq(3,3)) / sum(sum(m_medfreq(2:3,2:3)))
accuracy_bp = (m_bp(2,2) + m_bp(3,3)) / sum(sum(m_bp(2:3,2:3)))




%% functions

function num = numLabel(label)
%This function converts each arrhithmia label from a string into a number
    switch label
        case 'N'
            num = 1;
   
        case 'VFIB'
            num = 2;
        case 'VT'
            num = 3;
        case 'NOISE'
            num = 4;
        otherwise
            num = 0; %NONE
    end
end













