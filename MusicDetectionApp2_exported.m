classdef MusicDetectionApp2_exported < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        MusicNoteBoxV10UIFigure        matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        LeftPanel                      matlab.ui.container.Panel
        LoadButton                     matlab.ui.control.Button
        ThresholdSlider                matlab.ui.control.Slider
        LoadanaudiofiletoanalyseLabel  matlab.ui.control.Label
        MusicNoteBoxLabel              matlab.ui.control.Label
        Image                          matlab.ui.control.Image
        DETECTButton                   matlab.ui.control.Button
        DetectionWindowLabel           matlab.ui.control.Label
        PlayButton                     matlab.ui.control.StateButton
        SYNTHButton                    matlab.ui.control.StateButton
        ThresholdSlider_2              matlab.ui.control.Slider
        NoteDurationLabel              matlab.ui.control.Label
        RightPanel                     matlab.ui.container.Panel
        TextArea                       matlab.ui.control.TextArea
        NOTESLabel                     matlab.ui.control.Label
        UIAxes_2                       matlab.ui.control.UIAxes
        UNIQEButton                    matlab.ui.control.StateButton
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
            %   output: {note}  : Name of musical note
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
            
            % Choosen for best detection : can be made into input parameter
            % to provide flexibility 
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
        
        function sig  = frq2sound(app,value, duration)
            % frq2sound  Synthesizes a tone based on frequency and duration .
            %
            %   input:  {value} : frequency
            %   output: {duration}  : Duration of the sound
            
            NoteDuration=  app.ThresholdSlider_2.Value;
            
            Fs = 44100;
            toneFreq = value;  % Tone frequency in Hz
            nSeconds = NoteDuration* duration;      % Duration of the sound
            a = sin(linspace(0, nSeconds*toneFreq*2*pi, round(nSeconds*Fs)));
            sound(a,Fs); % Play sound at sampling rate Fs
            
        end
        
        
        
        
    end
    
    
    % Callbacks that handle component events
    methods (Access = private)
        
        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
            [filename,path] = uigetfile({'*.wav';'*.mp3'; '*.mp4';'*.m4a';'*.*'},...
                'File Selector');
            file = fullfile(path,filename);
            [dat, Fs] = audioread(file);
            %dat = (dat(:,1) + dat(:,2) /2);
            assignin('base',"dat", dat );
            assignin("base", "Fs", Fs);
               
        end
        
        % Callback function
        function NotesTextAreaValueChanged(app, event)
               
        end
        
        % Button pushed function: DETECTButton
        function DETECTButtonPushed(app, event)
            
            % Import variable values
            y = evalin("base", 'dat');
            Fs = evalin("base", 'Fs');
            
            % Slider Value for Detection Window
            val = app.ThresholdSlider.Value;
            
            aFE = audioFeatureExtractor( ...
                "SampleRate",Fs, ...
                "Window",hamming(round(val*Fs),"periodic"), ...
                "OverlapLength",round(0.002*Fs), ...
                "mfcc",true, ...
                "mfccDelta",true, ...
                "mfccDeltaDelta",true, ...
                "pitch",true, ...
                "spectralCentroid",true);
            
            % Extracting Pitch/Frequency from Audio file
            features = extract(aFE,y);
            idx = info(aFE)
            t = linspace(0,size(y,1)/Fs,size(features,1));
            
            % Displaying the notes Progression using a matlab Plot Style
            plot(app.UIAxes_2,t,features(:,idx.pitch), "Color", [0.55, 0.75, 0.75], 'LineWidth',2)
            
            % Frequency ticks on y-Axis
            yticks(app.UIAxes_2, [55 58 61 65 69 73 77 82 87 92 98 103.8 110 116.5 123.5 ...
                130.8 138.6 146.8 155.6 164.8 174.6 185 196 207.7 220 233.1 246.9 261.6 ...
                277.2 293.7 311.1 329.6 349.2 370 392 415.3 440 466.2 493.9 523.3 554.4 ...
                587.3 622.3 659.3 698.5 740 784 830.6 880 932.3 987.8 1046.5 1108.7 1174.7 1244.5 ...
                1318.5 1396.9 1480 1568 1661.2 1760 1864.7 1975.5 2093 2217.5 2349.3 2489 2637 2793.8 ...
                2960 3136 3322.4 3520]);
            
            % Note names on y-Axis
            yticklabels(app.UIAxes_2,{"A1", "AS1", "B2", "C2", "CS2", "D2", "DS2", "E2", "F2", "FS2", "G2", "GS2", ...
                "A2", "AS2", "B3", "C3", "CS3", "D3", "DS3", "E3", "F3", "FS3", "G3", "GS3", ...
                "A3", "AS3", "B4", "C4", "CS4", "D4", "DS4", "E4", "F4", "FS4", "G4", "GS4", ...
                "A4", "AS4", "B5", "C5", "CS5", "D5", "DS5", "E5", "F5", "FS5", "G5", "GS5", ...
                "A5", "AS5", "B6", "C6", "CS6", "D6", "DS6", "E6", "F6", "FS6", "G6", "GS6",...
                "A6", "AS6", "B7", "C7", "CS7", "D7", "DS7", "E7", "F7", "FS7", "G7", "GS7", "A7"})
            

            N = length(y);                     % Length of signal/Total # samples
            f = Fs*(0:(N/2))/N;                % Frequency
            
            %f = f(locs);
            f=features(:,idx.pitch);
            f=nonzeros(f);
            
            % list of valid frequencies/selected frequencies
            % matlab requires preallocating the size
            f_valid = zeros(1,length(f));
            
            % -------------------------------------------------------------------------
            % Detection
            % -------------------------------------------------------------------------
            
            for index = 1: length(f)
                
                % Find frequency corresponding to that peak
                f_valid(index) = f(index);
                
            end

            % Play filtered original soundsound
            %   sound(y,Fs)
            
            % Match frequencies to musical notes
            % but first matlab requires preallocating the size
               %notes = zeros(1,length(f_valid)); % --> Problematic
            
            for i = 1: length(f_valid)
                
                notes(i) = frq2note(app, f_valid(i));
            end
            
            for i = 1:length(f_valid)
                s(i) = sum(f_valid == f_valid(i));
            end
            count= s;
            
            %notes = unique(notes, 'stable');
            
            % Reset Button Values
            app.UNIQEButton.Value=0;
            app.TextArea.Value =  notes;
            app.UNIQEButton.Text =  'UNIQE';
            
            app.PlayButton.Value=0;
            app.PlayButton.Text = 'Play';
            
            % Export variables
            assignin("base", 'f_valid', f_valid);
            assignin('base',"count", count);
            assignin('base',"notes", notes);
            
            
        end
        
        % Callback function
        function UNIQEButtonPushed(app, event)
            
        end
        
        % Value changed function: SYNTHButton
        function SYNTHButtonValueChanged(app, event)
            v = app.SYNTHButton.Value;
            app.PlayButton.Value=0;
            app.PlayButton.Text = 'Play';
            
            dur=  app.ThresholdSlider_2.Value;
            clear sound;
            
            if v ==1
                
                % Flip Play -> Stop label 
                app.SYNTHButton.Text ='STOP';
                
                time_tick= evalin("base", 'count');
                
                value  = evalin("base", 'f_valid');  % Tone frequency in Hz
                
                for i = 1:length(value)
                    
                    % Synthesize sound
                    frq2sound(app,value(i), time_tick(i));
                    pause(dur);
                    
                    % Check for a Stop signal
                    v = app.SYNTHButton.Value;
                    % If Stop -> break the sound synthesis loop
                    if v ==0
                        break;
                    end
                end
                
                
            else
                
                % Reset Synthesize Button
                clear sound;
                app.SYNTHButton.Text ='SYNTH';
                
            end
            
            % Stop sound and reset Synthesize Button 
            app.SYNTHButton.Text ='SYNTH';
            app.SYNTHButton.Value=0;
            clear sound;
            
        end
        
        % Value changed function: UNIQEButton
        function UNIQEButtonValueChanged(app, event)
            v = app.UNIQEButton.Value;
            
            % Import/read notes variable
            notes= evalin("base", 'notes');
            
            % If UNIQE Button is pressed 
            if v ==1
                % Show unique notes (no repetitions)
                app.TextArea.Value =  unique(notes, 'stable');
                app.UNIQEButton.Text =  'FULL';
            else
                % SHow all note occurencies
                app.TextArea.Value = notes;
                app.UNIQEButton.Text =  'UNIQE';
            end
        end
        
        % Value changed function: PlayButton
        function PlayButtonValueChanged(app, event)
            v = app.PlayButton.Value;
            data = evalin("base", 'dat');
            Fs = evalin("base", 'Fs');
            
            % If Play button is pressed
            if v ==1
                % Flip Play -> Stop label
                app.PlayButton.Text = 'Stop';
                data = evalin("base", 'dat');
                Fs = evalin("base", 'Fs');
                
                % Play original audio file
                sound(data, Fs);
            else
                % Reset Play button
                app.PlayButton.Text = 'Play';
                % Stop all sounds
                clear sound;
            end
        end
        
        
        % Value changed function: ThresholdSlider_2
        function ThresholdSlider_2ValueChanged(app, event)
            v = app.ThresholdSlider_2.Value;
            
            
        end
        
        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.MusicNoteBoxV10UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {499, 499};
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
            
            % Create MusicNoteBoxV10UIFigure and hide until all components are created
            app.MusicNoteBoxV10UIFigure = uifigure('Visible', 'off');
            app.MusicNoteBoxV10UIFigure.AutoResizeChildren = 'off';
            app.MusicNoteBoxV10UIFigure.Position = [100 100 837 499];
            app.MusicNoteBoxV10UIFigure.Name = 'Music NoteBox V1.0';
            app.MusicNoteBoxV10UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
            
            % Create GridLayout
            app.GridLayout = uigridlayout(app.MusicNoteBoxV10UIFigure);
            app.GridLayout.ColumnWidth = {204, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';
            
            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.BackgroundColor = [1 1 1];
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            
            % Create LoadButton
            app.LoadButton = uibutton(app.LeftPanel, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.Position = [24 296 61 22];
            app.LoadButton.Text = 'Load';
            
            % Create ThresholdSlider
            app.ThresholdSlider = uislider(app.LeftPanel);
            app.ThresholdSlider.Limits = [0.04 1];
            app.ThresholdSlider.Position = [36 243 140 3];
            app.ThresholdSlider.Value = 0.1;
            
            % Create LoadanaudiofiletoanalyseLabel
            app.LoadanaudiofiletoanalyseLabel = uilabel(app.LeftPanel);
            app.LoadanaudiofiletoanalyseLabel.FontName = 'Arial Rounded MT Bold';
            app.LoadanaudiofiletoanalyseLabel.Position = [17 327 170 22];
            app.LoadanaudiofiletoanalyseLabel.Text = 'Load an audio file to analyse';
            
            % Create MusicNoteBoxLabel
            app.MusicNoteBoxLabel = uilabel(app.LeftPanel);
            app.MusicNoteBoxLabel.FontName = 'Arial Rounded MT Bold';
            app.MusicNoteBoxLabel.FontSize = 24;
            app.MusicNoteBoxLabel.FontWeight = 'bold';
            app.MusicNoteBoxLabel.FontColor = [0.0392 0.3451 0.3804];
            app.MusicNoteBoxLabel.Position = [33 386 111 56];
            app.MusicNoteBoxLabel.Text = {'Music'; 'NoteBox '};
            
            % Create Image
            app.Image = uiimage(app.LeftPanel);
            app.Image.Position = [111 409 61 58];
            app.Image.ImageSource = 'sound-mute-note-music-atm-round-512.png';
            
            % Create DETECTButton
            app.DETECTButton = uibutton(app.LeftPanel, 'push');
            app.DETECTButton.ButtonPushedFcn = createCallbackFcn(app, @DETECTButtonPushed, true);
            app.DETECTButton.BackgroundColor = [0.9412 0.9412 0.9412];
            app.DETECTButton.Position = [60 181 84 22];
            app.DETECTButton.Text = 'DETECT';
            
            % Create DetectionWindowLabel
            app.DetectionWindowLabel = uilabel(app.LeftPanel);
            app.DetectionWindowLabel.FontName = 'Arial Rounded MT Bold';
            app.DetectionWindowLabel.Position = [22 258 111 22];
            app.DetectionWindowLabel.Text = 'Detection Window';
            
            % Create SYNTHButton
            app.SYNTHButton = uibutton(app.LeftPanel, 'state');
            app.SYNTHButton.ValueChangedFcn = createCallbackFcn(app, @SYNTHButtonValueChanged, true);
            app.SYNTHButton.Text = 'SYNTH';
            app.SYNTHButton.BackgroundColor = [0.9412 0.9412 0.9412];
            app.SYNTHButton.Position = [60 63 84 22];
            
            % Create PlayButton
            app.PlayButton = uibutton(app.LeftPanel, 'state');
            app.PlayButton.ValueChangedFcn = createCallbackFcn(app, @PlayButtonValueChanged, true);
            app.PlayButton.Text = 'Play';
            app.PlayButton.Position = [109 296 63 22];
            
            % Create ThresholdSlider_2
            app.ThresholdSlider_2 = uislider(app.LeftPanel);
            app.ThresholdSlider_2.Limits = [0.1 2];
            app.ThresholdSlider_2.ValueChangedFcn = createCallbackFcn(app, @ThresholdSlider_2ValueChanged, true);
            app.ThresholdSlider_2.Position = [32 126 140 3];
            app.ThresholdSlider_2.Value = 0.5;
            
            % Create NoteDurationLabel
            app.NoteDurationLabel = uilabel(app.LeftPanel);
            app.NoteDurationLabel.FontName = 'Arial Rounded MT Bold';
            app.NoteDurationLabel.Position = [22 141 90 22];
            app.NoteDurationLabel.Text = 'Note Duration ';
            
            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            
            % Create TextArea
            app.TextArea = uitextarea(app.RightPanel);
            app.TextArea.HorizontalAlignment = 'center';
            app.TextArea.FontSize = 14;
            app.TextArea.FontWeight = 'bold';
            app.TextArea.FontColor = [0.149 0.149 0.149];
            app.TextArea.Position = [467 73 131 348];
            
            % Create NOTESLabel
            app.NOTESLabel = uilabel(app.RightPanel);
            app.NOTESLabel.BackgroundColor = [0.3647 0.4275 0.4314];
            app.NOTESLabel.HorizontalAlignment = 'center';
            app.NOTESLabel.FontName = 'Arial Rounded MT Bold';
            app.NOTESLabel.FontSize = 14;
            app.NOTESLabel.FontWeight = 'bold';
            app.NOTESLabel.FontColor = [1 1 1];
            app.NOTESLabel.Position = [467 420 131 22];
            app.NOTESLabel.Text = 'NOTES';
            
            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.RightPanel);
            title(app.UIAxes_2, 'PROGRESSION OF MUSICAL NOTES')
            xlabel(app.UIAxes_2, 'TIME [s]')
            ylabel(app.UIAxes_2, '')
            app.UIAxes_2.PlotBoxAspectRatio = [1.12225705329154 1 1];
            app.UIAxes_2.FontName = 'Arial Rounded MT Bold';
            app.UIAxes_2.FontSize = 13;
            app.UIAxes_2.Box = 'on';
            app.UIAxes_2.YTick = [55 3520];
            app.UIAxes_2.YTickLabel = {'A1'; 'A7'};
            app.UIAxes_2.YMinorTick = 'on';
            app.UIAxes_2.YScale = 'log';
            app.UIAxes_2.Position = [19 27 426 438];
            
            % Create UNIQEButton
            app.UNIQEButton = uibutton(app.RightPanel, 'state');
            app.UNIQEButton.ValueChangedFcn = createCallbackFcn(app, @UNIQEButtonValueChanged, true);
            app.UNIQEButton.Text = 'UNIQE';
            app.UNIQEButton.BackgroundColor = [0.298 0.5451 0.5608];
            app.UNIQEButton.FontColor = [1 1 1];
            app.UNIQEButton.Position = [483 32 100 22];
            
            % Show the figure after all components are created
            app.MusicNoteBoxV10UIFigure.Visible = 'on';
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        
        % Construct app
        function app = MusicDetectionApp2_exported
            
            % Create UIFigure and components
            createComponents(app)
            
            % Register the app with App Designer
            registerApp(app, app.MusicNoteBoxV10UIFigure)
            
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            
            % Delete UIFigure when app is deleted
            delete(app.MusicNoteBoxV10UIFigure)
        end
    end
end