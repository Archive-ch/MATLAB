function [A,S] = plot_NMFSC(V)
rdim = 100;
sW = 0.6;%��ʼϡ���
sH = 0.6;
fname = ['Indian_pines_NMFSC'];
showflag = 0;%��ʾͼ��
tol = 0.00001;%����
stopconv = 30;%ֹͣ״̬
timelimit = 100;%ʱ�����ƣ�̫����ҲҪֹͣ���������Ч
maxiter = 5000;%��������
[A,S] = NMFSC( V, rdim, sW, sH, fname, showflag, stopconv, tol,timelimit, maxiter );
end

