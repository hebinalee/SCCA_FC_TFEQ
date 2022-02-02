%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  TO LOAD AND PREPROCESS MRI DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

basepath = 'X:/path/myfolder'
addpath(genpath([basepath, '/toolbox']))

%% Load T1 path of whole data
datapath = [basepath, '/data/eNKI'];
sbj_list = dir(strcat(datapath,'/A*'));

for sbj_idx = 1 : length(sbj_list)
    sbj_file = fullfile(sbj_list(sbj_idx).folder, sbj_list(sbj_idx).name);
    T1_total_list(sbj_idx, :) = fullfile(sbj_file, '/MPRAGE/MPRAGE.nii.gz');    % should I use '\' or '/'?
end
save('T1_path.mat', 'T1_total_list')


%% Load obesity and eating habit features
obesity = xlsread(fullfile(datapath, 'Enhanced_NKI.xlsx'), 2, 'F:G');  % BMI and WHR
eating = xlsread(fullfile(datapath, 'Enhanced_NKI.xlsx'), 2, 'U:AA');  % EDE-Q and TFEQ
save('obesity.mat', 'obesity', 'eating');

%% Perform preprocessing of T1 for whole data
load('FuNP_Volume_T1_settings.mat');
load('T1_path.mat')

for sbj_idx = 1 : size(T1_total_list, 1)
    in_list = T1_total_list(sbj_idx, :);
    
    preproc_volume_T1(in_list, reorient, orientation, mficor, skullremoval_T1, regis_T1, standard_path, ...
        standard_name, standard_ext, dof, segmentation);
end

%% Load preproc T1 path and fMRI path
clear T1_total_list
for sbj_idx = 1 : length(sbj_list)
    sbj_file = fullfile(sbj_list(sbj_idx).folder, sbj_list(sbj_idx).name);
    T1_total_list(sbj_idx, :) = fullfile(sbj_file, 'MPRAGE/anat_results/SS_MPRAGE.nii.gz');
    fMRI_total_list(sbj_idx, :) = fullfile(sbj_file, 'REST_645/REST_645.nii.gz');
end
save('preproc_T1_path.mat', 'T1_total_list')
save('fMRI_path.mat', 'fMRI_total_list')

%% Perform preprocessing of fMRI for whole data
load('FuNP_Volume_fMRI_settings.mat');
load('preproc_T1_path.mat')
load('fMRI_path.mat')

for sbj_idx = 1 : size(fMRI_total_list, 1)
    in_list_fMRI = fMRI_total_list(sbj_idx, :);
    in_list_T1 = T1_total_list(sbj_idx, :);
    
    preproc_volume_fMRI(in_list_fMRI, reorient, orientation, delnvol, VOLorSEC, VOLorSEC_enterval,...
        motscrub, FDthresh_enterval, motcor, stcor, stcor2, stcor_opt, slice_order_file, discor,...
        reverse_path, reverse_name, reverse_ext, total_readout_time, skullremoval_fMRI, intnorm,...
        regis_fMRI, in_list_T1, dof1, standard_path, standard_name, standard_ext, dof2,...
        nvremove, FIX_dim, FIX_train, tempfilt, filter_kind, lpcutoff, hpcutoff, smoothing, fwhm_val);
    
    
    %% Re-registration using FLIRT
    IndPath = fullfile(DataPath, sbj_list(sbj_idx).name, 'REST_645/func_results_REST_645');
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

