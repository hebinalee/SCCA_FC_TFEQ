%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  TO PERFORM SCCA ANALYSIS
%%  (C) The right of this code is reserved by
%%      Mansu Kim and Ji Hye Won (co-authors)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [w1, w2] = svds_initial1(X, Y, ss_th)
p1 = size(X, 2);
p2 = size(Y, 2);
w2 = randn(size(Y, 2), 1);
w2 = w2 / norm(w2);

for ii = 1 : 200
    lam1 = max(p1 * 0.5 / 1.1^ii, ss_th(1));
    lam2 = max(p2 * 0.5 / 1.1^ii, ss_th(2));
    w1 = X' * (Y * w2);
    w1 = soft(w1, fix(lam1));
    w2 = Y' * (X * w1);
    w2 = soft(w2, fix(lam2));
%     if (ii == 50) || (ii == 100) || (ii == 150) || (ii == 200)
%         ii
%         w1
%         w2
%     end
end
end


function y = soft(x, lambda)
[n, k] = size(x);
temp = sort(abs(x), 'descend');
th = temp(lambda, :);
y = sign(x) .* max(abs(x) - repmat(th, n, 1), 0);
% y = half(x, th);
ny = sqrt(sum(y.^2));
y = y ./ repmat(ny, n, 1);
end
