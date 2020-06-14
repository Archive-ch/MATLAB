clear all;
clc;
load('Indian_pines_corrected.mat');
indian=indian_pines_corrected;
X=indian(:,:,140);
V=mapminmax(X,0,1);%��һ��
rdim = 100;
sW = 0.6;%��ʼϡ���
sH = 0.6;
fname = ['Indian_pines'];
showflag = 0;%��ʾͼ��
tol = 0.00001;%����
stopconv = 30;%ֹͣ״̬
timelimit = 100;%ʱ�����ƣ�̫����ҲҪֹͣ���������Ч
maxiter = 5000;%��������
[W,H,objhistory,iter,elapsed] = NMFSC( V, rdim, sW, sH, fname, showflag, stopconv, tol,timelimit, maxiter );
WH=W*H;
% V = V/max(V(:));
SAD=SAD(V,WH);%���׽Ǿ���

RMSE=sum(sqrt(mean((V-WH).^2)))/145;