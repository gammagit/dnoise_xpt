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
    int<lower=1> NC[NS]; // Number of correct RTs recorded
    vector<lower=0,upper=15000>[sum(NC)] rt; // assumes values in msec
}

parameters {
    // constraints assume rts in msec
    // not putting constraints leads to log(0)

    real<lower=200> mu[NS];
    real<lower=0.000005,upper=0.1> precision[NS]; // sigma ~ [5,500]
    real<lower=0.001,upper=0.1> lambda[NS]; // rate ~ [10, 1000]
    
}

transformed parameters {
    // Reparameterisation
    real rate[NS];
    real sigma[NS];
    for (nn in 1:NS) {
        rate[nn] = 1/lambda[nn];
        sigma[nn] = 1/sqrt(precision[nn]);
    }
}

model {
    // print("mu =", mu);
    // print("sigma =", sigma);
    // print("rate =", rate);
    // print("log-posterior_1 = ", target());
    int rtix_l; // left index of rt array for subject
    int rtix_r; // right index
    rtix_l = 0;
    rtix_r = 0;
    for (nn in 1:NS) {
        rtix_l = rtix_r + 1; // previous + 1
        rtix_r = rtix_l + NC[nn] - 1;

        rt[rtix_l:rtix_r] ~ exgauss(mu[nn], sigma[nn], rate[nn]);

        // Priors
        mu[nn] ~ normal(1000,1000);
        precision[nn] ~ gamma(0.0001, 0.05);
        lambda[nn] ~ gamma(0.0005, 0.05);
    }

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

