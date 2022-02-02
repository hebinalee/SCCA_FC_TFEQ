%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  TO PERFORM SCCA ANALYSIS WITH FC AND TFEQ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

basepath = 'X:/path/myfolder';
datapath = [basepath, '/data/eNKI'];
list_rest = dir([datapath, '/A*']);
suffix = 'REST_645/func_results_REST_645/Smooth_REST_645.nii.gz';

% Get BNA atlas map
bna_path = [basepath, '/Atlas/BrainnetomeAtlas/BNA3mm/BNA_3mm.nii'];
bna = load_nii(bna_path);
roi = bna.img;
clear bna

% Loop for each subject
meanBOLD = cell(length(list_rest), 1);    % set mean BOLD signal matrix
for Nsub = 2 : length(list_rest)
%% (1) Load fMRI data
    sbj_file = fullfile(list_rest(Nsub).folder, list_rest(Nsub).name, suffix);
    sbj = load_nii(sbj_file);
    fmri = sbj.img;
    clear sbj

%% (2) Calculate mean BOLD signal of region
    fmri_2d = reshape(fmri, [], size(fmri, 4));
    for j = 1 : 246
        region_idx = find(roi(:) == j);     % find voxels included in the region
        region_bold = fmri_2d(region_idx, :);    % find BOLD signal of those voxels
        meanBOLD{Nsub, 1}(:, j) = mean(region_bold, 1);     % calculate mean BOLD signal of region
    end
end
save('mean_BOLD.mat', 'meanBOLD')

%% (3) Calculate connectivity
CONN = cell(320, 1);    % set connectivity matrix
for Nsub = 1 : length(meanBOLD)
    bold = meanBOLD{Nsub, 1};
    conn = corrcoef(bold);
    conn = ((conn + 1) ./ 2) .^ 6;      % soft thresholded correlation coeff, scale-free index
    conn = atanh(conn);                 % z-transformed correlation coeff.
    for i = 1 : 246
        CONN{Nsub, 1}(i, i) = 0;
    end
    CONN{Nsub, 1} = conn;
end
save('static_connecticity.mat', 'CONN')

%% (4) Calculate centralities
DC = cell(320, 1);
BC = cell(320, 1);
for Nsub = 1 : length(CONN)
    [bc, dc, evc] = NetworkCentrality(CONN{Nsub, 1});
    DC(Nsub, :) = dc;
    BC(Nsub, :) = bc(:, 2);
end
save('static_DC.mat', 'DC')
save('static_BC.mat', 'BC')

%% (5) sCCA
%% Set data and parameter
addpath(genpath([basepath, '/5.sCCA']))
addpath(genpath([basepath, '/6.BNA']))
cen_type = ["DC", "BC"];
que_type = ["EDEQ", "TFEQ"];

%% Iterate for all centralities and questionnarie type
for cen_idx = 1 : 2         % 1: DC, 2: BC
    for que_idx = 1 : 2     % 1: EDEQ, 2: TFEQ
        clear X Y cca

        %% Prepare centrality and questionnaire data
        S = load(strcat('static_', cen_type(cen_idx), '.mat'));
        X = S.(cen_type(cen_idx));
        S = load(strcat(que_type(que_idx), '.mat'));
        Y = S.(que_type(que_idx)).rescored;
        clear S

        %% Perform sCCA
        cca.X = zscore(X, 0, 1);  % Using standardization
        cca.Y = zscore(Y, 0, 1);
        
        [cca.w1, cca.w2] = svds_initial1(cca.X, cca.Y, [246, 51]);
%         save(strcat('CCAresults-', cen_type(cen_idx), '-', que_type(que_idx), '.mat'), 'cca');
    end
end
 
%% Sort variables by significance
cca.U = cca.w1;
cca.V = cca.w2;
[~, Ui] = sort(abs(cca.U), 'descend');
[~, Vi] = sort(abs(cca.V), 'descend');

Usort = [Ui, cca.U(Ui)];
if que_idx == 1
    buf = [1,2,3,4,5,6,7,8,9,10,11,12,19,20,21,22,23,24,25,26,27,28]';
    Vsort = [buf(Vi), cca.V(Vi)];
else
    Vsort = [Vi, cca.V(Vi)];
end
clear Ui Vi

%% Check canonical correlation coefficient
U = cca.X * cca.w1;
V = cca.Y * cca.w2;
buf = corrcoef(U, V);
buf = buf(1,2);
