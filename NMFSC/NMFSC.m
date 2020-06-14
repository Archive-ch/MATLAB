function [W,H,objhistory,iter,elapsed] = NMFSC( V, rdim, sW, sH, fname, showflag, stopconv, tol,timelimit, maxiter )

    
% ����Ƿ��зǸ�����
if min(V(:))<0, error('Negative values in data!'); end
    
% ��ֹ���
V = V/max(V(:));%��С����0��1��

% ����ά��
vdim = size(V,1);
samples = size(V,2);

cons=zeros(samples,samples);  %����samples*samples�������
consold=cons;
inc=0;
j=0;
    
% ������ʼ����
W = abs(randn(vdim,rdim)); %�û�����ͷ�Ⱦ���Ǹ�
H = abs(randn(rdim,samples));
% H = H./(sqrt(sum(H.^2,2))*ones(1,samples));

%ʹ��ʼ���������ȷ��ϡ����
if ~isempty(sW), 
    L1a = sqrt(vdim)-(sqrt(vdim)-1)*sW;  %��ŷ����þ�����ӽ���ϡ��Լ��,����L1�������̶�L2�������ֻ�������(L2����Ϊ1)��
    %ͨ��������L1����ʹ�������������ϡ���
    for i=1:rdim, 
        W(:,i) = projfunc(W(:,i),L1a,1,1); %W������i����ʾW����ĵ�i��
    end
end
if ~isempty(sH), 
    L1s = sqrt(samples)-(sqrt(samples)-1)*sH; 
    for i=1:rdim, 
        H(i,:) = (projfunc(H(i,:)',L1s,1,1))'; 
    end
end

% ��ʼ����ʾ
if showflag,
    figure(1); clf; % ��ʾ������ϡ��
    figure(2); clf; % ��ʾĿ�꺯��
    drawnow;        % ˢ����Ļ
end

% �����ʼĿ��
objhistory = 0.5*sum(sum((V-W*H).^2));

% ��ʼ����
stepsizeW = 0.5;
stepsizeH = 0.5;

timestarted = clock;  %��ȡ��ǰʱ��
elapsed = etime(clock,timestarted);%���㺯������ʱ��
% ��ʼ����
iter = 0;
for iter=1:maxiter,
    % ֹͣ����
    if objhistory(end) < tol | elapsed > timelimit,
        break;
    end

    % Show progress
    fprintf('[%d]: %.5f\n',iter,objhistory(end));    

     % ÿ��һ��ʱ�䱣��һ��
    if rem(iter,5)==0,
        % ÿ 5 �ε�����������
        j=j+1;
        
        % �������Ӿ���
        [y,index]=max(H,[],1);   %�����������
        mat1=repmat(index,samples,1);  % ����ָ���½�
        mat2=repmat(index',1,samples); % ��������Ҳ�
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
%         fprintf('Saving...');
%         save(fname,'V','W','H','iter','objhistory','elapsed','inc');
%         fprintf('Done!\n');
    end
	
    % Show stats ��ʾͳ����Ϣ
    if showflag & (rem(iter,5)==0),
        figure(1);
        subplot(3,1,1); 
        bar(sqrt(sum(W.^2)).*sqrt(sum(H'.^2)));
        
        cursW = (sqrt(vdim)-(sum(abs(W))./sqrt(sum(W.^2))))/(sqrt(vdim)-1);
        subplot(3,1,2); 
        bar(cursW);
        
        cursH = (sqrt(samples)-(sum(abs(H'))./sqrt(sum(H'.^2))))/(sqrt(samples)-1);
        subplot(3,1,3); 
        bar(cursH);
        
        if iter>1,
            figure(2);
            plot(objhistory(2:end));
        end
        drawnow;
    end
    
    %���µ�������
    iter = iter+1;    
    
    % Save old values
    Wold = W;
    Hold = H;
        
    % ----- Update H ---------------------------------------
    %ֻ��Ȩ�ؾ���H�ϼ�ϡ��Լ��
    if ~isempty(sH),
        
        % H �Ľ���
        dH = W'*(W*H-V);
        begobj = objhistory(end);
        
        % ȷ�����ǽ���Ŀ�꣡
        while 1,
            % ���ݶȷ�������һ������ͶӰ
            Hnew = H - stepsizeH*dH;
            for i=1:rdim, 
                Hnew(i,:) = (projfunc(Hnew(i,:)',L1s,1,1))'; %��H��ÿһ�н���ϡ�軯
            end

            % ������Ŀ��
            newobj = 0.5*sum(sum((V-W*Hnew).^2));

            % ���Ŀ���½������ǿ��Լ���...
            if newobj<=begobj,
                break;
            end

            %...�����С������С��Ȼ������
            stepsizeH = stepsizeH/2;
            fprintf('.');
            if stepsizeH<1e-200, 
                fprintf('Algorithm converged.\n');
                return; 
            end
        end
        
        % ��΢���Ӳ���
        stepsizeH = stepsizeH*1.2;
        H = Hnew;

    else
        % ʹ�ñ�׼ NMF ��ҳ���¹�����и���
        H = H.*(W'*V)./(W'*W*H + 1e-9);

        % ���¹淶����ʹ H �о��к㶨������
        norms = sqrt(sum(H'.^2));
        H = H./(norms'*ones(1,samples));
        W = W.*(ones(vdim,1)*norms);  
    end
    
    
    % ----- Update W ---------------------------------------

    if ~isempty(sW),    
        % W �Ľ���
        dW = (W*H-V)*H';
        begobj = 0.5*sum(sum((V-W*H).^2));
	
        % ȷ�����ǽ���Ŀ�꣡
        while 1,
            % ���ݶȷ�������һ������ͶӰ
            Wnew = W - stepsizeW*dW;
            norms = sqrt(sum(Wnew.^2));
            for i=1:rdim, 
                Wnew(:,i) = projfunc(Wnew(:,i),L1a*norms(i),(norms(i)^2),1); 
                %��W��ÿһ�н���ϡ�軯
            end
	
            % ������Ŀ��
            newobj = 0.5*sum(sum((V-Wnew*H).^2));
	    
            % ���Ŀ���½������ǿ��Լ���...
            if newobj<=begobj,
                break;
            end
	    
            % ...�����С������С��Ȼ������
            stepsizeW = stepsizeW/2;
            fprintf(',');
            if stepsizeW<1e-200, 
                fprintf('Algorithm converged.\n');
                return; 
            end
        end
        
        % ��΢���Ӳ���
        stepsizeW = stepsizeW*1.2;
        W = Wnew;
    
    else
        %  ʹ�ñ�׼ NMF ��ҳ���¹�����и���
        W = W.*(V*H')./(W*H*H' + 1e-9);	
    end
    
    % ����Ŀ��
    newobj = 0.5*sum(sum((V-W*H).^2));
    objhistory = [objhistory newobj];
end
