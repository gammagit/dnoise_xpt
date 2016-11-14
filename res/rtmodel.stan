functions {
    real exgauss_lpdf(vector y, real mu, real sigma, real tau) {
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
    vector<lower=0,upper=10000>[NC] rt;
}

transformed data {

}

parameters {
    real<lower=200,upper=10000> mu;
    real<lower=50,upper=300> sigma;
    real<lower=1,upper=300> tau;
}

transformed parameters {
    // precision = 1 / (sigma^2);
}

model {
    rt ~ exgauss(mu, sigma, tau);

    // Priors
    mu ~ uniform(200,10000);
    sigma ~ uniform(50, 300);
    tau ~ uniform(1, 300);
}

generated quantities {
    // Posterior predictive checks
}

//R code:
/*
    fit <- stan()
    print(fit, digits=2)
    hist(extract(fit)$mu)
    traceplot(fit, include_warmup=FALSE)
    pairs(fit)
*/
