#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Oct  3 21:27:04 2020

@author: chendanlei
"""

import pandas as pd
import nibabel as nib
import numpy as np
import nipype.pipeline.engine as pe
import nipype.interfaces.fsl as fsl
import os
import glob
from nilearn.image import resample_img
from nilearn import plotting
from nilearn.image import mean_img
from nilearn.input_data import NiftiMasker
import matplotlib.pyplot as plt
import statistics 
from datetime import date
import math
from nilearn.image import concat_imgs, mean_img
from nilearn.decoding import Decoder

######
proj1 = os.environ.get("PROJNAME1")
proj2= os.environ.get("PROJNAME2")
topic = os.environ.get("topic")
task1Label = os.environ.get("task1Label")
task2Label = os.environ.get("task2Label")
base_dir='/scratch/'
mask_filename= glob.glob(base_dir+'roi/Template_6_resampled_25thresh_bin.nii.gz')[0]
output_dir = '/scratch/output/'
task1_files = glob.glob('/scratch/data/'+proj1+'/SC_warp/2_USneg_cope/warped_files/*cope2.nii.gz')
task1_files = task1_files + glob.glob('/scratch/data/'+proj1+'/SC_warp/2_USneg_cope/warped_files/*cope3.nii.gz')
task2_files = glob.glob('/scratch/data/'+proj2+'/SC_warp/2_USneg_onset_cope/warped_files/*cope2.nii.gz')
task2_files = task2_files + glob.glob('/scratch/data/'+proj2+'/SC_warp/2_USneg_onset_cope/warped_files/*cope3.nii.gz')
# proj1 = "emoAvd_CSUSnegneu"
# proj2= "painAvd_CSUS1snegneu"
# topic = "emoPain_neg_SVMtaskCLF_SC"
# task1Label = 'visual'
# task2Label = 'somatosensory'
# base_dir='/Users/chendanlei/Desktop/'
# mask_filename= glob.glob('/Users/chendanlei/Desktop/U01/ROI/subject_SC_mask/subject_SC_mask/emoAvd/avg_template/Template_6_resampled_25thresh_bin.nii.gz')[0]
# output_dir = '/Users/chendanlei/Google Drive/U01/AffPainTask_connectivity/analysis/MVPA/'+topic+'/'
# task1_files = glob.glob('/Users/chendanlei/Desktop/U01/level1_files/'+proj1+'/SC_warp/'+'*'+'/*cope2.nii.gz')
# task1_files = task1_files + glob.glob('/Users/chendanlei/Desktop/U01/level1_files/'+proj1+'/SC_warp/'+'*'+'/*cope3.nii.gz')
# task2_files = glob.glob('/Users/chendanlei/Desktop/U01/level1_files/'+proj2+'/SC_warp/'+'*'+'/*cope2.nii.gz')
# task2_files = task2_files + glob.glob('/Users/chendanlei/Desktop/U01/level1_files/'+proj2+'/SC_warp/'+'*'+'/*cope3.nii.gz')
######
fold_num_list=[80,10,4]
output_df= pd.DataFrame(columns = [str(i)+' folds' for i in fold_num_list])#two columns for k fold and two for leave one out
# feature_selection = False
# if feature_selection:
#     feature_selection_condition = ['Q1', 'Q4']
    
output_event_name = output_dir+topic+'_MVPA_event'
output_name = output_dir+topic+'_MVPA_classification'
print('*************************************************')
print('*************************************************')
print(topic)
print('*************************************************')
print('*************************************************')

# # read previous files and leave out masks that are already processed
# roi_done = 'None'
# try:
#     old_data = pd.read_table(glob.glob(output_dir+'*MVPA_classification_2020-10-*.tsv')[-1], sep='\t')
#     roi_done = old_data['roi'].tolist()
#     print('ROI done already')
#     print(roi_done)
# except:
#     print('no privious file')

#loop through all mask input
print('-----------------------------------------------')
print('-----------------------------------------------')
print(mask_filename)
print('-----------------------------------------------')
print('-----------------------------------------------')


task1_files.sort()
task2_files.sort()
all_files = task1_files+task2_files
concat_img = concat_imgs(all_files)
event_files = pd.DataFrame(np.array([np.concatenate([np.repeat(task1Label,len(task1_files)), np.repeat(task2Label,len(task2_files))]), 
                           ['run-'+i.split('/')[-1].split('run-')[-1].split('_cope')[0] for i in all_files], 
                           [i.split('/')[-1].split('wdata_')[-1].split('_run')[0] for i in all_files]]).T, 
                         columns=['labels','run', 'subject'])
#apply mask on combined image
# np.sum(nib.load(mask_filename).get_fdata())
masker = NiftiMasker(mask_img=mask_filename, standardize=False)
concat_img_masked = masker.fit_transform(concat_img)

print('masked combined image shape:')
print(concat_img_masked.shape)
# x=masker.inverse_transform(combined_data_masked)
# nib.save(x, combined_data_file_name)
print('event file shape:')
print(event_files.shape)
condition = event_files['labels']
session = event_files['subject']
event_files.to_csv((output_event_name+'.tsv'),index=True,sep='\t')

# #feature selection - restrict the analysis to certain conditions
# if feature_selection:
#     condition_mask = combined_event['labels'].isin(feature_selection_condition)
#     combined_data_masked = combined_data_masked[np.array(condition_mask)]
#     print(combined_data_masked.shape)

#########different methods of prediction########
# k-fold loop
from sklearn.svm import SVC
svc = SVC(kernel='linear')

# from sklearn.model_selection import KFold
# cv = KFold(n_splits=fold_num)
# # The "cv" object's split method can now accept data and create a
# # generator which can yield the splits.
# fold_predict = []
# for train, test in cv.split(X=combined_data_masked):
#     condition_masked = condition.values[train]
#     svc.fit(combined_data_masked[train], condition_masked, groups=session_label)
#     prediction = svc.predict(combined_data_masked[test])
#     fold_predict.append((prediction == condition.values[test]).sum()/ float(len(condition.values[test])))
# print('*************************')
# print(str(fold_num)+' folds loop prediction')
# print(fold_predict)
# print('mean: '+ str(statistics.mean(fold_predict)))
# print('*************************')
# file.write('\n') 
# if statistics.mean(fold_predict)>0.5:
#     file.write('***********************************')
# file.write(str(fold_num)+' folds loop prediction'+'\n') 
# file.writelines("%s " % i for i in fold_predict)
# file.write('\nMEAN: '+ str(statistics.mean(fold_predict))+'\n')
# file.write('SE: '+ str(statistics.stdev(fold_predict)/math.sqrt(max(session_label)))+'\n')

# #similar k-fold method using packages skilearn 
# print('k-fold running')
# from sklearn.model_selection import KFold
# from sklearn.model_selection import cross_val_score
# for fold_num in fold_num_list:
#     cv = KFold(n_splits=fold_num)
#     cv_score = cross_val_score(svc, concat_img_masked, condition, cv=cv, groups=session)
#     # print('*************************')
#     # print(str(fold_num)+' folds prediction:')
#     # print(cv_score)
#     # print('mean: '+ str(statistics.mean(cv_score)))
#     # print('*************************')
#     k_mean = statistics.mean(cv_score)
#     k_se = statistics.stdev(cv_score)/math.sqrt(len(np.unique(session)))

#similar k-fold method using packages nilearn decoder 
print('k-fold running')
from sklearn.model_selection import KFold
for fold_num in fold_num_list:
    cv = KFold(n_splits=fold_num)
    decoder = Decoder(estimator='svc', mask=mask_filename, standardize=True,
                  screening_percentile=5, scoring='accuracy', cv=cv)
    decoder.fit(concat_img, condition, groups=session)
    print(decoder.cv_scores_['visual'])
    print(decoder.cv_scores_['somatosensory'])
    # #dummy classifier to compare with
    # dummy_classifier = DummyClassifier()
    # dummy_scores = cross_val_score(dummy_classifier,concat_img_masked, condition, cv=cv,groups=session, scoring="accuracy",)
    
    output_df= pd.DataFrame(columns = [str(fold_num)+' folds'])#two columns for k fold and two for leave one out
    output_df[str(fold_num)+' folds'] = decoder.cv_scores_['visual']
    output_df.to_csv((output_name+'_'+str(fold_num)+'folds.tsv'),index=True,sep='\t')
    
    weight_img = decoder.coef_img_['visual']
    nib.save(weight_img, output_dir+'visual_weights_'+topic+'_'+str(fold_num)+'folds.nii.gz')
    weight_img = decoder.coef_img_['somatosensory']
    nib.save(weight_img, output_dir+'somatosensory_weights_'+topic+'_'+str(fold_num)+'folds.nii.gz')
    # from nilearn.plotting import plot_stat_map, show
    # plot_stat_map(weight_img, title='SVM weights')
    # show()







# #leave one out
# print('leave-one-out running')
# from sklearn.model_selection import LeaveOneGroupOut
# from sklearn.model_selection import cross_val_score
# cv = LeaveOneGroupOut()
# cv_score = cross_val_score(svc, combined_data_masked, condition, cv=cv, groups=session_label,)
# # print('*************************')
# # print('leave one out prediction:')
# # print(cv_score)
# # print('mean: '+ str(statistics.mean(cv_score)))
# # print('*************************')
# file.write('\n') 
# if statistics.mean(cv_score)>0.5:
#     file.write('***********************************')
# file.write('leave one out prediction'+'\n') 
# file.writelines("%s " % i for i in cv_score)
# loo_mean = statistics.mean(cv_score)
# file.write('\nMEAN: '+ str(loo_mean)+'\n')
# loo_se = statistics.stdev(cv_score)/math.sqrt(max(session_label))
# file.write('SE: '+ str(loo_se)+'\n')

# output_df.loc[len(output_df)] = [mask_filename.split('/')[-1], k_mean, k_se, loo_mean, loo_se]







