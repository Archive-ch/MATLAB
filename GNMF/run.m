clear;
% load('COIL20.mat');	
% S=load('C:\Users\Archive\Desktop\img\Indian_pines_gt.mat');%
% S1=struct2cell(S);%���ṹת��ΪԪ������
% V=cell2mat(S1);%��Ԫ������ת���Ϊ��ͨ�ľ���
load('Indian_pines_corrected.mat');
indian=indian_pines_corrected;
X=indian(:,:,140);
X=mapminmax(X,0,1);%��һ��

nClass = 100;

options = [];
options.WeightMode = 'Binary'; 
W = constructW(X,options);%����Ȩ���󣬶��������������̶�
options.maxIter = 1000;
options.nRepeat = 1;
options.alpha = 1;
%rand('twister',10);
[U,V,n,e] = GNMF(X',nClass,W,options);
newX=V*U';
SAD=sum(sum(abs(X-newX)))/(145*145);
RMSE=sum(sqrt(mean((X-newX).^2)))/145;
% imshow(newX);
subplot(1,2,1);imshow(X);title('Original');
subplot(1,2,2);imshow(newX);title('GNMF');xlabel("SAD:"+SAD+" RMSE:"+RMSE);
% rand('twister',5489);
% label = litekmeans(V,nClass,'Replicates',20);
% MIhat = MutualInfo(gnd,label);
% disp(['Clustering in the GNMF subspace. MIhat: ',num2str(MIhat)]);