%function [pahandle, myBeep] = prepare_audio()
function pahandle = prepare_audio()

    % Number of channels and Frequency of the sound
    nrchannels = 2;
    freq = 48000;

    % How many times to we wish to play the sound
    repetitions = 1;

    % Length of the beep
    beepLengthSecs = 0.1;

    % Open Psych-Audio port, with the follow arguements
    % (1) [] = default sound device
    % (2) 1 = sound playback only
    % (3) 1 = default level of latency
    % (4) Requested frequency in samples per second
    % (5) 2 = stereo putput
    pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);

    % Set the volume to half for this demo
    PsychPortAudio('Volume', pahandle, 0.5);

    % Make a beep which we will play back to the user
    myBeep = MakeBeep(500, beepLengthSecs, freq);

    % Fill the audio playback buffer with the audio data, doubled for stereo
    % presentation
    PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]);
%    cue_buffer = PsychPortAudio('CreateBuffer', [], [myBeep; myBeep]);
%    PsychPortAudio('UseSchedule', pahandle, 1);
%    PsychPortAudio('AddToSchedule', pahandle, cue_buffer, 1, 0, [], 1);
end
