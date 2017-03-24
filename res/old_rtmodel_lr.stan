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
}

data {
    int<lower=1> NS; // Number of subjects
    int<lower=1> ND; // Number of difficulties (SNRs)
    int<lower=1> NC[NS*ND]; // Number of correct RTs recorded
    vector[sum(NC)] rt; // reaction times in msec
}

parameters {
    // constraints assume rts in msec
    // lower constraints particularly important for convergence

    // parameters for each individual
//    real<lower=200,upper=5000> alpha_mu[NS]; // intercept for mu for each S
//    real beta_mu[NS]; // slope for mu for each S
//    real<lower=5,upper=500> alpha_sigma[NS];
//    real beta_sigma[NS];
//    real<lower=10,upper=1000> alpha_rate[NS];
//    real beta_rate[NS];

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
//    matrix<lower=200,upper=5000>[ND,NS] mu;
//    matrix<lower=5,upper=500>[ND,NS] sigma;
//    matrix<lower=10,upper=1000>[ND,NS] rate;
    matrix[ND,NS] mu;
    matrix[ND,NS] sigma;
    matrix[ND,NS] rate;

    // Vectorised group parameters -- to pass to multi_normal
    vector[2] mu_mu; // [mu_alpha_mu, mu_beta_mu]
    vector[2] mu_sigma; // [mu_alpha_sigma, mu_beta_sigma]
    vector[2] mu_rate; // [mu_alpha_rate, mu_beta_rate]
//    matrix[2,2] SIGMA_MU; // includes correlation (see Gelman & Hill, 376)
//    matrix[2,2] SIGMA_SIGMA;
//    matrix[2,2] SIGMA_RATE;

    // Compute params of ExGaussian from regression params
//    for (ss in 1:NS) {
//        for (dd in 1:ND) {
//            mu[dd,ss] = alpha_mu[ss] + (beta_mu[ss] * dd);
//            sigma[dd,ss] = alpha_sigma[ss] + (beta_sigma[ss] * dd);
//            rate[dd,ss] = alpha_rate[ss] + (beta_rate[ss] * dd);
//        }
//    }
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
//    SIGMA_MU[1,1] = sigma_alpha_mu ^ 2;
//    SIGMA_MU[2,2] = sigma_beta_mu ^ 2;
//    SIGMA_MU[1,2] = rho_mu * sigma_alpha_mu * sigma_beta_mu;
//    SIGMA_MU[2,1] = SIGMA_MU[1,2];

    mu_sigma[1] = mu_alpha_sigma;
    mu_sigma[2] = mu_beta_sigma;
//    SIGMA_SIGMA[1,1] = sigma_alpha_sigma ^ 2;
//    SIGMA_SIGMA[2,2] = sigma_beta_sigma ^ 2;
//    SIGMA_SIGMA[1,2] = rho_sigma * sigma_alpha_sigma * sigma_beta_sigma;
//    SIGMA_SIGMA[2,1] = SIGMA_SIGMA[1,2];

    mu_rate[1] = mu_alpha_rate;
    mu_rate[2] = mu_beta_rate;
//    SIGMA_RATE[1,1] = sigma_alpha_rate ^ 2;
//    SIGMA_RATE[2,2] = sigma_beta_rate ^ 2;
//    SIGMA_RATE[1,2] = rho_rate * sigma_alpha_rate * sigma_beta_rate;
//    SIGMA_RATE[2,1] = SIGMA_SIGMA[1,2];
}

model {
    int rtix_l; // left index of rt array for subject
    int rtix_r; // right index

    rtix_l = 0;
    rtix_r = 0;

    //TODO: Correlations b/w mu & sigma......................

    for (ss in 1:NS) {
        for (dd in 1:ND) {
            //Compute indices in the rt vector
            rtix_l = rtix_r + 1; // previous + 1
            rtix_r = rtix_l + NC[(ss-1)*ND+dd] - 1;
            // RTs from individual and SNR level parameters
            rt[rtix_l:rtix_r] ~ exgauss(mu[dd,ss], sigma[dd,ss], rate[dd,ss]);
        }
        // Individual regression parameters from group level parameters
//        alpha_mu[ss] = COEF_MU[ss,1];
//        beta_mu[ss] = COEF_MU[ss,2];
//        alpha_sigma[ss] = COEF_SIGMA[ss, 1];
//        beta_sigma[ss] = COEF_SIGMA[ss, 2];
//        alpha_rate[ss] = COEF_RATE[ss, 1];
//        beta_rate[ss] = COEF_RATE[ss, 2];

//        COEF_MU[ss,1:2] ~ multi_normal(mu_mu, SIGMA_MU);
//        COEF_SIGMA[ss,1:2] ~ multi_normal(mu_sigma, SIGMA_SIGMA);
//        COEF_RATE[ss,1:2] ~ multi_normal(mu_rate, SIGMA_RATE);

        beta_mu ~ multi_normal(mu_mu, quad_from_diag(Omega_mu, tau_mu));
        beta_sigma ~ multi_normal(mu_sigma, quad_from_diag(Omega_sigma, tau_sigma));
        beta_rate ~ multi_normal(mu_rate, quad_from_diag(Omega_rate, tau_rate));

        print("mu_mu = ", mu_mu);
        print("mu_sigma = ", mu_sigma);
        print("mu_rate = ", mu_rate);
        //print("log-posterior_1 = ", target());
    }

    // Priors on group parameters
    mu_alpha_mu ~ normal(1000, 1000);
    sigma_alpha_mu ~ uniform(0, 100);
    mu_beta_mu ~ normal(0, 1000);
    sigma_beta_mu ~ uniform(0, 100);
    rho_mu ~ uniform(-1,1);

    mu_alpha_sigma ~ normal(100, 500);
    sigma_alpha_sigma ~ uniform(0, 100);
    mu_beta_sigma ~ normal(0, 1000);
    sigma_beta_sigma ~ uniform(0, 100);
    rho_sigma ~ uniform(-1,1);

    mu_alpha_rate ~ normal(100, 500);
    sigma_alpha_rate ~ uniform(0, 100);
    mu_beta_rate ~ normal(0, 1000);
    sigma_beta_rate ~ uniform(0, 100);
    rho_rate ~ uniform(-1,1);
}

generated quantities {
    // Posterior predictive checks
}

//R code:
/*
    fit <- stan()
    print(fit, digits=2)
    pairs(fit)
    hist(extract(fit)$mu)
    traceplot(fit, include_warmup=FALSE)
*/

