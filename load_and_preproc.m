addpath(genpath('/store4/bypark/ETC/toolbox'))

%% Load T1 path of whole data
Datapath = '/store4/bypark/hblee/eNKI';
sbj_list = dir(strcat(Datapath,'/A*'));

for sbj_idx = 1 : length(sbj_list)
    sbj_file = fullfile(sbj_list(sbj_idx).folder, sbj_list(sbj_idx).name);
    T1_total_list(sbj_idx, :) = fullfile(sbj_file, '/MPRAGE/MPRAGE.nii.gz');    % should I use '\' or '/'?
end
save('T1_path.mat', 'T1_total_list')


%% Load obesity and eating habit features
Datapath = '/store4/bypark/hblee';
obesity = xlsread(fullfile(Datapath, 'Enhanced_NKI.xlsx'), 2, 'F:G');  % BMI and WHR
eating = xlsread(fullfile(Datapath, 'Enhanced_NKI.xlsx'), 2, 'U:AA');  % EDE-Q and TFEQ
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
end

%% Remove
% for sbj_idx = 4 : length(sbj_list)
%     folder_name = fullfile(sbj_list(sbj_idx).folder, sbj_list(sbj_idx).name, 'MPRAGE/anat_results');
%     rmdir(folder_name)
%     
%     buf1 = fullfile(sbj_list(sbj_idx).folder, sbj_list(sbj_idx).name, 'REST_1400/REST_1400.nii.gz');
%     buf2 = fullfile(sbj_list(sbj_idx).folder, sbj_list(sbj_idx).name, 'REST_CAP/REST_CAP.nii.gz');
%     delete(buf1)
%     delete(buf2)
%     rmdir(fullfile(sbj_list(sbj_idx).folder, sbj_list(sbj_idx).name, 'REST_1400'))
%     rmdir(fullfile(sbj_list(sbj_idx).folder, sbj_list(sbj_idx).name, 'REST_CAP'))
% end
