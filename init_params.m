function out_pars = init_params()

    %%% Experiment parameters
    out_pars.nblocks = 2; %10; % number of blocks
    out_pars.ntrials = 10; %60; % number of trials in block (if not fixed-time)
    out_pars.neg = 10; % number of example trials before RT blocks
    out_pars.pveasy = 0.10; % probability that trial will be very easy

    %%% Signal parameters
    out_pars.con.var = [0.45 1.0 1.90]; % contrast in variable signal xpt
    out_pars.con.const = 1.2 * ones (1,3); % contrast in variable noise xpt

    %%% Autocorrelation parameters
    out_pars.autox = 1; % flag indicating whether autocorrelated signal
    out_pars.low_high = [0.03 0.05 0.10]; % prob low->high (for 3 difficulties)
    out_pars.high_low = [0.25 0.25 0.25];

    %%% Noise parameters
    out_pars.mu = 0; % mean noise in frame
    out_pars.sd_mu.var = [0.05 0.08 0.10]; % mean sd frame-to-frame; var noise
    out_pars.sd_mu.const = [0.20 0.20 0.20]; % constant noise expt, mean sd
    out_pars.sd_sd.var = [0 0 0]; % sd of sd frame-to-frame; var noise
    out_pars.sd_sd.const = [0 0 0];%0.03; % constant noise expt, sd sd

    %%% Display parameters
    out_pars.blobsize = [200 200];
    out_pars.stimsize = [50 40];
    out_pars.thick = 8;
    out_pars.lumbk = 0.5;
    out_pars.lumax = 1;

    %%% Time-related parameters
    out_pars.mindt = 0.40;
    out_pars.isi = 0.04;
    out_pars.iti_c = 2;
    out_pars.iti_ic = 5;
    out_pars.tblock = 10; % duration of each block

    %%% Calibration related parameters
    out_pars.nct = 20;%60; % number of trials to calibrate
    out_pars.con.init = 2.0; % initial value of contrast for Quest
    out_pars.con.calib = out_pars.con.const(2); % contrast if noise is being calibrated
    out_pars.sd_mu.init = 0.11; % initial value of noise for Quest
    out_pars.sd_mu.calib = out_pars.sd_mu.const(2); % noise if contrast is being calibrated
    out_pars.pthresh = [0.60 0.75 0.90 0.99]; % psychometric thresholds for testing
    out_pars.tcalib = 1; % duration of calibration trial

    %%% Warm-up trials parameters
    out_pars.nwup = [10 5]; % warm-up trials in each calibration block
    out_pars.wup.min_con = 1.5; % minimum contrast during warm-up
    out_pars.wup.max_con = 3.0; % maximum contrast during warm-up
    out_pars.wup.min_sd = 0.05; % minimum contrast during warm-up
    out_pars.wup.max_sd = 0.20; % maximum contrast during warm-up
end
