library(ggplot2)
library(readr)
library(tidyr)
library(lme4)
library(nlme)
library(lmerTest)
library(pbkrtest)
library(emmeans)

######################################################################
######################################################################
# df_all <- read_csv('/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_signal_emo_0.25.csv')
# df_all <- rbind(df_all, read_csv('/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_signal_pain_0.25.csv'))
# df_all <- read_csv('/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_signal_emo_0.25_3mm_qua.csv')
# df_all <- rbind(df_all, read_csv('/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_signal_pain_0.25_3mm_qua.csv'))
df_all <- read_csv('/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_signal_emo_qua.csv')
df_all <- rbind(df_all, read_csv('/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_signal_pain_qua.csv'))
# df_all <- read_csv('/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_signal_emo_0.25_3mm.csv')
# df_all <- rbind(df_all, read_csv('/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_signal_pain_0.25_3mm.csv'))
# df_all = df_all[df_all$roi!='all',]
df_all = df_all[df_all$roi_dim1!='all',]
# # get rid of subject iwth only 1 run to run the anova
# for (n in unique(df_all$subject)){
#   if (sum(df_all$subject==n)<6 ){
#     print(n)
#     df_all = df_all[!(df_all$subject==n),]
#   }
# }
df_all$run[df_all$run=='run-01']=1
df_all$run[df_all$run=='run-02']=2
df_all$run[df_all$run=='run-03']=3
df_all$run[df_all$run=='run-04']=4
df_all$run[df_all$run=='run-05']=5
# df_all$run = as.factor(df_all$run)
df_all$roi_dim1[df_all$roi_dim1=='left']='left SC'
df_all$roi_dim1[df_all$roi_dim1=='right']='right SC'
df_all$roi_dim1 = as.factor(df_all$roi_dim1)
df_all$roi_dim1 <- factor(df_all$roi_dim1, levels = c("left SC", "right SC"))
df_all$roi_dim3[df_all$roi_dim3=='upper']='upper SC'
df_all$roi_dim3[df_all$roi_dim3=='lower']='lower SC'
df_all$roi_dim3 = as.factor(df_all$roi_dim3)
df_all$roi_dim3 <- factor(df_all$roi_dim3, levels = c("upper SC", "lower SC"))
df_all$type[df_all$type=='negative']='Aversive'
df_all$type[df_all$type=='neutral']='Neutral'
df_all$type = as.factor(df_all$type)
df_all$type <- factor(df_all$type, levels = c("Aversive", "Neutral"))
df_all$task[df_all$task=='emo']='Visual task'
df_all$task[df_all$task=='pain']='Somatosensory task'
df_all$task <- factor(df_all$task, levels = c('Visual task', 'Somatosensory task'))
# from most complicated to decrease to simpler model, if no difference in anova,

#both
df_all$run <- as.factor(df_all$run)
# df_all$run = as.integer(df_all$run)
# model.all <- lmer(mean_signal ~ (run + roi_dim1 + roi_dim3 + type + roi_dim1:type + roi_dim3:type)*task + (run + roi_dim1 + roi_dim3 + type + roi_dim1:type + roi_dim3:type| subject), data=df_all)
model.all <- lmer(mean_signal ~ (run + roi_dim1 + roi_dim3 + type + roi_dim1:roi_dim3:type)*task + (run + roi_dim1 + roi_dim3 + type + roi_dim1:roi_dim3:type| subject), data=df_all)
# model.all <- lmer(mean_signal ~ (run + roi + type + roi:type)*task + (run + roi + type | subject), data=df_all, control=lmerControl(optCtrl=list(maxfun=10000000) ))
# model.all.1 <- lmer(mean_signal ~ (run + roi + type + roi:type)*task + (run + roi + type + roi:type | subject), data=df_all)
save(model.all,file="/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/r_output/model.all.Rda")
anova(model.all)
summary(model.all)
#these models don't converge
# model.all.1 <- lmer(mean_signal ~ (run + roi + type + roi:type + run:type)*task + (run + roi + type + roi:type + run:type | subject), data=df_all)
# anova(model.all.1)
# model.all.2 <- lmer(mean_signal ~ (run + roi + type + roi:type + run:type)*task + (run + roi + type + roi:type | subject), data=df_all)
# anova(model.all.2)

###############################################
#plot the emmean estimates of ALL effects
emmean_column1 <- emmeans(model.all, ~ task*run*roi_dim1*roi_dim3*type)
emmean_plot.df1 <- emmean_column1 %>% broom::tidy()
save(emmean_plot.df1,file="/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/r_output/emmean_plot.df1.Rda")
# #for more about emmeans and plotting options, see: https://cran.r-project.org/web/packages/emmeans/vignettes/basics.html
# emmean_column.1 <- emmeans(model.all, ~ task*roi*type | run)
# emmean_plot.df.1 <- emmean_column.1 %>% broom::tidy()
# emmip(ref_grid(model.all, cov.reduce = FALSE), task*type*roi ~ run)
# emmip(model.all, task ~ run)
emmean_plot.df1$std.error.high <- emmean_plot.df1$estimate+emmean_plot.df1$std.error
emmean_plot.df1$std.error.low <- emmean_plot.df1$estimate-emmean_plot.df1$std.error
colnames(emmean_plot.df1) <- c("Task","run","Hemisphere","Upper","Aversiveness","estimates","std.error","df","conf.low","conf.high","std.error.high","std.error.low")
#visual
ggplot(emmean_plot.df1[emmean_plot.df1$Task=='Visual task',], aes(run, estimates, group=interaction(Aversiveness,Hemisphere,Upper), colour = Aversiveness)) + 
  facet_grid(Upper~Hemisphere) +
  geom_point(size=3)+
  # geom_line(size=1.1, aes(linetype=Aversiveness)) +
  geom_line(size=1.2) +
  geom_errorbar(aes(ymin=std.error.low, ymax=std.error.high), width=0.4) + 
  scale_colour_manual(values = c('Aversive' = "tan3", 'Neutral' = "tan1"))+
  coord_cartesian(ylim = c(-6, 21)) + scale_y_continuous(breaks = round(seq(-6, 21, by = 6),1)) +
  theme(axis.line = element_line(colour = "black"),
        axis.text=element_text(size=12),
        axis.title=element_text(size=18),
        plot.title = element_text(size=16,face="bold")) + 
  # ggtitle("mean signal in subejct-level superior colliculus mask") +
  theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+ 
  theme(panel.background = element_blank()) + 
  theme(legend.position="none") + theme(text=element_text(family="Times New Roman")) + theme(strip.background =element_rect(fill="white"))
#somatosensory
ggplot(emmean_plot.df1[emmean_plot.df1$Task=='Somatosensory task',], aes(run, estimates, group=interaction(Aversiveness,Hemisphere), colour = Aversiveness)) + 
  facet_grid(Upper~Hemisphere) +
  geom_point(size=3)+
  # geom_line(size=1.1, aes(linetype=Aversiveness)) +
  geom_line(size=1.2) +
  geom_errorbar(aes(ymin=std.error.low, ymax=std.error.high), width=0.4) + 
  scale_colour_manual(values = c('Aversive' = "darkslategray3", 'Neutral' = "darkslategray2"))+
  coord_cartesian(ylim = c(-6, 21)) + scale_y_continuous(breaks = round(seq(-6, 21, by = 6),1)) + 
  theme(axis.line = element_line(colour = "black"),
        axis.text=element_text(size=12),
        axis.title=element_text(size=18),
        plot.title = element_text(size=16,face="bold")) + 
  # ggtitle("mean signal in subejct-level superior colliculus mask") +
  theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+ 
  theme(panel.background = element_blank()) + 
  theme(legend.position="none") + theme(text=element_text(family="Times New Roman")) + theme(strip.background =element_rect(fill="white"))
# #both tasks
# ggplot(emmean_plot.df1, aes(run, estimates, group=interaction(Aversiveness,Hemisphere), colour = interaction(Task,Aversiveness))) +
#   facet_grid(Upper~Hemisphere) +
#   geom_point(size=3)+
#   # geom_line(size=1.1, aes(linetype=Aversiveness)) +
#   geom_line(size=1.2) +
#   geom_errorbar(aes(ymin=std.error.low, ymax=std.error.high), width=0.4) +
#   scale_colour_manual(values = c('Visual task.Aversive' = "tan3", 'Visual task.Neutral' = "tan1", 'Somatosensory task.Aversive' = "darkslategray3", 'Somatosensory task.Neutral' = "darkslategray2"))+
#   coord_cartesian(ylim = c(-6, 15)) +
#   theme(axis.line = element_line(colour = "black"),
#         axis.text=element_text(size=12),
#         axis.title=element_text(size=18),
#         plot.title = element_text(size=16,face="bold")) +
#   # ggtitle("mean signal in subejct-level superior colliculus mask") +
#   theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+
#   theme(panel.background = element_blank()) +
#   theme(legend.position="none") + theme(text=element_text(family="Times New Roman")) + theme(strip.background =element_rect(fill="white"))

###############################################
#plot the emmean estimates of both modalities
emmean_column2 <- emmeans(model.all, ~ task)
emmean_plot.df2 <- emmean_column2 %>% broom::tidy()
save(emmean_plot.df2,file="/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/r_output/emmean_plot.df2.Rda")
emmean_plot.df2$std.error.high <- emmean_plot.df2$estimate+emmean_plot.df2$std.error
emmean_plot.df2$std.error.low <- emmean_plot.df2$estimate-emmean_plot.df2$std.error
colnames(emmean_plot.df2) <- c("Sensory_modalities","estimates","std.error","df","conf.low","conf.high","std.error.high","std.error.low")
ggplot(emmean_plot.df2, aes(Sensory_modalities,estimates, fill=Sensory_modalities, group=1)) + 
  geom_bar(stat = "identity")+
  geom_errorbar(aes(ymin=std.error.low, ymax=std.error.high), width=0.1)+
  scale_fill_manual(values = c("tan3", "darkslategray2") ) +
  theme(axis.line = element_line(colour = "black"),
        axis.text=element_text(size=12),
        axis.title=element_text(size=18),
        plot.title = element_text(size=16,face="bold")) + 
  coord_cartesian(ylim = c(0, 11)) + scale_y_continuous(breaks = round(seq(0, 11, by = 2),1)) + 
  # coord_cartesian(ylim = c(-1, 8)) +
  # ggtitle("mean signal in subejct-level superior colliculus mask") +
  theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+ 
  theme(panel.background = element_blank()) + 
  theme(legend.position="none") + theme(text=element_text(family="Times New Roman")) + theme(strip.background =element_rect(fill="white"))

df_all_sub_agg <- aggregate(df_all$mean_signal,by=(list(df_all$subject,df_all$task)), FUN=mean)
colnames(df_all_sub_agg) <- c('subject', 'task','mean_signal')
t.test(df_all_sub_agg$mean_signal[df_all_sub_agg$task=='Visual task'], mu = 0, alternative = "greater")
t.test(df_all_sub_agg$mean_signal[df_all_sub_agg$task=='Somatosensory task'], mu = 0, alternative = "greater")

###############################################
#plot the emmean estimates of aversive effect
emmean_column3 <- emmeans(model.all, ~ type)
emmean_plot.df3 <- emmean_column3 %>% broom::tidy()
save(emmean_plot.df3,file="/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/r_output/emmean_plot.df3.Rda")
emmean_plot.df3$std.error.high <- emmean_plot.df3$estimate+emmean_plot.df3$std.error
emmean_plot.df3$std.error.low <- emmean_plot.df3$estimate-emmean_plot.df3$std.error
colnames(emmean_plot.df3) <- c("Aversiveness","estimates","std.error","df","conf.low","conf.high","std.error.high","std.error.low")
ggplot(emmean_plot.df3, aes(Aversiveness,estimates, fill=Aversiveness, group=1)) + 
  geom_bar(stat = "identity")+
  geom_errorbar(aes(ymin=std.error.low, ymax=std.error.high), width=0.1)+
  scale_fill_manual(values = c("gray40", "gray80") ) +
  theme(axis.line = element_line(colour = "black"),
        axis.text=element_text(size=12),
        axis.title=element_text(size=18),
        plot.title = element_text(size=16,face="bold")) + 
  coord_cartesian(ylim = c(0, 11)) + scale_y_continuous(breaks = round(seq(0, 11, by = 2),1)) + 
  # coord_cartesian(ylim = c(-1, 8)) +
  # ggtitle("mean signal in subejct-level superior colliculus mask") +
  theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+ 
  theme(panel.background = element_blank()) + 
  theme(legend.position="none") + theme(text=element_text(family="Times New Roman")) + theme(strip.background =element_rect(fill="white"))

ggplot(emmean_plot.df1, aes(Aversiveness,estimates, fill=Aversiveness, group=1)) + 
  # geom_bar(stat = "identity")+
  # geom_errorbar(aes(ymin=std.error.low, ymax=std.error.high), width=0.1)+
  stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.3, geom="bar", size = 1.5)+
  stat_summary(fun.data=mean_se, geom="errorbar",width=0.1,  size = 0.5)+
  scale_fill_manual(values = c("gray40", "gray80") ) +
  theme(axis.line = element_line(colour = "black"),
        axis.text=element_text(size=12),
        axis.title=element_text(size=18),
        plot.title = element_text(size=16,face="bold")) + 
  coord_cartesian(ylim = c(0, 11)) + scale_y_continuous(breaks = round(seq(0, 11, by = 2),1)) + 
  # coord_cartesian(ylim = c(-1, 8)) +
  # ggtitle("mean signal in subejct-level superior colliculus mask") +
  theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+ 
  theme(panel.background = element_blank()) + 
  theme(legend.position="none") + theme(text=element_text(family="Times New Roman")) + theme(strip.background =element_rect(fill="white"))

df_all_sub_agg <- aggregate(df_all$mean_signal,by=(list(df_all$subject,df_all$type)), FUN=sum)
colnames(df_all_sub_agg) <- c('subject', 'type','mean_signal')
t.test(df_all_sub_agg$mean_signal[df_all_sub_agg$type=='Aversive'], df_all_sub_agg$mean_signal[df_all_sub_agg$type=='Neutral'], paired = TRUE,alternative = "greater")

###############################################
#plot the emmean estimates of run effect
emmean_column4 <- emmeans(model.all, ~ run)
emmean_plot.df4 <- emmean_column4 %>% broom::tidy()
save(emmean_plot.df4,file="/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/r_output/emmean_plot.df4.Rda")
emmean_plot.df4$std.error.high <- emmean_plot.df4$estimate+emmean_plot.df4$std.error
emmean_plot.df4$std.error.low <- emmean_plot.df4$estimate-emmean_plot.df4$std.error
colnames(emmean_plot.df4) <- c("run","estimates","std.error","df","conf.low","conf.high","std.error.high","std.error.low")
ggplot(emmean_plot.df4, aes(run,estimates,group = 1)) + 
  geom_point(size=3, colour="gray50")+
  # geom_line(size=1.1, aes(linetype=Aversiveness)) +
  geom_line(size=1.2, colour="gray50")+
  geom_errorbar(aes(ymin=std.error.low, ymax=std.error.high), width=0.1, colour="gray50")+
  coord_cartesian(ylim = c(0, 11)) + scale_y_continuous(breaks = round(seq(0, 11, by = 2),1)) + 
  # coord_cartesian(ylim = c(-1, 8)) +
  theme(axis.line = element_line(colour = "black"),
        axis.text=element_text(size=12),
        axis.title=element_text(size=18),
        plot.title = element_text(size=16,face="bold")) + 
  # ggtitle("mean signal in subejct-level superior colliculus mask") +
  theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+ 
  theme(panel.background = element_blank()) + 
  theme(legend.position="none") + theme(text=element_text(family="Times New Roman")) + theme(strip.background =element_rect(fill="white"))

###############################################
#plot the emmean estimates of hemisphere*task effect
emmean_column5 <- emmeans(model.all, ~ roi_dim1*task)
emmean_plot.df5 <- emmean_column5 %>% broom::tidy()
save(emmean_plot.df5,file="/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/r_output/emmean_plot.df5.Rda")
emmean_plot.df5$std.error.high <- emmean_plot.df5$estimate+emmean_plot.df5$std.error
emmean_plot.df5$std.error.low <- emmean_plot.df5$estimate-emmean_plot.df5$std.error
colnames(emmean_plot.df5) <- c("Hemisphere", "Task","estimates","std.error","df","conf.low","conf.high","std.error.high","std.error.low")
ggplot(emmean_plot.df5, aes(Hemisphere, estimates, group=Task, colour=Task)) + 
  geom_point(size=3)+
  # geom_line(size=1.1, aes(linetype=Aversiveness)) +
  geom_line(size=1.2)+
  geom_errorbar(aes(ymin=std.error.low, ymax=std.error.high), width=0.1)+
  scale_colour_manual(values = c("tan2", "darkslategray3"))+
  coord_cartesian(ylim = c(0, 11)) + scale_y_continuous(breaks = round(seq(0, 11, by = 2),1)) + 
  # coord_cartesian(ylim = c(-1, 12)) +
  theme(axis.line = element_line(colour = "black"),
        axis.text=element_text(size=12),
        axis.title=element_text(size=18),
        plot.title = element_text(size=16,face="bold")) + 
  # ggtitle("mean signal in subejct-level superior colliculus mask") +
  theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+ 
  theme(panel.background = element_blank()) + 
  theme(legend.position="none") + theme(text=element_text(family="Times New Roman")) + theme(strip.background =element_rect(fill="white"))

###############################################
#plot the emmean estimates of dorsal/ventral*task effect
emmean_column6 <- emmeans(model.all, ~ roi_dim3*task)
emmean_plot.df6 <- emmean_column6 %>% broom::tidy()
save(emmean_plot.df6,file="/Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/r_output/emmean_plot.df6.Rda")
emmean_plot.df6$std.error.high <- emmean_plot.df6$estimate+emmean_plot.df6$std.error
emmean_plot.df6$std.error.low <- emmean_plot.df6$estimate-emmean_plot.df6$std.error
colnames(emmean_plot.df6) <- c("Layers", "Task","estimates","std.error","df","conf.low","conf.high","std.error.high","std.error.low")
emmean_plot.df6$Layers <- factor(emmean_plot.df6$Layers, levels = c("lower SC", "upper SC"))
emmean_plot.df6$Layers <- factor(emmean_plot.df6$Layers, levels = c("upper SC", "lower SC"))
ggplot(emmean_plot.df6, aes(Layers, estimates, group=Task, colour=Task)) + 
  geom_point(size=3)+
  # geom_line(size=1.1, aes(linetype=Aversiveness)) +
  geom_line(size=1.2)+
  geom_errorbar(aes(ymin=std.error.low, ymax=std.error.high), width=0.1)+
  scale_colour_manual(values = c("tan2", "darkslategray3"))+
  coord_cartesian(ylim = c(0, 11)) + scale_y_continuous(breaks = round(seq(0, 11, by = 2),1)) + 
  # coord_cartesian(ylim = c(-1, 11)) +
  theme(axis.line = element_line(colour = "black"),
        axis.text=element_text(size=12),
        axis.title=element_text(size=18),
        plot.title = element_text(size=16,face="bold")) + 
  # ggtitle("mean signal in subejct-level superior colliculus mask") +
  theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+ 
  theme(panel.background = element_blank()) + 
  # coord_flip() +
  theme(legend.position="none") + theme(text=element_text(family="Times New Roman")) + theme(strip.background =element_rect(fill="white"))


df_all_sub_agg <- aggregate(df_all$mean_signal,by=(list(df_all$subject,df_all$roi_dim3,df_all$task)), FUN=mean)
colnames(df_all_sub_agg) <- c('subject', 'layers','task','mean_signal')
t.test(df_all_sub_agg[df_all_sub_agg$task=='Visual task',]$mean_signal[df_all_sub_agg[df_all_sub_agg$task=='Visual task',]$layers=='upper SC'], df_all_sub_agg[df_all_sub_agg$task=='Visual task',]$mean_signal[df_all_sub_agg[df_all_sub_agg$task=='Visual task',]$layers=='lower SC'], paired = TRUE,alternative = "greater")
t.test(df_all_sub_agg[df_all_sub_agg$task=='Somatosensory task',]$mean_signal[df_all_sub_agg[df_all_sub_agg$task=='Somatosensory task',]$layers=='upper SC'], df_all_sub_agg[df_all_sub_agg$task=='Somatosensory task',]$mean_signal[df_all_sub_agg[df_all_sub_agg$task=='Somatosensory task',]$layers=='lower SC'], paired = TRUE,alternative = "less")


df_all_sub_agg <- aggregate(df_all$mean_signal,by=(list(df_all$subject,df_all$roi_dim3,df_all$task)), FUN=mean)
colnames(df_all_sub_agg) <- c('subject','layers','task','mean_signal')
t.test(df_all_sub_agg[df_all_sub_agg$task=='Visual task',]$mean_signal[df_all_sub_agg[df_all_sub_agg$task=='Visual task',]$layers=='upper SC'], df_all_sub_agg[df_all_sub_agg$task=='Visual task',]$mean_signal[df_all_sub_agg[df_all_sub_agg$task=='Visual task',]$layers=='lower SC'], paired = TRUE,alternative = "greater")
t.test(df_all_sub_agg[df_all_sub_agg$task=='Somatosensory task',]$mean_signal[df_all_sub_agg[df_all_sub_agg$task=='Somatosensory task',]$layers=='upper SC'], df_all_sub_agg[df_all_sub_agg$task=='Somatosensory task',]$mean_signal[df_all_sub_agg[df_all_sub_agg$task=='Somatosensory task',]$layers=='lower SC'], paired = TRUE,alternative = "less")

mean(df_all[df_all$task=='Visual task',]$mean_signal[df_all[df_all$task=='Visual task',]$roi_dim3=='upper SC'])
mean(df_all[df_all$task=='Visual task',]$mean_signal[df_all[df_all$task=='Visual task',]$roi_dim3=='lower SC'])
mean(df_all[df_all$task=='Somatosensory task',]$mean_signal[df_all[df_all$task=='Somatosensory task',]$roi_dim3=='upper SC'])
mean(df_all[df_all$task=='Somatosensory task',]$mean_signal[df_all[df_all$task=='Somatosensory task',]$roi_dim3=='lower SC'])


######################################################################
######################################################################
#read in files
file = '/Users/chendanlei/Google Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_signal_emo_0.25.csv'
options(contrasts = c("contr.sum","contr.poly")) #this line is a must, see https://stats.stackexchange.com/questions/249884/conflicting-results-of-summary-and-anova-for-a-mixed-model-with-interactions
df_emo <- read_csv(file)
df_emo = df_emo[df_emo$roi!='all',]
# #get rid of subject iwth only 1 run to run the anova
# for (n in unique(df_emo$subject)){
#   if (sum(df_emo$subject==n)<20 ){
#     # print(n)
#     df_emo = df_emo[!(df_emo$subject==n),]
#   }
# }
df_emo$run[df_emo$run=='run-01']=1
df_emo$run[df_emo$run=='run-02']=2
df_emo$run[df_emo$run=='run-03']=3
df_emo$run[df_emo$run=='run-04']=4
df_emo$run[df_emo$run=='run-05']=5
df_emo$run = as.integer(df_emo$run)
# df_emo$run = as.factor(df_emo$run)
df_emo$roi = as.factor(df_emo$roi)
df_emo$roi <- factor(df_emo$roi, levels = c("left", "right"))
df_emo$type = as.factor(df_emo$type)
df_emo$type <- factor(df_emo$type, levels = c("neutral", "negative"))
# from most complicated to decrease to simpler model, if no difference in anova,

######################################################################
######################################################################
#read in files
file = '/Users/chendanlei/Google Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_signal_pain_0.25.csv'
options(contrasts = c("contr.sum","contr.poly")) #this line is a must, see https://stats.stackexchange.com/questions/249884/conflicting-results-of-summary-and-anova-for-a-mixed-model-with-interactions
df_pain <- read_csv(file)
df_pain = df_pain[df_pain$roi!='all',]
# #get rid of subject iwth only 1 run to run the anova
# for (n in unique(df_pain$subject)){
#   if (sum(df_pain$subject==n)<20 ){
#     # print(n)
#     df_pain = df_pain[!(df_pain$subject==n),]
#   }
# }
df_pain$run[df_pain$run=='run-01']=1
df_pain$run[df_pain$run=='run-02']=2
df_pain$run[df_pain$run=='run-03']=3
df_pain$run[df_pain$run=='run-04']=4
df_pain$run[df_pain$run=='run-05']=5
df_pain$run = as.integer(df_pain$run)
# df_pain$run = as.factor(df_pain$run)
df_pain$roi = as.factor(df_pain$roi)
df_pain$roi <- factor(df_pain$roi, levels = c("left", "right"))
df_pain$type = as.factor(df_pain$type)
df_pain$type <- factor(df_pain$type, levels = c("neutral", "negative"))
# from most complicated to decrease to simpler model, if no difference in anova,

#emo
model.emo <- lmer(mean_signal ~ run + roi + type + roi:type + run:type + (run + roi + type + roi:type + run:type | subject), data=df_emo)
anova(model.emo)
summary(model.emo)

#pain
model.pain <- lmer(mean_signal ~ run + roi + type + roi:type + run:type + (run + roi + type + roi:type + run:type | subject), data=df_pain)
anova(model.pain)
summary(model.pain)



  
# #1.Full, most complicated model: 
# model1 <- lmer(mean_signal ~ task * run * roi * type + (run * roi * type|subject), data=df)
# anova(model1)
# model1.1 <- lmer(mean_signal ~ task * run * roi * type + (run * roi * type||subject), data=df) #|| uncorrelate random effect factors
# anova(model1.1)
# model1.2 <- lmer(mean_signal ~ task * run * roi * type + (run * roi * type||subject), data=df_5runsONly) #|| uncorrelate random effect factors
# anova(model1.2)
# #2.getting rid of 4-way interaction- task:run:roi:type #DO NOT CONVERGE
# model2 <- lmer(mean_signal ~ task + run + roi + type + run:roi + run:type + roi:type + task:run + task:roi + task:type + task:run:roi + task:run:type + task:roi:type + run:roi:type + (run + roi + type + run:roi + run:type + roi:type + run:roi:type|subject), data=df)
# anova(model1, model2, refit=FALSE)  #p=1, go with model 2
# anova(model2)
# #3.getting rid of the most useless term- run:roi:type #DO NOT CONVERGE
# model3 <- lmer(mean_signal ~ task + run + roi + type + run:roi + run:type + roi:type + task:run + task:roi + task:type + task:run:roi + task:run:type + task:roi:type + (run + roi + type + run:roi + run:type + roi:type|subject), data=df)
# anova(model2, model3, refit=FALSE)  #p=0.99, go with model 3
# anova(model3)
# #4.getting rid of the most useless term- run:roi #DO NOT CONVERGE
# model4 <- lmer(mean_signal ~ task + run + roi + type + run:type + roi:type + task:run + task:roi + task:type + task:run:roi + task:run:type + task:roi:type + (run + roi + type + run:type + roi:type|subject), data=df)
# anova(model3, model4, refit=FALSE)  #p=1, model 3 and 4 are not different, go with model 4
# anova(model4)
# #5.getting rid of the most useless term- task:run:roi
# ####FROM HERE: MODEL4 ACTUALLY HAS ROI AND TYPE AS THE MOST USELESS TERMS#####
# model5 <- lmer(mean_signal ~ task + run + roi + type + run:type + roi:type + task:run + task:roi + task:type + task:run:type + task:roi:type + (run + roi + type + run:type + roi:type|subject), data=df)
# anova(model4, model5, refit=FALSE)  #p=0.87, go with model 5
# anova(model5)
# model5.5 <- lmer(mean_signal ~ task + run * roi * type + (run * roi * type|subject), data=df)
# anova(model5.5)
# #6.getting rid of the most useless term- task:run #DO NOT CONVERGE
# model6 <- lmer(mean_signal ~ task + run + roi + type + run:type + roi:type + task:roi + task:type + task:run:type + task:roi:type + (run + roi + type + run:type + roi:type|subject), data=df)
# anova(model5, model6, refit=FALSE)  #p=0.000, KEEP task:run TERM????????????, go with model 5
# anova(model6)
# #7. getting rid of the SECOND MOST useless term from MODEL 5- task:type
# model7 <- lmer(mean_signal ~ task + run + roi + type + run:type + roi:type + task:run + task:roi + task:run:type + task:roi:type + (run + roi + type + run:type + roi:type|subject), data=df)
# anova(model5, model7, refit=FALSE)  #p=0.12, go with model 7
# anova(model7)
# #8. getting rid of the most useless term task:run:type #DO NOT CONVERGE
# model8 <- lmer(mean_signal ~ task + run + roi + type + run:type + roi:type + task:run + task:roi + task:roi:type + (run + roi + type + run:type + roi:type|subject), data=df)
# anova(model7, model8, refit=FALSE)  #p=0.000, KEEP task:run:type TERM, go with model 7
# anova(model8)
# #9. getting rid of the SECOND MOST useless term from MODEL 7- task:run #DO NOT CONVERGE
# model9 <- lmer(mean_signal ~ task + run + roi + type + run:type + roi:type + task:roi + task:run:type + task:roi:type + (run + roi + type + run:type + roi:type|subject), data=df)
# anova(model8, model9, refit=FALSE)  #p=1, go with model 9
# anova(model9)
# #10. getting rid of the most useless term task:run:type ????????? BUT IT WAS KEPT ON MODEL 8 #DO NOT CONVERGE
# model10 <- lmer(mean_signal ~ task + run + roi + type + run:type + roi:type + task:roi + task:roi:type + (run + roi + type + run:type + roi:type|subject), data=df)
# anova(model9, model10, refit=FALSE)  #p=1, go with model 10
# anova(model10)
# #11. getting rid of the most useless term roi:type #DO NOT CONVERGE
# model11 <- lmer(mean_signal ~ task + run + roi + type + run:type + task:roi + task:roi:type + (run + roi + type + run:type|subject), data=df)
# anova(model10, model11, refit=FALSE)  #p=1, go with model 11
# anova(model11)
# #12. getting rid of the most useless term task:roi:type #DO NOT CONVERGE
# model12 <- lmer(mean_signal ~ task + run + roi + type + run:type + task:roi + (run + roi + type + run:type|subject), data=df)
# anova(model11, model12, refit=FALSE)  #p=0.05, KEEP task:roi:type
# anova(model12)
# #13. getting rid of the SECOND MOST useless term from model 11 run:type #DO NOT CONVERGE
# model13 <- lmer(mean_signal ~ task + run + roi + type + task:roi + task:roi:type + (run + roi + type|subject), data=df) #?????fail to convergs
# anova(model11, model13, refit=FALSE)  #p=0.000, KEEP run:type 
# anova(model12)

