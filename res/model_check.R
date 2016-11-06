library(gamlss.dist) # Generating ex-Gaussian
library(retimes) # Fitting ex-Gaussian
library(vioplot) # Violin plot library

nreps <- 50

pdf(file="pilot_analysis.pdf")
subslist <- 1:2
for (ix in subslist) {
    # Read raw data from file into data.frame
    filename <- paste("sub", ix, ".csv", sep="")
    subtable <- read.csv(filename, header=TRUE)
    subdata <- data.frame(subtable)

    quant_all <- NULL # Replicated quantiles for all levels
    quant_dat <- NULL # Quantiles for data
    for (dd in seq(1, 3)) {
        ### Fit ex-Gaussian to data
        rt_dd <- subset(subdata, (diff == dd & correct == 1))
        rtfit <- timefit(rt_dd$rt, iter=1000, plot=TRUE)

        ### Get estimates based on only fits that estimate valid sigma
        mu_est <- kernestim(rtfit@bootPar[rtfit@sigmaValid, 1])
        sigma_est <- rtfit@par[["sigma"]] # Already based on only valid
        tau_est <- rtfit@par[["tau"]]

        ### Generate predictive distribution
        quant_vec <- NULL # Stores all the replicated quantiles
        for (rr in seq(1, nreps)) {
            rt_rep <- rexGAUS(length(rt_dd$rt), mu=mu_est, sigma=sigma_est, nu=tau_est)
            quant_rep <- quantile(rt_rep)
            quant_vec <- rbind(quant_vec, quant_rep)
        }
        if (dd == 1) {
            quant_all$one <- quant_vec
        } else if (dd == 2) {
            quant_all$two <- quant_vec
        } else {
            quant_all$three <- quant_vec
        }
        quant_dat <- rbind(quant_dat, quantile(rt_dd$rt))
    }

    par(mfrow=c(1,1))
    vioplot(quant_all$one[,2], quant_all$two[,2], quant_all$three[,2],
            names=c("low", "medium", "high"),
            col="aliceblue", 
            ylim=c(750,2000))
    title(main="Goodness-of-fit for ex-Gaussians",
          xlab="Signal-to-noise ratio", ylab="Reaction times")
    vioplot(quant_all$one[,3], quant_all$two[,3], quant_all$three[,3],
            add=TRUE,
            col="aliceblue",
            ylim=c(750,2000))
    vioplot(quant_all$one[,4], quant_all$two[,4], quant_all$three[,4],
            add=TRUE,
            col="aliceblue",
            ylim=c(750,2000))
    points(rep(seq(1,3),3), c(quant_dat[,2], quant_dat[,3], quant_dat[,4]), col="red", pch=17)
}
dev.off()
