library(gamlss.dist) # Generating ex-Gaussian
library(retimes) # Fitting ex-Gaussian
library(vioplot) # For plotting replication kernel densities
library(gplots) # For plotting means

subslist <- c(1,3,5,7) 
# subslist <- c(2,4,6) 

nreps <- 500

propc_vec <- NULL # proportion correct per subject
rtplus <- NULL # RTs on trials following incorrect decisions
rtother <- NULL # RTs on trials following incorrect decisions
mu_est_all <- NULL
mu_est_all_df <- NULL # dataframe containing all bootstrapped mu's / diff / sub

pdf(file="pilot_analysis.pdf")
for (ix in subslist) {
    # Read raw data from file into data.frame
    filename <- paste("sub", ix, ".csv", sep="")
    subtable <- read.csv(filename, header=TRUE)
    subdata <- data.frame(subtable)

    quant_all <- NULL # Replicated quantiles for all levels
    quant_dat <- NULL # Quantiles for data
    mu_est_vec <- NULL
    for (dd in seq(1, 3)) {
        ### Fit ex-Gaussian to data
        crt_dd <- subset(subdata, (diff == dd & correct == 1))
        crtfit <- timefit(crt_dd$rt, iter=1000, plot=TRUE)

        ### Get estimates based on only fits that estimate valid sigma
        mu_est <- kernestim(crtfit@bootPar[crtfit@sigmaValid, 1])
        sigma_est <- crtfit@par[["sigma"]] # Already based on only valid
        tau_est <- crtfit@par[["tau"]]

        mu_est_vec <- c(mu_est_vec, mu_est)
        mu_est_df <- data.frame(crtfit@bootPar[crtfit@sigmaValid, 1])
        names(mu_est_df) <- 'rt'
        mu_est_df$diff <- rep(dd, nrow(mu_est_df))
        mu_est_df$subid <- rep(ix, nrow(mu_est_df))
        mu_est_all_df <- rbind(mu_est_all_df, mu_est_df)

        ### Generate predictive distribution
        quant_vec <- NULL # Stores all the replicated quantiles
        for (rr in seq(1, nreps)) {
            crt_rep <- rexGAUS(length(crt_dd$rt), mu=mu_est, sigma=sigma_est, nu=tau_est)
            quant_rep <- quantile(crt_rep)
            quant_vec <- rbind(quant_vec, quant_rep)
        }
        if (dd == 1) {
            quant_all$one <- quant_vec
        } else if (dd == 2) {
            quant_all$two <- quant_vec
        } else {
            quant_all$three <- quant_vec
        }
        quant_dat <- rbind(quant_dat, quantile(crt_dd$rt))

        ### Collect data on proportion correct
        icrt_dd <- subset(subdata, (diff == dd & correct == 0)) # icorrect RTs
        propc <- length(crt_dd$rt) / (length(crt_dd$rt) + length(icrt_dd$rt))
        if (dd == 1) {
            propc_vec$one <- c(propc_vec$one, propc)
        } else if (dd == 2) {
            propc_vec$two <- c(propc_vec$two, propc)
        } else {
            propc_vec$three <- c(propc_vec$three, propc)
        }

        # Collect data on RTs following incorrect decision
        diffdata <- subset(subdata, diff == dd)
        ixic <- which(subdata$correct == 0) # indices of incorrect decisions
        ixplus <- ixic + 1 # indices of decisions after incorrect decisions
        ixplus <- ixplus[1:length(ixplus)-1] # final index as may be > length rtvec
        
        ixall <- seq(1,length(subdata$rt))
        ixother <- ixall[!ixall %in% ixplus] # all other indicies except ixplus

        dataplus <- subdata[ixplus,]
        dataother <- subdata[ixother,]
        dataplus_dd <- subset(dataplus, diff==dd)
        dataother_dd <- subset(dataother, diff==dd)
        if (dd == 1) {
            rtplus$one <- dataplus_dd$rt
            rtother$one <- dataother_dd$rt
        } else if (dd == 2) {
            rtplus$two <- dataplus_dd$rt
            rtother$two <- dataother_dd$rt
        } else {
            rtplus$three <- dataplus_dd$rt
            rtother$three <- dataother_dd$rt
        }

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

    boxplot(rtplus$one, rtother$one, rtplus$two, rtother$two, rtplus$three, rtother$three,
            at=c(1,2,5,6,10,11),
            main="Sequential effect",
            names=c("n+1(L)", "Other(L)", "n+1(M)", "Other(M)", "n+1(H)", "Other(H)"),
            ylab="Reaction times",
            col="gainsboro")

    mu_est_all <- rbind(mu_est_all, mu_est_vec)
}

# boxplot(propc_vec$one, propc_vec$two, propc_vec$three,
#         main="Error rates for different SNR",
#         names=c("low", "medium", "high"),
#         xlab="Signal-to-noise ratio",
#         ylab="Proportion correct",
#         col=c("aliceblue", "blanchedalmond", "gainsboro"))

propc_mat <- rbind(propc_vec$one, propc_vec$two, propc_vec$three)
matplot(propc_mat, type="o", lwd=2, pch=c(15,16,17,18),
        main="Error rates for different SNR",
        xlab="Signal-to-noise ratio",
        ylab="Proportion correct")

# Plot how estimates of means vary across conditions
matplot(t(mu_est_all), type="o", pch=21, lwd=2,
        xlab="Signal-to-noise ratio", ylab="Estimated mean of ex-Gaussian") 
# p <- plot_ly(x = ~x, y = ~trace_0, name = 'trace 0', type = 'scatter', mode = 'lines') %>%
#   add_trace(y = ~trace_1, name = 'trace 1', mode = 'lines+markers') %>%
#   add_trace(y = ~trace_2, name = 'trace 2', mode = 'markers')

# plotmeans(rt~diff, data=subset(mu_est_all_df, subid==subslist[1]),
#           xlab="Signal-to-noise ratio", ylab="Estimated mean of ex-Gaussian") 
# for (ix in subslist[2:length(subslist)]) {
#     plotmeans(rt~diff, data=subset(mu_est_all_df, subid==ix), 
#           xlab="Signal-to-noise ratio", ylab="Estimated mean of ex-Gaussian") 
# }

dev.off()
