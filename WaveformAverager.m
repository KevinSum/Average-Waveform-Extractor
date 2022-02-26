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
    
    % Remove '.wav' from file name to get only the midi note
    audioSamples.midiNote = erase(audioSamples.fileName, ".wav"); 
    audioSamples.midiNote = str2double(audioSamples.midiNote);
    
    % Get freq from midi note  (use equal temperature i.e. A4 = 440 Hz)
    A4 = 440;
    audioSamples.noteFreq = A4*(2.^((audioSamples.midiNote - 69)/12));
    
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

