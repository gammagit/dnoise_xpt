function out_Stim = add_noise(arg_Stim, arg_mu, arg_sd)

    out_Stim = ones(size(arg_Stim)); % initialise

    %%% Sample noise, if not in [-1, 1], resample
%    while (any(any(out_Stim >= 1)) || any(any(out_Stim <= -1)))
%        noise_Mat = arg_mu + (arg_sd * randn(size(arg_Stim)));
%        out_Stim = arg_Stim + noise_Mat;
%    end
    noise_Mat = arg_mu + (arg_sd * randn(size(arg_Stim)));
    out_Stim = arg_Stim + noise_Mat;
end
