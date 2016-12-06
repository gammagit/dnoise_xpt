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
    int NC; // Number of correct
    vector<lower=0,upper=10000>[NC] rt; // assumes values in msec
}

parameters {
    // constraints assume rts in msec
    // lower constraints particularly important for convergence
    real<lower=200,upper=10000> mu;
    real<lower=20,upper=300> sigma;
    real<lower=1,upper=1000> tau;
}

transformed parameters {
    // Could transform sigma to precision & tau to lambda here!
    // precision = 1 / (sigma^2);
}

model {
    rt ~ exgauss(mu, sigma, tau);

    // Priors
    mu ~ uniform(200,10000);
    sigma ~ uniform(20, 300); // or weakly informative half-Cauchy!
    tau ~ uniform(1, 1000);
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
