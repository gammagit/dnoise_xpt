function [out_stim, out_dt, out_dec, out_stim_vec, out_cue_ix] = trial(arg_wip,...
                                                                       arg_wrp,...
                                                                       arg_tid,...
                                                                       arg_level,...
                                                                       arg_keyid,...
                                                                       arg_pars,...
                                                                       arg_pahandle,...
                                                                       arg_flipint,...
                                                                       arg_probe_trial,...
                                                                       arg_cue_buffer,...
                                                                       arg_fb_buffer)
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

    %%% Record the stimuli presented during each frame
    out_stim.mu = []; % mean noise during each frame
    out_stim.sd = []; % sd of noise during each frame
    out_stim.con = []; % contrast during each frame

    %%% Simple detection task
    stim_displayed = 0; % flag indicated whether stim has been displayed
    audio_playback = 0; % Prepare audio for playing beep with stim

    %%% DEBUG
    %%% all_stim_times = zeros(1,100);
    %%% all_next_flip_times = zeros(1,100);
    %%% count_stim = 1;
    %%% DEBUG

    %%% for nonstationary stimulus
    %%% NOTE: Change this to non-aging distribution. TBD!!!!!!!!!!
    poss_stim_times = [0.7, 1.0, 1.5, 2.4]; %[0.6, 1.8]; %[0.5, 1.0, 1.5, 2.0]; %[0.3, 0.6, 0.9, 1.2];
    rand_time_ix = randi([1, 4], 1, 1); %randi([1, 2], 1, 1);
    arg_pars.stim_time = poss_stim_times(rand_time_ix);
    %%% Randomly choose templates to be displayed before and after stim
%    if (rand > 0.5)
%        template_before = 2;
%    else
%        template_before = 5;
%    end
%    if (rand > 0.5)
%        template_after = 2;
%    else
%        template_after = 5;
%    end

    %%% Construct a vector indicating stim at all points during trial
    max_stim_ix = arg_pars.max_cue_ix + 50; % very large number (5s after max_cue)
    stim_vec = -1 * ones(1,max_stim_ix); % Initialise

    %%% Determine which stimulus serves as cue drawing from "non-aging" dist
    %%% T = -W*ln(RND) (Gottsdanker,Perkins & Aftab, 1986)
    %%% Also cut-off at longest forperiod max_cue_ix
    cue_ix = ceil(arg_pars.min_cue_ix - arg_pars.mean_cue_ix * log(rand));
    cue_ix = min(cue_ix, arg_pars.max_cue_ix);

    %%% On probe trials, display cue only at cue_ix
    if (arg_probe_trial)
        stim_vec(cue_ix) = arg_tid;
    else
        %%% Initialise state of the world
        if (rand > 0.5)
            prev_state = 2;
        else
            prev_state = 5;
        end
        %%% Fill stim vector based on state of the world
        for ii = 1:numel(stim_vec)
            state_ii = get_current_state(prev_state, arg_pars.pswitch);
            pshow_ix = randperm(numel(arg_pars.pshow));
            if (rand < arg_pars.pshow(pshow_ix(1)) || cue_ix == ii) % display stimulus
                stim_vec(ii) = state_ii;
            else
                stim_vec(ii) = -1;
            end
            prev_state = state_ii;
        end
    end
    template_ix = 1; % initialise
    stim_update_time = tzero_trial;

    %%% Determine how many stims to show
    %%% If probe trial - then wait for L/R key
    %%% If not probe trial, draw from uniform dist
%    if (arg_probe_trial)
%        max_template_ix = max_stim_ix; % wait till end of ix i.e. till L/R press
%    else
%        unif_low = arg_pars.post_cue_minstim; % lower limit of uniform dist
%        unif_range = arg_pars.post_cue_maxstim - arg_pars.post_cue_minstim;
%        max_template_ix = cue_ix + floor(unif_low + unif_range*rand);
%    end
    
    %%% Show the stimuli till 'Left' or 'Right' key is pressed
    next_flip_time = 0; % Initially Flip immediately
    stim_disp_time = GetSecs + 100; % initially set to very large number -- leads to error if S responds before cue
%    prev_update_time = GetSecs; % records when to move along stim_vec
    while(~(any(pressedCode == KbName('Left')) ||...
            any(pressedCode == KbName('Right'))) &&...
          GetSecs < stim_disp_time + arg_pars.max_rt)
%          template_ix < max_template_ix)
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

        %%% Change template_ix once every isi seconds
        %%% Changes on every iteration, because isi between iterations
        template_ix = template_ix + 1;
        template = stim_vec(template_ix);

        isi = arg_pars.isi;

        %%% Generate texture for stim
        stimtex = gen_stimtex(arg_wip, arg_wrp, blobsize, stimsize, template,...
            thick, con, mu, sd, lumbk, lumax);

        out_stim.mu = [out_stim.mu, mu];
        out_stim.sd = [out_stim.sd, sd];
        out_stim.con = [out_stim.con, con];

        % Display stimuli
        Screen('DrawTexture', arg_wip, stimtex);

        %tzero_stim = GetSecs;
        [VBLTime tzero_flip FlipTime] = Screen('Flip', arg_wip, next_flip_time);
        next_flip_time = VBLTime + isi - 0.5*arg_flipint; % Keep displaying stim for isi.on
        %%% DEBUG - to make sure frames are refereshed at right time
        %%% all_stim_times(count_stim) = VBLTime - tzero_trial;
        %%% all_next_flip_times(count_stim) = next_flip_time - tzero_trial;
        %%% count_stim = count_stim + 1;
        %%% DEBUG

        %%% If this is cue, play audio for cue_duration
        if (template_ix == cue_ix && audio_playback ~= 1)
            PsychPortAudio('Start', arg_pahandle, 0, 0, 0, GetSecs+arg_pars.cue_duration); % Start audio
            stim_disp_time = GetSecs; % record time at which critical cue was displayed
            audio_playback = 1; % don't play audio for future iterations
        end

        % Check if keyboard has been pressed
        [pressed, firstPress] = KbQueueCheck(arg_keyid);
        pressedCode = find(firstPress);
        KbQueueFlush(arg_keyid);
        WaitSecs('YieldSecs', 0.01);
    end

    %%% DEBUG
    %%% all_stim_times(1:10)
    %%% all_next_flip_times(1:10)
    %%% DEBUG

    KbQueueStop(arg_keyid);

    %%% Record time and choice
    out_dt = GetSecs-stim_disp_time;
    if (out_dt < 0) % S pressed key before stim was displayed
        out_dec = 0; % 0 means too soon
        %%% NOTE: Could display error message here!
    else
        if (pressedCode == KbName('Left'))
            out_dec = 2;
        elseif (pressedCode == KbName('Right'))
            out_dec = 5;
        else % no key was pressed -- exited because max_time was passed
            out_dec = -1; % -1 means too late
            %%% NOTE: Could display error message here!
        end
    end
    out_stim_vec = stim_vec;
    out_cue_ix = cue_ix;

end


function out_state = get_current_state(arg_prev_state, arg_pswitch)
%%% Implements Markov process to determine the current state based on
%%% previous state and switch probability. Assumes p(switch) is same for
%%% both types of transitions (2->5 & 5->2)

    %%% Determine the 'other' state
    if (arg_prev_state == 2)
        other_state = 5;
    else
        other_state = 2;
    end

    %%% Determine whether switch happens
    if (rand < arg_pswitch)
        out_state = other_state;
    else
        out_state = arg_prev_state;
    end
end
