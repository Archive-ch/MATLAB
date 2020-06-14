function [A_4,S_4] = plot_MVCNMF(V)
%PLOT_MVCNMF �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
mixed=V;
M = 29;
N = 5;

% remove noise
c = test_p(mixed');%ͨ�����ɷַ��������Ԫ��
c=int8(c);
[UU, SS, VV] = svds(mixed,c);%SSΪc���������ֵ���ɵĶԽǾ��� UU,VV�ֱ�����Ӧ������ֵ��Ӧ����������������
%mixedԼ����UU*SS*VV'
[L I]=size(mixed);
r_m = mean(mixed,2); %��ÿ�����ֵ     
R_m = repmat(r_m,[1 I]); % ��չ�����������I����ͬ���������ɵľ���
R_o = mixed - R_m; 
x_p =  UU' * R_o;  
SNR=estimate_snr(mixed,r_m,x_p);%���������

Lowmixed = UU'*mixed;
mixed = UU*Lowmixed;

% HySime algorithm 
verbose = 'on';
c=double(c);
%[A_vca, EndIdx] = vca(mixed,'Endmembers', c,'verbose','on');
[A_vca, EndIdx] = vca(mixed,'Endmembers', c,'SNR', SNR,'verbose','on');

% ����ȫ����С���˷��Է�Ⱦ����������
warning off;
AA = [1e-5*A_vca;ones(1,length(A_vca(1,:)))];
s_fcls = zeros(length(A_vca(1,:)),M*N);
for j=1:M*N
    r = [1e-5*mixed(:,j); 1];
    % s_fcls(:,j) = nnls(AA,r);
    s_fcls(:,j) = lsqnonneg(AA,r);%���Ǹ�������С�������⣬����s_fcls(:,j)����0����µ���С����
end

% use vca to initiate
Ainit = A_vca;%������
sinit = s_fcls;%ϵ������


% use vca to initiate
PrinComp= pca(mixed');     %����N�����ɷ�ϵ�� ͨ��P���ݾ���X, X���ж�Ӧ�ڹ۲�ֵ���ж�Ӧ�ڱ�����
meanData = mean(mixed');

tol = 0.00001;
maxiter = 5000;
T = 0.015;%��=��/(p-1)!ϵ��
showflag = 0;
% figure(2);
% imshow(mixed);
[A_4,S_4] = mvcnmf_new(mixed,Ainit,sinit,UU,PrinComp,meanData,T,tol,maxiter,showflag,2,1);
end

