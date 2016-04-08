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

    use_quantile = true; % Use QuestQuantile or QuestP
    eps_noise = 0.1; % "e-greedy" noisy staircase method

    %%% Set initial values of estimates based on variable being calibrated
    if (arg_xid == 1)
        est = arg_pars.con.init; % Estimated variable init to con.init
        min_est = 0; % defines range for contrast
        max_est = 3; % max contrast
        est_sd = 1; % a large SD as prior
        xstring = 'contrast threshold estimates';
    else
        est = arg_pars.sd_mu.init; % Estimated variable init to sd_mu.init
        min_est = 0; % defines range for noise
        max_est = 0.2; % max mean noise
        est_sd = 0.1; % a large SD as prior
        xstring = 'noise threshold estimates';
    end

    %%% Create structure for Weibull psychometric function using Quest
    qthresh = arg_pars.pthresh(3);
    qbeta=3; qdelta=0.01; qgamma=0.5; % for 2AFC
    weib = QuestCreate(est, est_sd, qthresh, qbeta, qdelta, qgamma);

    %%% Create matrices of intensities displayed and responses given
    nints = numel(arg_pars.pthresh); % number of intensity thresholds to test
    for (ii = 1:nints)
        ints_vec{ii} = [];
        resp_vec{ii} = [];
    end
%    intsMat = zeros(nints, ceil(arg_pars.nct/nints)); % record of intensities
%    counters_ints = zeros(1,nints); % counters for each row of intsMat
%    respMat = -1 * ones(nints, ceil(arg_pars.nct/nints)); % record of responses

    %%% Create a vector of domain of intensity (for interpolation)
%    allx = linspace(-max_est, max_est, 1000); % Note: -max avoids NaNs in interp
    allx = linspace(min_est, max_est, 1000);
    ints_perms = randperm(nints); % first permutation of intensities

    %%% Iterate of nct trials and update estimate at each step
    for (ii = 0:arg_pars.nct-1)
        %%% Sample the estimate from posterior (usually just mean)
        test_ints = ints_perms(1); % randomly select one threshold
        if (numel(ints_perms) == 1)
            ints_perms = randperm(nints); % next permutation
        else
            ints_perms = ints_perms(2:end); % used first element, so remove
        end
%        test_ints = ceil(rand/(1/nints)); % randomly select one threshold
%        if (test_ints == 0) % if rand returns 0, correct it
%            test_ints = 1;
%        end
%        counters_ints(test_ints) = counters_ints(test_ints) + 1;
%        est_ii = QuestMean(weib); % using mean (not quantile) to get psych fn
        if (use_quantile)
            est_ii = QuestQuantile(weib, arg_pars.pthresh(test_ints));
        else
            mean_ii = QuestMean(weib);
            pf = QuestP(weib, allx-mean_ii);
            uniq=find(diff(pf));
            est_ii = interp1([pf(uniq), 1], [allx(uniq), max_est+1],...
                arg_pars.pthresh(test_ints));
        end

        %%% e-greedy: sample est_ii from a [0 0.5] w.p. eps_noise
        %%% Gives some low samples, in case the first few resps are wrong
        if (rand < eps_noise)
            est_ii = 0 + 0.5 * rand
        end

        %%% Ensure estimates are within range
        if (est_ii < min_est)
            est_ii = min_est; % 
        elseif (est_ii > max_est)
            est_ii = max_est;
        end

        %%% Construct psychometric fn and interpolate intensities from pthresh
%        pf=qdelta * qgamma + (1-qdelta) *...
%            (1 - (1-qgamma) * exp(-10.^(qbeta * (allx-est_ii)))); % Weibull pf
%        pf = QuestP(weib, allx-est_ii);
%        uniq=find(diff(pf));
%        xvals = interp1(pf(uniq), allx(uniq), arg_pars.pthresh);
%        ints_ii = xvals(test_ints); % select one of nints
        ints_ii = est_ii; % select one of nints

%        intsMat(test_ints, counters_ints(test_ints)) = ints_ii;
        ints_vec{test_ints} = [ints_vec{test_ints}, ints_ii];

        %%% Change contrast or noise to display based on Quest sample
        if (arg_xid == 1)
            arg_pars.con.calib = max(ints_ii, min_est); % minimum contrast = 0
        else
            arg_pars.sd_mu.calib = max(ints_ii, min_est); % minimum noise = 0
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
            resp_ii = 1;
        else
            resp_ii = 0;
        end
        weib = QuestUpdate(weib, ints_ii, resp_ii);
%        respMat(test_ints, floor(ii/nints)+1) = resp_ii;
        resp_vec{test_ints} = [resp_vec{test_ints} resp_ii];

        %%% Wait for ITI
        WaitSecs('YieldSecs', 0.5);
    end


    %%% Construct final psychometric fn based on staircase method (Quest)
    est_mean = QuestMean(weib); % final estimate
    est_beta = QuestBetaAnalysis(weib);
%    pf_quest = qdelta * qgamma + (1-qdelta) *...
%               (1 - (1-qgamma) * exp(-10.^(est_beta * (allx-est_mean))));
    pf_quest = QuestP(weib, allx-est_mean);

    %%% Aggregate all intensity and response vectors
    all_ints = [];
    all_resps = [];
    for (ii = 1:nints)
        all_ints = [all_ints ints_vec{ii}];
        all_resps = [all_resps resp_vec{ii}];
    end

    %%% Construct final psychometric fn based on ML est
    pf_ml = fit_mlepf(allx, all_ints, all_resps);
    all_ints
    all_resps

    uniq=find(diff(pf_quest));
    quest_xvals = interp1(pf_quest(uniq), allx(uniq), arg_pars.pthresh(1:3));
    uniq=find(diff(pf_ml));
    out_xvals = interp1(pf_ml(uniq), allx(uniq), arg_pars.pthresh(1:3));

    figure
    subplot(2,1,1)
%    plot(intsMat');
    colorMat = [1 0 0; 0 0 1; 0 0 0; 0 1 0; 1 1 0; 0 1 1; 1 0 1];
    hold on
    for (ii = 1:nints)
        plot(1:numel(ints_vec{ii}), ints_vec{ii}, 'Color', colorMat(ii,:));
    end
    hold off
    ylim([0, 2])
    xlabel('trial')
    ylabel(xstring)
    subplot(2,1,2)
    hold on
    plot(allx(uniq), pf_quest(uniq), '-.b', out_xvals, arg_pars.pthresh(1:3), 'ob',...
         'MarkerSize', 7);
    plot(allx(uniq), pf_ml(uniq), '-.r', out_xvals, arg_pars.pthresh(1:3), 'or',...
         'MarkerSize', 7);
    hold off
    xlim([0, 1.5])
    xlabel(xstring);
    ylabel('p (resp=1)')
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
