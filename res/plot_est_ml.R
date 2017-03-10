# Defines functions for plotting Bayesian estimates of Multi-level model

plot_sub <- function(arg_subslist, arg_subfit, arg_plotvar, arg_ml, arg_ylim) {
    psub <- NULL # Plot handle
    pred_ii <- NULL
    ixcount <- 1
    ci_ii <- NULL
    df <- NULL

    if (arg_ml == TRUE) {
        ml_string <- "ML"
    } else {
        ml_string <- "SL"
    }

    for (ii in arg_subslist) {
        # Bootstrap distribution of mean for each subject
        pred_ii$one <- extract(arg_subfit$one, paste(arg_plotvar, '[',ixcount,']', sep=''))
        pred_ii$one <- unlist(pred_ii$one, use.names=FALSE)
        pred_ii$two <- extract(arg_subfit$two, paste(arg_plotvar, '[',ixcount,']', sep=''))
        pred_ii$two <- unlist(pred_ii$two, use.names=FALSE)
        pred_ii$three <- extract(arg_subfit$three, paste(arg_plotvar, '[',ixcount,']', sep=''))
        pred_ii$three <- unlist(pred_ii$three, use.names=FALSE)

        # Compute confidence intervals
        ci_ii$one <- quantile(pred_ii$one, c(0.025,0.975), names = FALSE)
        ci_ii$two <- quantile(pred_ii$two, c(0.025,0.975), names = FALSE)
        ci_ii$three <- quantile(pred_ii$three, c(0.025,0.975), names = FALSE)

        # Plot means & confidence intervals
        snrs <- c('1_low', '2_medium', '3_high') # signal-to-noise ratios for one, two & three
        mean_rts <- c(mean(pred_ii$one),
                    mean(pred_ii$two),
                    mean(pred_ii$three))
        ci_low <- c(ci_ii$one[1], ci_ii$two[1], ci_ii$three[1]) # lower confidence interval
        ci_up <- c(ci_ii$one[2], ci_ii$two[2], ci_ii$three[2]) # upper confidence interval
        df_ii <- data.frame(condition=snrs, rt = mean_rts, low = ci_low, up = ci_up, subject=rep(ixcount,3))
        df <- rbind(df, df_ii)

        ixcount <- ixcount + 1
    }

    df$subject <- as.factor(df$subject)

    pd <- position_dodge(width=0.1)
    psub <- ggplot(df, aes(x=condition, y=rt, group=subject)) +
            geom_line(aes(color=subject), position=pd, alpha=0.7) +
            geom_errorbar(width=.1, aes(ymin=low, ymax=up, color=subject), position=pd, alpha=0.7) +
            geom_point(shape=21, size=3, fill="white", position=pd, alpha=0.7) +
            ggtitle(paste("Estimated", arg_plotvar," for each participant (", ml_string, ", VarSignal)")) +
            ylab(arg_plotvar) +
            xlab("Signal-to-noise ratio") +
            scale_color_manual(values=c("#2b2d42", "#8d99ae", "#d90429", "#00962f",
                                        "#ff420e", "#11c1fe", "#3f339d", "#f6aacb",
                                        "#dc8580", "#008989", "#ff9a00", "#bd00ff",
                                        "#7a624f", "#e72a89", "#d3b6aa", "#280da1",
                                        "#1995ad", "#cb0000")) +
            theme_bw()

    if (!is.na(arg_ylim[1])) {
        psub <- psub + ylim(arg_ylim)
    }

    return(psub)
}


plot_groupvar <- function(arg_subfit, arg_plotvar, arg_ylim)
{
    pred <- NULL
    pred$one <- extract(arg_subfit$one, arg_plotvar)
    pred$one <- unlist(pred$one, use.names=FALSE)
    pred$two <- extract(arg_subfit$two, arg_plotvar)
    pred$two <- unlist(pred$two, use.names=FALSE)
    pred$three <- extract(arg_subfit$three, arg_plotvar)
    pred$three <- unlist(pred$three, use.names=FALSE)

    # Compute confidence intervals
    ci <- NULL
    ci$one <- quantile(pred$one, c(0.025,0.975), names = FALSE)
    ci$two <- quantile(pred$two, c(0.025,0.975), names = FALSE)
    ci$three <- quantile(pred$three, c(0.025,0.975), names = FALSE)

    # Plot means & confidence intervals
    snrs <- c('1_low', '2_medium', '3_high') # signal-to-noise ratios for one, two & three
    mean_rts <- c(mean(pred$one),
                mean(pred$two),
                mean(pred$three))
    ci_low <- c(ci$one[1], ci$two[1], ci$three[1]) # lower confidence interval
    ci_up <- c(ci$one[2], ci$two[2], ci$three[2]) # upper confidence interval
    df <- data.frame(condition=snrs, rt = mean_rts, low = ci_low, up = ci_up)

    ph <- ggplot(df, aes(x=condition, y=rt, group=1)) +
        geom_line(color=1, alpha=0.7) +
        geom_errorbar(data=df, width=.1, aes(ymin=low, ymax=up), color=1) +
        geom_point(shape=21, size=3, fill="white") +
        ggtitle(paste("Estimated ", arg_plotvar, " (ML, VarSignal)")) +
        ylab(arg_plotvar) +
        xlab("Signal-to-noise ratio") +
        theme_bw()

    if (!is.na(arg_ylim[1])) {
        ph <- ph + ylim(arg_ylim)
    }

    return(ph)
}

