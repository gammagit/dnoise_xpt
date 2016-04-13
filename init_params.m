function out_pars = init_params()

    %%% SNR parameters
    out_pars.con.lo = 0.45;
    out_pars.con.hi = 1.90;
    out_pars.con.const = 0.50; % contrast in single SNR expt

    %%% Noise parameters
    out_pars.mu = 0; % mean noise in frame
    out_pars.sd_mu.lo = 0.05; % low noise: mean sd frame-to-frame
    out_pars.sd_sd.lo = 0.02; % low noise: sd of sd frame-to-frame
    out_pars.sd_mu.hi = 0.10; % high noise: mean sd frame-to-frame
    out_pars.sd_sd.hi = 0.03; % high noise: sd of sd frame-to-frame
    out_pars.sd_mu.const = 0.10; % constant noise expt, mean sd
    out_pars.sd_sd.const = 0.03; % constant noise expt, sd sd

    %%% Display parameters
    out_pars.blobsize = [200 200];
    out_pars.stimsize = [50 40];
    out_pars.thick = 8;
    out_pars.lumbk = 128;
    out_pars.lumax = 254;

    %%% Time-related parameters
    out_pars.isi = 0.05;
    out_pars.iti_c = 2;
    out_pars.iti_ic = 5;
    out_pars.tblock = 10; % duration of each block

    %%% Calibration related parameters
    out_pars.nct = 20; % number of trials to calibrate
    out_pars.con.init = 0.4; % initial value of contrast for Quest
    out_pars.con.calib = 0.70; % contrast if noise is being calibrated
    out_pars.sd_mu.init = 0.10; % initial value of noise for Quest
    out_pars.sd_mu.calib = 0.10; % noise if contrast is being calibrated
    out_pars.pthresh = [0.60 0.75 0.90 0.9999]; % psychometric thresholds for testing
    out_pars.tcalib = 1; % duration of calibration trial
end
