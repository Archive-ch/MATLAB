function [v,usediters] = projfunc( s, k1, k2, nn )
%ʵ�� L1\L2 ��׼ͶӰ
%�������� s���ҵ���ŷ�����������ӽ� s ��ʸ�� v �� sum��abs��v��=k1 �� sum��v^2��_k2��
%��������˶����Ʊ�־ nn�������� v ��������Ϊ�Ǹ� ��v=0����
    
% ����ά��
N = length(s);

% ���δ���÷Ǹ��Ա�־�����¼��־����ȡ abs
if ~nn,
    isneg = s<0;
    s = abs(s);
end

% ���Ƚ���ͶӰ����Լ����ƽ��
v = s + (k1-sum(s))/N;

% ��ʼ����coeff�������û�мٶ�Ϊ��Ԫ�أ�
zerocoeff = [];

j = 0;
while 1,

    % This does the proposed projection operator
    midpoint = ones(N,1)*k1/(N-length(zerocoeff));
    midpoint(zerocoeff) = 0;
    w = v-midpoint;
    a = sum(w.^2); %�ƣ�yi-mi��^2*��^2��2��mi��yi-mi��������m^2i-l2^2=0 ��ϵ��Ϊa,b,c
    b = 2*w'*v;
    c = sum(v.^2)-k2;
    alphap = (-b+real(sqrt(b^2-4*a.*c)))./(2*a);
    %fprintf('alpha1 %.5f ', size(alphap,1));
    v = w*alphap + v;
    
    if all(v>=0),
	%���v������Ԫ�ؾ�Ϊ�Ǹ������������
	usediters = j+1;
	break;
    end
        
    j = j+1;
        
    % ����������Ϊ�㣬����Ϣ�м�ȥ�ʵ�������
    zerocoeff = find(v<=0);
    v(zerocoeff) = 0;
    tempsum = sum(v);
    v = v + (k1-tempsum)/(N-length(zerocoeff));
    v(zerocoeff) = 0;
            
end

% ���δ���÷Ǹ��Ա�־���򽫷��ŷ��ص��������
if ~nn,
    v = (-2*isneg + 1).*v;
end

% Check for problems
if max(max(abs(imag(v))))>1e-10,
    error('Somehow got imaginary values!');
end
