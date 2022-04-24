# python /Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/level2/2.Apply_smoothing.py

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
from nilearn.image import resample_img
from nilearn.image import smooth_img
import os, glob

####################################################################
####################################################################
#apply smoothing to level 2 (run level) copes before level 3 (group/subj level)

#### INPUT ####
proj_list = ['emoTest_CSUSPEnegUSPEpos']
# proj_list = ['emoAvd_CSUSnegneu','painAvd_CSUS1snegneu']
# proj_list = ['emoAvd_CSUS_2']
# proj_list = ['painAvd_CSUS1s_2']
# smooth_list = ['5.0','1.5']
# smooth_list = ['PAG_warp']
smooth_list = ['SC_warp']
# smooth_mm_list = [3, 1.5]
smooth_mm_list = [3]
# level_data = 2
level_data = 1

data_dir_base = '/Users/chendanlei/Desktop/U01/'
# out_space_f = '/Users/chendanlei/Google Drive/fMRI/atlas/MNI/mni_icbm152_nlin_asym_09b_nifti/mni_icbm152_nlin_asym_09b/mni_icbm152_t1_tal_nlin_asym_09b_hires.nii'
# temp=['sub-018', 'sub-020', 'sub-026', 'sub-032', 'sub-055', 'sub-058', 'sub-062', 'sub-065', 'sub-072', 'sub-090','sub-019', 'sub-025', 'sub-031', 'sub-041', 'sub-056', 'sub-059', 'sub-064', 'sub-067', 'sub-080','sub-091']

def apply_smoothing(data_dir, smooth_mm):
    file_data = nib.load(data_dir)
    file_smooth = smooth_img(file_data,fwhm=smooth_mm)
    return file_smooth

# proj=proj_list[0]
# smooth=smooth_list[0]

for proj in proj_list:
    for smooth in smooth_list:
        for smooth_mm in smooth_mm_list:
            #get all subject names
            if level_data ==2:
                # all_subj = glob.glob(data_dir_base+'flameo_results/workdir/'+proj+'_'+smooth+'_sub*')
                # all_subj = glob.glob(data_dir_base+'flameo_results/output/'+proj+'_'+smooth)
                all_subj = glob.glob(data_dir_base+'flameo_results/workdir/'+proj+'_'+smooth)
            elif level_data == 1:
                all_subj = glob.glob(data_dir_base+'level1_files/'+proj+'/'+smooth+'/sub*')
            all_subj.sort()
            # all_subj=[i for i in all_subj if 'sub-018' and 'sub-019' and 'sub-059' not in i]
            # all_subj=[i for i in all_subj if i[-14:-7] in temp]
            for subj in all_subj:
                if level_data ==2:
                  all_copes = glob.glob(subj+'/cope*')
                  # all_copes = glob.glob(subj+'/*')
                  all_copes.sort()
                  con_list=[i.split("/")[-1] for i in all_copes]
                elif level_data == 1:
                   all_copes = glob.glob(subj+'/*cope*')
                   all_copes.sort()
                   con_list=[i.split('/')[-1] for i in all_copes]
                   con_list=[i for i in con_list if 'smoothed' not in i]
                   con_list=[i.split('_')[-1] for i in con_list]
                for con in con_list:
                    print('-----------------------')  
                    print(proj)  
                    print(smooth) 
                    print(subj.split('/')[-1]) 
                    print(con) 
                    try:
                      if level_data ==2:
                        # path_base = subj+'/'+con.split(".")[0]+'/fixedfx/flameo/mapflow/_flameo0/stats/'
                        path_base = subj+'/'+con+'/fixedfx/flameo/mapflow/_flameo0/stats/'
                        # path_base = subj+'/'+con+'/'
                        # cope_dir = path_base+con
                        cope_dir = glob.glob(path_base+'*zstat1.*')[0]
                      elif level_data == 1:
                        path_base = subj+'/'
                        cope_dir = glob.glob(path_base+'*_'+con)[0]
                      cope_smooth = apply_smoothing(cope_dir, smooth_mm)
                      new_name = cope_dir.split("/")[-1].split(".nii")[-2] + '_smoothed'+str(smooth_mm)+'mm.nii.gz'
                      nib.save(cope_smooth, os.path.join(path_base, new_name))
                    except:
                      print('********************************************')
                      print('******* warning, take a look here **********')
                      print('********************************************')



