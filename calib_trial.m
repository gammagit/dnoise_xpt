function out_dec = calib_trial(arg_wip,...
                               arg_wrp,...
                               arg_tid,...
                               arg_keyid,...
                               arg_pars,...
                               arg_ints,...
                               arg_xid)
%%% CALIB_TRIAL simulates a single calibration trial. Stimulus is displayed for
%%% a fixed amount of time and participant choosed between two options.
%%%
%%% arg_wip = Screen windowPtr (see Psychtoolbox)
%%% arg_wrp = Screen rect (see Psychtoolbox)
%%% arg_tid = integer containing the id of stimulus template: 0=Back, 2=T2, 5=T5
%%% arg_keyid = int containing the ID of keyboard
%%% arg_pars = structure containing parameters of the experiment
%%% arg_ints = intensity of stimulus (contrast for expt1 or noise for expt2)
%%% arg_xid = integer containing the id of the intensity variable to calibrate
%%%     (1=contrast; 2=external noise).

    [cx, cy] = RectCenter(arg_wrp); % get coordinates of center

    %%% Use local variables for pars (for brevity)
    blobsize = arg_pars.blobsize;
    stimsize = arg_pars.stimsize;
    thick = arg_pars.thick;
    isi = arg_pars.isi;
    lumbk = arg_pars.lumbk;
    lumax = arg_pars.lumax;
    mu = arg_pars.mu;
    if (arg_xid == 1)
        con = arg_pars.con.calib;
        sd_mu = arg_ints; % sd_sd is assumed to be 0 during calib
    else
        con = arg_ints; % Note: not using lo & hi for calib
        sd_mu = arg_pars.sd_mu.calib;
    end

    %%% Display background and fixation cross
    texbk = gen_stimtex(arg_wip, arg_wrp, blobsize, stimsize, 0, thick, con,...
        0, 0, lumbk, lumax);
    Screen('DrawTexture', arg_wip, texbk);
    draw_fixation(arg_wip, arg_wrp, [lumax lumax lumax]*0.75);
    [VBLTime tzero_flip FlipTime]=Screen('Flip', arg_wip);
    WaitSecs(1);

    %%% Remove fixation cross and Wait
    texbk = gen_stimtex(arg_wip, arg_wrp, blobsize, stimsize, 0, thick, con,...
        0, 0, lumbk, lumax);
    Screen('DrawTexture', arg_wip, texbk);
    Screen('Flip', arg_wip);
    WaitSecs(0.5);

    tzero_trial = GetSecs; % record starting time

    next_flip_time = 0; % Initially Flip immediately
    while((GetSecs - tzero_trial) <= arg_pars.tcalib)
        if (exist('stimtex'))
            Screen('Close', stimtex);
            clear stimtex;
        end
        %%% Generate texture for stim
        stimtex = gen_stimtex(arg_wip, arg_wrp, blobsize, stimsize, arg_tid,...
            thick, con, mu, sd_mu, lumbk, lumax);

        %%% Display stimulus
        tzero_stim = GetSecs;
        Screen('DrawTexture', arg_wip, stimtex);
        [VBLTime tzero_flip FlipTime] = Screen('Flip', arg_wip, next_flip_time);
        ifi = FlipTime - tzero_stim; % Inter-frame interval
        next_flip_time = tzero_flip + isi - ifi; % Keep displaying stim for isi.on

        WaitSecs('YieldSecs', 0.01);
    end

    %%% Create input queue for keyboard
    KbQueueCreate(arg_keyid); % Create a keyboard queue in advance to save time
    pressed = 0; pressedCode = []; % Flag & code for keyboard queue
    KbQueueStart(arg_keyid); % Start a new queue for each trial

    %%% Remove stimulus and Wait
    texbk = gen_stimtex(arg_wip, arg_wrp, blobsize, stimsize, 0, thick, con,...
        0, 0, lumbk, lumax);
    Screen('DrawTexture', arg_wip, texbk);
    Screen('Flip', arg_wip);
    WaitSecs(0.5);

    %%% Ask for a response
    texbk = gen_stimtex(arg_wip, arg_wrp, blobsize, stimsize, 0, thick, con,...
        0, 0, lumbk, lumax);
    Screen('DrawTexture', arg_wip, texbk);
    DrawFormattedText(arg_wip,...
                        'Press Left for "2"   or   Right for "5"',...
                        'center',...
                        'center',...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    Screen('Flip', arg_wip);

    %%% Check if keyboard has been pressed
    while(~(any(pressedCode == KbName('Left')) ||...
            any(pressedCode == KbName('Right'))))
        [pressed, firstPress] = KbQueueCheck(arg_keyid);
        pressedCode = find(firstPress);
        KbQueueFlush(arg_keyid);
        WaitSecs('YieldSecs', 0.05);
    end

    %%% Stop Queue
    KbQueueStop(arg_keyid);

    %%% Record choice
    if (pressedCode == KbName('Left'))
        out_dec = 2;
    elseif (pressedCode == KbName('Right'))
        out_dec = 5;
    else
        out_dec = -1;
    end
end

