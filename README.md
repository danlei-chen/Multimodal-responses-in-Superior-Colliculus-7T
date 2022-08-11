# multimodal-responses-in-Superior-Colliculus-7T

For pre-registration, see: https://osf.io/pa5b9/?view_only=eebabf5e01eb4860b0b33e217f991821

The project focuses on modeling brain (specifically the superior colliculus) responses during visual or somatosensory stimulation period. The stimulation was either affectively aversive or neutral. Data was collected in high-resolution 7 Tesla fMRI (N=80). 

The scripts include univariate analysis of task modeling and warping of first level result on group-level superior colliculus mask, MVPA analysis using SVM to classify task labels, and superior colliculus signal extraction and mixed effects modeling.

Main analyses were done in Python (Sklearn, Nipype, Nilearn), mixed effects statistical model was done in R (lmer), visualization was mostly done in R (ggplot). 
