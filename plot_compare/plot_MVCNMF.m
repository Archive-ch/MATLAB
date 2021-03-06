function [A_4,S_4] = plot_MVCNMF(V)
%PLOT_MVCNMF 此处显示有关此函数的摘要
%   此处显示详细说明
mixed=V;
M = 29;
N = 5;

% remove noise
c = test_p(mixed');%通过主成分分析测出端元数
c=int8(c);
[UU, SS, VV] = svds(mixed,c);%SS为c个最大特征值构成的对角矩阵； UU,VV分别是相应的特征值对应的列向量和行向量
%mixed约等于UU*SS*VV'
[L I]=size(mixed);
r_m = mean(mixed,2); %对每行求均值     
R_m = repmat(r_m,[1 I]); % 扩展列向量，变成I个相同列向量构成的矩阵
R_o = mixed - R_m; 
x_p =  UU' * R_o;  
SNR=estimate_snr(mixed,r_m,x_p);%测量信噪比

Lowmixed = UU'*mixed;
mixed = UU*Lowmixed;

% HySime algorithm 
verbose = 'on';
c=double(c);
%[A_vca, EndIdx] = vca(mixed,'Endmembers', c,'verbose','on');
[A_vca, EndIdx] = vca(mixed,'Endmembers', c,'SNR', SNR,'verbose','on');

% 利用全局最小二乘法对丰度矩阵进行演算
warning off;
AA = [1e-5*A_vca;ones(1,length(A_vca(1,:)))];
s_fcls = zeros(length(A_vca(1,:)),M*N);
for j=1:M*N
    r = [1e-5*mixed(:,j); 1];
    % s_fcls(:,j) = nnls(AA,r);
    s_fcls(:,j) = lsqnonneg(AA,r);%求解非负线性最小二乘问题，返回s_fcls(:,j)大于0情况下的最小向量
end

% use vca to initiate
Ainit = A_vca;%基矩阵
sinit = s_fcls;%系数矩阵


% use vca to initiate
PrinComp= pca(mixed');     %返回N的主成分系数 通过P数据矩阵X, X的行对应于观测值，列对应于变量。
meanData = mean(mixed');

tol = 0.00001;
maxiter = 5000;
T = 0.015;%φ=λ/(p-1)!系数
showflag = 0;
% figure(2);
% imshow(mixed);
[A_4,S_4] = mvcnmf_new(mixed,Ainit,sinit,UU,PrinComp,meanData,T,tol,maxiter,showflag,2,1);
end

