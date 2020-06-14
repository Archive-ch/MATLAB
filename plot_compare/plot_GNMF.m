function [newX] = plot_GNMF(X)
%PLOT_GNMF �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
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
end

