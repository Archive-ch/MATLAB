clear;
clc;
% S=load('C:\Users\Archive\Desktop\img\Indian_pines_gt.mat');%
% S1=struct2cell(S);%���ṹת��ΪԪ������
% V=cell2mat(S1);%��Ԫ������ת���Ϊ��ͨ�ľ��� 
% V = V/max(V(:));
load('Indian_pines_corrected.mat');
X=indian_pines_corrected;
M=X(:,:,160);
V=mapminmax(M,0,1);
k=100;
[A,S]=wecnmf(V,k);
X=A*S;
% imshow(X);
SAD_5=sum(sum(abs(V-X)))/(145*145);
RMSE_5=sum(sqrt(mean((V-X).^2)))/145;