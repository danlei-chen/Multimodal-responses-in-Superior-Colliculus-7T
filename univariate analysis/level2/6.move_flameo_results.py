# python /Volumes/GoogleDrive/My\ Drive/U01/AffPainTask_connectivity/analysis/univariate/level2/6.move_flameo_results.py

# #schedule the script to run at a certain time
# import datetime
# import time
# run_now=0
# while run_now == 0:
#     currentDT = datetime.datetime.now()
#     print (str(currentDT))
#     if int(currentDT.hour) > 5 and int(currentDT.minute) > 30:
#         run_now = 1
#         print("start to run the script at "+(str(currentDT)))
#     time.sleep(600) #600: check every 10m

import glob
import os
from shutil import copyfile
import shutil

#move all  stats files of the all projects in workdir to output
move_from = '/Users/chendanlei/Desktop/U01/flameo_results/workdir/'
move_to = '/Users/chendanlei/Desktop/U01/flameo_results/output/'
# projs = ['emoAvd_CSUSnegneu_smoothed3mm_masked','emoAvd_CSUSnegneu_smoothed1.5mm_masked']
projs = ['emoTest_CSUSPEnegUSPEpos_smoothed3mm_masked']
# all_cope_name = ['1CS_combo','2USneg','3USneu','4USnegVneu']
all_cope_name = ['3_US_PEneg','4_US_PEpos','5_US_PEnegVpos']
# projs = ['emoAvd_CSUS_2_PAG_warp','emoAvd_CSUS_2_PAG_warp_run-05','emoAvd_CSUS_2_PAG_warp_run-01']
# all_cope_name = ['1CS_combo','2US']
# projs = ['painAvd_CSUS1s_2_PAG_warp']
# all_cope_name = ['1CS_combo','2USonset','3USperiod']

# projs = glob.glob(move_from+'*')
# projs = [i.split('/')[-1] for i in projs]
# projs = [ i for i in projs if ".ipynb" not in i ]
# projs.sort()
# projs = [i for i in projs if '_' in i]
# projs = glob.glob(move_from+projs[0])
# projs = [i.split('/')[-1] for i in projs]

for proj in projs:
    print(proj)
    if not os.path.exists(move_to+proj):
        os.mkdir(move_to+proj)

    copes = glob.glob(move_from+proj+'/*')
    copes = [i.split('/')[-1] for i in copes]
    copes = [ i for i in copes if '.nii.gz' not in i ]
    copes=sorted(copes, key=lambda x: int(x.partition('cope')[2]))

    # if 'Avd_CSUSvalPEmodeled_' in proj:
    #     all_cope_name=['CS','US','USnegneu','USPE']
    # elif 'Test_CS+-USnegneu_' in proj:
    #     all_cope_name=['CS+>CS-','USneg>USneu','rating']
    # elif 'Test_CSExpUSUnp_' in proj:
    #     all_cope_name=['CS','CSExp','US','USUnp','rating']
    # elif 'Test_CSExpUSUnprankedPE_' in proj:
    #     all_cope_name=['CS','CSExp','US','USUnp','USPE','rating']
    # elif 'Test_CSUSnegPEH2USneuPEH2_' in proj:
    #     all_cope_name=['CS','USneg_H2>H1','USneu_H2>H1','rating']
    # elif 'Test_CSUSnegPEUSneuPE_' in proj:
    #     all_cope_name=['CS','USneg>USneu','USneg','USneg_PEneg','USneu','USneu_PEneu','rating']
    # elif 'Test_CSUSrankedPE_' in proj:
    #     all_cope_name=['CS','US','USPE','rating']
    # elif 'Test_newCSUSrankedPEQ4_' in proj:
    #     all_cope_name=['CS','US_Q3Q4>US_Q1Q2','US_Q4>US_Q1','rating']    
    # elif 'Avd_CSUSvalPEposPEneg_' in proj:
    #     all_cope_name=['CS','US','USval','US_PEneu','US_PEneg']
    # elif 'Avd_CSUSPEmodeled_' in proj:
    #     all_cope_name=['CS','US','US_PE']    
    # elif 'Avd_CSPEmodeled_' in proj:
    #     all_cope_name=['CS','US_PE']

    # #CSUSExp
    # all_cope_name=['1CS','2USneu','3USneg','4USneg>neu','5USneutral_PredictionNEU','6USnegative_PredictionNEG']
    #CSUS
    # all_cope_name=['1CS','2USneu1','3USneu2','4USneu3','5USneu4','6USneg1','7USneg2','8USneg3','9USneg4','10USneu1>4','11USneu12>34','12USneg1>4','13USneg12>34','14USneg>neu']
    #CSUS1s
    # all_cope_name=['1CS','2USonsetNeu1','3USonsetNeu2','4USonsetNeu3','5USonsetNeu4','6USonsetNeg1','7USonsetNeg2','8USonsetNeg3','9USonsetNeg4','10USonsetNeu1>4','11USonsetNeu12>34','12USonsetNeg1>4','13USonsetNeg12>34','14USonsetNeg>Neu','15USperiodNeu','16USperiodNeg']
    # #CSUSExp1s
    # all_cope_name=['1CS','2USonset_neu','3USonset_neg','4USperiod_neu','5USperiod_neg','6USonset_neg>neu','7USperiod_neg>neu','8USonset_neu_PE','9USonset_neg_PE','10USperiod_neu_PE','11USperiod_neg_PE']
    # #CSUSExp1sPM
    # all_cope_name=['1CS','2USonset','3USperiod','4USonset_NegNeu','5USperiod_NegNeu','6USonset_Prediction','7USperiod_Prediction']
    #CSUSExp1sPM
    # all_cope_name=['1CS','2US','3US_NegNeu','4US_Prediction']
    #CSUSabsPE
    # all_cope_name=['1CS','2US','3US_NegNeu','4US_absPE']

    # if 'emoAvd_CSUSabsPEQ4' in proj:
    #     all_cope_name=['CS','PEQ1','PEQ2','PEQ3','PEQ4','PEQ4_Q1','PEQ34_Q12']
    # elif 'emoAvd_CSUS+-PEQ4' in proj:
    #     all_cope_name=['CS','neuPEQ1','neuEQ2','neuPEQ3','neuPEQ4','negPEQ1','negEQ2','negPEQ3','negPEQ4','neuPEQ4_Q1','neuPEQ34_Q12','negPEQ1_Q4','negPEQ12_Q34','neg_neu']
    # elif 'painAvd_CSUS1sabsPEQ4' in proj:
    #     all_cope_name=['CS','onsetPEQ1','onsetPEQ2','onsetPEQ3','onsetPEQ4','onsetPEQ4_Q1','onsetPEQ34_Q12','period']
    # elif 'painAvd_CSUS1s+-PEQ4' in proj:
    #     all_cope_name=['CS','onsetNeuPEQ1','onsetNeuEQ2','onsetNeuPEQ3','onsetNeuPEQ4','onsetNegPEQ1','onsetNegEQ2','onsetNegPEQ3','onsetNegPEQ4','onsetNeuPEQ4_Q1','onsetNeuPEQ34_Q12','onsetNegPEQ1_Q4','onsetNegPEQ12_Q34','onsetNeg_Neu','periodNeu','periodNeg']

    for cope_num,cope_name in enumerate(copes):
        print(cope_name)

        if not os.path.exists(move_to+proj+'/'+cope_name):
            os.mkdir(move_to+proj+'/'+cope_name)

        # move all files in stats folder
        # for filename in glob.glob(move_from+proj+'/'+cope_name+'/fixedfx/flameo/mapflow/_flameo0/stats/thresh_1_minus_p1*'):
        for filename in glob.glob(move_from+proj+'/'+cope_name+'/fixedfx/flameo/mapflow/_flameo0/stats/*'):
            os.system("rsync  -a --ignore-existing "+ filename + " " + move_to+proj+'/'+cope_name+'/'+filename.split('/')[-1])
            # copyfile(filename, move_to+proj+'/'+cope_name+'/'+filename.split('/')[-1])
        # move design.grp file
        # copyfile(move_from+proj+'/'+cope_name+'/fixedfx/l2model//design.grp', move_to+proj+'/'+cope_name+'/'+'design.grp')
        os.system("rsync  -a --ignore-existing "+move_from+proj+'/'+cope_name+'/fixedfx/l2model/design.grp' + " " + move_to+proj+'/'+cope_name+'/'+'design.grp')

        #change all file names in the folder with moved files
        os.chdir(move_to+proj+'/'+cope_name+'/')
        for filename in glob.glob(move_to+proj+'/'+cope_name+'/*'):
            filename=filename.split('/')[-1]
            os.rename(filename, all_cope_name[cope_num]+'_'+filename)
        
        #change folder name
        if os.path.exists(move_to+proj+'/'+cope_name+'_'+all_cope_name[cope_num]+'/'):
            shutil.rmtree(move_to+proj+'/'+cope_name+'_'+all_cope_name[cope_num]+'/')
            # os.rmdir(move_to+proj+'/'+cope_name+'_'+all_cope_name[cope_num]+'/')
        os.replace(move_to+proj+'/'+cope_name+'/', move_to+proj+'/'+all_cope_name[cope_num]+'/')

