functions {
    real exgauss_lpdf(vector y, real mu, real sigma, real tau) {
    // Defines log-likelihood for ex-Gaussian
        real eterm; // exponential term
        real gterm; // cumulative gaussian term
        vector[num_elements(y)] prob;
        real out;

        for (ii in 1:num_elements(y)) {
            eterm = exp((sigma^2) / (2*(tau^2)) - ((y[ii] - mu)/tau));
            gterm = Phi(((y[ii] - mu) / sigma) - (sigma / tau));
            prob[ii] = (1 /tau) * eterm * gterm;
        }

        out = sum(log(prob));
        return out;
    }
}

data {
    int<lower=1> NS; // Number of subjects
    int<lower=1> NC[NS]; // Number of correct RTs recorded
    vector<lower=0,upper=10000>[sum(NC)] rt; // assumes values in msec
}

parameters {
    // constraints assume rts in msec
    // lower constraints particularly important for convergence
    real<lower=200,upper=10000> mu[NS];
    real<lower=20,upper=300> sigma[NS];
    real<lower=1,upper=1000> tau[NS];

    real <lower=100,upper=2000> mu_mu;
    real <lower=10,upper=500> mu_sigma;
    real <lower=20,upper=300> sigma_mu;
    real <lower=20,upper=300> sigma_sigma;
    real <lower=1,upper=1000> tau_mu;
    real <lower=1,upper=500> tau_sigma;
}

transformed parameters {
    // Could transform sigma to precision & tau to lambda here!
    // precision = 1 / (sigma^2);
}

model {
    int rtix_l; // left index of rt array for subject
    int rtix_r; // right index
    rtix_l = 0;
    rtix_r = 0;
    for (nn in 1:NS) {
        rtix_l = rtix_r + 1; // previous + 1
        rtix_r = rtix_l + NC[nn] - 1;
        rt[rtix_l:rtix_r] ~ exgauss(mu[nn], sigma[nn], tau[nn]);

        // Hierarchical model
        mu[nn] ~ normal(mu_mu, mu_sigma);
        sigma[nn] ~ normal(sigma_mu, sigma_sigma);
        tau[nn] ~ normal(tau_mu, tau_sigma);
    }

    // Priors
    mu_mu ~ uniform(200, 10000);
    mu_sigma ~ uniform(1, 5000);
    sigma_mu ~ uniform(20, 300);
    sigma_sigma ~ uniform(1, 150);
    tau_mu ~ uniform(1, 1000);
    tau_sigma ~ uniform(1, 500);
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

