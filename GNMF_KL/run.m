clear;
% load('COIL20.mat');	
% S=load('C:\Users\Archive\Desktop\img\Indian_pines_gt.mat');%
% S1=struct2cell(S);%���ṹת��ΪԪ������
% V=cell2mat(S1);%��Ԫ������ת���Ϊ��ͨ�ľ���
% X = V/max(V(:));
load('Indian_pines_corrected.mat');
indian=indian_pines_corrected;
X=indian(:,:,140);
X=mapminmax(X,0,1);%��һ��
fea=X;
% nClass = 100;
%fea = tfidf(fea);
% fea=abs(fea);
% fea1=full(fea);
% nClass = length(unique(gnd));
disp('GNMF_KL...');	
Woptions = [];
Woptions.WeightMode = 'Cosine';%Binary  Cosine  HeatKernel
Woptions.k = 1;
W = constructW(fea,Woptions);
GNMFKLoptions = [];
GNMFKLoptions.maxIter = 1000;
GNMFKLoptions.alpha = 1;
GNMFKLoptions.weight = 'NCW';
nFactor = 100;
% rand('twister',5489);
% imshow(fea1);
[U, V] = GNMF_KL(fea', nFactor, W, GNMFKLoptions); %'
newX=V*U';
SAD=sum(sum(abs(X-newX)))/(145*145);
RMSE=sum(sqrt(mean((X-newX).^2)))/145;
%imshow(newX);
% subplot(1,2,1);imshow(fea);title('Original');
% subplot(1,2,2);imshow(newX);title('GNMF_KL');xlabel("SAD:"+SAD+" RMSE:"+RMSE);
% rand('twister',5489);
% label = litekmeans(V,nClass,'Replicates',20);
% MIhat = MutualInfo(gnd,label);
% disp(['Clustering in the GNMF subspace. MIhat: ',num2str(MIhat)]);

