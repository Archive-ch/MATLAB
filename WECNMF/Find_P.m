function [pi,P]= Find_P(S)
%Ȩ����P����Ⱦ����к͵ĵ���
[x,y]=size(S);
pi=sum(S,2);
P=zeros(x,y);
for i=1:x
    P(i,i)=1/pi(i,1);  
end
return

