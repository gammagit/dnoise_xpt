function [out_stim, out_dt, out_dec] = trial(arg_wip, arg_wrp, arg_tid,...
                                             arg_level, arg_keyid, arg_pars)
%%% TRIAL simulates a single trial
%%%
%%% arg_wip = Screen windowPtr (see Psychtoolbox)
%%% arg_wrp = Screen rect (see Psychtoolbox)
%%% arg_tid = integer containing the id of stimulus template: 0=Back, 2=T2, 5=T5
%%% arg_level = integer indicating the level of contrast / noise
%%% arg_keyid = int containing the ID of keyboard
%%% arg_pars = structure containing parameters of the experiment

    %%% Use local variables for pars (for brevity)
    blobsize = arg_pars.blobsize;
    stimsize = arg_pars.stimsize;
    thick = arg_pars.thick;
    lumbk = arg_pars.lumbk;
    lumax = arg_pars.lumax;
    isi = arg_pars.isi;
    mu_trial = arg_pars.mu;
    if (arg_level ~= 0)
        con = arg_pars.con.var(arg_level);
%         sd_mu_trial = sqrt(1/arg_pars.sd_mu.var(arg_level)); % as calibrate computes precision
        sd_mu_trial = arg_pars.sd_mu.var(arg_level);
        sd_sd_trial = arg_pars.sd_sd.var(arg_level);
    else % indicates high contrast trial
        con = arg_pars.con.var(end) + 1.0;
%         sd_mu_trial = sqrt(1/(arg_pars.sd_mu.var(end)*2));
        sd_mu_trial = arg_pars.sd_mu.var(end);
        sd_sd_trial = arg_pars.sd_sd.var(1);
    end

    %%% DEBUG
%     sd_mu_trial
    %%% DEBUG
    
    %%% Display background and fixation cross
%    texbk = gen_stimtex(arg_wip, arg_wrp, blobsize, stimsize, 0, thick, con, 0, 0,...
%        lumbk, lumax);
%    Screen('DrawTexture', arg_wip, texbk);
%    draw_fixation(arg_wip, arg_wrp, [lumax lumax lumax]*0.75);
    tzero_trial = GetSecs;
%    [VBLTime tzero_trial FlipTime]=Screen('Flip', arg_wip);

    %%% If autocorrelated noise, init current SNR epoch
    if (arg_pars.autox == 1)
        curr_snr_epoch = 1; % 1 = low (snr); 2 = high
    end

    %%% Create input queue for keyboard
    KbQueueCreate(arg_keyid); % Create a keyboard queue in advance to save time
    pressed = 0; pressedCode = []; % Flag & code for keyboard queue
    KbQueueStart(arg_keyid); % Start a new queue for each trial

    %%% Prepare audio for playing beep with stim
    pahandle = prepare_audio();
    audio_playback = 0;

    %%% Record the stimuli presented during each frame
    out_stim.mu = []; % mean noise during each frame
    out_stim.sd = []; % sd of noise during each frame
    out_stim.con = []; % contrast during each frame

    %%% Simple detection task % TODO: MOVE THESE TO INIT_PARAMS
    stim_time = 0.3; % time (secs) of stim display (could be drawn from exp)
    stim_duration = 0.100; % secs
    stim_displayed = 0; % flag indicated whether stim has been displayed

    all_stim_times = [];
    
    %%% Show the stimuli till 'Left' or 'Right' key is pressed
    next_flip_time = 0; % Initially Flip immediately
    while(~(any(pressedCode == KbName('Left')) ||...
            any(pressedCode == KbName('Right'))))
        %%% if autocorrelated noise, set sd noise a/c to epoch
        %%% fluctuates between most easy (1) and most difficult (end)
        if (arg_pars.autox == 1 && arg_level ~= 0)
            if (curr_snr_epoch == 1) % currently low SNR
                sd_mu_trial = arg_pars.sd_mu.var(1); % high noise, low SNR
                if (rand <= arg_pars.low_high(arg_level))
                    curr_snr_epoch = 2; % change to high SNR
                end
            else % currently high SNR
                sd_mu_trial = arg_pars.sd_mu.var(end); % low noise, high SNR
                if (rand <= arg_pars.high_low(arg_level))
                    curr_snr_epoch = 1; % change to low SNR
                end
            end
        end

        %%% Sample noise from noise distribution
        mu = mu_trial;
        sd = sd_mu_trial + (sd_sd_trial * randn); % sample N(sd_mu,sd_sd)

        %%% Close previous texture pointers
        if (exist('stimtex'))
            Screen('Close', stimtex);
        end

        curr_time = GetSecs - tzero_trial;
        if (curr_time >= stim_time && stim_displayed ~= 1) % display stimulus
            template = arg_tid;
            isi = stim_duration; % don't flip till duration has passed
            stim_displayed = 1;
        else % display noise
            template = -1;
            isi = arg_pars.isi;
        end

        %%% Generate texture for stim
        stimtex = gen_stimtex(arg_wip, arg_wrp, blobsize, stimsize, template,...
            thick, con, mu, sd, lumbk, lumax);

        out_stim.mu = [out_stim.mu, mu];
        out_stim.sd = [out_stim.sd, sd];
        out_stim.con = [out_stim.con, con];

        % Display stimuli
        tzero_stim = GetSecs;

        %%% DEBUG - to make sure frames are refereshed at right time
        all_stim_times = [all_stim_times tzero_stim - tzero_trial];
        %%% DEBUG

        Screen('DrawTexture', arg_wip, stimtex);
        [VBLTime tzero_flip FlipTime] = Screen('Flip', arg_wip, next_flip_time);
        ifi = FlipTime - tzero_stim; % Inter-frame interval
        next_flip_time = tzero_flip + isi - ifi; % Keep displaying stim for isi.on

        %%% Play audio for stim_duration starting stim_time
        if (curr_time >= stim_time && audio_playback ~= 1)
            PsychPortAudio('Start', pahandle, 1, 0, 0, GetSecs+stim_duration); % Start audio
            audio_playback = 1;
        end

        % Check if keyboard has been pressed
        [pressed, firstPress] = KbQueueCheck(arg_keyid);
        pressedCode = find(firstPress);
        KbQueueFlush(arg_keyid);
        WaitSecs('YieldSecs', 0.01);
    end

    %%% At end of trial, close audio port
    PsychPortAudio('Close', pahandle);

    %%% DEBUG
    all_stim_times
    %%% DEBUG

    KbQueueStop(arg_keyid);

    %%% Record time and choice
    out_dt = GetSecs-tzero_trial;
    if (pressedCode == KbName('Left'))
        out_dec = 2;
    elseif (pressedCode == KbName('Right'))
        out_dec = 5;
    else
        out_dec = -1;
    end
end


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
end
