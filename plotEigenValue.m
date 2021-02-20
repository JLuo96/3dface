folder = '90ply';
filePattern = fullfile(folder, '*.ply');
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
    path = fullfile(theFiles(k).folder, theFiles(k).name);
    % a= plyshape(path);
    [a, f] = plyRead(path, 0);
    n = size(a);
    a = reshape(a, [n(1)*n(2), 1]);
    if k==1
        faces = a;
    else
        faces = horzcat(faces, a);
    end
end

% calculate the mean face, and substract it
M = mean(faces, 2);
faces = faces - repmat(M,1,90);

[u, s, v] = svd(faces', 'econ');
save('EigenValue90.mat', 's')

eigen_value = load('EigenValue700.mat', 's');
s700 = eigen_value.s;

n = size(s700);

X = zeros(n(1), 1);
Y = zeros(n(1), 1);
Y2 = zeros(n(1), 1);

for k = 1:n(1)
    X(k, 1) = k;
    Y(k, 1) = s700(k, k);
end

for k = 1:90
    X(k, 1) = k;
    Y2(k, 1) = s(k, k);
end

plot(X,Y,X,Y2)