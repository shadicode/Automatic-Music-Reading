function freq  = note2freq(note)

%   File:           note2freq.m
%   Autor:          Shadi Alhaj
%   Date:           29.3.2020
% 
%   Description:    note2freq converts a note's name to the corresponding frequency value . 
%                   input:  {note}  : note's name 
%                   output: {freq}  : frequency
%
%   Usage:          note = note2freq("F4")  yields the frequency value: 349.2282
%                   note = note2freq("A14") yields no frequency value but outputs "x"
%
%   Theory:         fn = f0 * (a)n
%                   where
%                   f0 = the frequency of one predefined fixed note . A common choice (A4) at f0 = 440 Hz.
%                   n  = the number of semitones/half steps away from the fixed note. At a higher note, n is +ve. At a lower note, n is -ve.
%                   fn = the frequency of the note n one semitone away.
%                   a  = (2)^1/12 = the twelth root of 2 
%



%% Note names in the given number of Octaves

music_notes = ["A1", "AS1", "B2", "C2", "CS2", "D2", "DS2", "E2", "F2", "FS2", "G2", "GS2", ...
               "A2", "AS2", "B3", "C3", "CS3", "D3", "DS3", "E3", "F3", "FS3", "G3", "GS3", ...
               "A3", "AS3", "B4", "C4", "CS4", "D4", "DS4", "E4", "F4", "FS4", "G4", "GS4", ...
               "A4", "AS4", "B5", "C5", "CS5", "D5", "DS5", "E5", "F5", "FS5", "G5", "GS5", ...
               "A5", "AS5", "B6", "C6", "CS6", "D6", "DS6", "E6", "F6", "FS6", "G6", "GS6",...
               "A6", "AS6", "B7", "C7", "CS7", "D7", "DS7", "E7", "F7", "FS7", "G7", "GS7", "A7"];
              
      
% Number of octaves to be generated/detected  

octaves = 6;

%Tuning frequency / base frequency ( A4 = 440 Hz)
f0=440;     

%twelth root of 2 - 
a= 2^(1/12);

% total number of steps in 1 octage = 12
total_steps = octaves*12;

% number of half steps around center frequency
n = - (total_steps/2):(total_steps/2);

%Generate all frequencies / half steps spaning
fn=f0 * a.^n;



% Assign musical notes to frequencies
for index = 1: length(music_notes)
    
    
    % The input name is found in the note's list!
    isEqual = (music_notes(index) == note);
    
    if (isEqual)
        
        % Output corresponding frequency value
        freq=fn(index);
      
        break       
    end
end    

    if (~isEqual)
        freq = "x";
            
    end