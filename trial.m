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
        sd_mu_trial = arg_pars.sd_mu.var(arg_level);
        sd_sd_trial = arg_pars.sd_sd.var(arg_level);
    else % indicates high contrast trial
        con = arg_pars.con.var(end) + 1.0;
        sd_mu_trial = arg_pars.sd_mu.var(1); %%% TODO: Change for noise xpt
        sd_sd_trial = arg_pars.sd_sd.var(1);
    end

    %%% Display background and fixation cross
%    texbk = gen_stimtex(arg_wip, arg_wrp, blobsize, stimsize, 0, thick, con, 0, 0,...
%        lumbk, lumax);
%    Screen('DrawTexture', arg_wip, texbk);
%    draw_fixation(arg_wip, arg_wrp, [lumax lumax lumax]*0.75);
    tzero_trial = GetSecs;
%    [VBLTime tzero_trial FlipTime]=Screen('Flip', arg_wip);

    %%% Create input queue for keyboard
    KbQueueCreate(arg_keyid); % Create a keyboard queue in advance to save time
    pressed = 0; pressedCode = []; % Flag & code for keyboard queue
    KbQueueStart(arg_keyid); % Start a new queue for each trial

    %%% Record the stimuli presented during each frame
    out_stim.mu = []; % mean noise during each frame
    out_stim.sd = []; % sd of noise during each frame
    out_stim.con = []; % contrast during each frame
    
    %%% Show the stimuli till 'Left' or 'Right' key is pressed
    next_flip_time = 0; % Initially Flip immediately
    while(~(any(pressedCode == KbName('Left')) ||...
            any(pressedCode == KbName('Right'))))
        %%% Sample noise from noise distribution
        mu = mu_trial;
        sd = sd_mu_trial + (sd_sd_trial * randn); % sample N(sd_mu,sd_sd)

        %%% Close previous texture pointers
        if (exist('stimtex'))
            Screen('Close', stimtex);
        end

        %%% Generate texture for stim
        stimtex = gen_stimtex(arg_wip, arg_wrp, blobsize, stimsize, arg_tid,...
            thick, con, mu, sd, lumbk, lumax);

        out_stim.mu = [out_stim.mu, mu];
        out_stim.sd = [out_stim.sd, sd];
        out_stim.con = [out_stim.con, con];

        % Display stimuli
        tzero_stim = GetSecs;
        Screen('DrawTexture', arg_wip, stimtex);
        [VBLTime tzero_flip FlipTime] = Screen('Flip', arg_wip, next_flip_time);
        ifi = FlipTime - tzero_stim; % Inter-frame interval
        next_flip_time = tzero_flip + isi - ifi; % Keep displaying stim for isi.on

        % Check if keyboard has been pressed
        [pressed, firstPress] = KbQueueCheck(arg_keyid);
        pressedCode = find(firstPress);
        KbQueueFlush(arg_keyid);
        WaitSecs('YieldSecs', 0.01);
    end

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
