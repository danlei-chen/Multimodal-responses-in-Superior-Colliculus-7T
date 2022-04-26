# multimodal-responses-in-Superior-Colliculus-7T

The project focuses on modeling brain (specifically the superior colliculus) responses during visual or somatosensory stimulation period. The stimulation was either affectively aversive or neutral. Data was collected in high-resolution 7 Tesla fMRI. 

The scripts include univariate analysis of task modeling and warping of first level result on group-level superior colliculus mask, MVPA analysis using SVM to classify task labels, and superior colliculus signal extraction and mixed effects modeling.

Main analyses were done in Python (Sklearn, Nipype, Nilearn), mixed effects statistical model was done in R (lmer), visualization was mostly done in R (ggplot). 
