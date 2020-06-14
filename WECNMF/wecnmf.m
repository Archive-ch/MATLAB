function [A,S]=wecnmf(X,k)

maxiter=1000;
[r,c]=size(X); 
A=rand(r,k);
S=rand(k,c);
showflag=0;
objhistory = 0.5*sum(sum((X-A*S).^2));%Ŀ�꺯��
timestarted = clock;  %��ȡ��ǰʱ��
elapsed = etime(clock,timestarted);%���㺯������ʱ��
timelimit=100;
tol=0.0001;
cons=zeros(c,c);  %����samples*samples�������
consold=cons;
inc=0;
stopconv=42;
fname=['Indian_pines'];
% ��ʼ����ʾ
if showflag,
    figure(1); clf; % ��ʾ������ϡ��
    figure(2); clf; % ��ʾĿ�꺯��
    drawnow;        % ˢ����Ļ
end


for iter=1:maxiter
     % ֹͣ����
    if objhistory(end) < tol || elapsed > timelimit
        break;
    end
    
    fprintf('[%d]: %.5f\n',iter,objhistory(end));    
    
     % ÿ��һ��ʱ�䱣��һ��
    if rem(iter,5)==0
        % ÿ 5 �ε�����������   
        % �������Ӿ���
        [~,index]=max(S,[],1);   %�����������
        mat1=repmat(index,c,1);  % ����ָ���½�
        mat2=repmat(index',1,c); % ��������Ҳ�
        cons=mat1==mat2;
        
        if(sum(sum(cons~=consold))==0) % ���Ӿ���δ����
            inc=inc+1;                     %�ۻ�����
        end
        fprintf('\t%d\t%d\t%d\n',iter,inc,sum(sum(cons~=consold))),
        
        if(inc>=stopconv)
            break,                % �����ں�������ֹͣ�仯 
        end
        
        consold=cons;
        
        elapsed = etime(clock,timestarted);
        fprintf('Saving...');
        save(fname,'X','A','S','iter','objhistory','elapsed','inc');
        fprintf('Done!\n');
    end
    
    %��ʾ������Ϣ
    if showflag & (rem(iter,5)==0),
        figure(1);
        subplot(3,1,1); 
        bar(sqrt(sum(A.^2)).*sqrt(sum(S'.^2)));

        cursA = (sqrt(r)-(sum(abs(A))./sqrt(sum(A.^2))))/(sqrt(r)-1);
        subplot(3,1,2); 
        bar(cursA);

        cursS = (sqrt(c)-(sum(abs(S'))./sqrt(sum(S'.^2))))/(sqrt(c)-1);
        subplot(3,1,3); 
        bar(cursS);

    if iter>1,
        figure(2);
        plot(objhistory(2:end));
    end
    drawnow;
    end
    
     
    %��������
    [pi,P]=Find_P(S);%Ȩ����P����Ⱦ����к͵ĵ���
    M_m=mean(X,2); %����������ľ�ֵ
    M= repmat(M_m,[1 k]); % ��չ��1��N��
    WED=0.5*sum(sum(((A-M)*P).^2));
    
    WED_A=(A-M)*P*(P'); %�Ի�������ƫ��
    for j=1:k %��ϵ��������ƫ��
        AM=A(:,j)-M(:,j);
        WED_S(j,:)=-(1/power(pi(j,1),3))*power(AM,2);
    end

    A=A.*(X*S'-0.5*WED_A)./((A*S*(S'))+eps);
    S=S.*((A')*X-0.5*WED_S)./(((A')*A*S)+eps);
    
    % ����Ŀ��
    newobj = 0.5*sum(sum((X-A*S).^2))+WED;
    objhistory = [objhistory newobj];
end

return
