% clear;clc
addpath(genpath('/store4/bypark/ETC/toolbox'))

DataPath = '/store4/bypark/hblee/eNKI';
sbj_list = dir(strcat(DataPath,'/A*'));

for idx = 1 : length(sbj_list)
	disp(strcat(['list = ',int2str(idx),' -- ',sbj_list(idx).name]));
   
    IndPath = fullfile(DataPath, sbj_list(idx).name, 'REST_645/func_results_REST_645');
   
    %% Remove failed results (Move to 'fail_ants' file)
    mkdir(strcat(IndPath,'/fail_ants'));
    system(strcat(['mv ',IndPath,'/Func2HR_* ',IndPath,'/fail_ants/']));
    system(strcat(['mv ',IndPath,'/HR2STD_* ',IndPath,'/fail_ants/']));
    system(strcat(['mv ',IndPath,'/Func2STD_* ',IndPath,'/fail_ants/']));
    system(strcat(['mv ',IndPath,'/Smooth_* ',IndPath,'/fail_ants/']));
   
    %% Re-registration using FLIRT
    % 1) Register T1 to MNI - 12dof
    % output : matrix (HR2STD)
    system(strcat(['flirt -in ',IndPath,'/highres_REST_645 -ref ',IndPath,'/standard_REST_645 -omat ',IndPath,'/fsl_HR2STD_REST_645.mat -dof 12 -cost mutualinfo']));

    % 2) Multiply matrices
    % output : matrix (Func2STD)
    system(strcat(['convert_xfm -omat ',IndPath,'/fsl_Func2STD_REST_645.mat -concat ',IndPath,'/fsl_HR2STD_REST_645.mat ',IndPath,'/fsl_Func2HR_REST_645.mat']));

    % 3) Register 3D example image of fMRI to MNI using matrix resulted by 2)
    % output : 3D image (Func2STD)
    system(strcat(['flirt -applyxfm -init ',IndPath,'/fsl_Func2STD_REST_645.mat -in ',IndPath,'/Mean4reg_REST_645 -ref ',IndPath,'/standard_REST_645 -out ',IndPath,'/Func2STD_REST_645 -interp trilinear']));

    % 4) Register 4D fMRI to MNI using matrix resulted by 2)
    % output : 4D image (Func2STD_4D)
    system(strcat(['flirt -applyxfm -init ',IndPath,'/fsl_Func2STD_REST_645.mat -in ',IndPath,'/Filtered_clean_REST_645 -ref ',IndPath,'/standard_REST_645 -out ',IndPath,'/Func2STD_4D_REST_645 -interp trilinear']));

    % 5) Apply smoothing
    % output : 4D image (Smooth)
    system(strcat(['3dmerge -quiet -1blur_fwhm 5 -doall -prefix ',IndPath,'/Smooth_REST_645.nii.gz ',IndPath,'/Func2STD_4D_REST_645.nii.gz']));
end
