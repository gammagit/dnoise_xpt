rm(list=ls())

library(ggplot2)

pdf(file="raw_rts.pdf")

df_rtpc <- NULL # Data frame storing RTs & proportion correct for each sub
df_diff_crt <- NULL # Stores within-subject difference in RTs (between conditions)

psub <- NULL # Plot handle
subslist <- seq(1,16)
all_correct <- NULL
all_error <- NULL

# Concatenate data from all subjects
for (ix in subslist) {
    filename <- paste("sub", ix, ".csv", sep="")
    subtable <- read.csv(filename, header=TRUE)
    subdata <- data.frame(subtable)

    # Exclude data with difficulty = 0 (very very easy)
    subdata <- subset(subdata, diff!=0)

    # Add a column of subject id
    subdata$subid <- rep(ix, nrow(subdata))

    for (ss in seq(1,2)) { # for each session
        # Get data for session
        session_data <- subset(subdata, stype==ss)
        if (ss == 1){
            sname = 'signal'; # 1 for signal
        } else {
            sname = 'noise'; # 2 for noise
        }

        # Divide into correct and incorrect decisions
        correct_data <- subset(session_data, correct==1)
        error_data <- subset(session_data, correct==0)

        # Compute mean RT, error rate and difference in RT for subject
        crt_list <- NULL
        for (dd in seq(1,3)) {
            correct_data_dd <- subset(correct_data, diff==dd)
            error_data_dd <- subset(error_data, diff==dd)
            mean_crt_dd <- mean(correct_data_dd$rt)
            sd_crt_dd <- sd(correct_data_dd$rt)
            mean_ert_dd <- mean(error_data_dd$rt)
            pc_dd <- nrow(correct_data_dd) / (nrow(correct_data_dd) +
                                                nrow(error_data_dd))
            df_dd <- data.frame(condition=dd,
                                mean_crt=mean_crt_dd,
                                sd_crt=sd_crt_dd,
                                mean_ert=mean_ert_dd,
                                pc=pc_dd,
                                session=sname,
                                subid=ix)
            df_rtpc <- rbind(df_rtpc, df_dd)

            # Aggregate rts to compute within-subject difference
            crt_list <- c(crt_list, mean_crt_dd)
        }

        mean_diff_crt <- ((crt_list[2] - crt_list[1]) +
                        (crt_list[3] - crt_list[2])) / 2
        df_diff_crt <- rbind(df_diff_crt, data.frame(subid=ix,
                                                     diff_crt=mean_diff_crt,
                                                     session=sname))

        # Concatenate
#         all_correct <- rbind(all_correct, correct_data)
#         all_error <- rbind(all_error, error_data)
    }
}

df_rtpc$session <- as.factor(df_rtpc$session)
df_rtpc$subid <- as.factor(df_rtpc$subid)
df_diff_crt$subid <- as.factor(df_diff_crt$subid)

# all_correct$subid <- as.factor(all_correct$subid)
# all_error$subid <- as.factor(all_error$subid)

# Plot proportion of correct
pall_pc <- ggplot(df_rtpc, aes(interaction(factor(condition), session), pc)) +
           geom_boxplot(aes(fill=session), alpha=0.2) +
           geom_line(aes(color=subid,
                         group=interaction(subid, session)),
                     alpha=0.2) +
           geom_jitter(width=0.2, aes(color=subid), alpha=0.4) +
           xlab("Signal-to-noise ratio") +
           ylab("Proportion correct") +
           ylim(0.45, 1) +
           ggtitle("Proportion correct") +
           scale_color_manual(values=c("#2b2d42", "#8d99ae", "#d90429", "#00962f",
                                       "#ff420e", "#11c1fe", "#3f339d", "#f6aacb",
                                       "#dc8580", "#008989", "#ff9a00", "#bd00ff",
                                       "#7a624f", "#e72a89", "#d3b6aa", "#280da1",
                                       "#1995ad", "#cb0000")) +
           theme_bw()
print(pall_pc)

# Plot RTs in each condition
pall_rt <- ggplot(df_rtpc, aes(interaction(factor(condition), session), mean_crt)) +
           geom_boxplot(aes(fill=session), alpha=0.2) +
           geom_line(aes(color=subid,
                         group=interaction(subid,session)),
                     alpha=0.2) +
           geom_jitter(width=0.2, aes(color=subid), alpha=0.4) +
           xlab("Signal-to-noise ratio") +
           ylab("Mean RT (correct)") +
#            ylim(600, 2000) +
           ggtitle("Mean correct RT") +
           scale_color_manual(values=c("#2b2d42", "#8d99ae", "#d90429", "#00962f",
                                       "#ff420e", "#11c1fe", "#3f339d", "#f6aacb",
                                       "#dc8580", "#008989", "#ff9a00", "#bd00ff",
                                       "#7a624f", "#e72a89", "#d3b6aa", "#280da1",
                                       "#1995ad", "#cb0000")) +
           theme_bw()
print(pall_rt)

# Plot difference in RTs between conditions
ph_drt <- ggplot(df_diff_crt, aes(session, diff_crt)) +
          geom_boxplot(aes(fill=session), alpha=0.2) +
          geom_jitter(width=0.2, aes(color=subid), alpha=0.4) +
          ylab("Difference in (correct) RTs") +
          ggtitle("Change in RTs with SNR") +
          scale_color_manual(values=c("#2b2d42", "#8d99ae", "#d90429", "#00962f",
                                      "#ff420e", "#11c1fe", "#3f339d", "#f6aacb",
                                      "#dc8580", "#008989", "#ff9a00", "#bd00ff",
                                      "#7a624f", "#e72a89", "#d3b6aa", "#280da1",
                                      "#1995ad", "#cb0000")) +
          theme_bw()
print(ph_drt)

# Plot RT variance
# pall_sd <- ggplot(df_rtpc, aes(factor(condition), sd_crt)) +
#            geom_boxplot() +
#            geom_line(aes(color=factor(subid), group=subid), alpha=0.5) +
#            geom_jitter(width=0.1, aes(color=factor(subid)), alpha=0.5) +
#            xlab("Signal-to-noise ratio") +
#            ylab("Sample SD RT (correct)") +
#            ggtitle("Standard deviation in RT (VarNoise)") +
#            scale_color_manual(values=c("#2b2d42", "#8d99ae", "#d90429", "#00962f",
#                                        "#ff420e", "#11c1fe", "#3f339d", "#f6aacb",
#                                        "#dc8580", "#008989", "#ff9a00", "#bd00ff",
#                                        "#7a624f", "#e72a89", "#d3b6aa", "#280da1",
#                                        "#1995ad", "#cb0000")) +
#            theme_bw()
# print(pall_sd)

# Plot correct RT distributions
# psub <- ggplot(all_correct, aes(factor(diff), rt)) +
#         geom_boxplot(aes(fill = subid)) +
#         ylim(600, 4000) +
#         xlab("Signal-to-noise ratio") +
#         ggtitle("Raw Correct RTs (VarNoise)") +
#         scale_fill_manual(values=c("#2b2d42", "#8d99ae", "#d90429", "#00962f",
#                                     "#ff420e", "#11c1fe", "#3f339d", "#f6aacb",
#                                     "#dc8580", "#008989", "#ff9a00", "#bd00ff",
#                                     "#7a624f", "#e72a89", "#d3b6aa", "#280da1",
#                                     "#1995ad", "#cb0000")) +
#         theme_bw()

# print(psub)

dev.off()
