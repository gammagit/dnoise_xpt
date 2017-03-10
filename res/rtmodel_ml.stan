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
    // lower constraints particularly important for convergence

    real mu[NS];
    real<lower=0.000005,upper=0.01> precision[NS]; // sigma ~ [5,500]
    real<lower=0.001,upper=0.1> lambda[NS]; // rate ~ [10, 1000]
    
    real <lower=0,upper=5000> group_mu_mu;
    real <lower=0.000005,upper=100> group_mu_precision;
    real <lower=0.000005,upper=0.01> group_precision_mean;
    real <lower=0.000005,upper=100> group_precision_dev;
    real <lower=0.001,upper=0.1> group_lambda_mean;
    real <lower=0.01,upper=100> group_lambda_dev;
}

transformed parameters {
    real rate[NS];
    real sigma[NS];
    real mu_trans[NS];

    real group_mu_sigma;

    real group_precision_shape;
    real group_precision_rate;
    real group_lambda_shape;
    real group_lambda_rate;

    // Reparameterisation
    group_mu_sigma = 1/sqrt(group_mu_precision);

    for (nn in 1:NS) {
        mu_trans[nn] = group_mu_mu + group_mu_sigma * mu[nn];

        rate[nn] = 1/lambda[nn];
        sigma[nn] = 1/sqrt(precision[nn]);
    }

    // Transform mean & dev of Gamma functions into shape & rate params
    group_precision_shape = (group_precision_mean ^ 2) / (group_precision_dev ^ 2);
    group_precision_rate = group_precision_mean / (group_precision_dev ^ 2);
    group_lambda_shape = (group_lambda_mean ^ 2) / (group_lambda_dev ^ 2);
    group_lambda_rate = group_lambda_mean / (group_lambda_dev ^ 2);
}

model {
    int rtix_l; // left index of rt array for subject
    int rtix_r; // right index
    rtix_l = 0;
    rtix_r = 0;
    for (nn in 1:NS) {
        rtix_l = rtix_r + 1; // previous + 1
        rtix_r = rtix_l + NC[nn] - 1;

        rt[rtix_l:rtix_r] ~ exgauss(mu_trans[nn], sigma[nn], rate[nn]);

        //print("mu = ", mu);
        //print("sigma = ", sigma);
        //print("rate = ", rate);
        //print("log-posterior_1 = ", target());

        // Hierarchical model: Each subject is instance of group
        //mu[nn] ~ normal(group_mu_mu, group_mu_sigma);
        mu[nn] ~ normal(0,1);
        precision[nn] ~ gamma(group_precision_shape, group_precision_rate);
        lambda[nn] ~ gamma(group_lambda_shape, group_lambda_rate);
    }

    // Priors on group parameters
    group_mu_mu ~ normal(1000, 1000); // Large standard-deviation
    group_mu_precision ~ gamma(0.00001, 0.1); // Prior high on low precision, but heavy tail
    group_precision_mean ~ gamma(0.0001, 0.05); // Mean sigma ~ 70, large weight on low precision
    group_precision_dev ~ gamma(0.1, 0.1); //
    group_lambda_mean ~ gamma(0.0005, 0.05); // 
    group_lambda_dev ~ gamma(0.1,1); //
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

