#!/bin/tcsh
setenv PROJNAME1 emoAvd_CSUSnegneu
setenv PROJNAME2 painAvd_CSUS1snegneu
setenv topic emoPain_all_SVMtaskCLF_SC
setenv task1Label 'visual'
setenv task2Label 'somatosensory'

setenv SCroi /autofs/cluster/iaslab_7T/FSMAP/FSMAP_data/BIDS_modeled/subject_SC_mask

setenv DATA /autofs/cluster/iaslab_7T/FSMAP/FSMAP_data
setenv SCRIPTPATH /autofs/cluster/iaslab/users/danlei/FSMAP/scripts
setenv IMAGE /autofs/cluster/iaslab/users/jtheriault/singularity_images/jtnipyutil/jtnipyutil-2019-01-03-4cecb89cb1d9.simg
setenv SINGULARITY /usr/bin/singularity
setenv OUTPUT /autofs/cluster/iaslab2/FSMAP/FSMAP_data/BIDS_modeled/emoPain_MVPA_results
mkdir -p /scratch/$USER/$topic/wrkdir/
mkdir -p /scratch/$USER/$topic/output/

#  #get this list from local file directory without subjects with high vif and no prediction score
#  set SUBJ_LIST = (sub-018_run-01 sub-020_run-03 sub-026_run-05 sub-041_run-02 sub-049_run-04 sub-058_run-01 sub-062_run-03 sub-065_run-05 sub-072_run-02 sub-082_run-04 sub-088_run-01 sub-091_run-03 sub-106_run-05 sub-122_run-02 sub-132_run-04 sub-018_run-02 sub-020_run-04 sub-031_run-01 sub-041_run-03 sub-049_run-05 sub-058_run-02 sub-062_run-04 sub-067_run-01 sub-072_run-03 sub-082_run-05 sub-088_run-02 sub-091_run-04 sub-113_run-01 sub-122_run-03 sub-132_run-05 sub-018_run-03 sub-020_run-05 sub-031_run-02 sub-041_run-04 sub-055_run-01 sub-058_run-03 sub-062_run-05 sub-067_run-02 sub-072_run-04 sub-084_run-01 sub-088_run-03 sub-091_run-05 sub-113_run-02 sub-122_run-04 sub-134_run-01 sub-018_run-04 sub-025_run-01 sub-031_run-03 sub-041_run-05 sub-055_run-02 sub-058_run-04 sub-064_run-01 sub-067_run-03 sub-072_run-05 sub-084_run-02 sub-088_run-04 sub-103_run-01 sub-113_run-03 sub-122_run-05 sub-134_run-02 sub-018_run-05 sub-025_run-02 sub-031_run-04 sub-048_run-01 sub-055_run-03 sub-058_run-05 sub-064_run-02 sub-067_run-04 sub-080_run-01 sub-084_run-03 sub-088_run-05 sub-103_run-02 sub-113_run-04 sub-127_run-01 sub-134_run-03 sub-019_run-01 sub-025_run-03 sub-031_run-05 sub-048_run-02 sub-055_run-04 sub-059_run-01 sub-064_run-03 sub-067_run-05 sub-080_run-02 sub-084_run-04 sub-090_run-01 sub-103_run-03 sub-113_run-05 sub-127_run-02 sub-134_run-04 sub-019_run-02 sub-025_run-04 sub-032_run-01 sub-048_run-03 sub-055_run-05 sub-059_run-02 sub-064_run-04 sub-070_run-01 sub-080_run-03 sub-084_run-05 sub-090_run-02 sub-103_run-04 sub-120_run-01 sub-127_run-03 sub-134_run-05 sub-019_run-03 sub-025_run-05 sub-032_run-02 sub-048_run-04 sub-056_run-01 sub-059_run-03 sub-064_run-05 sub-070_run-02 sub-080_run-04 sub-085_run-01 sub-090_run-03 sub-103_run-05 sub-120_run-02 sub-127_run-04 sub-136_run-01 sub-019_run-04 sub-026_run-01 sub-032_run-03 sub-048_run-05 sub-056_run-02 sub-059_run-04 sub-065_run-01 sub-070_run-03 sub-080_run-05 sub-085_run-02 sub-090_run-04 sub-106_run-01 sub-120_run-03 sub-127_run-05 sub-136_run-02 sub-019_run-05 sub-026_run-02 sub-032_run-04 sub-049_run-01 sub-056_run-03 sub-059_run-05 sub-065_run-02 sub-070_run-04 sub-082_run-01 sub-085_run-03 sub-090_run-05 sub-106_run-02 sub-120_run-04 sub-132_run-01 sub-136_run-03 sub-020_run-01 sub-026_run-03 sub-032_run-05 sub-049_run-02 sub-056_run-04 sub-062_run-01 sub-065_run-03 sub-070_run-05 sub-082_run-02 sub-085_run-04 sub-091_run-01 sub-106_run-03 sub-120_run-05 sub-132_run-02 sub-136_run-04 sub-020_run-02 sub-026_run-04 sub-041_run-01 sub-049_run-03 sub-056_run-05 sub-062_run-02 sub-065_run-04 sub-072_run-01 sub-082_run-03 sub-085_run-05 sub-091_run-02 sub-106_run-04 sub-122_run-01 sub-132_run-03 sub-136_run-05)
 
#  foreach SUBJ ($SUBJ_LIST)
#  	echo $SUBJ
#  	rsync -ra $DATA/BIDS_modeled/${PROJNAME}/PAG_warp/${cope1_1}*_cope/warped_files/*${SUBJ}*.nii /scratch/$USER/$PROJNAME/data/${SUBJ}/
#  	rsync -ra $DATA/BIDS_modeled/${PROJNAME}/PAG_warp/${cope1_2}*_cope/warped_files/*${SUBJ}*.nii /scratch/$USER/$PROJNAME/data/${SUBJ}/
#  	rsync -ra $DATA/BIDS_modeled/${PROJNAME}/PAG_warp/${cope2_1}*_cope/warped_files/*${SUBJ}*.nii /scratch/$USER/$PROJNAME/data/${SUBJ}/
#  	rsync -ra $DATA/BIDS_modeled/${PROJNAME}/PAG_warp/${cope2_2}*_cope/warped_files/*${SUBJ}*.nii /scratch/$USER/$PROJNAME/data/${SUBJ}/
#  end
#  	# if (! -f /scratch/$USER/$PROJNAME/data/${SUBJ}/*${SUBJ}*.nii) then
#  	# 	echo "removing dir"
#  	# 	rm -r /scratch/$USER/$PROJNAME/data/${SUBJ}/
#  	# endif
 
#  # rsync -ra ${PAGroi}/* /scratch/$USER/$PROJNAME/roi/
#  # rsync -ra ${WAGERroiBRSTEM}/* /scratch/$USER/$PROJNAME/roi/
#  # rsync -ra ${WAGERroiSBCTX}/* /scratch/$USER/$PROJNAME/roi/
#  # rsync -ra ${WAGERroiCRBLM}/* /scratch/$USER/$PROJNAME/roi/
#  rsync -ra ${WAGERroiCTX1}/* /scratch/$USER/$PROJNAME/roi/
#  # rsync -ra ${WAGERroiCTX2}/* /scratch/$USER/$PROJNAME/roi/
#  # rsync -ra ${WAGERroiCTX3}/* /scratch/$USER/$PROJNAME/roi/
 
# rsync -ra ${OUTPUT}/* /scratch/$USER/$PROJNAME/output/

rsync $SCRIPTPATH/model/$topic/{SVM_classification.py,SVM_classification_startup.sh} /scratch/$USER/$topic/wrkdir/
chmod +x /scratch/$USER/$topic/wrkdir/SVM_classification_startup.sh
cd /scratch/$USER

$SINGULARITY exec  \
--bind "$DATA/BIDS_modeled:/scratch/data" \
--bind "$SCroi/emoAvd/avg_template:/scratch/roi" \
--bind "/scratch/$USER/$topic/wrkdir:/scratch/wrkdir" \
--bind "/scratch/$USER/$topic/output:/scratch/output" \
$IMAGE\
/scratch/wrkdir/SVM_classification_startup.sh

mkdir -p $OUTPUT
mkdir -p $OUTPUT/$topic
rsync -r /scratch/$USER/$topic/output/ ${OUTPUT}/$topic
rm -r /scratch/$USER/$PROJNAME/
exit

# python /Users/chendanlei/Google\ Drive/U01/EmotionAvoidanceTask/BIDS_model_setup/MVPAscripts/temp_pred14.py