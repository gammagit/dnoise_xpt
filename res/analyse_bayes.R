rm(list=ls())

library(rstan)
library(ggplot2)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

ml_analysis <- TRUE # Single or multi-level analysis

session_sig <- FALSE # Session type = signal / noise
subslist <- seq(1,5)

mu_all <- NULL
crt_all <- NULL
nresp <- NULL
ixcount <- 1

for (ix in subslist) {
    filename <- paste("sub", ix, ".csv", sep="")
    subtable <- read.csv(filename, header=TRUE)
    subdata <- data.frame(subtable)

    # Pick out signal or noise variation session 
    if (session_sig == TRUE){
        session_data <- subset(subdata, stype == 1)
    } else {
        session_data <- subset(subdata, stype == 2)
    }

    for (dd in seq(1, 3)) {
        crt_dd <- subset(session_data, (diff == dd & correct == 1))
        if (dd == 1) {
            crt_all$one <- c(crt_all$one, crt_dd$rt)
            nresp$one <- c(nresp$one, length(crt_dd$rt))
        } else if (dd == 2) {
            crt_all$two <- c(crt_all$two, crt_dd$rt)
            nresp$two <- c(nresp$two, length(crt_dd$rt))
        } else {
            crt_all$three <- c(crt_all$three, crt_dd$rt)
            nresp$three <- c(nresp$three, length(crt_dd$rt))
        }
    }
}

if (ml_analysis == TRUE) {
    model_file <- "rtmodel_ml.stan"
} else {
    model_file <- "rtmodel.stan"
}

subfit <- NULL

subfit$one <- stan(file = model_file,
                   data = list(NS=length(subslist),
                               NC=nresp$one,
                               rt=crt_all$one),
                   iter = 5000,
                   control = list(adapt_delta=0.999),
                   chains = 3)
print(subfit$one)

# pairs(subfit$one)

subfit$two <- stan(fit = subfit$one,
                   data = list(NS=length(subslist),
                               NC=nresp$two,
                               rt=crt_all$two),
                   iter = 5000,
                   control = list(adapt_delta=0.999),
                   chains = 3)
print(subfit$two)

subfit$three <- stan(fit = subfit$one,
                     data = list(NS=length(subslist),
                                 NC=nresp$three,
                                 rt=crt_all$three),
                     iter = 5000,
                     control = list(adapt_delta=0.999),
                     chains = 3)
print(subfit$three)

# Plot estimated parameters
# source('plot_est_ml.R')

# if (ml_analysis == TRUE) {
#     pdf(file="post_fits_ml_varnoise.pdf")

#     ph_submu <- plot_sub(subslist, subfit, 'mu_trans', ml_analysis, c(600,1600))
#     ph_mu <- plot_groupvar(subfit, 'group_mu_mu', c(600, 1600))
#     print(ph_submu)
#     print(ph_mu)

#     ph_subprec <- plot_sub(subslist, subfit, 'precision', ml_analysis, NA)
#     ph_precision <- plot_groupvar(subfit, 'group_precision_mean', NA)
#     print(ph_subprec)
#     print(ph_precision)

#     ph_sublambda <- plot_sub(subslist, subfit, 'lambda', ml_analysis, NA)
#     ph_lambda <- plot_groupvar(subfit, 'group_lambda_mean', NA)
#     print(ph_sublambda)
#     print(ph_lambda)

#     dev.off()
# } else {
#     pdf(file="post_fits_sl_varnoise.pdf")

#     ph_submu <- plot_sub(subslist, subfit, 'mu', ml_analysis, c(600,1600))
#     ph_subsigma <- plot_sub(subslist, subfit, 'sigma', ml_analysis, NA)
#     ph_subrate <- plot_sub(subslist, subfit, 'rate', ml_analysis, NA)
#     print(ph_submu)
#     print(ph_subsigma)
#     print(ph_subrate)

###    Analyse difference in parameters across conditions
#     df <- NULL
#     mu_ii <- NULL
#     sigma_ii <- NULL
#     rate_ii <- NULL
#     for (ii in subslist) {
#         mu_ii$one <- extract(subfit$one, paste('mu[',ii,']', sep=''))
#         mu_ii$one <- unlist(mu_ii$one, use.names=FALSE)
#         mu_ii$two <- extract(subfit$two, paste('mu[',ii,']', sep=''))
#         mu_ii$two <- unlist(mu_ii$two, use.names=FALSE)
#         mu_ii$three <- extract(subfit$three, paste('mu[',ii,']', sep=''))
#         mu_ii$three <- unlist(mu_ii$three, use.names=FALSE)

#         diff_mu_1 <- mean(mu_ii$one) - mean(mu_ii$two)
#         diff_mu_2 <- mean(mu_ii$two) - mean(mu_ii$three)
#         avg_diff_mu <- (diff_mu_1 + diff_mu_2) / 2

#         df_ii <- data.frame(difference=avg_diff_mu, param='mu', subid=ii)
#         df <- rbind(df, df_ii)

#         sigma_ii$one <- extract(subfit$one, paste('sigma[',ii,']', sep=''))
#         sigma_ii$one <- unlist(sigma_ii$one, use.names=FALSE)
#         sigma_ii$two <- extract(subfit$two, paste('sigma[',ii,']', sep=''))
#         sigma_ii$two <- unlist(sigma_ii$two, use.names=FALSE)
#         sigma_ii$three <- extract(subfit$three, paste('sigma[',ii,']', sep=''))
#         sigma_ii$three <- unlist(sigma_ii$three, use.names=FALSE)

#         diff_sigma_1 <- mean(sigma_ii$one) - mean(sigma_ii$two)
#         diff_sigma_2 <- mean(sigma_ii$two) - mean(sigma_ii$three)
#         avg_diff_sigma <- (diff_sigma_1 + diff_sigma_2) / 2

#         df_ii <- data.frame(difference=avg_diff_sigma, param='sigma', subid=ii)
#         df <- rbind(df, df_ii)

#         rate_ii$one <- extract(subfit$one, paste('rate[',ii,']', sep=''))
#         rate_ii$one <- unlist(rate_ii$one, use.names=FALSE)
#         rate_ii$two <- extract(subfit$two, paste('rate[',ii,']', sep=''))
#         rate_ii$two <- unlist(rate_ii$two, use.names=FALSE)
#         rate_ii$three <- extract(subfit$three, paste('rate[',ii,']', sep=''))
#         rate_ii$three <- unlist(rate_ii$three, use.names=FALSE)

#         diff_rate_1 <- mean(rate_ii$one) - mean(rate_ii$two)
#         diff_rate_2 <- mean(rate_ii$two) - mean(rate_ii$three)
#         avg_diff_rate <- (diff_rate_1 + diff_rate_2) / 2

#         df_ii <- data.frame(difference=avg_diff_rate, param='rate', subid=ii)
#         df <- rbind(df, df_ii)
#     }
#     df$param <- as.factor(df$param)

#     ph <- ggplot(df, aes(param, difference)) +
#           geom_boxplot() +
#           geom_jitter(width=0.1, aes(color=factor(subid)), alpha=0.5) +
#           xlab("Parameter") +
#           ylab("Mean change with SNR") +
#           ggtitle("Change in estimated parameter (VarNoise)") +
#           theme_bw()

#     print(ph)

#     dev.off()
# }

save(subfit, file="subfit_ml_varnoise.RData")
