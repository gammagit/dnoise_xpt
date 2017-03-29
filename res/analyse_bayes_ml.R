rm(list=ls())

library(rstan)
library(vioplot) # For plotting replication kernel densities
# library(scales)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


subslist <- seq(1,18)
# subslist <- c(2,4,6) 
pdf(file="post_fits_ml.pdf")

mu_all <- NULL
crt_all <- NULL
nresp <- NULL
ixcount <- 1

for (ix in subslist) {
    filename <- paste("sub", ix, ".csv", sep="")
    subtable <- read.csv(filename, header=TRUE)
    subdata <- data.frame(subtable)

    for (dd in seq(1, 3)) {
        crt_dd <- subset(subdata, (diff == dd & correct == 1))
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

subfit <- NULL

subfit$one <- stan(file = "rtmodel_ml.stan",
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

# Plot individual mu
psub <- NULL # Plot handle
mu_pred_ii <- NULL
ixcount <- 1
ci_ii <- NULL
df_muii <- NULL

for (ii in subslist) {
    # Bootstrap distribution of mean for each subject
    mu_pred_ii$one <- extract(subfit$one, paste('mu_trans[',ixcount,']', sep=''))
    mu_pred_ii$one <- unlist(mu_pred_ii$one, use.names=FALSE)
    mu_pred_ii$two <- extract(subfit$two, paste('mu_trans[',ixcount,']', sep=''))
    mu_pred_ii$two <- unlist(mu_pred_ii$two, use.names=FALSE)
    mu_pred_ii$three <- extract(subfit$three, paste('mu_trans[',ixcount,']', sep=''))
    mu_pred_ii$three <- unlist(mu_pred_ii$three, use.names=FALSE)

    # Compute confidence intervals
    ci_ii$one <- quantile(mu_pred_ii$one, c(0.025,0.975), names = FALSE)
    ci_ii$two <- quantile(mu_pred_ii$two, c(0.025,0.975), names = FALSE)
    ci_ii$three <- quantile(mu_pred_ii$three, c(0.025,0.975), names = FALSE)

    # Plot means & confidence intervals
    snrs <- c('1_low', '2_medium', '3_high') # signal-to-noise ratios for one, two & three
    mean_rts <- c(mean(mu_pred_ii$one),
                  mean(mu_pred_ii$two),
                  mean(mu_pred_ii$three))
    ci_low <- c(ci_ii$one[1], ci_ii$two[1], ci_ii$three[1]) # lower confidence interval
    ci_up <- c(ci_ii$one[2], ci_ii$two[2], ci_ii$three[2]) # upper confidence interval
    df_ii <- data.frame(condition=snrs, rt = mean_rts, low = ci_low, up = ci_up, subject=rep(ixcount,3))
    df_muii <- rbind(df_muii, df_ii)

    ixcount <- ixcount + 1
}

df_muii$subject <- as.factor(df_muii$subject)

pd <- position_dodge(width=0.1)
psub <- ggplot(df_muii, aes(x=condition, y=rt, group=subject)) +
        geom_line(aes(color=subject), position=pd, alpha=0.7) +
        geom_errorbar(width=.1, aes(ymin=low, ymax=up, color=subject), position=pd, alpha=0.7) +
        geom_point(shape=21, size=3, fill="white", position=pd, alpha=0.7) +
        ggtitle(paste("Estimated mu for each participant")) +
        ylab(expression(hat(mu))) +
        xlab("Signal-to-noise ratio") +
        ylim(600, 1600) +
        scale_color_manual(values=c("#2b2d42", "#8d99ae", "#d90429", "#00962f",
                                    "#ff420e", "#11c1fe", "#3f339d", "#f6aacb",
                                    "#dc8580", "#008989", "#ff9a00", "#bd00ff",
                                    "#7a624f", "#e72a89", "#d3b6aa", "#280da1",
                                    "#1995ad", "#cb0000")) +
        theme_bw()

print(psub)

# Plot group mu
mu_mu_pred <- NULL
mu_mu_pred$one <- extract(subfit$one, 'group_mu_mu')
mu_mu_pred$one <- unlist(mu_mu_pred$one, use.names=FALSE)
mu_mu_pred$two <- extract(subfit$two, 'group_mu_mu')
mu_mu_pred$two <- unlist(mu_mu_pred$two, use.names=FALSE)
mu_mu_pred$three <- extract(subfit$three, 'group_mu_mu')
mu_mu_pred$three <- unlist(mu_mu_pred$three, use.names=FALSE)

# Compute confidence intervals
ci <- NULL
ci$one <- quantile(mu_mu_pred$one, c(0.025,0.975), names = FALSE)
ci$two <- quantile(mu_mu_pred$two, c(0.025,0.975), names = FALSE)
ci$three <- quantile(mu_mu_pred$three, c(0.025,0.975), names = FALSE)

# Plot means & confidence intervals
snrs <- c('1_low', '2_medium', '3_high') # signal-to-noise ratios for one, two & three
mean_rts <- c(mean(mu_mu_pred$one),
              mean(mu_mu_pred$two),
              mean(mu_mu_pred$three))
ci_low <- c(ci$one[1], ci$two[1], ci$three[1]) # lower confidence interval
ci_up <- c(ci$one[2], ci$two[2], ci$three[2]) # upper confidence interval
df_mu_mu <- data.frame(condition=snrs, rt = mean_rts, low = ci_low, up = ci_up)

pmu_mu <- ggplot(df_mu_mu, aes(x=condition, y=rt, group=1)) +
          geom_line(color=1, alpha=0.7) +
          geom_errorbar(data=df_mu_mu, width=.1, aes(ymin=low, ymax=up), color=1) +
          geom_point(shape=21, size=3, fill="white") +
          ggtitle("Estimated mu for group") +
          ylab(expression(hat(mu))) +
          xlab("Signal-to-noise ratio") +
          ylim(600, 1600) +
          theme_bw()

print(pmu_mu)

dev.off()

