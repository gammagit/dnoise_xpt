function out_xvals = calibrate(arg_wip, arg_wrp, arg_keyid, arg_pars,...
    arg_xid, arg_pvals)
%%% CALIBRATE runs a sequence of 2AFC trials and uses the responses to generate
%%% a psychometric function for the participant. It then computes the values
%%% of the desired intensity variable at the given probability values.
%%%
%%% out_xvals = vector of float containing the intensity value at the desired
%%%     probability of response.
%%%
%%% arg_wip = Screen windowPtr (see Psychtoolbox)
%%% arg_wrp = Screen rect (see Psychtoolbox)
%%% arg_keyid = int containing the ID of keyboard
%%% arg_pars = structure containing parameters of the experiment
%%% arg_xid = integer containing the id of the intensity variable to calibrate
%%%     (1=contrast; 2=external noise).

    %%% Set initial values of estimates based on variable being calibrated
    if (arg_xid == 1)
        est = arg_pars.con.init; % Estimated variable init to con.init
        min_est = 0; % defines range for contrast
        max_est = 3; % max contrast
        est_sd = 2; % a large SD as prior
        xstring = 'contrast'
    else
        est = arg_pars.sd_mu.init; % Estimated variable init to sd_mu.init
        min_est = 0; % defines range for noise
        max_est = 0.2; % max mean noise
        est_sd = 0.1; % a large SD as prior
        xstring = 'noise'
    end

    %%% Create structure for Weibull psychometric function using Quest
    qthresh = arg_pars.pthresh(1);
    qbeta=3.5; qdelta=0.01; qgamma=0.5; % for 2AFC
    weib1 = QuestCreate(est, est_sd, qthresh, qbeta, qdelta, qgamma);
%    weib.pThreshold = 0.75;
    weib2 = QuestCreate(est, est_sd, qthresh, qbeta, qdelta, qgamma);
%    weib2.pThreshold = 0.99;

    est_vec1 = [];
    est_vec2 = [];
    est_sd_vec = [];
    for (ii = 1:arg_pars.nct)
        %%% Sample the estimate from posterior (usually just mean)
        if (mod(ii,2) == 0)
            est_ii = QuestQuantile(weib1, arg_pars.pthresh(1));
            est_vec1 = [est_vec1 est_ii];
        else
            est_ii = QuestQuantile(weib2, arg_pars.pthresh(2));
            est_vec2 = [est_vec2 est_ii];
        end
%        est_ii = QuestMean(weib);

        %%% Ensure estimates are within range
        if (est_ii < min_est)
            est_ii = min_est; % 
        elseif (est_ii > max_est)
            est_ii = max_est;
        end
%        est_sd_vec = [est_sd_vec est_sd_ii];

        %%% Change contrast or noise based on Quest sample
        if (arg_xid == 1)
            arg_pars.con.calib = est_ii;
        else
            arg_pars.sd_mu.calib = est_ii;
        end

        %%% Display stimulus
        if (rand > 0.5)
            stim_id = 2;
        else
            stim_id = 5;
        end
        dec = calib_trial(arg_wip, arg_wrp, stim_id, arg_keyid, arg_pars);

        %%% Update estimate using Quest
        if (dec == stim_id)
            resp = 1;
        else
            resp = 0;
        end
        if (mod(ii,2) == 0)
            weib1 = QuestUpdate(weib1, est_ii, resp);
        else
            weib2 = QuestUpdate(weib2, est_ii, resp);
        end

        %%% Wait for ITI
        WaitSecs('YieldSecs', 0.5);
    end

    est_final1 = QuestMean(weib1)
    est_final2 = QuestMean(weib2)
%    est_sd_final = QuestSd(weib)
    est_vec1 = [est_vec1 est_final1];
    est_vec2 = [est_vec2 est_final2];
%    est_sd_vec = [est_sd_vec est_sd_final];

    allx = min_est:0.01:max_est;
    pf1=qdelta * qgamma + (1-qdelta) *...
        (1 - (1-qgamma) * exp(-10.^(qbeta * (allx-est_final1))));
    uniq=find(diff(pf1));
    out_xvals = interp1(pf1(uniq), allx(uniq), arg_pars.pthresh);
    pf2=qdelta * qgamma + (1-qdelta) *...
        (1 - (1-qgamma) * exp(-10.^(qbeta * (allx-est_final2))));
    uniq2=find(diff(pf2));
    out_xvals2 = interp1(pf2(uniq2), allx(uniq2), arg_pars.pthresh);

    figure
    subplot(2,1,1)
    plot(1:length(est_vec1), est_vec1, '-ok', 1:length(est_vec2), est_vec2, '-or');
    xlabel('trial')
    ylabel(xstring)
    subplot(2,1,2)
    plot(allx(uniq), pf1(uniq), '-.b', out_xvals, arg_pars.pthresh, 'or',...
         allx(uniq2), pf2(uniq2), '-.r', out_xvals2, arg_pars.pthresh, 'or',...
         'MarkerSize', 7);
    xlabel(xstring);
    ylabel('p (resp=1)')
%    newweib = QuestCreate(est_final, est_sd_final, qthresh, qbeta, qdelta, qgamma)
%    newweib = QuestRecompute(newweib, 1); % compute the psychometric function
%    QuestBetaAnalysis(newweib)
%    newweib
%    xThreshold=interp1(weib.p2, weib.x2, weib.pThreshold);
%    out_xval = weib.xThreshold; % intensity by interpolating pThreshold
end


function out_dec = calib_trial(arg_wip, arg_wrp, arg_tid, arg_keyid, arg_pars)
%%% CALIB_TRIAL simulates a single calibration trial. Stimulus is displayed for
%%% a fixed amount of time and participant choosed between two options.
%%%
%%% arg_wip = Screen windowPtr (see Psychtoolbox)
%%% arg_wrp = Screen rect (see Psychtoolbox)
%%% arg_tid = integer containing the id of stimulus template: 0=Back, 2=T2, 5=T5
%%% arg_keyid = int containing the ID of keyboard
%%% arg_pars = structure containing parameters of the experiment

    [cx, cy] = RectCenter(arg_wrp); % get coordinates of center

    %%% Use local variables for pars (for brevity)
    blobsize = arg_pars.blobsize;
    stimsize = arg_pars.stimsize;
    thick = arg_pars.thick;
    isi = arg_pars.isi;
    lumbk = arg_pars.lumbk;
    lumax = arg_pars.lumax;
    con = arg_pars.con.calib; % Note: not using lo & hi for calib
    mu = arg_pars.mu;
    sd_mu = arg_pars.sd_mu.calib; % sd_sd is assumed to be 0 during calib

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
    WaitSecs(1);

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
