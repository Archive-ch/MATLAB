clear all;
clc;
S=load('C:\Users\Archive\Desktop\img\Indian_pines_gt.mat');%
S1=struct2cell(S);%���ṹת��ΪԪ������
X=cell2mat(S1);%��Ԫ������ת���Ϊ��ͨ�ľ��� 
%ÿ����һ������
%newX  ��ά����¾���
%T �任����
%meanValue  Xÿ�о�ֵ���ɵľ������ڽ���ά��ľ���newX�ָ���X
%CRate ������
%�������Ļ���������
meanValue=ones(size(X,1),1)*mean(X);
X=X-meanValue;%ÿ��ά�ȼ�ȥ��ά�ȵľ�ֵ
C=X'*X/(size(X,1)-1);%����Э�������
%������������������ֵ
[V,D]=eig(C);
%��������������������
[dummy,order]=sort(diag(-D));
V=V(:,order);%������������������ֵ��С���н�������
d=diag(D);%������ֵȡ��������һ��������
newd=d(order);%������ֵ���ɵ�����������������
%ȡǰn���������������ɱ任����
sumd=sum(newd);%����ֵ֮��
for j=1:length(newd)
    i=sum(newd(1:j,1))/sumd;%���㹱���ʣ�������=ǰn������ֵ֮��/������ֵ֮��
    if i>0.9%�������ʴ���95%ʱѭ������,������ȡ���ٸ�����ֵ
        cols=j;
        break;
    end
 end
 T=V(:,1:cols);%ȡǰcols���������������ɱ任����T
 newX=X*T;%�ñ任����T��X���н�ά
