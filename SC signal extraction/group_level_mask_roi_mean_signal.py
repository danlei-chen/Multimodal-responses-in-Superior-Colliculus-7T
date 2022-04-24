#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jun  5 21:25:00 2021

@author: chendanlei
"""
#python /Users/chendanlei/Google\ Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/subject_roi_mean_signal.py

import nibabel as nib
import numpy as np
import glob
from nilearn.glm import threshold_stats_img
from nilearn.image import resample_img
import pandas as pd 
import os

#subject level roi directory
data_dir = ['/Users/chendanlei/Desktop/U01/level1_files/emoAvd_CSUSnegneu/SC_warp/', '/Users/chendanlei/Desktop/U01/level1_files/painAvd_CSUS1snegneu/SC_warp/']
# data_dir = '/Users/chendanlei/Desktop/U01/level1_files/painAvd_CSUS1snegneu/SC_warp/'
roi_dir = ['/Users/chendanlei/Google Drive/U01/AffPainTask_connectivity/roi/group_level_sensory_mask/emo_2USneg_tstat1_fdr1.688-3.41_Template_6_resampled_25thresh_bin.nii.gz','/Users/chendanlei/Google Drive/U01/AffPainTask_connectivity/roi/group_level_sensory_mask/pain_2USneg_onset_tstat1_fdr1.69-3.62_Template_6_resampled_25thresh_bin.nii.gz']
roi_label = ['picture','pain']
# task = 'emo'
# roi_thresh = 0.25
output = '/Users/chendanlei/Google Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_sensory_group_mask_signal_3mm.csv'
# output = '/Users/chendanlei/Google Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_signal/SC_signal_pain_'+str(roi_thresh)+'_3mm.csv'
# output = '/Users/chendanlei/Google Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_mean_signal/PAG_mean_signal_emo.csv'
# output = '/Users/chendanlei/Google Drive/U01/AffPainTask_connectivity/analysis/univariate/SC_mean_signal/PAG_mean_signal_pain.csv'
file_format1 = 'cope2_smoothed3mm_masked.nii.gz'
template_file = '/Users/chendanlei/Google Drive/fMRI/atlas/MNI/mni_icbm152_nlin_asym_09b_nifti/mni_icbm152_nlin_asym_09b/mni_icbm152_t1_tal_nlin_asym_09b_hires.nii'

subj_list = [i.split('/')[-1] for i in glob.glob(data_dir[0]+'*')]+[i.split('/')[-1] for i in glob.glob(data_dir[1]+'*')]
task_list = ['emo3']*len(glob.glob(data_dir[0]+'*')) + ['pain3']*len(glob.glob(data_dir[1]+'*'))
task_list = [x for _,x in sorted(zip(subj_list,task_list))] #sort task_list based on subj_list
subj_list.sort()

df = pd.DataFrame(columns = ['subjID', 'subject','run','task','roi_name','roi_subregion','roi_vox_size','mean_signal','peak_signal'])
for s_n, s in enumerate(subj_list):
    print(s)
    
    subj = s[0:7]
    run = s[8:]
    task = task_list[s_n]
    
    ######## NEGATIVE COPE #######s
    #load contrast
    if task == 'emo3':
        file = glob.glob(data_dir[0]+s+'/*'+file_format1)[0]
    elif task == 'pain3':
        file = glob.glob(data_dir[1]+s+'/*'+file_format1)[0]
    
    for roi_n in range(len(roi_dir)):
    
        #load roi
        # roi_file = glob.glob(roi_dir+'/*SC*'+s+'*')[0]
        roi_file = glob.glob(roi_dir[roi_n])[0]
        
        #whole left roi
        roi_data = nib.load(roi_file).get_fdata()    
        # roi_data = resample_img(nib.load(roi_file),
        #     target_affine=file_img.affine,
        #     target_shape=file_img.shape[0:3],
        #     interpolation='nearest').get_fdata()    
        roi_data[roi_data!=0] = 1
        roi_data[roi_data!=1] = np.nan
        roi_size = len(roi_data[pd.notnull(roi_data)])
        #mask contrast file
        file_data = nib.load(file).get_fdata()
        file_data[np.isnan(roi_data)] = np.nan
        #get mean
        mean_signal = np.nanmean(file_data)
        #get peak
        max_signal = np.nanmax(file_data)
        #write to df
        df_row = pd.Series([s, subj, run, task, roi_label[roi_n], 'all', roi_size,mean_signal, max_signal], index = df.columns)
        df = df.append(df_row, ignore_index=True)
        
        #get left roi
        roi_data = nib.load(roi_file).get_fdata()    
        # roi_data = resample_img(nib.load(roi_file),
        #     target_affine=file_img.affine,
        #     target_shape=file_img.shape[0:3],
        #     interpolation='nearest').get_fdata()    
        roi_data[roi_data!=0] = 1
        roi_data[roi_data!=1] = np.nan
        roi_data[int(roi_data.shape[0]/2):,:,:] = np.nan #second half - left
        roi_size = len(roi_data[pd.notnull(roi_data)])
        #mask contrast file
        file_data = nib.load(file).get_fdata()
        file_data[np.isnan(roi_data)] = np.nan
        # test_img = nib.Nifti1Image(roi_data, nib.load(roi_file).affine, nib.load(roi_file).header)
        # nib.save(test_img, '/Users/chendanlei/Desktop/x.nii.gz')
        #get mean
        mean_signal = np.nanmean(file_data)
        #get peak
        max_signal = np.nanmax(file_data)
        #write to df
        df_row = pd.Series([s, subj, run, task, roi_label[roi_n], 'left', roi_size,mean_signal, max_signal], index = df.columns)
        df = df.append(df_row, ignore_index=True)
        
        #get right roi
        roi_data = nib.load(roi_file).get_fdata()    
        # roi_data = resample_img(nib.load(roi_file),
        #     target_affine=file_img.affine,
        #     target_shape=file_img.shape[0:3],
        #     interpolation='nearest').get_fdata()    
        roi_data[roi_data!=0] = 1
        roi_data[roi_data!=1] = np.nan
        roi_data[0:int(roi_data.shape[0]/2),:,:] = np.nan #second half - right
        roi_size = len(roi_data[pd.notnull(roi_data)])
        #mask contrast file
        file_data = nib.load(file).get_fdata()
        file_data[np.isnan(roi_data)] = np.nan
        #get mean
        mean_signal = np.nanmean(file_data)
        #get peak
        max_signal = np.nanmax(file_data)
        #write to df
        df_row = pd.Series([s, subj, run, task, roi_label[roi_n], 'right', roi_size,mean_signal, max_signal], index = df.columns)
        df = df.append(df_row, ignore_index=True)
        
        df.to_csv(output)
        
    
    