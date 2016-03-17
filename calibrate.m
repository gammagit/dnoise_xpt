function out_xvals = calibrate(arg_wip, arg_wrp, arg_keyid, arg_pars, arg_xid, arg_pvals)
%%% CALIBRATE runs a sequence of 2AFC trials and uses the responses to generate
%%% a psychometric function for the participant. It then computes the values
%%% of the desired intensity variable at the given probability values.
%%%
%%% arg_wip = Screen windowPtr (see Psychtoolbox)
%%% arg_wrp = Screen rect (see Psychtoolbox)
%%% arg_keyid = int containing the ID of keyboard
%%% arg_pars = structure containing parameters of the experiment
%%% arg_xid = integer containing the id of the intensity variable to calibrate
%%%     (1=contrast; 2=external noise).
%%% arg_pvals = vector of floats containing the probabilities of response = 1
%%%     at which the intensity level has to be determined

    if (arg_xid == 1)
        con = arg_pars.con.init;
        sd_mu = arg_pars.sd_mu.calib;
    else
        con = arg_pars.con.calib;
        sd_mu = arg_pars.sd_mu.init;
    end
    sd_sd = 0; % always zero during calibration

    %%% Create structure for Weibull psychometric function using Quest
    weib = QuestCreate()

    for (ii = 1:arg_pars.nct)
        %%% Set values of contrast or noise
        if (arg_xid == 1)
            arg_pars.
        else
        end
        %%% Display stimulus
    end
end
