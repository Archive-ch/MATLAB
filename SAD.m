function sad = SAD(V,newV)
%SAD �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
[~,n]=size(V);
s=[];
for i=1:n
    a=V(:,i);
    b=newV(:,i);
    c=acos((a'*b)/(sqrt(a'*a)*sqrt(b'*b)));
    s(:,i)=c;
end
sad=mean(s);
end

