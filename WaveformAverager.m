thisDirectory = pwd; % Get this folder
audioFolder = fullfile(thisDirectory, '/RawFiles/Shout'); % Get the raw audio folder
audioFiles = dir(fullfile(audioFolder, '*.wav')); % Get raw audio files

audioSamplesStruct = struct([]);

for idx = 1 : length(audioFiles)
    % Get file details
    baseFileName = audioFiles(idx).name; % File name
    fullFileName = fullfile(audioFiles(idx).folder, baseFileName); % File directory 
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    % Get file name and samples
    audioSamples.fileName = baseFileName;
    [audioSamples.samples, audioSamples.Fs] = audioread(fullFileName);
    
    % Get note details (octave and note name) from file name
    noteDetails = split(audioSamples.fileName); % Split file name (with space as delimiter) to get note and octave. Note has be be first in file name. E.g. 'A# 2.wav'
    noteDetails{2} = noteDetails{2}(1); % For octave part of file name, get rid of .wav extention
    % Save note details to structure
    audioSamples.note = noteDetails{1};
    audioSamples.octave = str2double(noteDetails(2));
    
    % Get freq from note details (use equal temperature and A0 - 27.50Hz as
    % starting note)
    A0 = 27.50;
    switch audioSamples.note
        case 'C'
            noteDiff = -9;
        case 'C#'
            noteDiff = -8;
        case 'D'
            noteDiff = -7;
        case 'D#'
            noteDiff = -6;
        case 'E'
            noteDiff = -5;
        case 'F'
            noteDiff = -4;
        case 'F#'
            noteDiff = -3;
        case 'G'
            noteDiff = -2;
        case 'G#'
            noteDiff = -1;
        case 'A'
            noteDiff = 0;
        case 'A#'
            noteDiff = 1;
        case 'B'
            noteDiff = 2;
        otherwise
            disp('Invalid note name')
    end
    audioSamples.noteFreq = A0*(2.^(((audioSamples.octave*12)+noteDiff)/12));
    
    % Get number of samples in one cycle
    audioSamples.samplesPerCycle = audioSamples.Fs/audioSamples.noteFreq;
    audioSamples.samplesPerCycle = round(audioSamples.samplesPerCycle);
    
    % Get average waveform/single cycle
    averageWaveform = zeros(audioSamples.samplesPerCycle, 1); % Store average waveform
    currentSample = 1;
    numCycles = 0; 
    while ((currentSample + audioSamples.samplesPerCycle) < length(audioSamples.samples)) % Make sure we don't go outside of array
        averageWaveform = averageWaveform + audioSamples.samples(currentSample:currentSample + audioSamples.samplesPerCycle - 1); % Add current waveform to average
        % Increment
        currentSample = currentSample + audioSamples.samplesPerCycle;
        numCycles = numCycles + 1;
    end
    % Divide by number of cycles to get average
    averageWaveform = averageWaveform / numCycles; 
    
    % Add average waveform to structure
    audioSamples.averageWaveform = averageWaveform;
    % Write to .wav file
    filePatch = append('ProcessedFiles/', audioSamples.fileName);
    audiowrite(filePatch, averageWaveform, audioSamples.Fs);
    
    % Add structure to overarching structure containing all files
    audioSamplesStruct = [audioSamplesStruct, audioSamples];
end

