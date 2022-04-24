# python /Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/level2/5.poststats_FDR.py

# #schedule the script to run at a certain time
# import datetime
# import time
# run_now=0
# while run_now == 0:
#	 currentDT = datetime.datetime.now()
#	 print (str(currentDT))
#	 if int(currentDT.hour) > 7 and int(currentDT.minute) > 30:
#		 run_now = 1
#		 print("start to run the script at "+(str(currentDT)))
#	 time.sleep(600)

import os
import nibabel as nib
import numpy as np
import glob
from nilearn.glm import threshold_stats_img
from nilearn.image import resample_img
from scipy import stats

# vox_thresh = '1.65' #voxel threshold
# cluster_thresh = '0.05'
# cluster_size_thresh = '50' #cluster size threshold
# input_file = 'zstat1_smoothed3mm.nii.gz'

base_dir = '/Users/chendanlei/Desktop/U01/flameo_results/workdir/'
# projs = glob.glob(base_dir+'*')
# projs = [i.split('/')[-1] for i in projs]
# projs.sort()
# projs = [ i for i in projs if ".ipynb" not in i ]
# projs = [i for i in projs if '_' in i]
# projs = [i for i in projs if 'Avd_CSUS' in i]
# projs = ['emoAvd_CSUSnegneu_smoothed3mm_masked','emoAvd_CSUSnegneu_smoothed1.5mm_masked']
projs = ['emoTest_CSUSPEnegUSPEpos_smoothed3mm_masked']
# masks = ['/Users/chendanlei/Desktop/U01/ROI/subject_SC_mask/subject_SC_mask/emoAvd/avg_template/Template_6_resampled_25thresh_bin.nii.gz']
# masks = ['/Users/chendanlei/Google Drive/fMRI/atlas/MNI/mni_icbm152_nlin_sym_09a_nifti/mni_icbm152_nlin_sym_09a/mni_icbm152_t1_tal_nlin_sym_09a_mask.nii', '/Users/chendanlei/Desktop/U01/ROI/subject_SC_mask/subject_SC_mask/emoAvd/avg_template/Template_6_resampled_25thresh_bin.nii.gz','/Users/chendanlei/Google Drive/U01/AffPainTask_connectivity/roi/subcortical_mask.nii.gz']
masks = ['/Volumes/GoogleDrive/My Drive/fMRI/atlas/MNI/mni_icbm152_nlin_sym_09a_nifti/mni_icbm152_nlin_sym_09a/mni_icbm152_t1_tal_nlin_sym_09a_mask.nii', '/Users/chendanlei/Desktop/U01/ROI/subject_SC_mask/subject_SC_mask/painAvd/avg_template/Template_6_resampled_25thresh_bin.nii.gz','/Volumes/GoogleDrive/My Drive/U01/AffPainTask_connectivity/roi/subcortical_mask.nii.gz']
# pvalue='0.05'
# zvalue=[1.3,3]
cluster_size = 20
load_map = "tstat1"
# fdr_thresh = 1.688 #df=37: t=1.688 --> p=0.05
fdr_thresh = 1.69 #df=37: t=1.688 --> p=0.05

for proj in projs:
	print(proj)
	copes = glob.glob(base_dir+proj+'/*')
	copes = [i.split('/')[-1] for i in copes]
	copes = [ i for i in copes if '.nii.gz' not in i ]
	# copes.sort()
	copes=sorted(copes, key=lambda x: int(x.partition('cope')[2]))

	for cope_num,cope_name in enumerate(copes):
		print(cope_name)

		os.chdir(base_dir+proj+'/'+cope_name+'/fixedfx/flameo/mapflow/_flameo0/stats/')
		# #if the final file already exit, move on to the next one
		# if os.path.exists(os.path.join(os.getcwd(),'zstat1_thresh_mask.nii.gz')):
		# 	pass
	
		for mask in masks:
			print(mask)

			try:
				stat_map_img = nib.load(load_map+".nii.gz")
				stat_map_data = stat_map_img.get_fdata()
				######convert to p-map
# 				print('calculating p value...')
# 				df = nib.load('tdof_t1.nii.gz').get_fdata()[0,0,0]
# 				print(df)
# 				stat_map_data = stats.t.sf(abs(stat_map_data), df=df)
# 				stat_map_img = nib.Nifti1Image(stat_map_data, stat_map_img.affine, stat_map_img.header)
#                 # nib.save(stat_map_img,'/Users/chendanlei/Desktop/x.nii.gz')
                
				mask_img = nib.load(mask)
				mask_img = resample_img(mask_img,
						target_affine=stat_map_img.affine,
						target_shape=stat_map_img.shape[0:3],
						interpolation='nearest')
# 				stat_map_data[mask_data_resampled==0]=np.nan
# 				stat_map_img = nib.Nifti1Image(stat_map_data, stat_map_img.affine, stat_map_img.header)
				# stat_map_data[stat_map_data<zvalue[0]] = 0
				# stat_map_data[stat_map_data>zvalue[1]] = zvalue[1]
				# stat_map_thresh = nib.Nifti1Image(stat_map_data, stat_map_img.affine, stat_map_img.header)
				# nib.save(stat_map_thresh,"zstat1_"+str(zvalue[0])+'-'+str(zvalue[1])+'.nii.gz')
	
				#FDR adjusted zstats
				stat_map_img_fdr,threshold = threshold_stats_img(stat_map_img, cluster_threshold=0, threshold=fdr_thresh, height_control='fdr', mask_img=mask_img)
				print('FDR adjusted zstats threshold: '+str(threshold))
				fname = load_map+"_fdr"+str(fdr_thresh)+'-'+str(threshold)[0:4]+'_'+mask.split('/')[-1].split('.nii')[0]+'.nii.gz'
# 					fname = load_map+"_fdr"+str(fdr_thresh)+'-'+str(threshold)[0:4]+'.nii.gz'
				nib.save(stat_map_img_fdr,fname)
	
				#cluster adjusted based on FDR results above
				stat_map_img_fdr_clust,t = threshold_stats_img(stat_map_img_fdr, cluster_threshold=cluster_size, threshold=0, height_control=None, mask_img=mask_img)
				fname = load_map+"_fdr"+str(fdr_thresh)+'-'+str(threshold)[0:4]+'_clust'+str(cluster_size)+'_'+mask.split('/')[-1].split('.nii')[0]+'.nii.gz'
# 					fname = load_map+"_fdr"+str(fdr_thresh)+'-'+str(threshold)[0:4]+'_clust'+str(cluster_size)+'.nii.gz'
				nib.save(stat_map_img_fdr_clust,fname)
	
				# dof = nib.load('tdof_t1.nii.gz')
				# dof = dof.get_fdata()
				# dof = dof[np.where(dof!=0)][0]
				# os.system('ttologp -logpout logp1 varcope1.nii.gz cope1.nii.gz '+str(dof))
				# os.system('fslmaths logp1 -exp p1')
				# FDRthresh=os.popen('fdr -i p1 -m ../../../../../../mask'+cope_name+' -q '+pvalue).read()
				# print(FDRthresh)
				# FDRthresh=FDRthresh.split('\n')[1]
				# FDRthresh=str(1-float(FDRthresh))
				# if FDRthresh != '0':
				# 	os.system('fslmaths p1 -mul -1 -add 1 -thr '+FDRthresh+' -mas ../../../../../../mask'+cope_name+' thresh_1_minus_p1_'+pvalue)
	
			except:
				print("**************************************************")
				print("**************************************************")
				print("**************************************************")
				print("THERE IS A PROBLEM IN "+os.getcwd())
				print("**************************************************")
				print("**************************************************")
				print("**************************************************")
				pass

