# !/usr/bin/env python
# coding: utf-8

# python /Users/chendanlei/Google\ Drive/U01/AffPainTask_connectivity/analysis/univariate/level2/4.flameo_avoidance.py

#schedule the script to run at a certain time
# import datetime
# import time
# run_now=0
# while run_now == 0:
#     currentDT = datetime.datetime.now()
#     print (str(currentDT))
#     if int(currentDT.hour) > 3 and int(currentDT.minute) > 30:
#         run_now = 1
#         print("start to run the script at "+(str(currentDT)))
#     time.sleep(1200)

import nibabel as nib
import numpy as np
import nipype.pipeline.engine as pe
import nipype.interfaces.fsl as fsl
import os, glob

#### INPUT ####
proj_list = ['painAvd_CSUS1snegneu']
# proj_list = ['emoAvd_CSUSnegneu', 'painAvd_CSUS1snegneu']
# proj_list = ['emoAvd_CSUS_2']
# proj_list = ['painAvd_CSUS1s_2']
smooth_list = ['smoothed1.5mm_masked','smoothed3mm_masked']
# smooth_list = ['smoothed1.5mm_masked']
warping = 'SC_warp'
# warping = 'PAG_warp'
# flameo_run_mode = 'flame1'
flameo_run_mode = 'ols'

fixed_fx = pe.Workflow(name='fixedfx')

copemerge = pe.MapNode(
    interface=fsl.Merge(dimension='t'),
    iterfield=['in_files'],
    name='copemerge')

if flameo_run_mode == 'flame1':
    varcopemerge = pe.MapNode(
        interface=fsl.Merge(dimension='t'),
        iterfield=['in_files'],
        name='varcopemerge')

level2model = pe.Node(interface=fsl.L2Model(), name='l2model')

if flameo_run_mode == 'ols':
    flameo = pe.MapNode(
        interface=fsl.FLAMEO(run_mode='ols'),
        name='flameo',
        iterfield=['cope_file'])
    fixed_fx.connect([
        (copemerge, flameo, [('merged_file', 'cope_file')]),
        (level2model, flameo, [('design_mat', 'design_file'),
                               ('design_con', 't_con_file'),
                               ('design_grp', 'cov_split_file')]),
    ])
elif flameo_run_mode == 'flame1':
    flameo = pe.MapNode(
        interface=fsl.FLAMEO(run_mode='flame1'),
        name='flameo',
        iterfield=['cope_file', 'var_cope_file'])
    fixed_fx.connect([
        (copemerge, flameo, [('merged_file', 'cope_file')]),
        (varcopemerge, flameo, [('merged_file', 'var_cope_file')]),
        (level2model, flameo, [('design_mat', 'design_file'),
                               ('design_con', 't_con_file'),
                               ('design_grp', 'cov_split_file')]),
    ])

def run_flameo(con, work_dir, path_base, group_level, smooth_level):
    if not os.path.exists(work_dir):
        os.mkdir(work_dir)
    if not os.path.exists(os.path.join(work_dir, con)):
        os.mkdir(os.path.join(work_dir, con))
    fixed_fx.base_dir = os.path.join(work_dir, con)
    print('working on con:', con)
    if group_level:
        cope_path = [path_base + 'cope1.nii.gz']
        if flameo_run_mode == 'flame1':
            varcope_path = [path_base + 'varcope1.nii.gz']
    else:
        # cope_path = [path_base +'*_'+ con+'_*']
        cope_path = [path_base +'*_'+ con+'_*']
        if flameo_run_mode == 'flame1':
            varcope_path = [path_base + '*var' + con+'_*']
    # get files
    cope_list = glob.glob(cope_path[0])
    cope_list.sort()
    if smooth_level and not group_level:
        cope_list = [i for i in cope_list if smooth_level in i]
    print(cope_list)
    # cope_list=[i for i in cope_list if 'sub-037' not in i and 'sub-039' not in i and 'sub-053' not in i and 'sub-060' not in i and 'sub-066' not in i and 'sub-119' not in i]
    if flameo_run_mode == 'flame1':
        varcope_list = glob.glob(varcope_path[0])
        varcope_list.sort()
        if smooth_level and not group_level:
            varcope_list = [i for i in varcope_list if smooth_level in i]
        # varcope_list=[i for i in varcope_list if 'sub-037' not in i and 'sub-039' not in i and 'sub-053' not in i and 'sub-060' not in i and 'sub-066' not in i and 'sub-119' not in i]
    # build mask.
    print('mask')
    mask = np.mean(np.array([nib.load(f).get_fdata() for f in cope_list]), axis=0)
    print('mask finished')
    mask[mask != 0] = 1
    nib.save(nib.Nifti1Image(mask, nib.load(cope_list[0]).affine, nib.load(cope_list[0]).header),
     os.path.join(work_dir, 'mask'+con.split(".")[0]+'.nii.gz'))
    mask_file = os.path.join(work_dir, 'mask'+con.split(".")[0]+'.nii.gz')
    fixed_fx.inputs.flameo.mask_file = mask_file
    fixed_fx.inputs.copemerge.in_files = cope_list
    fixed_fx.inputs.l2model.num_copes = len(cope_list)
    print(work_dir)
    if flameo_run_mode == 'flame1':
        fixed_fx.inputs.varcopemerge.in_files = varcope_list
    print('before fx.run')
    try:
        fixed_fx.run()
    except:
        pass

####################################################################
####################################################################
#run level (before running group level)
####################################################################
####################################################################
group_level = False
data_dir_base = '/Users/chendanlei/Desktop/U01/level1_files/'
work_dir_base = '/Users/chendanlei/Desktop/U01/flameo_results/workdir/'
# data_dir_base = '/scratch/data/'
# work_dir_base = '/scratch/workdir/'

for proj in proj_list:
    for smooth in smooth_list:
        #get all subject names
        all_subj = glob.glob(data_dir_base+proj+'/'+warping+'/sub*')
        all_subj.sort()
        subj_list = [i[-14:-7] for i in all_subj]
        subj_list = list(set(subj_list))
        subj_list.sort()
        for subj in subj_list:
            #get all cope names from the first subject
            first_subj = all_subj[0]
            all_copes = glob.glob(first_subj+'/*_cope*')
            if smooth:
                all_copes = [i for i in all_copes if smooth in i]
            # con_list=[i.split("_")[-1] for i in all_copes]
            con_list=[i.split('_'+smooth)[0].split("_")[-1] for i in all_copes]
            con_list.sort()
            for con in con_list:
                print('---------------------------------')
                print('---------------------------------')
                print(proj)  
                print(smooth) 
                print(subj) 
                print(con) 
                print('---------------------------------')
                print('---------------------------------')
                work_dir = work_dir_base+proj+'_'+smooth+'_'+subj
                path_base = data_dir_base+proj+'/'+warping+'/'+subj+'*/'
                try:
                    run_flameo(con, work_dir, path_base, group_level, smooth)
                except:
                    pass
                    print('################################################################')
                    print('################################################################')
                    print('################################################################')
                    print('check here')
                    print('################################################################')
                    print('################################################################')
                    print('################################################################')

####################################################################
####################################################################
#group level (after running run level)
####################################################################
####################################################################
#set up new base directory to run level copes
group_level = True
data_dir_base = '/Users/chendanlei/Desktop/U01/flameo_results/workdir/'
work_dir_base = '/Users/chendanlei/Desktop/U01/flameo_results/workdir/'
# data_dir_base = '/scratch/workdir/'
# work_dir_base = '/scratch/workdir/'

for proj in proj_list:
    
    for smooth in smooth_list:
        #get all subject names
        all_subj = glob.glob(data_dir_base+proj+'_'+smooth+'_sub*')
        all_subj.sort()
        #get all cope names from the first subject
        first_subj = all_subj[0]
        all_copes = glob.glob(first_subj+'/cope*')
        all_copes.sort()
        con_list=[i.split("/")[-1] for i in all_copes]
        # con_list=['cope5.nii', 'cope6.nii']

        for con in con_list:
            print('************************************************')
            print('************************************************')  
            print(proj)  
            print(smooth) 
            print(con) 
            print('************************************************')
            print('************************************************')

            work_dir = work_dir_base+proj+'_'+smooth
            path_base = data_dir_base+proj+'_'+smooth+'_sub*'+'/'+con+'/fixedfx/flameo/mapflow/_flameo0/stats/'
            run_flameo(con, work_dir, path_base, group_level, smooth)

# ####################################################################
# ####################################################################
# #single run only 
# ####################################################################
# ####################################################################
# group_level = False
# data_dir_base = '/Users/chendanlei/Desktop/U01/level1_files/'
# work_dir_base = '/Users/chendanlei/Desktop/U01/flameo_results/workdir/'
# # data_dir_base = '/scratch/data/'
# # work_dir_base = '/scratch/workdir/'
# run_list = ['01', '05']
# # run_list = ['01','02','03','04','05']
# for proj in proj_list:
    
#     for smooth in smooth_list:

#         for run in run_list:
#             #get all subject names
#             all_subj = glob.glob(data_dir_base+proj+'/'+warping+'/sub*run-'+run)
#             all_subj.sort()
#             #get all cope names from the first subject
#             first_subj = all_subj[0]
#             all_copes = glob.glob(first_subj+'/*_cope*')
#             all_copes.sort()
#             if smooth:
#                 all_copes = [i for i in all_copes if smooth in i]
#             con_list=[i.split('_'+smooth)[0].split("_")[-1] for i in all_copes]

#             for con in con_list:
#                 print('************************************************')
#                 print('************************************************')  
#                 print(proj + 'run-'+run)  
#                 print(smooth) 
#                 print(con) 
#                 print('************************************************')
#                 print('************************************************')
                
#                 work_dir = work_dir_base+proj+'_'+smooth+'_run-'+run
#                 path_base = data_dir_base+proj+'/'+warping+'/'+'sub*_run-'+run+'/'
#                 try:
#                     run_flameo(con, work_dir, path_base, group_level, smooth)
#                 except:
#                     pass
#                     print('################################################################')
#                     print('################################################################')
#                     print('################################################################')
#                     print('check here')
#                     print('################################################################')
#                     print('################################################################')
#                     print('################################################################')




