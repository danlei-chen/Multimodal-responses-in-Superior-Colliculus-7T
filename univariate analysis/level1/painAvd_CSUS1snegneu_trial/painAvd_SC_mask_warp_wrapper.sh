#!/bin/tcsh
setenv DATA /autofs/cluster/iaslab2/FSMAP/FSMAP_data
setenv SCRIPTPATH /autofs/cluster/iaslab/users/danlei/FSMAP/scripts
setenv IMAGE /autofs/cluster/iaslab/users/jtheriault/singularity_images/jtnipyutil/jtnipyutil-2019-01-03-4cecb89cb1d9.simg
setenv PROJNAME painAvd_CSUS1snegneu_trial
setenv SINGULARITY /usr/bin/singularity
setenv OUTPUT $DATA/BIDS_modeled/$PROJNAME/SC_warp

mkdir -p /scratch/$USER/$PROJNAME/wrkdir/
mkdir -p /scratch/$USER/$PROJNAME/output/
mkdir -p /scratch/$USER/$PROJNAME/data
mkdir -p $OUTPUT

# #emoAvd and painAvd
# # set SUBJ_LIST = (sub-014 sub-016 sub-028 sub-034 sub-037 sub-039 sub-045 sub-050 sub-053 sub-054 sub-057 sub-060 sub-061 sub-068 sub-073 sub-074 sub-081 sub-083 sub-086 sub-087 sub-092 sub-094 sub-099 sub-100 sub-102 sub-104 sub-105 sub-111 sub-112 sub-114 sub-117 sub-118 sub-119 sub-124 sub-128 sub-131 sub-135)
# # sub-014 sub-016 sub-028 sub-034 sub-037 sub-039 sub-045 sub-050 sub-053 sub-054 sub-057 sub-060 sub-061 sub-068 sub-073 sub-074 sub-081 sub-083 sub-086 sub-087 sub-092 sub-094 sub-099 sub-100 sub-102 sub-104 sub-105 sub-111 sub-112 sub-114 sub-117 sub-118 sub-119 sub-124 sub-128 sub-131 sub-135)
# # sub-018 sub-019 sub-020 sub-025 sub-026 sub-031 sub-032 sub-033 sub-041 sub-048 sub-049 sub-055 sub-056 sub-058 sub-059 sub-062 sub-064 sub-065 sub-067 sub-070 sub-072 sub-080 sub-082 sub-084 sub-085 sub-088 sub-090 sub-091 sub-103 sub-106 sub-113 sub-118 sub-120 sub-122 sub-127 sub-132 sub-134 sub-136)
# set SUBJ_LIST=(`ls $DATA/BIDS_modeled/${PROJNAME}/nosmooth/`)
# set SUBJ_LIST = `echo $SUBJ_LIST | fmt -1 | sort -n`
# foreach SUBJRUN ($SUBJ_LIST)
# 	set SUBJ=`echo "$SUBJRUN" | awk '{print substr($1,1,7)}'`
# 	echo $SUBJ
# 	set RUN=`echo "$SUBJRUN" | awk '{print substr($1,23,24)}'`
# 	echo $RUN
# 	mkdir /scratch/$USER/$PROJNAME/data/${SUBJ}_run-${RUN}/
# 	rsync -ra $DATA/BIDS_modeled/${PROJNAME}/nosmooth/${SUBJ}*run-${RUN}/model/_${SUBJ}*run-${RUN}/_modelestimate0/cope*.nii.gz /scratch/$USER/$PROJNAME/data/${SUBJ}_run-${RUN}/
# end
# 	# rsync -ra $DATA/BIDS_modeled/${PROJNAME}/nosmooth/$SUBJ*run-${RUN}/model/_${SUBJ}*run-${RUN}/_modelestimate0/sigmasquareds.nii.gz /scratch/$USER/$PROJNAME/data/${SUBJ}_run-${RUN}/
# 	# rsync -ra /autofs/cluster/iaslab/FSMAP/FSMAP_data/BIDS_fmriprep/fmriprep/ses-02/${SUBJ}/anat/${SUBJ}_T1w_space-MNI152NLin2009cAsym_class-GM_probtissue.nii.gz /scratch/$USER/$PROJNAME/data/${SUBJ}_run-${RUN}/
# 	# if (! -f /scratch/$USER/$PROJNAME/data/${SUBJ}_run-${RUN}/cope1.nii.gz) then
# 	# 	echo "removing dir"
# 	# 	rm -r /scratch/$USER/$PROJNAME/data/${SUBJ}_run-${RUN}/
# 	# endif

# set SUBJ_LIST=`ls /scratch/$USER/$PROJNAME/data/`
# # set SUBJ_LIST=`ls $DATA/BIDS_modeled/$PROJNAME/nosmooth`
# set SUBJ_LIST = `echo $SUBJ_LIST | fmt -1 | sort -n`
# setenv SUBJ_LIST "$SUBJ_LIST"
# echo $SUBJ_LIST

# # rsync -ra /autofs/cluster/iaslab_7T/FSMAP/FSMAP_data/BIDS_modeled/subject_SC_mask/emoAvd/SC_mask/*resampled* /scratch/$USER/$PROJNAME/wrkdir/SC_mask/
# # gunzip /scratch/$USER/$PROJNAME/wrkdir/SC_mask/*
# mkdir /scratch/$USER/$PROJNAME/wrkdir/dartel
# rsync -ra /autofs/cluster/iaslab_7T/FSMAP/FSMAP_data/BIDS_modeled/subject_SC_mask/emoAvd/dartel_flow/*_resample* /scratch/$USER/$PROJNAME/wrkdir/dartel_flow/
# gunzip /scratch/$USER/$PROJNAME/wrkdir/dartel_flow/*

# rsync -ra $SCRIPTPATH/model/search_region.nii /scratch/$USER/$PROJNAME/wrkdir/
rsync $SCRIPTPATH/model/$PROJNAME/{painAvd_SC_mask_warp_startup.sh,painAvd_SC_mask_warp.py} /scratch/$USER/$PROJNAME/wrkdir/
chmod a+rwx /scratch/$USER/$PROJNAME/wrkdir/painAvd_SC_mask_warp_startup.sh
cd /scratch/$USER

$SINGULARITY exec  \
--bind "$DATA/BIDS_modeled/$PROJNAME/nosmooth:/scratch/data" \
--bind "/autofs/cluster/iaslab_7T/FSMAP/FSMAP_data/BIDS_modeled/subject_SC_mask/painAvd/dartel_flow:/scratch/dartel_flow" \
--bind "/scratch/$USER/$PROJNAME/output:/scratch/output" \
--bind "/scratch/$USER/$PROJNAME/wrkdir:/scratch/wrkdir" \
$IMAGE\
/scratch/wrkdir/painAvd_SC_mask_warp_startup.sh

cd /scratch/$USER/$PROJNAME/output
gzip sub*/warped_files/w_*.nii
mkdir $OUTPUT
mkdir $OUTPUT/warped_files
rsync -r /scratch/$USER/$PROJNAME/output/sub*/warped_files/w_*.nii.gz $OUTPUT/warped_files/

cd /autofs/cluster/iaslab/users/danlei/FSMAP/scripts/model/
chmod -R a+rwx *

rm -r /scratch/$USER/$PROJNAME/
exit


# scp -r * /autofs/cluster/iaslab/users/danlei/test/
# scp -r dz609@door.nmr.mgh.harvard.edu:/autofs/cluster/iaslab/users/danlei/test /Users/chendanlei/Desktop/
