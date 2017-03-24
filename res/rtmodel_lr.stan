functions {
    real exgauss_lpdf(vector y, real mu, real sigma, real rate) {
    // Defines log-likelihood for ex-Gaussian
        real eterm; // exponential term
        real gterm; // cumulative gaussian term
        vector[num_elements(y)] prob;
        real out;

        for (ii in 1:num_elements(y)) {
            eterm = exp((sigma^2) / (2*(rate^2)) - ((y[ii] - mu)/rate));
            gterm = Phi(((y[ii] - mu) / sigma) - (sigma / rate));
            prob[ii] = (1 /rate) * eterm * gterm;
        }

        out = sum(log(prob));
        return out;
    }
    
    matrix quad_from_diag(matrix Omega, vector tau) {
        matrix[2,2] out;
        out = diag_matrix(tau) * Omega * diag_matrix(tau);
        return out;
    }
}

data {
    int<lower=1> NS; // Number of subjects
    int<lower=1> ND; // Number of difficulties (SNRs)
    int<lower=1> NC[NS*ND]; // Number of correct RTs recorded
    int<lower=1> NX; // Number of values of predictor variable 'newx'
    vector[NX] newx; // reponse variable used for generating regression predictions
    vector[sum(NC)] rt; // reaction times in msec
}

parameters {
    corr_matrix[2] Omega_mu; // correlation matrix for mu
    corr_matrix[2] Omega_sigma;
    corr_matrix[2] Omega_rate;

    vector<lower=0>[2] tau_mu; // scale
    vector<lower=0>[2] tau_sigma;
    vector<lower=0>[2] tau_rate;

    // parameters for group
    real<lower=200,upper=5000> mu_alpha_mu; // group mean for intercept of mu param of ExG
    real mu_beta_mu; // group mean for slope of mu
    real<lower=5,upper=500> mu_alpha_sigma; // group mean for intercept of sigma
    real mu_beta_sigma; // group mean for slope of sigma
    real<lower=10,upper=1000> mu_alpha_rate; // group mean for intercept of rate
    real mu_beta_rate; // group mean for slope of rate

    // parameters for individual
    vector[2] beta_mu[NS];
    vector[2] beta_sigma[NS];
    vector[2] beta_rate[NS];
}

transformed parameters {
    matrix[ND,NS] mu;
    matrix[ND,NS] sigma;
    matrix[ND,NS] rate;

    // Vectorised group parameters -- to pass to multi_normal
    vector[2] mu_mu; // [mu_alpha_mu, mu_beta_mu]
    vector[2] mu_sigma; // [mu_alpha_sigma, mu_beta_sigma]
    vector[2] mu_rate; // [mu_alpha_rate, mu_beta_rate]
    {
        row_vector[2] x;
        for (ss in 1:NS) {
            for (dd in 1:ND) {
                x[1] = 1;
                x[2] = dd;
                mu[dd,ss] = x * beta_mu[ss]; //COEF_MU[ss,1] + (COEF_MU[ss,2] * dd);
                sigma[dd,ss] = x * beta_sigma[ss]; //COEF_SIGMA[ss,1] + (COEF_SIGMA[ss,2] * dd);
                rate[dd,ss] = x * beta_rate[ss]; //COEF_RATE[ss,1] + (COEF_RATE[ss,2] * dd);
            }
        }
    }

    // Construct multinomial mean vector & sigma matrix
    mu_mu[1] = mu_alpha_mu;
    mu_mu[2] = mu_beta_mu;

    mu_sigma[1] = mu_alpha_sigma;
    mu_sigma[2] = mu_beta_sigma;

    mu_rate[1] = mu_alpha_rate;
    mu_rate[2] = mu_beta_rate;
}

model {
    int rtix_l; // left index of rt array for subject
    int rtix_r; // right index

    // Priors on group parameters
    tau_mu ~ cauchy(0, 2.5);
    tau_sigma ~ cauchy(0, 2.5);
    tau_rate ~ cauchy(0, 2.5);
    Omega_mu ~ lkj_corr(2);
    Omega_sigma ~ lkj_corr(2);
    Omega_rate ~ lkj_corr(2);
    mu_alpha_mu ~ normal(1000, 1000);
    mu_beta_mu ~ normal(0, 1000);
    mu_alpha_sigma ~ normal(100, 500);
    mu_beta_sigma ~ normal(0, 1000);
    mu_alpha_rate ~ normal(100, 500);
    mu_beta_rate ~ normal(0, 1000);

    // Individual regression parameters from group level parameters
    for (ss in 1:NS) {
        beta_mu[ss] ~ multi_normal(mu_mu, quad_from_diag(Omega_mu, tau_mu));
        beta_sigma[ss] ~ multi_normal(mu_sigma, quad_from_diag(Omega_sigma, tau_sigma));
        beta_rate[ss] ~ multi_normal(mu_rate, quad_from_diag(Omega_rate, tau_rate));
    }

    // Trials from individual parameters
    rtix_l = 0;
    rtix_r = 0;
    for (ss in 1:NS) {
        for (dd in 1:ND) {
            //Compute indices in the rt vector
            rtix_l = rtix_r + 1; // previous + 1
            rtix_r = rtix_l + NC[(ss-1)*ND+dd] - 1;
            // RTs from individual and SNR level parameters
            rt[rtix_l:rtix_r] ~ exgauss(mu[dd,ss], sigma[dd,ss], rate[dd,ss]);
        }
    }

    //print("beta_mu = ", beta_mu);
    //print("mu_sigma = ", mu_sigma);
    //print("mu_rate = ", mu_rate);
    //print("log-posterior_1 = ", target());

}

generated quantities {
    // Posterior predictive checks
    vector[NX] mu_pred[NS]; // predictions of mu
    for (ss in 1:NS) {
        mu_pred[ss] = beta_mu[ss,1] + newx * beta_mu[ss,2];
    }
    
}

//R code:
/*
    fit <- stan()
    print(fit, digits=2)
    pairs(fit)
    hist(extract(fit)$mu)
    traceplot(fit, include_warmup=FALSE)
*/

