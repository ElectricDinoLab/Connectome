# denoise original files
dwidenoise

# skull strip denoised DWI
bet -f 0.1 -F
# dwipreprocess
dwipreproc AP <denoised & skull-stripped data> -rpe_none -fslgrad -export_grad_fsl

####-fslgrad is only needed if you are working with nii.gz files, not .mif####

# create an initial mask via bet
bet -f 0.2 -F

# bias-field correction
dwibiascorrect -ants -mask -fslgrad

# create a better mask with the bias-corrected info
dwi2mask -fslgrad

# create tensor, create FA
dwi2tensor -mask -fslgrad tensor2metric -fa -rd -ad

# get the response function
dwi2response tournier <output.txt> -fslgrad

# response function for wm/gm/csf
dwi2response dhollander -fslgrad

# acquiring FOD
dwi2fod csd <output.txt> -mask -fslgrad

# dwi2fod msmt_csd $ <sfwm.txt> <gm.txt> <csf.txt> -fslgrad

# generate the b0
fslroi 0 1 bet -f 0.1

# seeding done at random within a mask image
tckgen -seed_image <tracks.tck> -number 10M -maxlength 250 -fslgrad tcksift <tracks.tck> <SIFTtracks.tck> -term_number 1M -force

# registration of MNI to subject space
flirt -in <MNI152_T1_2mm_brain> -ref -out <MNI_to_native> -omat <MNI_to_native.mat> -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -interp nearestneighbour

# registration to HOA in preparation of connectome creation
flirt -in <HOAsp.nii> -ref -out <b0_HOAsp> -applyxfm -init <MNI_to_native.mat> -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -interp nearestneighbour flirt -in <HOA100_LR.nii.gz> -ref -out <b0_HOA100_LR> -applyxfm -init <MNI_to_native.mat> -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -interp nearestneighbour

# generate the connectomes
tck2connectome <SIFTtracks.tck> <b0_HOAsp> <output_471.csv> tck2connectome <SIFTtracks.tck> <b0_HOA100_LR> <output_100.csv>
