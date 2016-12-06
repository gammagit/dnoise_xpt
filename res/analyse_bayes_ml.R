rm(list=ls())

library(rstan)
library(vioplot) # For plotting replication kernel densities
# library(scales)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


subslist <- c(1,3,5,7) 
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

mu_mu_pred <- NULL
mu_mu_pred$one <- extract(subfit$one, 'mu_mu')
mu_mu_pred$one <- unlist(mu_mu_pred$one, use.names=FALSE)
mu_mu_pred$two <- extract(subfit$two, 'mu_mu')
mu_mu_pred$two <- unlist(mu_mu_pred$two, use.names=FALSE)
mu_mu_pred$three <- extract(subfit$three, 'mu_mu')
mu_mu_pred$three <- unlist(mu_mu_pred$three, use.names=FALSE)

muall <- NULL
mu_pred_ii <- NULL
ixcount <- 1

for (ii in subslist) {
    mu_pred_ii$one <- extract(subfit$one, paste('mu[',ixcount,']', sep=''))
    mu_pred_ii$two <- extract(subfit$two, paste('mu[',ixcount,']', sep=''))
    mu_pred_ii$three <- extract(subfit$three, paste('mu[',ixcount,']', sep=''))

    muixs <- ((ixcount-1) * 3) + 1 # indices into mu_all
    mu_all[seq(muixs, muixs+2)] <- mu_pred_ii

    ixcount <- ixcount + 1
}

vioplot(mu_mu_pred$one, mu_mu_pred$two, mu_mu_pred$three,
        names=c("low", "medium", "high"),
        col="aliceblue",
        lwd=2,
        ylim=c(500,1200))
lines(seq(1,3),
      c(mean(unlist(mu_mu_pred$one, use.names = FALSE)),
        mean(unlist(mu_mu_pred$two, use.names = FALSE)),
        mean(unlist(mu_mu_pred$three, use.names = FALSE))),
      type="b", lwd=2,
      lty=1,
      col="black",
      pch=16)

ncolors <- length(subslist)
vcolors <- c("lightpink", "darkseagreen1", "blanchedalmond", "gainsboro")
lcolors <- rainbow(ncolors) 
linetype <- c(1:ncolors) 
plotchar <- seq(1,ncolors,1)
atlocs <- jitter(seq(1,3), factor=1/4)
title(main=expression(paste("Posterior p(", hat(mu), "| RTs)", " for fitted ex-Gaussians")),
      xlab="Signal-to-noise ratio",
      ylab="msec")

ixcount <- 1
for (ix in subslist){
    muixs <- ((ixcount-1) * 3) + 1 # indices into mu_all
    atlocs <- jitter(seq(1,3), factor=1/8)
    vioplot(unlist(mu_all[muixs], use.names = FALSE),
            unlist(mu_all[muixs+1], use.names = FALSE),
            unlist(mu_all[muixs+2], use.names = FALSE),
            names=c("", "", ""),
            add=TRUE,
            at = atlocs,
            col=NA, 
            rectCol=NA, 
            lty=2,
            lwd=1,
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

