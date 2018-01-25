rm(list=ls())

library(rstan)
library(ggplot2)
library(grid)
library(gridExtra)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

session_sig <- FALSE # Session type = signal / noise
# subslist <- seq(1,16)
subslist <- seq(1,3)
model_file <- "rtmodel_lr.stan"
crt_all <- NULL
nresp <- NULL

# Aggregate the data in the format of the stan model
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
        df_dd <- subset(session_data, (diff == dd & correct == 1))
        crt_all <- c(crt_all, df_dd$rt)
        nresp <- c(nresp, length(df_dd$rt))
    }
}

# Fit the stan model
lrfit <- NULL
newx <- seq(0,3,length.out=31)
lrfit <- stan(file = model_file,
              data = list(NS=length(subslist), ND=3, NC=nresp, NX=31, x=newx, rt=crt_all),
###               init = list(list(beta_mu=matrix(rep(c(1000,10), 16), nrow=16, ncol=2, byrow=TRUE), beta_sigma=matrix(rep(c(100,10), 16), nrow=16, ncol=2, byrow=TRUE), beta_rate=matrix(rep(c(100,10), 16), nrow=16, ncol=2, byrow=TRUE))),
              init = list(list(beta_mu=matrix(rep(c(1000,10), 3), nrow=3, ncol=2, byrow=TRUE), beta_sigma=matrix(rep(c(100,10), 3), nrow=3, ncol=2, byrow=TRUE), beta_rate=matrix(rep(c(100,10), 3), nrow=3, ncol=2, byrow=TRUE))),
              iter = 5000,
###                control = list(adapt_delta=0.999), # TODO: Uncomment
              chains = 1) # TODO: Change to 3 chains - will also need to specify list of init params for each chain
print(lrfit)

### To display previous fit, uncomment following line and comment block above
### load('lrfit_varnoise.RData')

# Plot estimated parameters
pdf(file="lr_varnoise_pilot.pdf")

load('subfit_ml_varnoise.RData')
mu_pred_samples <- extract(lrfit, 'mu_pred')
all_plots <- list()
df_slopes <- NULL
for (ix in subslist) {
    # Get mean slope & intercept from fit
    beta_mu_ix <- summary(lrfit, pars=c(paste("beta_mu[", ix, ",1]", sep=""), paste("beta_mu[", ix,",2]", sep="")))$summary
    mean_inter <- beta_mu_ix[paste("beta_mu[", ix, ",1]", sep=""), "mean"]
    mean_slope <- beta_mu_ix[paste("beta_mu[", ix, ",2]", sep=""), "mean"]
    q025_slope <- beta_mu_ix[paste("beta_mu[", ix, ",2]", sep=""), "2.5%"]
    q975_slope <- beta_mu_ix[paste("beta_mu[", ix, ",2]", sep=""), "97.5%"]
    df_slope_ix <- data.frame(subid = ix, mean = mean_slope, q025 = q025_slope, q975 = q975_slope)
    df_slopes <- rbind(df_slopes, df_slope_ix)

    # Get confidence intervals based on samples from fit
    mu_pred_ix <- mu_pred_samples$mu_pred[,ix,]
    quant_ix <- apply(mu_pred_ix, 2, quantile, probs=c(0.025,0.5,0.975))
    df_ix <- data.frame(mu = quant_ix[2,], lowmu = quant_ix[1,], upmu = quant_ix[3,], snr=seq(0,30)/10)
    ph <- ggplot(df_ix, aes(snr)) +
          geom_ribbon(aes(ymin=lowmu, ymax=upmu), fill="gray50", alpha=0.4) +
          geom_abline(intercept = mean_inter, slope = mean_slope, size=1, col="firebrick2") +
          theme_bw() +
          theme(axis.title.y=element_blank(), axis.title.x=element_blank()) +
          scale_x_continuous(breaks=c(1,2,3), labels=c("l", "m", "h"), limits=c(0.9,3.1))

    # Plot estimated means
    pred_ii <- NULL
    pred_ii$one <- extract(subfit$one, paste('mu_trans[',ix,']', sep=''))
    pred_ii$one <- unlist(pred_ii$one, use.names=FALSE)
    pred_ii$two <- extract(subfit$two, paste('mu_trans[',ix,']', sep=''))
    pred_ii$two <- unlist(pred_ii$two, use.names=FALSE)
    pred_ii$three <- extract(subfit$three, paste('mu_trans[',ix,']', sep=''))
    pred_ii$three <- unlist(pred_ii$three, use.names=FALSE)

    # Compute confidence intervals
    ci_ii <- NULL
    ci_ii$one <- quantile(pred_ii$one, c(0.025,0.975), names = FALSE)
    ci_ii$two <- quantile(pred_ii$two, c(0.025,0.975), names = FALSE)
    ci_ii$three <- quantile(pred_ii$three, c(0.025,0.975), names = FALSE)

    # Plot means & confidence intervals
    snrs <- c(1,2,3) # signal-to-noise ratios for one, two & three
    mean_rts <- c(mean(pred_ii$one),
                mean(pred_ii$two),
                mean(pred_ii$three))
    ci_low <- c(ci_ii$one[1], ci_ii$two[1], ci_ii$three[1]) # lower confidence interval
    ci_up <- c(ci_ii$one[2], ci_ii$two[2], ci_ii$three[2]) # upper confidence interval
    df_ii <- data.frame(condition=snrs, rt = mean_rts, low = ci_low, up = ci_up, subject=rep(ix,3))

    ph <- ph + geom_point(data=df_ii, aes(x=condition, y=rt), shape=21, size=3, fill="white", alpha=0.7) +
               geom_errorbar(data=df_ii, width=.2, aes(x=condition, ymin=low, ymax=up), alpha=0.5)

    all_plots[[ix]] <- ph
}

grid.arrange(grobs=all_plots, ncol=4, left="Estimated mu (Correct)",
             bottom="Signal-to-noise ratio",
             top="Estimated LR and mu (VarNoise)")

# Plot individual and group slope
mu_beta_mu <- summary(lrfit, pars=c("mu_beta_mu"))$summary
mean_mu_mu <- mu_beta_mu["mu_beta_mu", "mean"]
q025_mu_mu <- mu_beta_mu["mu_beta_mu", "2.5%"]
q975_mu_mu <- mu_beta_mu["mu_beta_mu", "97.5%"]
df_mu_mu <- data.frame(subid = 0, mean = mean_mu_mu, q025 = q025_mu_mu, q975 = q975_mu_mu)

pslopes <- ggplot(df_slopes, aes(x=subid, y=mean)) +
           geom_point(aes(x=subid, y=mean), shape=21, size=3, fill="white") +
           geom_errorbar(width=.2, aes(ymin=q025, ymax=q975), alpha=0.5) +
           geom_point(data=df_mu_mu, aes(x=subid, y=mean), shape=21, size=3, fill="red") +
           geom_errorbar(data=df_mu_mu, width=.2, aes(ymin=q025, ymax=q975), col="red", alpha=0.5) +
           geom_hline(yintercept=0, linetype=2) +
           ggtitle(expression(paste("Estimated ", beta[1], " for each participant (VarNoise)"))) +
           xlab("Subject") +
           ylab(expression(paste("Slope (ms / ", Delta," snr)"))) +
           theme_bw() +
           scale_x_continuous(breaks=c(0,seq(2,16,by=2)), labels=c("Group", "2", "4", "6", "8", "10", "12", "14", "16"))
print(pslopes)

dev.off()

save(lrfit, file="lrfit_varnoise.RData")
