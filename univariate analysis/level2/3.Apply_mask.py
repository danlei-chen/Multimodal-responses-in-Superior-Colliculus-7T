# python /Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/level2/3.Apply_mask.py

# #schedule the script to run at a certain time
# import datetime
# import time
# run_now=0
# while run_now == 0:
#     currentDT = datetime.datetime.now()
#     print (str(currentDT))
#     if int(currentDT.hour) > 2 and int(currentDT.minute) > 30:
#         run_now = 1
#         print("start to run the script at "+(str(currentDT)))
#     time.sleep(600)

import nibabel as nib
import numpy as np
import nipype.pipeline.engine as pe
import nipype.interfaces.fsl as fsl
import os, glob
import glob
from nilearn.image import resample_img

####################################################################
####################################################################
#apply mask to level 1 copes OR level 2 (run level) copes before level 3 (group/subj level)

proj_list = ['emoTest_CSUSPEnegUSPEpos']
# proj_list = ['emoAvd_CSUSnegneu', 'painAvd_CSUS1snegneu']
# proj_list = ['emoAvd_CSUS_2']
# proj_list = ['painAvd_CSUS1s_2']
# smooth_mm=3
# smooth_mm_list=['smoothed3mm', 'smoothed1.5mm']
smooth_mm_list=['smoothed3mm']
warping = 'SC_warp'
# warping = 'PAG_warp'

for proj in proj_list:

    for smooth_mm in smooth_mm_list:

        #### INPUT ####
        # data_dir = '/Users/chendanlei/Desktop/U01/flameo_results/output/*Avd_CSUSExp_SC_warp/*/*zstat1*clstr200*'
        data_dir = '/Users/chendanlei/Desktop/U01/level1_files/'+proj+'/'+warping+'/sub-*/*_'+smooth_mm+'.nii.gz'
        # data_dir = '/Users/chendanlei/Desktop/U01/unrollPAG_output/*/PAG_15cat*.nii.gz'
        # data_dir = '/Users/chendanlei/Google Drive/fMRI/atlas/MNI/mni_icbm152_nlin_sym_09a_nifti/mni_icbm152_nlin_sym_09a/mni_icbm152_t1_tal_nlin_sym_09a.nii'
        mask_dir = '/Volumes/GoogleDrive/My Drive/fMRI/atlas/MNI/mni_icbm152_nlin_sym_09a_nifti/mni_icbm152_nlin_sym_09a/mni_icbm152_t1_tal_nlin_sym_09a_mask.nii'
        # mask_dir = '/Users/chendanlei/Google Drive/fMRI/atlas/MNI/mni_icbm152_nlin_asym_09a_nifti/mni_icbm152_t1_tal_nlin_asym_09b_hires.nii'
        # mask_dir = '/usr/local/fsl/data/standard/MNI152_T1_1mm_brain_mask.nii.gz'

        def apply_mask(mask_dir, cope_dir, interpolation):
            mask_data = nib.load(mask_dir)
            cope_data = nib.load(cope_dir)
            cope_img_resampled = resample_img(cope_data,
                target_affine=mask_data.affine,
                target_shape=mask_data.shape[0:3],
                interpolation=interpolation).get_fdata()
            #change 4d file to 3d
            if cope_data.get_fdata().ndim != 3:
                print('**********************************************')
                print('**********************************************')
                cope_img = cope_data.get_fdata()[:,:,:,0]
            cope_img_resampled[mask_data.get_fdata()==0]=0
            masked_cope = nib.Nifti1Image(cope_img_resampled, mask_data.affine, mask_data.header)
            return masked_cope

        all_files = glob.glob(data_dir)
        all_files.sort()
        for file_dir in all_files:
            # if 'masked' not in file_dir:
            #resample mask_img to cope_img
            print(file_dir)
            print('resample mask')
            interpolation='nearest'
            masked_file = apply_mask(mask_dir, file_dir, interpolation)
            print('save masked image')
            new_name = file_dir.split(".nii")[-2] + '_masked.nii.gz'
            nib.save(masked_file, new_name)


# #resampling only
# data_dir = '/Users/chendanlei/Desktop/U01/ROI/subject_SC_mask/warped_files/SC_combined_Wager_atlas_edited__PROB50thesh_masked.nii.gz'
# mask_dir = '/Users/chendanlei/Desktop/U01/flameo_results/output/emoAvd_CSUSnegneu_smoothed3mm_masked/2USneg/2USneg_zstat1_fdr1.64-3.42_SC_combined_emoPain_50thesh.nii.gz'
# data_dir = '/Users/chendanlei/Desktop/U01/level1_files/emoAvd_CSUSnegneu/SC_warp/sub-014_run-01/*nii'
# mask_dir = '/Users/chendanlei/Desktop/U01/level1_files/emoAvd_CSUSnegneu/PAG_warp/sub-014_run-01/wdata_sub-014_run-01_cope1.nii.gz'
# def apply_mask(mask_dir, cope_dir, interpolation):
#     mask_data = nib.load(mask_dir)
#     cope_data = nib.load(cope_dir)
#     cope_data_resampled = resample_img(cope_data,
#         target_affine=mask_data.affine,
#         target_shape=mask_data.shape[0:3],
#         interpolation=interpolation)
#     return cope_data_resampled

# all_files = glob.glob(data_dir)
# all_files.sort()
# for file_dir in all_files:
#     #resample mask_img to cope_img
#     print(file_dir)
#     print('resample mask')
#     interpolation='nearest'
#     masked_file = apply_mask(mask_dir, file_dir, interpolation)
#     print('save masked image')
#     new_name = file_dir.split(".nii")[-2] + '_resammpled.nii.gz'
#     nib.save(masked_file, new_name)






# mask_dir = '/Users/chendanlei/Desktop/MNI152_T1_1mm_brain_corticalOnly.nii.gz'
# data_dir = '/usr/local/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz'

# mask_data = nib.load(mask_dir)
# cope_data = nib.load(data_dir)
# mask_img_resampled = resample_img(mask_data,
#     target_affine=cope_data.affine,
#     target_shape=cope_data.shape[0:3],
#     interpolation='nearest').get_fdata()
# #change 4d file to 3d
# cope_img = cope_data.get_fdata()
# if cope_img.ndim != 3:
#     print('**********************************************')
#     print('**********************************************')
#     cope_img = cope_img[:,:,:,0]
    
# cope_img[mask_img_resampled!=0]=0
# masked_cope = nib.Nifti1Image(cope_img, cope_data.affine, cope_data.header)
# nib.save(masked_cope, '/Users/chendanlei/Desktop/MNI152_T1_1mm_brain_subcorticalOnly.nii.gz')

