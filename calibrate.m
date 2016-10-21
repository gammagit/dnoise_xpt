function [out_xvals, out_nc, out_nic] = calibrate(arg_wip, arg_wrp, arg_keyid,...
                                                  arg_pars, arg_xid, arg_plot)
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

    %%% Set initial values of estimates based on variable being calibrated
    if (arg_xid == 1)
        est = 1/(arg_pars.sd_mu.init^2); % Est precision at start of Quest
        max_est = 1/(0.1^2); % defines range for precision of noise
        min_est = 1/(0.5^2); % min mean noise
        est_sd = 1/(0.1^2); % a large SD as prior
        xstring = 'precision threshold estimates';
    else
        est = arg_pars.con.init; % Estimated variable init to con.init
        min_est = 0; % defines range for contrast
        max_est = 3; % max contrast
        est_sd = 0.25; % a large SD as prior
        xstring = 'contrast threshold estimates';
    end

    %%% Create matrices of intensities displayed and responses given
    nints = numel(arg_pars.pthresh); % number of intensity thresholds to test
    for (ii = 1:nints)
        ints_vec{ii} = [];
        resp_vec{ii} = [];
    end

    %%% Create structure for Weibull psychometric function using Quest
%     %%% DEBUG
%     clear Screen
%     %%% DEBUG
    qthresh = arg_pars.pthresh(2);
    if (arg_xid == 1)
        qbeta=0.25; qdelta=0.20; qgamma=0.5; % for 2AFC
        weib = QuestCreate(est, est_sd, qthresh, qbeta, qdelta, qgamma, 1, 100);
%         weib = QuestCreate(est, est_sd, qthresh, qbeta, qdelta, qgamma);
    else
        qbeta=3; qdelta=0.20; qgamma=0.5; % for 2AFC
        weib = QuestCreate(est, est_sd, qthresh, qbeta, qdelta, qgamma);
    end

    %%% Create a vector of domain of intensity (for interpolation)
    allx = linspace(min_est, max_est, 5000);
    ints_perms = randperm(nints); % first permutation of intensities

    for (jj = 1:2) % Split calibration into two sub-blocks
        %%% Warm-up: Display some easy trials
        for (ii = 1:arg_pars.nwup(jj))
            %%% Sample intensity
            if (arg_xid == 1)
                ints_ii = 1/((arg_pars.wup.min_sd +...
                        (arg_pars.wup.max_sd - arg_pars.wup.min_sd) * rand)^2);
            else
                ints_ii = arg_pars.wup.min_con +...
                        (arg_pars.wup.max_con - arg_pars.wup.min_con) * rand;
            end

            %%% Display a trial
            if (rand > 0.5)
                stim_id = 2;
            else
                stim_id = 5;
            end
            dec = calib_trial(arg_wip, arg_wrp, stim_id, arg_keyid, arg_pars,...
                            ints_ii, arg_xid);

            %%% Wait for ITI
            WaitSecs('YieldSecs', 0.5);
        end

%         %%% DEBUG
%         figure;
%         %%% DEBUG
        
        %%% Iterate over nct trials and update estimate at each step
        for (ii = 0:arg_pars.nct-1)
            %%% Choose a random threshold but circulate over all of them
            test_ints = ints_perms(1); % randomly select one threshold
            if (numel(ints_perms) == 1)
                ints_perms = randperm(nints); % next permutation
            else
                ints_perms = ints_perms(2:end); % used first element, so remove
            end

            %%% Sample the intensity to be displayed from posterior
            if (use_quantile) % sample based on Quantile
                ints_ii = QuestQuantile(weib, arg_pars.pthresh(test_ints));
            else % sample based on mean and then interpolated from pf
                mean_ii = QuestMean(weib);
                pf = QuestP(weib, allx-mean_ii);
                uniq=find(diff(pf));
                ints_ii = interp1([pf(uniq), 1], [allx(uniq), max_est+1],...
                    arg_pars.pthresh(test_ints));
            end

            %%% Ensure samples are within range
            if (ints_ii < min_est)
                ints_ii = min_est; % 
            elseif (ints_ii > max_est)
                ints_ii = max_est;
            end

            %%% Record the intensities
           ints_vec{test_ints} = [ints_vec{test_ints}, ints_ii];
%             ints_vec{test_ints} = [ints_vec{test_ints}, sqrt(ints_ii)];

            %%% Display stimulus trial
            if (rand > 0.5)
                stim_id = 2;
            else
                stim_id = 5;
            end

            dec = calib_trial(arg_wip, arg_wrp, stim_id, arg_keyid, arg_pars,...
                            ints_ii, arg_xid);

%             %%% DEBUG
%             if (ii == 8)
%                 clear Screen
%                 disp(ints_vec{2})
%             end
            
            %%% Update Quest's estimate based on response
            if (dec == stim_id)
                resp_ii = 1;
            else
                resp_ii = 0;
            end
            
%             %%% DEBUG
%             est_mean0 = QuestMean(weib)
%             pf_quest0 = QuestP(weib, allx-est_mean0);
%             uniq0=find(diff(pf_quest0));
%             plot(allx(uniq0), pf_quest0(uniq0), '-.b');
%             hold on
% %             clear Screen
%             %%% DEBUG
            
            weib = QuestUpdate(weib, ints_ii, resp_ii);
    
            %%% Record the responses
            resp_vec{test_ints} = [resp_vec{test_ints} resp_ii];

            %%% Wait for ITI
            WaitSecs('YieldSecs', 0.5);
        end

        if (jj == 1) % Mandatory break between calibration blocks
            DrawFormattedText(arg_wip,...
                                ['You are half-way through the first block.\n\nPlease take a 30 sec break. The experiment will automatically proceed after after this time.'],...
                                'center',...
                                'center',...
                                BlackIndex(arg_wip),...
                                60, 0, 0, 1.5);
            Screen('Flip', arg_wip);
            WaitSecs('YieldSecs', 30);
            %%%DEBUG
%             WaitSecs('YieldSecs', 2);

            Screen('Flip', arg_wip);
            WaitSecs('YieldSecs', 1);
            DrawFormattedText(arg_wip,...
                                ['Press any key to proceed.'],...
                                'center',...
                                'center',...
                                BlackIndex(arg_wip),...
                                60, 0, 0, 1.5);
            Screen('Flip', arg_wip);
            WaitSecs('YieldSecs', 1);
            [KeyIsDown, endrt, KeyCode]=KbCheck;
            while(~KeyIsDown)
                [KeyIsDown, endrt, KeyCode]=KbCheck;
            end
            Screen('Flip', arg_wip);
            WaitSecs('YieldSecs', 0.5);
        end
    end

    %%% Aggregate all intensity and response vectors
    all_ints = [];
    all_resps = [];
    for (ii = 1:nints)
        all_ints = [all_ints ints_vec{ii}];
        all_resps = [all_resps resp_vec{ii}];
    end
    out_nc = sum(all_resps == 1); % number of correct responses
    out_nic = sum(all_resps == 0); % number of incorrect

    %%% Construct final psychometric fn based on staircase method (Quest)
    est_mean = QuestMean(weib); % final estimate
    est_beta = QuestBetaAnalysis(weib);
%     pf_quest = QuestP(weib, allx-est_mean);

    %%% Construct final psychometric fn based on ML est
    pf_ml = fit_mlepf(allx, all_ints, all_resps);
%    all_ints
%    all_resps

%     %%% DEBUG
%     clear Screen
%     %%% DEBUG
    
    %%% Get final thresholds by interpolating p(thresh) from pf
%     uniq=find(diff(pf_quest));
%     quest_xvals = interp1(pf_quest(uniq), allx(uniq), arg_pars.pthresh(1:3));
    uniq=find(diff(pf_ml));
    out_xvals = interp1(pf_ml(uniq), allx(uniq), arg_pars.pthresh(1:3));
%     if (arg_xid == 1)
%         out_xvals = sqrt(1./out_xvals); % convert precision back into sd
%     end

    %%% Display estimated psychometric functions and data
    if (arg_plot)
        figure
        %%% Plot staircases
        subplot(2,1,1)
        colorMat = [1 0 0; 0 0 1; 0 0 0; 0 1 0; 1 1 0; 0 1 1; 1 0 1];
        hold on
        for (ii = 1:nints)
            plot(1:numel(ints_vec{ii}), ints_vec{ii}, '-.x', 'Color', colorMat(ii,:));
        end
        hold off
        %ylim([0, 2])
        xlabel('trial')
        ylabel(xstring)

        %%% Plot psychometric functions
        subplot(2,1,2)
%         pf_quest(uniq)
%         plot(allx(uniq), pf_quest(uniq), '-.b', out_xvals, arg_pars.pthresh(1:3), 'ob',...
%             'MarkerSize', 7);
        hold on
        plot(allx(uniq), pf_ml(uniq), '-r', out_xvals, arg_pars.pthresh(1:3), 'or',...
            'MarkerSize', 8, 'LineWidth', 2);

        %%% Plot proportion of responses
        resp0 = all_ints(find(all_resps == 0));
        resp1 = all_ints(find(all_resps == 1));
        if (arg_xid == 1)
            edges = linspace(min_est, max(resp1), 20);
        else
            edges = linspace(min_est, 1.0, 20);
        end
        bins_resp0 = histc(resp0, edges);
        bins_resp1 = histc(resp1, edges);
        sum_bins = bins_resp1 + bins_resp0
        prop_bins = bins_resp1 ./ sum_bins
        nzix = find(sum_bins ~= 0); % to avoid divide by 0
        scatter(edges(nzix), prop_bins(nzix), 15*sum_bins(nzix), 'k', 'filled');
        hold off
        %xlim([0, 1.5])
        %ylim([0, 1.1])
        
%         %%% DEBUG - start
%         clear Screen
%         %%% DEBUG - end
        
        xlabel(xstring);
        ylabel('p (resp=1)')
    end
end
