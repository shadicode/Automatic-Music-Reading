
% -------------------------------------------------------------------------
%   File:           test_1.m
%   Autor:          Shadi Alhaj
%   Date:           2.4.2020
%   Description:    Attempts to detect frequiencies present in audio file .
%                   Works best with single notes.
%
% -------------------------------------------------------------------------
%
%   1) Signal acquisition & processing
%        - Read wav file
%        - Stereo to mono
%        - Filtering
%
%   2) Analysis
%       - FFT
%       - Threshold for detecting valed peaks ?!! 1st problem
%       - Peaks and their indicies
%       - Normalise peak values
%
%   3) Detection
%       - Detect note using freq2note.m function
%   
%   4) Display Notes / Play notes
%       
% -------------------------------------------------------------------------

clear all
close all
clc

% Start timer
tic


% -------------------------------------------------------------------------
% Signal Processing
% -------------------------------------------------------------------------

% File path and name 
filename = '/data/G4.wav',

% Read audio file to matlab
[x,Fs] = audioread(filename);

% Stereo to mono by selecting one channel
    x1 = x(:,1);
% Stereo to mono by mixing the two channels
    x1 = (x(:,1) + x(:,2) /2);

% Filtering using Butterworth band pass filter.
%     order =2;
%     Fc_low = 85 ;                                 % high cutoff frequency (Hz) A1 =55 Hz
%     Fc_high = 1800;                               % high cutoff frequency (Hz) A6 =1760 Hz
%     [b, a] = butter(order, [Fc_low, Fc_high]/(Fs/2), 'bandpass');
%     freqz(b,a,Fs)
% Apply the Butterworth filter.
%     y = filter(b, a, x1);

% Bypass the filter.
    y = x1;
    
% -------------------------------------------------------------------------
%  FFT and Analysis
% -------------------------------------------------------------------------

% Fast Fouriesr Transform
    N = length(y);                     % Length of signal/Total # samples
    y_fft = fft(y);                    
    P2 = abs(y_fft/N);                 % Magnitude
    P1 = P2(1:(N/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = Fs*(0:(N/2))/N;                % Frequency
    P1 = P1/max(P1);
    
% Plot The single-Sided Spectrum   
    figure(1)
    plot(f,P1)
    title('Single-Sided Amplitude Spectrum of S(t)')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')

% 1st MAGIC NUMBER/Problem:  
% Threshold for selecting peak |P1(f)| values ...
% Here its difficult to detect a single frequency due to
% harmonics/overtones. 
    thr = max(P1)*0.7012

[pks, locs] = findpeaks(P1 ,'MinPeakDistance',40, 'MinPeakHeight',thr);

% Normalise the peak values
    pks = pks/max(pks);
% Clearly the new created locs vector has a different size than f vector
% and this causes a shift in frequency when used in f_valid(index) = locs(index);

% However updating the frequency vector with new indicies solves it
    f = f(locs);

% list of valid frequencies/selected frequencies
% matlab requires preallocating the size
    f_valid = zeros(1,1000);             
    
% -------------------------------------------------------------------------
% Detection
% -------------------------------------------------------------------------

for index = 1: length(pks)
    
    % This comparison with thr is not needed but works as a reminder that some comparison need to be done
    % When a peak is detected
    if (pks(index)> thr)
        
        % Find frequency corresponding to that peak
        f_valid(index) = f(index);   
    end
      
end

% Display valid frequencies
    f_valid = nonzeros(f_valid)

% Play filtered original soundsound
%   sound(y,Fs)

% Match frequencies to musical notes
% but first matlab requires preallocating the size
%    notes = zeros(1,1000); % --> Problematic

for i = 1: length(f_valid)
    
    notes(i) = frq2note(f_valid(i));
    
end

% -------------------------------------------------------------------------
% Display/ play detected notes
% -------------------------------------------------------------------------

notes

%     for x = 1: length(f_valid)
%
%     frq2sound(f_valid(x))
%     pause(1)
%
%     end

% Display Elapsed time 
toc