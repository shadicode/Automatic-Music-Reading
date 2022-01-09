classdef MusicDetectionApp_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        LeftPanel                      matlab.ui.container.Panel
        LoadButton                     matlab.ui.control.Button
        ThresholdSlider                matlab.ui.control.Slider
        LoadanaudiofiletoanalyseLabel  matlab.ui.control.Label
        MusicToolBoxLabel              matlab.ui.control.Label
        Image                          matlab.ui.control.Image
        PlayButton                     matlab.ui.control.Button
        DetectButton                   matlab.ui.control.Button
        SensitivityLabel               matlab.ui.control.Label
        RightPanel                     matlab.ui.container.Panel
        UIAxes                         matlab.ui.control.UIAxes
        TextArea                       matlab.ui.control.TextArea
        NotesLabel                     matlab.ui.control.Label
        UIAxes_2                       matlab.ui.control.UIAxes
        SynthesizeButton               matlab.ui.control.Button
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
 
    
    methods (Access = private)
        
        
function note  = frq2note(app,freq)

% frq2note  Converts a frequency value to the corresponding note's name .
%   
%   input:  {freq} : frequency 
%   output: {note}  : name of musical note
%
%   note = frq2note(349) yields the note's name: "F4"
%   note = frq2note(375) yields no note's name but outputs "0"
%
%   Theory:
%   ------
%   fn = f0 * (a)n
%   where
%   f0 = the frequency of one predefined fixed note . A common choice (A4) at f0 = 440 Hz.
%   n  = the number of semitones/half steps away from the fixed note. At a higher note, n is +ve. At a lower note, n is -ve.
%   fn = the frequency of the note n one semitone away.
%   a  = (2)^1/12 = the twelth root of 2 
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
tolerance_base = 7;          

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
            
end

function sig  = frq2sound(app,value)


Fs = 44100;       
toneFreq = value;  % Tone frequency in Hz
nSeconds = 0.8;      % Duration of the sound
a = sin(linspace(0, nSeconds*toneFreq*2*pi, round(nSeconds*Fs)));
sound(a,Fs); % Play sound at sampling rate Fs
end




    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
            [filename,path] = uigetfile({'*.wav';'*.mp3'; '*.mp4';'*.mat';'*.*'},...
                          'File Selector');
            file = fullfile(path,filename);
            [dat, Fs] = audioread(file);
            dat = (dat(:,1) + dat(:,2) /2);
            assignin('base',"dat", dat );
            assignin("base", "Fs", Fs);

           
        

        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            
            data = evalin("base", 'dat');
            Fs = evalin("base", 'Fs');
            sound(data, Fs);
      
            
 
        end

        % Callback function
        function NotesTextAreaValueChanged(app, event)
        
            
       
        end

        % Button pushed function: DetectButton
        function DetectButtonPushed(app, event)
             
            
            y = evalin("base", 'dat');
            Fs = evalin("base", 'Fs');
            
     
            N = length(y);                     % Length of signal/Total # samples
            y_fft = fft(y);                    
            P2 = abs(y_fft/N);                 % Magnitude
            P1 = P2(1:(N/2)+1);
            P1(2:end-1) = 2*P1(2:end-1);

            f = Fs*(0:(N/2))/N;                % Frequency
            %P1 = P1/max(P1);
            plot(app.UIAxes,f,20*log10(P1),'-r');
            xlim(app.UIAxes,[0 20000]) 
            ylim(app.UIAxes,[-80 0])
            
            
            
            aFE = audioFeatureExtractor( ...
                "SampleRate",Fs, ...
                "Window",hamming(round(0.03*Fs),"periodic"), ...
                "OverlapLength",round(0.02*Fs), ...
                "mfcc",true, ...
                "mfccDelta",true, ...
                "mfccDeltaDelta",true, ...
                "pitch",true, ...
                "spectralCentroid",true);
            
            features = extract(aFE,y);
            idx = info(aFE)
            t = linspace(0,size(y,1)/Fs,size(features,1));
            plot(app.UIAxes_2,t,features(:,idx.pitch))
      

            
            
%             assignin("base", "P1", P1);
%             assignin("base", "f", f);
%             
%             
%             P1 = evalin("base", 'P1');
%             f = evalin("base", 'f');
            
            val = app.ThresholdSlider.Value;
            
            thr = max(P1)/val;
            
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
            %    notes = zeros(1,length(f_valid)); % --> Problematic
            
            for i = 1: length(f_valid)
                
                notes(i) = frq2note(app, f_valid(i));
                 app.TextArea.Value = notes;
            end
            
            assignin("base", 'f_valid', f_valid);
           
            
            
        end

        % Button pushed function: SynthesizeButton
        function SynthesizeButtonPushed(app, event)
            
            
            
            value  = evalin("base", 'f_valid');  % Tone frequency in Hz
            for i = 1:length(value)
            frq2sound(app,value(i));
            pause(1);
            end
            
            
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {457, 457};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {204, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 835 457];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {204, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create LoadButton
            app.LoadButton = uibutton(app.LeftPanel, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.Position = [29 230 61 22];
            app.LoadButton.Text = 'Load';

            % Create ThresholdSlider
            app.ThresholdSlider = uislider(app.LeftPanel);
            app.ThresholdSlider.Limits = [1 10];
            app.ThresholdSlider.Position = [32 142 140 3];
            app.ThresholdSlider.Value = 1.1;

            % Create LoadanaudiofiletoanalyseLabel
            app.LoadanaudiofiletoanalyseLabel = uilabel(app.LeftPanel);
            app.LoadanaudiofiletoanalyseLabel.Position = [26 267 159 22];
            app.LoadanaudiofiletoanalyseLabel.Text = 'Load an audio file to analyse';

            % Create MusicToolBoxLabel
            app.MusicToolBoxLabel = uilabel(app.LeftPanel);
            app.MusicToolBoxLabel.FontSize = 18;
            app.MusicToolBoxLabel.FontWeight = 'bold';
            app.MusicToolBoxLabel.Position = [24 371 79 46];
            app.MusicToolBoxLabel.Text = {'Music'; 'ToolBox '};

            % Create Image
            app.Image = uiimage(app.LeftPanel);
            app.Image.Position = [111 365 61 58];
            app.Image.ImageSource = 'sound-mute-note-music-atm-round-512.png';

            % Create PlayButton
            app.PlayButton = uibutton(app.LeftPanel, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Position = [119 230 61 22];
            app.PlayButton.Text = 'Play';

            % Create DetectButton
            app.DetectButton = uibutton(app.LeftPanel, 'push');
            app.DetectButton.ButtonPushedFcn = createCallbackFcn(app, @DetectButtonPushed, true);
            app.DetectButton.Position = [52 67 100 22];
            app.DetectButton.Text = 'Detect';

            % Create SensitivityLabel
            app.SensitivityLabel = uilabel(app.LeftPanel);
            app.SensitivityLabel.Position = [32 156 60 22];
            app.SensitivityLabel.Text = 'Sensitivity';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Amplitude Spectrum')
            xlabel(app.UIAxes, 'Frequency [Hz]')
            ylabel(app.UIAxes, '|P(f)| [dB]')
            app.UIAxes.FontSize = 13;
            app.UIAxes.Box = 'on';
            app.UIAxes.XMinorTick = 'on';
            app.UIAxes.XScale = 'log';
            app.UIAxes.Position = [17 232 419 197];

            % Create TextArea
            app.TextArea = uitextarea(app.RightPanel);
            app.TextArea.HorizontalAlignment = 'center';
            app.TextArea.FontSize = 14;
            app.TextArea.FontWeight = 'bold';
            app.TextArea.FontColor = [0.4667 0.6745 0.1882];
            app.TextArea.Position = [469 83 131 322];

            % Create NotesLabel
            app.NotesLabel = uilabel(app.RightPanel);
            app.NotesLabel.FontSize = 14;
            app.NotesLabel.FontWeight = 'bold';
            app.NotesLabel.Position = [479 407 45 22];
            app.NotesLabel.Text = 'Notes';

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.RightPanel);
            title(app.UIAxes_2, 'Pitch ')
            xlabel(app.UIAxes_2, 'Time [s]')
            ylabel(app.UIAxes_2, 'Frequency [Hz]')
            app.UIAxes_2.FontSize = 13;
            app.UIAxes_2.Box = 'on';
            app.UIAxes_2.YMinorTick = 'on';
            app.UIAxes_2.YScale = 'log';
            app.UIAxes_2.Position = [17 27 419 188];

            % Create SynthesizeButton
            app.SynthesizeButton = uibutton(app.RightPanel, 'push');
            app.SynthesizeButton.ButtonPushedFcn = createCallbackFcn(app, @SynthesizeButtonPushed, true);
            app.SynthesizeButton.Position = [485 49 100 22];
            app.SynthesizeButton.Text = 'Synthesize';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MusicDetectionApp_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end