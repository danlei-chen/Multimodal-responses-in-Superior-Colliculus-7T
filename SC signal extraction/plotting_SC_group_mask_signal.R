library(ggplot2)
library(readr)
library(tidyr)
library(lme4)
library(nlme)

file = '/Volumes/GoogleDrive/My Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_sensory_group_mask_signal_3mm.csv'

########### ANOVA ########### 
df <- read_csv(file)
# df=df[df['subjID']!='sub-062_run-01',]
df$roi_task_subregion <- paste(df$roi_name, df$roi_subregion, sep="_")
df$roi_task_subregion <- factor(df$roi_task_subregion, levels = c("picture_left", "pain_left", "picture_right", "pain_right"))
df$roi_name[df$roi_name=='pain'] <- 'somatosensory'
df$roi_name[df$roi_name=='picture'] <- 'visual'
df$roi_subregion[df$roi_subregion=='left'] <- 'left subregion'
df$roi_subregion[df$roi_subregion=='right'] <- 'right subregion'
df$roi_name <- factor(df$roi_name, levels = c("visual", "somatosensory"))
df = df[df$roi_subregion!='all',]
df_subjmean <- aggregate(list(df$mean_signal),by=(list(df$subject, df$task, df$roi_name, df$roi_subregion, df$roi_task_subregion, df$roi_vox_size)), FUN=mean, na.rm=TRUE)
colnames(df_subjmean) <- c('subject','task','roi_name','roi_subregion','roi_task_subregion','roi_vox_size','mean_signal')

#### MEAN ####
df_emo <- df_subjmean[df_subjmean['task']=='emo3',]
# summary(aov(mean_signal ~ roi_subregion * roi_name * run + Error(subject/(roi_subregion * roi_name * run)), data=df_emo))
summary(aov(mean_signal ~ roi_subregion * roi_name + Error(subject/(roi_subregion * roi_name)), data=df_emo))
df_pain <- df_subjmean[df_subjmean['task']=='pain3',]
# summary(aov(mean_signal ~ roi_subregion * roi_name * run + Error(subject/(roi_subregion * roi_name * run)), data=df_pain))
summary(aov(mean_signal ~ roi_subregion * roi_name + Error(subject/(roi_subregion * roi_name)), data=df_pain))
# anova(fit2<-lmer(mean_signal ~ run * roi * type + (1|subject), data=df, na.action = na.exclude))
# #### PEAK ####
# summary(aov(peak_signal ~ roi * type * run + Error(subject/(roi * type * run)), data=df))
# # anova(fit2<-lmer(peak_signal ~ run * roi * type + (1|subject), data=df, na.action = na.exclude))

#### MEAN ####
ggplot(df_emo, aes(x=roi_name,y=mean_signal)) + 
  # stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.9, geom="bar", size = 0.5, fill="tan2", colour='black')+
  # stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.7, geom="bar", size = 0.5, fill="cadetblue2", colour='black')+
  stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.7, geom="bar", size = 0.5, colour='black', fill=c("tan2","cadetblue2","tan2","cadetblue2"))+
  stat_summary(fun.data=mean_se,position=position_dodge(width=0.90), geom="errorbar",width=0.2,  size = 0.5)+
  geom_point(data = df_emo, aes(roi_name, mean_signal, group=subject, color=subject), alpha = 0.3, size = 1)+
  geom_line(data = df_emo, aes(roi_name, mean_signal, group=subject, color=subject), alpha = 0.3, size = 0.5)+
  # geom_violin(trim=TRUE, alpha = 0.1, size=0.02)+
  # geom_hline(aes(yintercept=mean(mean_signal, na.rm=TRUE)),color="blue", linetype="dashed", size=0.3) +
  theme(axis.line = element_line(colour = "black"),
        axis.text=element_text(size=12),
        axis.title=element_text(size=15),
        plot.title = element_text(size=16,face="bold")) + 
  # ggtitle("Visual task") + 
  facet_wrap(~roi_subregion)+
  theme(strip.text.x = element_text(size = 15),strip.text.y = element_text(size = 15))+ 
  theme(panel.background = element_blank()) + theme(legend.position = "none") +
  ylab('average signal') + xlab('SC sensory subregion') 
  # theme(panel.background = element_rect(fill = "cornsilk1"))

left_sub <- c()
right_sub <- c()
for (s in unique(df_emo$subject)){
  if (df_emo$mean_signal[df_emo$roi_name=='visual' & df_emo$subject==s & df_emo$roi_subregion=='left subregion'] - df_emo$mean_signal[df_emo$roi_name=='somatosensory' & df_emo$subject==s & df_emo$roi_subregion=='left subregion'] > 0){
    left_sub <- c(left_sub, s)
  }
  if (df_emo$mean_signal[df_emo$roi_name=='visual' & df_emo$subject==s & df_emo$roi_subregion=='right subregion'] - df_emo$mean_signal[df_emo$roi_name=='somatosensory' & df_emo$subject==s & df_emo$roi_subregion=='right subregion'] > 0){
    right_sub <- c(right_sub, s)
  }
}
print('visual left sc:')
print(length(left_sub)/length(unique(df_emo$subject)))
print('visual right sc:')
print(length(right_sub)/length(unique(df_emo$subject)))


ggplot(df_pain, aes(x=roi_name,y=mean_signal)) + 
  # stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.9, geom="bar", size = 0.5, fill="tan2", colour='black')+
  # stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.7, geom="bar", size = 0.5, fill="cadetblue2", colour='black')+
  stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.7, geom="bar", size = 0.5, colour='black', fill=c("tan2","cadetblue2","tan2","cadetblue2"))+
  stat_summary(fun.data=mean_se,position=position_dodge(width=0.90), geom="errorbar",width=0.2,  size = 0.5)+
  geom_point(data = df_pain, aes(roi_name, mean_signal, group=subject, color=subject), alpha = 0.3, size = 1)+
  geom_line(data = df_pain, aes(roi_name, mean_signal, group=subject, color=subject), alpha = 0.3, size = 0.5)+
  # geom_violin(trim=TRUE, alpha = 0.1, size=0.02)+
  # geom_hline(aes(yintercept=mean(mean_signal, na.rm=TRUE)),color="blue", linetype="dashed", size=0.3) +
  theme(axis.line = element_line(colour = "black"),
        axis.text=element_text(size=12),
        axis.title=element_text(size=15),
        plot.title = element_text(size=16,face="bold")) + 
  # ggtitle("Somatosensory task") + 
  facet_wrap(~roi_subregion)+
  theme(strip.text.x = element_text(size = 15),strip.text.y = element_text(size = 15))+ 
  theme(panel.background = element_blank()) + theme(legend.position = "none") +
  ylab('average signal') + xlab('SC sensory subregion') 

left_sub <- c()
right_sub <- c()
for (s in unique(df_pain$subject)){
  if (df_pain$mean_signal[df_pain$roi_name=='somatosensory' & df_pain$subject==s & df_pain$roi_subregion=='left subregion'] - df_pain$mean_signal[df_pain$roi_name=='visual' & df_pain$subject==s & df_pain$roi_subregion=='left subregion'] > 0){
    left_sub <- c(left_sub, s)
  }
  if (df_pain$mean_signal[df_pain$roi_name=='somatosensory' & df_pain$subject==s & df_pain$roi_subregion=='right subregion'] - df_pain$mean_signal[df_pain$roi_name=='visual' & df_pain$subject==s & df_pain$roi_subregion=='right subregion'] > 0){
    right_sub <- c(right_sub, s)
  }
}
print('visual left sc:')
print(length(left_sub)/length(unique(df_pain$subject)))
print('visual right sc:')
print(length(right_sub)/length(unique(df_pain$subject)))


# theme(panel.background = element_rect(fill = "cornsilk1"))
# ggplot(df_pain, aes(x=roi_task_subregion,y=mean_signal)) + 
#   # stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.9, geom="bar", size = 0.5, fill="tan2", colour='black')+
#   # stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.7, geom="bar", size = 0.5, fill="cadetblue2", colour='black')+
#   stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.7, geom="bar", size = 0.5, colour='black', fill=c("tan2","tan2","cadetblue2","cadetblue2"))+
#   stat_summary(fun.data=mean_se,position=position_dodge(width=0.90), geom="errorbar",width=0.2,  size = 0.5)+
#   geom_point(data = df_pain, aes(roi_task_subregion, mean_signal, group=subject, color=subject), alpha = 0.3, size = 1)+
#   geom_line(data = df_pain, aes(roi_task_subregion, mean_signal, group=subject, color=subject), alpha = 0.3, size = 0.5)+
#   # geom_violin(trim=TRUE, alpha = 0.1, size=0.02)+
#   # geom_hline(aes(yintercept=mean(mean_signal, na.rm=TRUE)),color="blue", linetype="dashed", size=0.3) +
#   theme(axis.line = element_line(colour = "black"),
#         axis.text=element_text(size=11),
#         axis.title=element_text(size=16),
#         plot.title = element_text(size=16,face="bold")) + 
#   ggtitle("Pain Subjects") +
#   theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+ 
#   theme(panel.background = element_blank()) + theme(legend.position = "none") +
#   ylab('average signal')  + xlab('Sensory modality subregion') 
#   # theme(panel.background = element_rect(fill = "azure1"))


df_subjmean <- aggregate(list(df$mean_signal),by=(list(df$subject, df$task, df$roi_name)), FUN=mean, na.rm=TRUE)
colnames(df_subjmean) <- c('subject','task','roi_name','mean_signal')
df_emo <- df_subjmean[df_subjmean['task']=='emo3',]
df_pain <- df_subjmean[df_subjmean['task']=='pain3',]

#### MEAN ####
ggplot(df_emo, aes(x=roi_name,y=mean_signal)) + 
  # stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.9, geom="bar", size = 0.5, fill="tan2", colour='black')+
  # stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.7, geom="bar", size = 0.5, fill="cadetblue2", colour='black')+
  stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.7, geom="bar", size = 0.5, colour='black', fill=c("tan2","cadetblue2"))+
  stat_summary(fun.data=mean_se,position=position_dodge(width=0.90), geom="errorbar",width=0.2,  size = 0.5)+
  geom_point(data = df_emo, aes(roi_name, mean_signal, group=subject, color=subject), alpha = 0.3, size = 1)+
  geom_line(data = df_emo, aes(roi_name, mean_signal, group=subject, color=subject), alpha = 0.3, size = 0.5)+
  # geom_violin(trim=TRUE, alpha = 0.1, size=0.02)+
  # geom_hline(aes(yintercept=mean(mean_signal, na.rm=TRUE)),color="blue", linetype="dashed", size=0.3) +
  theme(axis.line = element_line(colour = "black"),
        axis.text=element_text(size=12),
        axis.title=element_text(size=15),
        plot.title = element_text(size=16,face="bold")) + 
  # ggtitle("Visual task") +
  theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+ 
  theme(panel.background = element_blank()) + theme(legend.position = "none") +
  ylab('average signal') + xlab('SC sensory subregion') 
# theme(panel.background = element_rect(fill = "cornsilk1"))

ggplot(df_pain, aes(x=roi_name,y=mean_signal)) + 
  # stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.9, geom="bar", size = 0.5, fill="tan2", colour='black')+
  # stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.7, geom="bar", size = 0.5, fill="cadetblue2", colour='black')+
  stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.7, geom="bar", size = 0.5, colour='black', fill=c("tan2","cadetblue2"))+
  stat_summary(fun.data=mean_se,position=position_dodge(width=0.90), geom="errorbar",width=0.2,  size = 0.5)+
  geom_point(data = df_pain, aes(roi_name, mean_signal, group=subject, color=subject), alpha = 0.3, size = 1)+
  geom_line(data = df_pain, aes(roi_name, mean_signal, group=subject, color=subject), alpha = 0.3, size = 0.5)+
  # geom_violin(trim=TRUE, alpha = 0.1, size=0.02)+
  # geom_hline(aes(yintercept=mean(mean_signal, na.rm=TRUE)),color="blue", linetype="dashed", size=0.3) +
  theme(axis.line = element_line(colour = "black"),
        axis.text=element_text(size=12),
        axis.title=element_text(size=15),
        plot.title = element_text(size=16,face="bold")) + 
  # ggtitle("Somatosensory task") +
  theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+ 
  theme(panel.background = element_blank()) + theme(legend.position = "none") +
  ylab('average signal')  + xlab('SC sensory subregion') 
# theme(panel.background = element_rect(fill = "azure1"))

# ggplot(df_subjmean, aes(x=roi_task_subregion,y=mean_signal)) + 
#   # stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.9, geom="bar", size = 0.5, fill="tan2", colour='black')+
#   # stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.7, geom="bar", size = 0.5, fill="cadetblue2", colour='black')+
#   stat_summary(fun=mean,position=position_dodge(width=0.90), alpha = 0.7, geom="bar", size = 0.5, colour='black')+
#   stat_summary(fun.data=mean_se,position=position_dodge(width=0.90), geom="errorbar",width=0.2,  size = 0.5)+
#   geom_point(data = df_subjmean, aes(roi_task_subregion, mean_signal, group=subject, color=subject), alpha = 0.2, size = 1)+
#   geom_line(data = df_subjmean, aes(roi_task_subregion, mean_signal, group=subject, color=subject), alpha = 0.2, size = 0.5)+
#   # geom_violin(trim=TRUE, alpha = 0.1, size=0.02)+
#   # geom_hline(aes(yintercept=mean(mean_signal, na.rm=TRUE)),color="blue", linetype="dashed", size=0.3) +
#   theme(axis.line = element_line(colour = "black"),
#         axis.text=element_text(size=11),
#         axis.title=element_text(size=16),
#         plot.title = element_text(size=16,face="bold")) + 
#   ggtitle("Picture and Pain Subjects") + facet_wrap(~task)+
#   theme(strip.text.x = element_text(size = 18),strip.text.y = element_text(size = 18))+ 
#   theme(panel.background = element_blank()) + theme(legend.position = "none") +
#   ylab('average signal')

