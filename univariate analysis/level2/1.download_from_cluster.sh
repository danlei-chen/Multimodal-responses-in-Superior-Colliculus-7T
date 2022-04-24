# to run a shell sciprt in bash:
# chmod +x /Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/level2/1.download_from_cluster.sh
# /Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/level2/1.download_from_cluster.sh

# echo "start sleep"
# # sleep 18000 #18000=5hrs
# sleep 39600 #18000=5hrs
# echo "end sleep"

# #################### download res4d data #####################
# MOVE_FROM=/autofs/cluster/iaslab2/FSMAP/FSMAP_data/BIDS_modeled
# MOVE_TO=/Users/chendanlei/Desktop/U01/level1_files
# PROJ=emoAvd_CSUSnegneu
# SMOOTH='nosmooth'

# echo "$PROJ"
# mkdir "${MOVE_TO}/${PROJ}"
# mkdir "${MOVE_TO}/${PROJ}/${SMOOTH}"

# FILES="$(ssh dz609@door.nmr.mgh.harvard.edu ls -Q /autofs/cluster/iaslab2/FSMAP/FSMAP_data/BIDS_modeled/${PROJ}/${SMOOTH}/)"
# # FILES=('sub-135_task-emo3_run-01' 'sub-131_task-emo3_run-01' 'sub-128_task-emo3_run-01')
# # echo "${FILES}"
# for SUBJ in $FILES
# do
# 	SUBJ="${SUBJ%\"}"
# 	SUBJ="${SUBJ#\"}"
# 	echo "${SUBJ}"
# 	# echo "${MOVE_TO}/${PROJ}/${SMOOTH}/${SUBJ}"
# 	mkdir "${MOVE_TO}/${PROJ}/${SMOOTH}/${SUBJ[@]}"

# 	# if [[ $SUBJ == *"run-01"* ]]; then
# 	# 	# rsync -ra --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${PROJ}/${SMOOTH}/${SUBJ}/design/fwhm_${SMOOTH}_${SUBJ}/_modelgen0/* ${MOVE_TO}/${PROJ}/${SMOOTH}/${SUBJ}/
# 	# 	rsync -ra --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${PROJ}/${SMOOTH}/${SUBJ}/model/*/*/res4d.nii.gz ${MOVE_TO}/${PROJ}/${SMOOTH}/${SUBJ}/
# 	# 	rsync -ra --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${PROJ}/${SMOOTH}/${SUBJ}/model/*/*/res4d.nii.gz ${MOVE_TO}/${PROJ}/${SMOOTH}/${SUBJ}/
# 	# fi
# 	rsync -ra --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${PROJ}/${SMOOTH}/${SUBJ}/model/*/_modelestimate0/cope2.nii.gz ${MOVE_TO}/${PROJ}/${SMOOTH}/${SUBJ}/
# 	rsync -ra --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${PROJ}/${SMOOTH}/${SUBJ}/model/*/_modelestimate0/cope3.nii.gz ${MOVE_TO}/${PROJ}/${SMOOTH}/${SUBJ}/

# done

##################### download confound files #####################
# MOVE_FROM=/autofs/cluster/iaslab/FSMAP/FSMAP_data/BIDS_fmriprep/fmriprep/ses-02
# MOVE_TO=/Users/chendanlei/Desktop/U01/ses-02_confound_files

# mkdir "${MOVE_TO}"

# FILES=($(ssh dz609@door.nmr.mgh.harvard.edu ls -Q ${MOVE_FROM}))
# # FILES=('sub-135_task-emo3_run-01' 'sub-131_task-emo3_run-01' 'sub-128_task-emo3_run-01')
# # echo "${FILES}"
# for SUBJ in ${FILES}
# do
# 	SUBJ="${SUBJ%\"}"
# 	SUBJ="${SUBJ#\"}"

# 	#check substring
# 	if [[ "$SUBJ" != *"html" ]]; then
# 		echo $SUBJ
# 		mkdir "${MOVE_TO}/${SUBJ}"
# 		rsync -ra "dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${SUBJ}/func/*_bold_confounds.tsv" "${MOVE_TO}/${SUBJ}"
# 	fi
# done


##################### PAG template and warping files #####################
MOVE_FROM=/autofs/cluster/iaslab2/FSMAP/FSMAP_data/BIDS_modeled
MOVE_TO=/Users/chendanlei/Desktop/U01/level1_files
PROJ_LIST=("emoAvd_CSUSnegneu" "painAvd_CSUS1snegneu")
PROJ_LIST=("emoTest_CSUSPEnegUSPEpos")

# SUBJ_LIST="$(ssh dz609@door.nmr.mgh.harvard.edu ls -Q "/autofs/cluster/iaslab2/FSMAP/FSMAP_data/BIDS_modeled/${PROJ}/PAG_warp/1*cope/warped_files/*sub*.nii")"
# SUBJ_LIST="$(ssh dz609@door.nmr.mgh.harvard.edu ls -Q /autofs/cluster/iaslab2/FSMAP/FSMAP_data/BIDS_modeled/${PROJ}/nosmooth/)"
SUBJ_LIST=("sub-014" "sub-016" "sub-022" "sub-028" "sub-030" "sub-034" "sub-037" "sub-039" "sub-043" "sub-045" "sub-050" "sub-053" "sub-054" "sub-057" "sub-060" "sub-061" "sub-066" "sub-068" "sub-069" "sub-073" "sub-074" "sub-081" "sub-083" "sub-086" "sub-087" "sub-092" "sub-094" "sub-096" "sub-099" "sub-100" "sub-102" "sub-104" "sub-105" "sub-111" "sub-112" "sub-117" "sub-119" "sub-124" "sub-128" "sub-131")
SUBJ_LIST=("sub-011" "sub-012" "sub-013" "sub-018" "sub-019" "sub-020" "sub-024" "sub-026" "sub-031" "sub-041" "sub-047" "sub-048" "sub-049" "sub-055" "sub-056" "sub-058" "sub-059" "sub-062" "sub-064" "sub-065" "sub-067" "sub-070" "sub-072" "sub-080" "sub-082" "sub-084" "sub-085" "sub-088" "sub-090" "sub-091" "sub-098" "sub-103" "sub-106" "sub-113" "sub-118" "sub-120" "sub-122" "sub-127" "sub-132" "sub-134")
EMO=emo
PAIN=pai

for PROJ in "${PROJ_LIST[@]}"
do
	echo "$PROJ"
	echo "${MOVE_TO}/${PROJ}/SC_warp"
	mkdir "${MOVE_TO}/${PROJ}/"
	mkdir "${MOVE_TO}/${PROJ}/SC_warp"
	
	if [ "${PROJ:0:3}" = "${EMO}" ]; then
		SUBJ_LIST=("sub-014" "sub-016" "sub-022" "sub-028" "sub-030" "sub-034" "sub-037" "sub-039" "sub-043" "sub-045" "sub-050" "sub-053" "sub-054" "sub-057" "sub-060" "sub-061" "sub-066" "sub-068" "sub-069" "sub-073" "sub-074" "sub-081" "sub-083" "sub-086" "sub-087" "sub-092" "sub-094" "sub-096" "sub-099" "sub-100" "sub-102" "sub-104" "sub-105" "sub-111" "sub-112" "sub-117" "sub-119" "sub-124" "sub-128" "sub-131")
	elif [ "${PROJ:0:3}" = "${PAIN}" ]; then
		SUBJ_LIST=("sub-011" "sub-012" "sub-013" "sub-018" "sub-019" "sub-020" "sub-024" "sub-026" "sub-031" "sub-041" "sub-047" "sub-048" "sub-049" "sub-055" "sub-056" "sub-058" "sub-059" "sub-062" "sub-064" "sub-065" "sub-067" "sub-070" "sub-072" "sub-080" "sub-082" "sub-084" "sub-085" "sub-088" "sub-090" "sub-091" "sub-098" "sub-103" "sub-106" "sub-113" "sub-118" "sub-120" "sub-122" "sub-127" "sub-132" "sub-134")
	fi
	echo "$SUBJ_LIST"

	for SUBJ in "${SUBJ_LIST[@]}"
	do
		# SUBJ="${SUBJ%\"}" # remove prefix after %
		# SUBJ="${SUBJ#"_task"}" # remove suffix after #
		# SUBJ="$(echo $SUBJ | cut -d'_' -f 2)"
		# echo "$SUBJ_FULL"
		# SUBJ="$(echo $SUBJ_FULL | cut -d'_' -f 1)"
		echo "$SUBJ"	

        #downlaod avoidance phase results with multiple runs
		# for RUN in "01" "02" "03" "04" "05"
		# do
		# 	echo "$RUN"
		# 	mkdir "${MOVE_TO}/${PROJ}/SC_warp/${SUBJ}_run-${RUN}"
		# 	rsync -ra --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${PROJ}/nosmooth/${SUBJ}*_run-${RUN}/design/_${SUBJ}*_run-${RUN}/ev* ${MOVE_TO}/${PROJ}/SC_warp/${SUBJ}_run-${RUN}
		# 	rsync -ra --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${PROJ}/nosmooth/${SUBJ}*_run-${RUN}/design/_${SUBJ}*_run-${RUN}/_modelgen0/* ${MOVE_TO}/${PROJ}/SC_warp/${SUBJ}_run-${RUN}
		# 	rsync --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${PROJ}/SC_warp/*_cope/warped_files/*${SUBJ}*run-${RUN}* ${MOVE_TO}/${PROJ}/SC_warp/${SUBJ}_run-${RUN}
			
		# 	#remove directory that doesn't have cope1
		# 	FILE=${MOVE_TO}/${PROJ}/SC_warp/${SUBJ}_run-${RUN}/wdata_${SUBJ}_run-${RUN}_cope1.nii
		# 	if [ -f "$FILE" ]; then
		# 	    echo "$FILE exists."
		# 	else 
		# 	    echo "$FILE does not exist."
		# 	    rm -r ${MOVE_TO}/${PROJ}/SC_warp/${SUBJ}_run-${RUN}
		# 	fi

		# done

    	#downlaod testing phase results with one run
    	mkdir "${MOVE_TO}/${PROJ}/SC_warp/${SUBJ}"
		rsync -ra --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${PROJ}/nosmooth/${SUBJ}*/design/_${SUBJ}/ev* ${MOVE_TO}/${PROJ}/SC_warp/${SUBJ}
		rsync -ra --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${PROJ}/nosmooth/${SUBJ}/design/_${SUBJ}/_modelgen0/* ${MOVE_TO}/${PROJ}/SC_warp/${SUBJ}
		rsync --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${PROJ}/SC_warp/*_cope/warped_files/*${SUBJ}* ${MOVE_TO}/${PROJ}/SC_warp/${SUBJ}
		
		#remove directory that doesn't have cope1
		FILE=${MOVE_TO}/${PROJ}/SC_warp/${SUBJ}/w_${SUBJ}__modelestimate0_cope3.nii
		if [ -f "$FILE" ]; then
		    echo "$FILE exists."
		else 
		    echo "$FILE does not exist."
		    rm -r ${MOVE_TO}/${PROJ}/SC_warp/${SUBJ}
		fi

	done
done
# #delete empty files
# cd ${MOVE_TO}/${PROJ}/PAG_warp/
# find . -type d -empty -print
# find . -type d -empty -delete
# /Users/chendanlei/Google\ Drive/U01/EmotionAvoidanceTask/BIDS_model_setup/flameo_scripts/1.download_copes.sh


# # func preproc files
# # # func file from preprocessing
# cd /Users/chendanlei/Google Drive/U01_data
# MOVE_FROM=/autofs/cluster/iaslab/FSMAP/FSMAP_data/BIDS_fmriprep/fmriprep/ses-02
# MOVE_TO=/Users/chendanlei/Desktop/U01/level1_files
# # MOVE_TO=/Volumes/IASL/People/Researchers/Danlei/U01/level1_files
# # PROJ=emoAvd_CSUS
# PROJ=emoAvd_CSUS

# echo "$PROJ"
# # mkdir "${MOVE_TO}/${PROJ}/PAG_warp"

# SUBJ_LIST="sub-014" "sub-016" "sub-028" "sub-034" "sub-037" "sub-039" "sub-045" "sub-050" "sub-053" "sub-054" "sub-057" "sub-060" "sub-061" "sub-068" "sub-073" "sub-074" "sub-081" "sub-083" "sub-086" "sub-087" "sub-092" "sub-094" "sub-099" "sub-100" "sub-102" "sub-104" "sub-105" "sub-111" "sub-112" "sub-114" "sub-117" "sub-118" "sub-119" "sub-124" "sub-128" "sub-131" "sub-135"
# SUBJ_LIST="sub-018" "sub-019" "sub-020" "sub-025" "sub-026" "sub-031" "sub-032" "sub-041" "sub-048" "sub-049" "sub-055" "sub-056" "sub-058" "sub-059" "sub-062" "sub-064" "sub-065" "sub-067" "sub-070" "sub-072" "sub-080" "sub-082" "sub-084" "sub-085" "sub-088" "sub-090" "sub-091" "sub-103" "sub-106" "sub-113" "sub-120" "sub-122" "sub-127" "sub-132" "sub-134" "sub-136"
# echo "$SUBJ_LIST"

# mkdir "${MOVE_TO}/${PROJ}/"
# mkdir "${MOVE_TO}/${PROJ}/func/"
# for SUBJ in "sub-014" "sub-016" "sub-028" "sub-034" "sub-037" "sub-039" "sub-045" "sub-050" "sub-053" "sub-054" "sub-057" "sub-060" "sub-061" "sub-068" "sub-073" "sub-074" "sub-081" "sub-083" "sub-086" "sub-087" "sub-092" "sub-094" "sub-099" "sub-100" "sub-102" "sub-104" "sub-105" "sub-111" "sub-112" "sub-114" "sub-117" "sub-118" "sub-119" "sub-124" "sub-128" "sub-131" "sub-135"
# do
# 	echo "$SUBJ"
# 	mkdir "${MOVE_TO}/${PROJ}/func/${SUBJ}"
# 	rsync -ra --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${SUBJ}/func/*3_run*_events.tsv ${MOVE_TO}/${PROJ}/func/${SUBJ}
# 	rsync -ra --ignore-existing dz609@door.nmr.mgh.harvard.edu:${MOVE_FROM}/${SUBJ}/func/*3_run*MNI152NLin2009cAsym_preproc.nii.gz  ${MOVE_TO}/${PROJ}/func/${SUBJ}
# done

#




