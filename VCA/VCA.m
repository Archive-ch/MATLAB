function [Ae, Rp, SAD, RMSE] = VCA(R,varargin)
%RΪ�߹������ݼ�ת���ľ��� vararginΪ�ɱ�����б� 
verbose = 'on';                          % ��ʾ�й�������ξ������Ϣ��
snr_input = 0;                           % default this flag is zero,������
% which means we estimate the SNR
dim_in_par = length(varargin);           %��ɱ��������
if (nargin - dim_in_par)~=1              %narginΪ�����������
    error('Wrong parameters');
elseif rem(dim_in_par,2) == 1
    error('Optional parameters should always go by pairs');
else
    for i = 1 : 2 : (dim_in_par-1)       %��1Ϊ��ʼ ÿ�μ�2 ������-1 �����ڣ����Բ�ִ��
        switch lower(varargin{i})
          case 'verbose'
               verbose = varargin{i+1};
          case 'endmembers'     
               p = varargin{i+1};
          case 'snr'     
               SNR = varargin{i+1};
               snr_input = 1;       % flag meaning that user gives SNR       
          otherwise
               fprintf(1,'Unrecognized parameter:%s\n', varargin{i});
        end %switch
    end %for
end %if
if isempty(R)
    error('there is no data');
else
    [L, N]=size(R);  % L number of bands (channels)  ��Ԫ�����ص�
                % N number of pixels (LxC)           ��
end

p=test_p(R);
p=ceil(p);%����ȡ��
if (p<0 || p>L || rem(p,1)~=0)
    error('ENDMEMBER parameter must be integer between 1 and L');
end

if snr_input==0
    r_m = mean(R,2);         %����������ľ�ֵ
    R_m = repmat(r_m,[1 N]); % ��չ��1��N��
    R_o = R - R_m;           % data with zero-mean 
    [Ud,Sd,Vd] = svds(R_o*R_o'/N,p);  %  ���� p ���������ֵ��
    x_p =  Ud' * R_o;                 % �����ֵ����ͶӰ�� p �ӿռ���

    SNR = estimate_snr(R,r_m,x_p);    %����ͼ�������

    if strcmp (verbose, 'on')
        fprintf(1,'SNR estimated = %g[dB]\n',SNR);
    end
else   
    if strcmp (verbose, 'on')
        fprintf(1,'input    SNR = %g[dB]\t',SNR); 
    end
end

SNR_th = 15 + 10*log10(p);

if SNR < SNR_th    %PCA��ά
    if strcmp (verbose, 'on')
        fprintf(1,'... Select the projective proj.\n',SNR); 
    end

    d = p-1;
    if snr_input==0
         Ud= Ud(:,1:d);      % �����ֵ����ͶӰ�� p-1 �ӿռ���
    else
         r_m = mean(R,2);      
         R_m = repmat(r_m,[1 N]); % mean of each band
         R_o = R - R_m;           % data with zero-mean 

         [Ud,Sd,Vd] = svds(R_o*R_o'/N,d);  % computes the p-projection matrix 

         x_p =  Ud' * R_o;                 % project thezeros mean data onto p-subspace

    end

    Rp =  Ud * x_p(1:d,:) + repmat(r_m,[1 N]);      % again in dimension L

    x = x_p(1:d,:);             %  x_p =  Ud' * R_o; is on a p-dim subspace
    c = max(sum(x.^2,1))^0.5;
    y = [x ; c*ones(1,N)] ;     %
else   %SVD��ά
    if strcmp (verbose, 'on')
        fprintf(1,'... Select proj. to p-1\n',SNR); 
    end

    d = p;
    [Ud,Sd,Vd] = svds(R*R'/N,d);         % computes the p-projection matrix 

    x_p = Ud'*R;
    Rp =  Ud * x_p(1:d,:);      % again in dimension L (note that x_p has no null mean)

    x =  Ud' * R;
    u = mean(x,2);        %equivalent to  u = Ud' * r_m
    y =  x./ repmat( sum( x .* repmat(u,[1 N]) ) ,[d 1]);  %��xͶӰ����ƽ���ϵõ�y

end
indice = zeros(1,p);
A = zeros(p,p);
A(p,1) = 1;

for i=1:p
      w = rand(p,1);             %�������һ�����ֵ��˹�������w��
      f = w - A*pinv(A)*w;
      f = f / sqrt(sum(f.^2));   %�������ӿռ��������
      
      v = f'*y;                  %������yͶӰ��f������
      [v_max, indice(i)] = max(abs(v));     %���ͶӰ�ļ�ֵ��Ӧ����Ԫλ��
      A(:,i) = y(:,indice(i));              %�������ȡһ��ͶӰ����
end
Ae = Rp(:,indice);               %��Ԫ�Ĺ�������

% SAD=sum(sum(abs(R-Rp)))/(145*145);%���׽Ǿ���
% RMSE=sum(sqrt(mean((R-Rp).^2)))/145;%���������

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of the vca function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Internal functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function snr_est = estimate_snr(R,r_m,x)  %����������

         [L , ~]=size(R);           % L number of bands (channels)
                                  % N number of pixels (Lines x Columns) 
         [p, N]=size(x);           % p number of endmembers (reduced dimension)

         P_y = sum(R(:).^2)/N;
         P_x = sum(x(:).^2)/N + r_m'*r_m;
         snr_est = 10*log10( (P_x - p/L*P_y)/(P_y- P_x) );
return;

