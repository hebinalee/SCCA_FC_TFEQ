%% 1. Set data and parameter
addpath(genpath('5.sCCA'))
addpath(genpath('6.BNA'))
load('static_BC.mat'); X = BC;
load('TFEQ.mat'); Y = TFEQ.rescored;
X = zscore(X, 0, 1);  % Using standardization
Y = zscore(Y, 0, 1);

%% 2. Perform sCCA for all possible number of cases
%% Method 1) When quesionnaire 1 or 3 is dominant
tfeq_rev23 = [3,3,2,1,2,1,3,2,3,1,3,2,3,1,3,3,2,1,2,3,1,2,1,2,3,2,3,1,2,1,3,1,1,2,1,3,1,1,2,1,2,1,1,1,3,1,2,1,3,1,3];
results_stack = cell(size(X, 2) - 1, size(Y, 2) - 1);

for Nroi = 1 : size(X, 2) - 1
    for Nque = 1 : size(Y, 2) - 1
        results_stack{Nroi, Nque} = cell(2, 3);
        th = [Nroi + 1, Nque + 1];
        for nque = 1 : 10
            [w1, w2] = svds_initial1(X, Y, th);
            U = X * w1;
            V = Y * w2;
            [~, Vi] = sort(abs(w2), 'descend');
            if Nque <= 10
                type_idx = mode(tfeq_idx(Vi));
            else
                type_idx = mode(tfeq_idx(Vi(1 : 10)));
            end
            
            if type_idx == 3
                0
            elseif isempty(results_stack{Nroi, Nque}{type_idx, 1})
                buf = corrcoef(U, V);
                results_stack{Nroi, Nque}{type_idx, 1} = buf(1, 2);
                results_stack{Nroi, Nque}{type_idx, 2} = w1;
                results_stack{Nroi, Nque}{type_idx, 3} = w2;
            end
        end
    end
end
save('results_stack.mat', 'results_stack');

%% Method 1-1) For the case, when questionnaire 1 is not dominant
nque = 0;
for Nroi = 1 : size(results_stack, 1)
    for Nque = 1 : size(results_stack, 2)
        nque = nque + isempty(results_stack{Nroi, Nque}{2, 1});
        if isempty(results_stack{Nroi, Nque}{1, 1})
            [Nroi, Nque]
        end
    end
end

%% Method 1-2) Fill the stack for the case when questionnaire 1 is not dominant
Nroi = 4;
for Nque = 34 : 35
    th = [Nroi + 1, Nque + 1];
	[w1, w2] = svds_initial1(X, Y, th);
    U = X * w1;
    V = Y * w2;
    [~, Vi] = sort(abs(w2), 'descend');
    tfeq_idx(Vi(1 : 10))
    
    buf = corrcoef(U, V);
    results_stack{Nroi, Nque}{1, 1} = buf(1, 2);
    results_stack{Nroi, Nque}{1, 2} = w1;
    results_stack{Nroi, Nque}{1, 3} = w2;
end

%% Method 2) Using maximum corr among 10 iterations
results_stack = cell(size(X, 2) - 1, size(Y, 2) - 1);
for Nroi = 1 : size(X, 2) - 1
    for Nque = 1 : size(Y, 2) - 1
        results_stack{Nroi, Nque} = cell(3, 1);
        th = [Nroi + 1, Nque + 1];
        results_stack{Nroi, Nque}{1, 1} = 0;
        for i = 1 : 100
            [w1, w2] = svds_initial1(X, Y, th);
            U = X * w1; V = Y * w2;
            buf = corrcoef(U, V);
            if abs(buf(1,2)) > abs(results_stack{Nroi, Nque}{1, 1})
                results_stack{Nroi, Nque}{1, 1} = buf(1, 2);
                results_stack{Nroi, Nque}{2, 1} = w1;
                results_stack{Nroi, Nque}{3, 1} = w2;
            end
        end
    end
end
save('results_stack_maxcorr_100.mat', 'results_stack');

%% 3. Make canonical correlation matrix
canon_corr = zeros(size(results_stack));
for Nroi = 1 : size(results_stack, 1)
    for Nque = 1 : size(results_stack, 2)
        canon_corr(Nroi, Nque) = results_stack{Nroi, Nque}{1, 1};
    end
end

save('canonical_maxcorr_100.mat', 'canon_corr')

%% 4. Plot results and find the optimal point
surf(canon_corr), xlabel('the number of questions selected'), ylabel('the number of ROI selected')
title('The change in canonnical correlation when the number of ROI and questions vary')
% effect of ROI # is dominant in deciding cannonical correlation.

% Take mean of questionnaire # and find the optimal number of ROI
figure, plot(mean(canon_corr, 2)), xlabel('number of ROIs selected'), ylabel('canonnical correlation coefficient')
title('The change in canonnical correlation when the number of ROI varies')
fix_que = mean(canon_corr, 2);
idx = find(fix_que >= max(fix_que) * 0.9);
% idx(1) == 33;
smoothed = smooth(fix_que);
figure, plot(smoothed)
for nque = 1 : length(smoothed) - 1
    slope(nque) = smoothed(nque+1) - smoothed(nque);
end
figure, plot(smooth(slope))

% Take mean of ROI # and find the optimal number of questionnaire
figure, plot(mean(canon_corr, 1)), xlabel('number of items selected'), ylabel('canonnical correlation coefficient')
title('The change in canonnical correlation when the number of questions varies')
% max == 4;

%% 5. Save the results with the optimal point
Nroi = 33; Nque = 50;    % the optimal point
tfeq_idx = [2 2 3 1 3 1 2 3 2 1 2 3 2 1 2 2 3 1 3 2 1 3 1 3 2 3 2 1 3 1 2 1 1 3 1 2 1 1 3 1 3 1 1 1 2 1 3 1 2 1 2]';

% cca.X = X; cca.Y = Y;
cca.w1 = results_stack{Nroi, Nque}{2, 1};
cca.w2 = results_stack{Nroi, Nque}{3, 1};
cca.corr = results_stack{Nroi, Nque}{1, 1};
[~, Ui] = sort(abs(cca.w1), 'descend');
[~, Vi] = sort(abs(cca.w2), 'descend');
cca.Usort = [Ui(1 : Nroi), cca.w1(Ui(1 : Nroi))];
cca.Vsort = [Vi, tfeq_ix(Vi), cca.w2(Vi)];
clear Ui Vi
save('CCAresults_BC33_TFEQ51_100.mat', 'cca')

%% 6. Check the number of selection as a dominant factor and the sCCA results
tfeq_idx = [2 2 3 1 3 1 2 3 2 1 2 3 2 1 2 2 3 1 3 2 1 3 1 3 2 3 2 1 3 1 2 1 1 3 1 2 1 1 3 1 3 1 1 1 2 1 3 1 2 1 2]';
results_stack_diffQ = cell(5, 2);   % 10 ~ 50, dominant: 1, 3
num_factors = zeros(5, 3);

for nque = 1 : 5
    Nroi = 33; Nque = nque * 10;
    th = [Nroi + 1, Nque + 1];
    
    results_stack_diffQ{nque, 1} = cell(3, 1); % corr, Usort, Vsort
    results_stack_diffQ{nque, 2} = cell(3, 1);
    results_stack_diffQ{nque, 1}{1, 1} = 0;
    results_stack_diffQ{nque, 2}{1, 1} = 0;
    
    for iter = 1 : 1000
        [w1, w2] = svds_initial1(X, Y, th);
        [~, Ui] = sort(abs(w1), 'descend');
        [~, Vi] = sort(abs(w2), 'descend');
        Usort = [Ui(1 : Nroi), w1(Ui(1 : Nroi))];
        Vsort = [Vi(1 : Nque), tfeq_idx(Vi(1 : Nque)), w2(Vi(1 : Nque))];
        if nque == 1
            dominant = mode(Vsort(1:10, 2));
        else
            dominant = mode(Vsort(1:15, 2));
        end
        num_factors(nque, dominant) = num_factors(nque, dominant) + 1;
        
        U = X * w1; V = Y * w2;
        buf = corrcoef(U, V);
        
        if dominant == 1
            j = 1;
        else
            j = 2;
        end
        
        if abs(buf(1,2)) > abs(results_stack_diffQ{nque, j}{1, 1})
            results_stack_diffQ{nque, j}{1, 1} = buf(1, 2);
            results_stack_diffQ{nque, j}{2, 1} = Usort;
            results_stack_diffQ{nque, j}{3, 1} = Vsort;
        end
    end
end
save('results_stack_diffQ.mat', 'results_stack_diffQ')

%% 7. Check correlation with selected ROIs and obesity
load('obesity.mat')
roi = sort(abs(cca.Usort(:, 1)), 'ascend');

for i = 1 : length(roi)
[r1, p1] = corrcoef(X(:, roi(i)), obesity(:, 1));
[r2, p2] = corrcoef(X(:, roi(i)), obesity(:, 2));
R(i, 1) = r1(1, 2);
R(i, 2) = r2(1, 2);
[~, ~, ~, P(i, 1)] = fdr_bh(p1(1, 2));
[~, ~, ~, P(i, 2)] = fdr_bh(p2(1, 2));
end

BMIidx = find(P(:, 1) < 0.05);
WHRidx = find(P(:, 2) < 0.05);
BMIrelated = [roi(BMIidx), R(BMIidx, 1), P(BMIidx, 1)];
WHRrelated = [roi(WHRidx), R(WHRidx, 2), P(WHRidx, 2)];
save('ROI_obesity_corr_results.mat', 'roi', 'R', 'P', 'BMIrelated', 'WHRrelated')
