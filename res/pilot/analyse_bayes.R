rm(list=ls())

library(rstan)
library(vioplot) # For plotting replication kernel densities
# library(scales)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


# subslist <- c(1,3,5,7) 
subslist <- c(2,4,6) 
pdf(file="post_fits.pdf")

mu_all <- NULL
ixcount <- 1

for (ix in subslist) {
    filename <- paste("sub", ix, ".csv", sep="")
    subtable <- read.csv(filename, header=TRUE)
    subdata <- data.frame(subtable)

    subfit <- NULL

    for (dd in seq(1, 3)) {
        crt_dd <- subset(subdata, (diff == dd & correct == 1))
        fit <- stan(file = "rtmodel.stan",
                    data = list(NC=length(crt_dd$rt), rt=crt_dd$rt),
                    iter = 5000,
                    control = list(adapt_delta=0.999),
                    chains = 3)
        print(fit)
        if (dd == 1) {
            subfit$one <- fit
        } else if (dd == 2) {
            subfit$two <- fit
        } else {
            subfit$three <- fit
        }

    }

    mu_pred <- NULL
    mu_pred$one <- extract(subfit$one, 'mu')
    mu_pred$one <- unlist(mu_pred$one, use.names=FALSE)
    mu_pred$two <- extract(subfit$two, 'mu')
    mu_pred$two <- unlist(mu_pred$two, use.names=FALSE)
    mu_pred$three <- extract(subfit$three, 'mu')
    mu_pred$three <- unlist(mu_pred$three, use.names=FALSE)

    muixs <- ((ixcount-1) * 3) + 1 # indices into mu_all
    ixcount <- ixcount + 1
    mu_all[seq(muixs, muixs+2)] <- mu_pred
}

ncolors <- length(subslist)
vcolors <- c("lightpink", "darkseagreen1", "aliceblue", "blanchedalmond", "gainsboro")
lcolors <- rainbow(ncolors) 
linetype <- c(1:ncolors) 
plotchar <- seq(18,18+ncolors,1)
atlocs <- jitter(seq(1,3), factor=1/4)
# plot.new()
# frame()
vioplot(unlist(mu_all[1], use.names = FALSE),
        unlist(mu_all[2], use.names = FALSE),
        unlist(mu_all[3], use.names = FALSE),
        names=c("low", "medium", "high"),
        at = atlocs,
        col=NA, 
        rectCol=lcolors[1], 
        border=NA,
        ylim=c(600,1200))
lines(atlocs, c(mean(unlist(mu_all[1], use.names = FALSE)),
                  mean(unlist(mu_all[2], use.names = FALSE)),
                  mean(unlist(mu_all[3], use.names = FALSE))),
      type="b", lwd=1.5,
      lty=linetype[1],
      col=lcolors[1],
      pch=plotchar[1])
title(main=expression(paste("Posterior p(", hat(mu), "| RTs)", " for fitted ex-Gaussians")),
      xlab="Signal-to-noise ratio",
      ylab="msec")

ixcount <- 2
for (ix in subslist[2:length(subslist)]){
    muixs <- ((ixcount-1) * 3) + 1 # indices into mu_all
    atlocs <- jitter(seq(1,3), factor=1/4)
    vioplot(unlist(mu_all[muixs], use.names = FALSE),
            unlist(mu_all[muixs+1], use.names = FALSE),
            unlist(mu_all[muixs+2], use.names = FALSE),
            names=c("", "", ""),
            add=TRUE,
            at = atlocs,
            col=NA, 
            rectCol=lcolors[((ixcount-1) %% length(vcolors))+1], 
            border=NA, 
            ylim=c(600,1200))
    lines(atlocs,
          c(mean(unlist(mu_all[muixs], use.names = FALSE)),
            mean(unlist(mu_all[muixs+1], use.names = FALSE)),
            mean(unlist(mu_all[muixs+2], use.names = FALSE))),
          type="b", lwd=1.5,
          lty=linetype[ixcount],
          col=lcolors[ixcount],
          pch=plotchar[ixcount])
    ixcount <- ixcount + 1
}
legend(x="topleft", legend=1:length(subslist),
       cex=0.8, col=lcolors,
       pch=plotchar, lty=linetype, title="Subject")

dev.off()

#print(fit)
#plot(fit)


#    ### Fit ex-Gaussian to data
#    crt_dd <- subset(subdata, (diff == dd & correct == 1))
#}
