function out_pf = fit_mlepf(arg_domvec, arg_sigvec, arg_respvec)
%%% FIT_MLEPF finds the maximum likelihood estimate for the psychometric
%%% function for a dataset containing signals and responses. The psychometric
%%% function is given by:
%%%     pf(x|a,b,g,d) = g + (1-g-d) * W(x|a,b)
%%% where, a,b,g,d are parameters and W(x) is the Weibull function (see
%%% Wichmann & Hill, 2001)
%%%
%%% out_pf = vector containing the value of the psychometric function at each
%%%     point in the domain.
%%%
%%% arg_domvec = vector containing the domain of the signal vector
%%% arg_sigvec = vector containing the values of signal seen by participant
%%% arg_respvec = vector containing the participants responses (0/1)

    data.respvec = arg_respvec;
    data.sigvec = arg_sigvec;

    init_pars = [0.05 1 3]; %initial lapse, scale & shape parameters
    options=optimset('Display','off','MaxIter',10000,'TolX',10^-30,'TolFun',10^-30);

    fit_pars = fminsearch('nllpf', init_pars, options, data);
end

function out_y = psychf(arg_pars, arg_x)
%%% PSYCHF computes the values of the psychometric function at given vector of
%%% points for a given set of parameters. The psychometric function is given by:
%%%
%%%     pf(x|\scale,\shape,\lbound,\lapse) =...
%%%         \lbound + (1-\lbound-\lapse) * W(x|\scale,\shape)
%%%
%%% where, \scale, \shape, \lbound and \lapse are parameters of the psychometric
%%% function and W(x) is the 2-parameter Weibull function, which in turn is
%%% given by:
%%%
%%%     W(x|\scale,\shape) = 1 - exp[(-x/\scale).^\shape]
%%%
%%% out_y = vector containing value of weibull distribution
%%%
%%% arg_pars = structure containing parameters for the psychometric function:
%%%     arg_pars(1) = lapse parameter of pf
%%%     arg_pars(2) = scale parameter Weibull dist
%%%     arg_pars(3) = shape parameter Weibull dist

    lbound = 0.5; % fix the lbound parameter for 2AFC
    lapse = arg_pars(1);
    scale = arg_pars(2);
    shape = arg_pars(3);
    
    out_y = lbound + ((1 - lbound - lapse) .*...
                      (1 - exp((-arg_x./scale) .^ shape)));
end


function out_ll = nllpf(arg_pars, arg_data)
%%% LLPF computes the negative log-likelihood of set of parameters of the
%%% psychometric function, given a set of signals and responses
%%%     Prob correct responses = pf(pars, data)
%%%     Prob incorrect responses = 1 - pf(pars, data)
%%%     Therefore, if ri=1 for correct responses and ri=0 for incorrect, then
%%%     lik = prod(prob_correct.^ri * prob_incorrect.^(1-ri))
%%%     lik = prod( pf.^ri * (1-pf).^(1-ri), and
%%%     loglik = sum(ri .* pf + (1-ri).*(1-pf))
%%%
%%% out_ll = float containing the log-likelihood
%%%
%%% arg_pars = structure containing the parameters of the psychometric fn
%%% arg_data = structure containing set of signals (arg_data.sigvec) and
%%%     responses (arg_data.respvec)

    responses = arg_data.respvec;
    signals = arg_data.sigvec;

    out_ll = -sum(responses .* log(psychf(arg_pars, signals)) +...
                 (1 - responses) .* (1 - log(psychf(arg_pars, signals))));
end
