rm(list=ls())

library(rstan)

filename <- paste("sub2.csv", sep="")
subtable <- read.csv(filename, header=TRUE)
subdata <- data.frame(subtable)

crt_dd <- subset(subdata, (diff == 1 & correct == 1))
fit <- stan(file = "rtmodel.stan",
            data = list(NC=length(crt_dd$rt), rt=crt_dd$rt),
            iter = 5000,
            control = list(adapt_delta=0.999),
            chains = 3)
print(fit)
plot(fit)

#for (dd in seq(1, 3)) {
#    ### Fit ex-Gaussian to data
#    crt_dd <- subset(subdata, (diff == dd & correct == 1))
#}
