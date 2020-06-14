function Endmember = test_p(x)
[Lines, Columns, Bands]=size(x); 
N = Lines * Columns;    % ��Ԫ��
Data = reshape(x, N, Bands);
Data = permute(Data, [2,1]);
numEndmember = 145;   % ��Ԫ��
numSkewers = 145;   % ͶӰ������
skewers = randn(Bands, numSkewers);  % ͶӰ����
votes = zeros(N, 1);    % ����Ԫָ��
for i = 1:numSkewers
    r = skewers(:,i).' * Data;
    [val, id] = max(r);
    votes(id) = votes(id) + 1;
    [val, id] = min(r);
    votes(id) = votes(id) + 1;
end
[val, id] = sort(votes, 'descend');

Endmember = Data(:, id(1:numEndmember));
Endmember =sum(Endmember);
return;