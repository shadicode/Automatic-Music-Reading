function note  = frq2note(freq)


%   File:           frq2note.m
%   Autor:          Shadi Alhaj
%   Date:           29.3.2020
%
%   Description:    frq2note converts a frequency value to the corresponding note's name .
%                   input:  {freq}  : frequency 
%                   output: {note}  : name of musical note
%
%   Usage:          note = frq2note(349) yields the note's name: "F4"
%                   note = frq2note(375) yields no note's name but outputs "0"
%
%   Theory:         fn = f0 * (a)n
%                   where
%                   f0 = the frequency of one predefined fixed note . A common choice (A4) at f0 = 440 Hz.
%                   n  = the number of semitones/half steps away from the fixed note. At a higher note, n is +ve. At a lower note, n is -ve.
%                   fn = the frequency of the note n one semitone away.
%                   a  = (2)^1/12 = the twelth root of 2 



%% Note names in the given number of Octaves

music_notes = ["A1", "AS1", "B2", "C2", "CS2", "D2", "DS2", "E2", "F2", "FS2", "G2", "GS2", ...
               "A2", "AS2", "B3", "C3", "CS3", "D3", "DS3", "E3", "F3", "FS3", "G3", "GS3", ...
               "A3", "AS3", "B4", "C4", "CS4", "D4", "DS4", "E4", "F4", "FS4", "G4", "GS4", ...
               "A4", "AS4", "B5", "C5", "CS5", "D5", "DS5", "E5", "F5", "FS5", "G5", "GS5", ...
               "A5", "AS5", "B6", "C6", "CS6", "D6", "DS6", "E6", "F6", "FS6", "G6", "GS6",...
               "A6", "AS6", "B7", "C7", "CS7", "D7", "DS7", "E7", "F7", "FS7", "G7", "GS7", "A7"];

           
% Number of octaves to be generated/detected           
octaves = 6;

% Tuning frequency / base frequency ( A4 = 440 Hz)
f0=440;     

% Twelth root of 2 - 
a= nthroot(2,12);

% Total number of steps/semitones in 1 octage = 12
total_steps = octaves*12;

% Number of half steps around center frequency
n = - (total_steps/2):(total_steps/2);

% Generate all frequencies / half steps spaning
fn=f0 * a.^n;

% Maximum allawable diveation from generated frequency
% could I define a tolerance var that also grows exponentially ?
% The tollerence between A1 (55 Hz) and AS1(58.27 Hz) is much smaller than
% that between A6(1760 Hz) and AS6(1864.66 Hz)


% The tolerance base is callculated as 1/3 of the difference between 2 first tones :
% (AS1)=58.27 - (A1)= 55 = 3.27 / 3  --> 1.09
tolerance_base = 1.09;          

% Generate tollrance values
tolerance_n = tolerance_base * a.^n;



% Assign musical notes to frequencies
for index = 1: length(fn)
    
    % How different is the input value from generated frequencies?
    diff = abs (fn(index) - freq);
    
    % The input value falls in a defined range!
    isEqual = (diff == 0 || (diff < tolerance_n(index)));
    
    if (isEqual)
        
        % Output corresponding note's name
        note=music_notes(index);
      
        break       
    end
end    

    % The input value falls out of range!
    if (~isEqual)
        note = "0";
            
    end