% % % 
% folder = 'trainply2';
% filePattern = fullfile(folder, '*.ply');
% theFiles = dir(filePattern);
% for k = 1 : length(theFiles)
%     path = fullfile(theFiles(k).folder, theFiles(k).name);
%     % a= plyshape(path);
%     [a, f] = plyRead(path, 0);
%     n = size(a);
%     a = reshape(a, [n(1)*n(2), 1]);
%     if k==1
%         faces = a;
%     else
%         faces = horzcat(faces, a);
%     end
% end
% size(faces);
% 
% face_num = length(theFiles);
% 
% % calculate the mean face, and substract it
% M = mean(faces, 2);
% faces = faces - repmat(M,1,face_num);
% 
% % calcuate the svd, and v are all the eigenvectors we need
% [u, s, v] = svd(faces', 'econ');
% % for k = 1 : 90
% %     s(k, k)
% % end
% 
% % s(90, 90)
% % s(89, 89)
% save('EigenValue.mat', 's')
% save('v.mat', 'v');



% % load saved PCA and mean face
[M, f] = plyRead('mean.ply', 0);
n = size(M);                      % n = [26317, 3]; n(1)=26317: number of vertices; n(2)=3: x, y and z
M = reshape(M, [n(1)*n(2), 1]);

PCA = load('v.mat', 'v');
v = PCA.v;

compo_num = 7;
v = v(:, 1:compo_num);            % set how many eigen vector to use

folder = 'testply';               % read testset
filePattern = fullfile(folder, '*.ply');
theFiles = dir(filePattern);
for file_num = 1 : length(theFiles)
    path = fullfile(theFiles(file_num).folder, theFiles(file_num).name);
    [a, f] = plyRead(path, 0);
    % a = a * 1.05;    % explore some scale problem
    n = size(a);
    
    
    % % full face reconstruction
    a1 = reshape(a, [n(1)*n(2), 1]);
    a1 = a1 - M;           % test face substract mean face
    w = pinv(v) * a1;       % calculate the weights
    recon = v * w;         % calculate the reconstruction
    mae(recon, a1, n);     % print mae, mse, max absolute error, min absolute error, median absolute error
    out = reshape(recon+M, [n(1), n(2)]); % add reconstruction with mean
    path = fullfile('output/fullhead', theFiles(file_num).name);
    plyWrite(out,f,path);                 % write output as ply file
    
    
    % % % %     size(a) = [n(1),      n(2)     ]
    % % % %     size(v) = [n(1)*n(2), compo_num]
    % % % %     size(M) = [n(1)*n(2), 1        ]       

    % % remove all the z
    am = a;                          
    vm = v;                          
    Mm = M;                          % save copy for test face, PCA matrix and mean face.
    for k = 1 : n(1)
        am(k, 3) = NaN;              % set z coordinate to be NaN
        vm(k+n(1)*2, :) = NaN;       % set corresponding part of PCA matric to be NaN
        Mm(k+n(1)*2) = NaN;          % set corresponding part of mean face to be NaN
    end
    am = reshape(am, [n(1)*n(2), 1]);
    am = am - Mm;                    % test face substract mean face
    am = am(~isnan(am));
    vm(any(isnan(vm), 2), :) = [];
    Mm = Mm(~isnan(Mm));             % remove all NaN in am, vm and Mm

    w1 = pinv(vm) * am;              % calculate weights
    recon1 = v * w1;                 % calculate reconstruction
    err1 = mae(recon1, a1, n);       % print mae, mse, max absolute error, min absolute error, median absolute error
    out = reshape(recon1+M, [n(1), n(2)]);
    path = fullfile('output/removeZ', theFiles(file_num).name);
    plyWrite(out,f,path);            % save ply file

% 
%     % % remove 10k random points (overlapping doesn't matter)
%     am = a;
%     vm = v;
%     Mm = M;                          % save copy for test face, PCA matrix and mean face.
%     for k = 1 : 10000
%         r = randperm(n(1), 1);       % ramdom integer between 1 to 10000
%         am(r, 1) = NaN;
%         am(r, 2) = NaN;
%         am(r, 3) = NaN;
%         vm(r, :) = NaN;
%         vm(r+n(1), :) = NaN;
%         vm(r+n(1)*2, :) = NaN;
%         Mm(r) = NaN;
%         Mm(r+n(1)) = NaN;
%         Mm(r+n(1)*2) = NaN;          % set the corresponding part of am, vm and Mm to be NaN
%     end
%     am = reshape(am, [n(1)*n(2), 1]);
%     am = am - Mm;                    % test face substract mean face
%     am = am(~isnan(am));
%     vm(any(isnan(vm), 2), :) = [];
%     Mm = Mm(~isnan(Mm));             % remove all NaN in am, vm and Mm
% 
%     w1 = pinv(vm) * am;              % calcualte the weights
%     recon1 = v * w1;                 % calculate the reconstruction
%     err1 = mae(recon1, a1, n);       % print mae, mse, max absolute error, min absolute error, median absolute error
%     out = reshape(recon1+M, [n(1), n(2)]);
%     path = fullfile('output/remove10kpts', theFiles(file_num).name);
%     plyWrite(out,f,path);            % save ply
%     
%     
%     % % set 68 points available
%     am = NaN(size(a));
%     vm = NaN(size(v));
%     Mm = NaN(size(M));               % everyone is NaN first, no data available
%     for k = 1 : 68
%         r = randperm(n(1), 1);
%         am(r, 1) = a(r, 1);
%         am(r, 2) = a(r, 2);
%         am(r, 3) = a(r, 3);
%         vm(r, :) = v(r, :);
%         vm(r+n(1), :) = v(r+n(1), :);
%         vm(r+n(1)*2, :) = v(r+n(1)*2, :);
%         Mm(r) = M(r);
%         Mm(r+n(1)) = M(r+n(1));
%         Mm(r+n(1)*2) = M(r+n(1)*2);    
%     end                             % set 200 available points from original a, v and M 
%     am = reshape(am, [n(1)*n(2), 1]);
%     am = am - Mm;                   % test face substract mean face
%     am = am(~isnan(am));
%     vm(any(isnan(vm), 2), :) = [];
%     Mm = Mm(~isnan(Mm));            % remove all NaN in am, vm and Mm
%     w1 = pinv(vm) * am;             % calculate the weights
%     recon1 = v * w1;                % calculate the weights
%     % err1 = mae(recon1, a1, n);      % print mae, mse, max absolute error, min absolute error, median absolute error
%     out = reshape(recon1+M, [n(1), n(2)]);
%     path = fullfile('output/set68pts', theFiles(file_num).name);
%     plyWrite(out,f,path);           % save ply
% 
% 
%     % set 80 points available
%     am = NaN(size(a));
%     vm = NaN(size(v));
%     Mm = NaN(size(M));               % everyone is NaN first, no data available
%     for k = 1 : 80
%         r = randperm(n(1), 1);
%         am(r, 1) = a(r, 1);
%         am(r, 2) = a(r, 2);
%         am(r, 3) = a(r, 3);
%         vm(r, :) = v(r, :);
%         vm(r+n(1), :) = v(r+n(1), :);
%         vm(r+n(1)*2, :) = v(r+n(1)*2, :);
%         Mm(r) = M(r);
%         Mm(r+n(1)) = M(r+n(1));
%         Mm(r+n(1)*2) = M(r+n(1)*2);    
%     end                             % set 200 available points from original a, v and M 
%     am = reshape(am, [n(1)*n(2), 1]);
%     am = am - Mm;                   % test face substract mean face
%     am = am(~isnan(am));
%     vm(any(isnan(vm), 2), :) = [];
%     Mm = Mm(~isnan(Mm));            % remove all NaN in am, vm and Mm
%     w1 = pinv(vm) * am;             % calculate the weights
%     recon1 = v * w1;                % calculate the weights
%     err1 = mae(recon1, a1, n);      % print mae, mse, max absolute error, min absolute error, median absolute error
%     out = reshape(recon1+M, [n(1), n(2)]);
%     path = fullfile('output/set80pts', theFiles(file_num).name);
%     plyWrite(out,f,path);           % save ply
%     
%     
%     % set 100 points available
%     am = NaN(size(a));
%     vm = NaN(size(v));
%     Mm = NaN(size(M));               % everyone is NaN first, no data available
%     for k = 1 : 100
%         r = randperm(n(1), 1);
%         am(r, 1) = a(r, 1);
%         am(r, 2) = a(r, 2);
%         am(r, 3) = a(r, 3);
%         vm(r, :) = v(r, :);
%         vm(r+n(1), :) = v(r+n(1), :);
%         vm(r+n(1)*2, :) = v(r+n(1)*2, :);
%         Mm(r) = M(r);
%         Mm(r+n(1)) = M(r+n(1));
%         Mm(r+n(1)*2) = M(r+n(1)*2);    
%     end                             % set 200 available points from original a, v and M 
%     am = reshape(am, [n(1)*n(2), 1]);
%     am = am - Mm;                   % test face substract mean face
%     am = am(~isnan(am));
%     vm(any(isnan(vm), 2), :) = [];
%     Mm = Mm(~isnan(Mm));            % remove all NaN in am, vm and Mm
%     w1 = pinv(vm) * am;             % calculate the weights
%     recon1 = v * w1;                % calculate the weights
%     err1 = mae(recon1, a1, n);      % print mae, mse, max absolute error, min absolute error, median absolute error
%     out = reshape(recon1+M, [n(1), n(2)]);
%     path = fullfile('output/set100pts', theFiles(file_num).name);
%     plyWrite(out,f,path);           % save ply
% 
% 
%     % set 120 points available
%     am = NaN(size(a));
%     vm = NaN(size(v));
%     Mm = NaN(size(M));               % everyone is NaN first, no data available
%     for k = 1 : 120
%         r = randperm(n(1), 1);
%         am(r, 1) = a(r, 1);
%         am(r, 2) = a(r, 2);
%         am(r, 3) = a(r, 3);
%         vm(r, :) = v(r, :);
%         vm(r+n(1), :) = v(r+n(1), :);
%         vm(r+n(1)*2, :) = v(r+n(1)*2, :);
%         Mm(r) = M(r);
%         Mm(r+n(1)) = M(r+n(1));
%         Mm(r+n(1)*2) = M(r+n(1)*2);    
%     end                             % set 200 available points from original a, v and M 
%     am = reshape(am, [n(1)*n(2), 1]);
%     am = am - Mm;                   % test face substract mean face
%     am = am(~isnan(am));
%     vm(any(isnan(vm), 2), :) = [];
%     Mm = Mm(~isnan(Mm));            % remove all NaN in am, vm and Mm
%     w1 = pinv(vm) * am;             % calculate the weights
%     recon1 = v * w1;                % calculate the weights
%     err1 = mae(recon1, a1, n);      % print mae, mse, max absolute error, min absolute error, median absolute error
%     out = reshape(recon1+M, [n(1), n(2)]);
%     path = fullfile('output/set120pts', theFiles(file_num).name);
%     plyWrite(out,f,path);           % save ply    
% 
%     
%     % set 140 points available
%     am = NaN(size(a));
%     vm = NaN(size(v));
%     Mm = NaN(size(M));               % everyone is NaN first, no data available
%     for k = 1 : 140
%         r = randperm(n(1), 1);
%         am(r, 1) = a(r, 1);
%         am(r, 2) = a(r, 2);
%         am(r, 3) = a(r, 3);
%         vm(r, :) = v(r, :);
%         vm(r+n(1), :) = v(r+n(1), :);
%         vm(r+n(1)*2, :) = v(r+n(1)*2, :);
%         Mm(r) = M(r);
%         Mm(r+n(1)) = M(r+n(1));
%         Mm(r+n(1)*2) = M(r+n(1)*2);    
%     end                             % set 200 available points from original a, v and M 
%     am = reshape(am, [n(1)*n(2), 1]);
%     am = am - Mm;                   % test face substract mean face
%     am = am(~isnan(am));
%     vm(any(isnan(vm), 2), :) = [];
%     Mm = Mm(~isnan(Mm));            % remove all NaN in am, vm and Mm
%     w1 = pinv(vm) * am;             % calculate the weights
%     recon1 = v * w1;                % calculate the weights
%     err1 = mae(recon1, a1, n);      % print mae, mse, max absolute error, min absolute error, median absolute error
%     out = reshape(recon1+M, [n(1), n(2)]);
%     path = fullfile('output/set140pts', theFiles(file_num).name);
%     plyWrite(out,f,path);           % save ply    
% 
%     
%     % set 160 points available
%     am = NaN(size(a));
%     vm = NaN(size(v));
%     Mm = NaN(size(M));               % everyone is NaN first, no data available
%     for k = 1 : 160
%         r = randperm(n(1), 1);
%         am(r, 1) = a(r, 1);
%         am(r, 2) = a(r, 2);
%         am(r, 3) = a(r, 3);
%         vm(r, :) = v(r, :);
%         vm(r+n(1), :) = v(r+n(1), :);
%         vm(r+n(1)*2, :) = v(r+n(1)*2, :);
%         Mm(r) = M(r);
%         Mm(r+n(1)) = M(r+n(1));
%         Mm(r+n(1)*2) = M(r+n(1)*2);    
%     end                             % set 200 available points from original a, v and M 
%     am = reshape(am, [n(1)*n(2), 1]);
%     am = am - Mm;                   % test face substract mean face
%     am = am(~isnan(am));
%     vm(any(isnan(vm), 2), :) = [];
%     Mm = Mm(~isnan(Mm));            % remove all NaN in am, vm and Mm
%     w1 = pinv(vm) * am;             % calculate the weights
%     recon1 = v * w1;                % calculate the weights
%     err1 = mae(recon1, a1, n);      % print mae, mse, max absolute error, min absolute error, median absolute error
%     out = reshape(recon1+M, [n(1), n(2)]);
%     path = fullfile('output/set160pts', theFiles(file_num).name);
%     plyWrite(out,f,path);           % save ply 
%     
%     
%     % set 180 points available
%     am = NaN(size(a));
%     vm = NaN(size(v));
%     Mm = NaN(size(M));               % everyone is NaN first, no data available
%     for k = 1 : 180
%         r = randperm(n(1), 1);
%         am(r, 1) = a(r, 1);
%         am(r, 2) = a(r, 2);
%         am(r, 3) = a(r, 3);
%         vm(r, :) = v(r, :);
%         vm(r+n(1), :) = v(r+n(1), :);
%         vm(r+n(1)*2, :) = v(r+n(1)*2, :);
%         Mm(r) = M(r);
%         Mm(r+n(1)) = M(r+n(1));
%         Mm(r+n(1)*2) = M(r+n(1)*2);    
%     end                             % set 200 available points from original a, v and M 
%     am = reshape(am, [n(1)*n(2), 1]);
%     am = am - Mm;                   % test face substract mean face
%     am = am(~isnan(am));
%     vm(any(isnan(vm), 2), :) = [];
%     Mm = Mm(~isnan(Mm));            % remove all NaN in am, vm and Mm
%     w1 = pinv(vm) * am;             % calculate the weights
%     recon1 = v * w1;                % calculate the weights
%     err1 = mae(recon1, a1, n);      % print mae, mse, max absolute error, min absolute error, median absolute error
%     out = reshape(recon1+M, [n(1), n(2)]);
%     path = fullfile('output/set180pts', theFiles(file_num).name);
%     plyWrite(out,f,path);           % save ply    
%     

    % % set 200 points available
    sample200 = load('200pts.mat', 'indexes');
    indexes = sample200.indexes;
    sample_size = size(indexes);
    am = NaN(size(a));
    vm = NaN(size(v));
    Mm = NaN(size(M));               % everyone is NaN first, no data available
    for k = 1 : sample_size(1)
        r = randperm(n(1), 1);
        am(indexes(k, 1), :) = a(indexes(k, 1), :);
        vm(indexes(k, 1), :) = v(indexes(k, 1), :);
        vm(indexes(k, 1)+n(1), :) = v(indexes(k, 1)+n(1), :);
        vm(indexes(k, 1)+n(1)*2, :) = v(indexes(k, 1)+n(1)*2, :);
        Mm(indexes(k, 1)) = M(indexes(k, 1));
        Mm(indexes(k, 1)+n(1)) = M(indexes(k, 1)+n(1));
        Mm(indexes(k, 1)+n(1)*2) = M(indexes(k, 1)+n(1)*2);    
    end                             % set 200 available points from original a, v and M 
    am = reshape(am, [n(1)*n(2), 1]);
    am = am - Mm;                   % test face substract mean face
    am = am(~isnan(am));
    vm(any(isnan(vm), 2), :) = [];
    Mm = Mm(~isnan(Mm));            % remove all NaN in am, vm and Mm
    w1 = pinv(vm) * am;             % calculate the weights
    recon1 = v * w1;                % calculate the weights
    % err1 = mae(recon1, a1, n);      % print mae, mse, max absolute error, min absolute error, median absolute error
    out = reshape(recon1+M, [n(1), n(2)]);
    path = fullfile('output/set200pts', theFiles(file_num).name);
    plyWrite(out,f,path);           % save ply


    % % set 500 points available
    sample500 = load('500pts.mat', 'indexes');
    indexes = sample500.indexes;
    sample_size = size(indexes);
    am = NaN(size(a));
    vm = NaN(size(v));
    Mm = NaN(size(M));               % everyone is NaN first, no data available
    for k = 1 : sample_size(1)
        r = randperm(n(1), 1);
        am(indexes(k, 1), :) = a(indexes(k, 1), :);
        vm(indexes(k, 1), :) = v(indexes(k, 1), :);
        vm(indexes(k, 1)+n(1), :) = v(indexes(k, 1)+n(1), :);
        vm(indexes(k, 1)+n(1)*2, :) = v(indexes(k, 1)+n(1)*2, :);
        Mm(indexes(k, 1)) = M(indexes(k, 1));
        Mm(indexes(k, 1)+n(1)) = M(indexes(k, 1)+n(1));
        Mm(indexes(k, 1)+n(1)*2) = M(indexes(k, 1)+n(1)*2);    
    end                             % set 200 available points from original a, v and M 
    am = reshape(am, [n(1)*n(2), 1]);
    am = am - Mm;                   % test face substract mean face
    am = am(~isnan(am));
    vm(any(isnan(vm), 2), :) = [];
    Mm = Mm(~isnan(Mm));            % remove all NaN in am, vm and Mm
    w1 = pinv(vm) * am;             % calculate the weights
    recon1 = v * w1;                % calculate the weights
    % err1 = mae(recon1, a1, n);      % print mae, mse, max absolute error, min absolute error, median absolute error
    out = reshape(recon1+M, [n(1), n(2)]);
    path = fullfile('output/set500pts', theFiles(file_num).name);
    plyWrite(out,f,path);           % save ply


    % % set 800 points available
    sample800 = load('800pts.mat', 'indexes');
    indexes = sample800.indexes;
    sample_size = size(indexes);
    am = NaN(size(a));
    vm = NaN(size(v));
    Mm = NaN(size(M));               % everyone is NaN first, no data available
    for k = 1 : sample_size(1)
        r = randperm(n(1), 1);
        am(indexes(k, 1), :) = a(indexes(k, 1), :);
        vm(indexes(k, 1), :) = v(indexes(k, 1), :);
        vm(indexes(k, 1)+n(1), :) = v(indexes(k, 1)+n(1), :);
        vm(indexes(k, 1)+n(1)*2, :) = v(indexes(k, 1)+n(1)*2, :);
        Mm(indexes(k, 1)) = M(indexes(k, 1));
        Mm(indexes(k, 1)+n(1)) = M(indexes(k, 1)+n(1));
        Mm(indexes(k, 1)+n(1)*2) = M(indexes(k, 1)+n(1)*2);    
    end                             % set 200 available points from original a, v and M 
    am = reshape(am, [n(1)*n(2), 1]);
    am = am - Mm;                   % test face substract mean face
    am = am(~isnan(am));
    vm(any(isnan(vm), 2), :) = [];
    Mm = Mm(~isnan(Mm));            % remove all NaN in am, vm and Mm
    w1 = pinv(vm) * am;             % calculate the weights
    recon1 = v * w1;                % calculate the weights
    % err1 = mae(recon1, a1, n);      % print mae, mse, max absolute error, min absolute error, median absolute error
    out = reshape(recon1+M, [n(1), n(2)]);
    path = fullfile('output/set800pts', theFiles(file_num).name);
    plyWrite(out,f,path);           % save ply



    % % set 68 2D landmarks(LM) available. LM contain all landmark indexes.
    am = NaN(size(a));
    vm = NaN(size(v));
    Mm = NaN(size(M));
    LM = [23404 4607 4615 4655 20356 4643 5022 5013 1681 1692 11470 10441 1336 1343 1303 1295 2372 6143 6141 6126 6113 6109 2844 2762 2765 2774 2789 6053 6041 1870 1855 4728 4870 1807 1551 1419 3434 3414 3447 3457 3309 3373 3179 151 127 143 3236 47 21018 4985 4898 6571 1575 1663 1599 1899 12138 5231 21978 5101 21067 21239 11378 11369 11553 12048 5212 21892];
    LM = LM + 1;
    for k = 1:68
        am(LM(k), 1) = a(LM(k), 1);  
        am(LM(k), 2) = a(LM(k), 2);
        vm(LM(k), :) = v(LM(k), :);
        vm(LM(k)+n(1), :) = v(LM(k)+n(1), :);
        Mm(LM(k)) = M(LM(k));
        Mm(LM(k)+n(1)) = M(LM(k)+n(1));     
    end
    am = reshape(am, [n(1)*n(2), 1]);
    am = am - Mm;
    am = am(~isnan(am));
    vm(any(isnan(vm), 2), :) = [];
    Mm = Mm(~isnan(Mm));
    w1 = pinv(vm) * am;
    recon1 = v * w1;
    err1 = mae(recon1, a1, n);
    out = reshape(recon1+M, [n(1), n(2)]);
    path = fullfile('output/2Dlandmarks', theFiles(file_num).name);
    plyWrite(out,f,path);


    % % set 68 3D landmarks(LM) available
    am = NaN(size(a));
    vm = NaN(size(v));
    Mm = NaN(size(M));
    LM = [23404 4607 4615 4655 20356 4643 5022 5013 1681 1692 11470 10441 1336 1343 1303 1295 2372 6143 6141 6126 6113 6109 2844 2762 2765 2774 2789 6053 6041 1870 1855 4728 4870 1807 1551 1419 3434 3414 3447 3457 3309 3373 3179 151 127 143 3236 47 21018 4985 4898 6571 1575 1663 1599 1899 12138 5231 21978 5101 21067 21239 11378 11369 11553 12048 5212 21892];
    LM = LM + 1;
    for k = 1:68
        am(LM(k), 1) = a(LM(k), 1);
        am(LM(k), 2) = a(LM(k), 2);
        am(LM(k), 3) = a(LM(k), 3);                       % z
        vm(LM(k), :) = v(LM(k), :);
        vm(LM(k)+n(1), :) = v(LM(k)+n(1), :);
        vm(LM(k)+n(1)*2, :) = v(LM(k)+n(1)*2, :);         % z
        Mm(LM(k)) = M(LM(k));
        Mm(LM(k)+n(1)) = M(LM(k)+n(1));
        Mm(LM(k)+n(1)*2) = M(LM(k)+n(1)*2);               % z 
    end
    am = reshape(am, [n(1)*n(2), 1]);
    am = am - Mm;
    am = am(~isnan(am));
    vm(any(isnan(vm), 2), :) = [];
    Mm = Mm(~isnan(Mm));
    w1 = pinv(vm) * am;
    recon1 = v * w1;
    err1 = mae(recon1, a1, n);
    out = reshape(recon1+M, [n(1), n(2)]);
    path = fullfile('output/3Dlandmarks', theFiles(file_num).name);
    plyWrite(out,f,path);



    % % remove eyes
    am = a;
    vm = v;
    Mm = M;
    for k = 1 : n(1)
        if a(k, 2) > 15 & a(k, 2) < 55 & a(k, 1) < 60 & a(k, 1) > -60  % eye missing
            am(k, 1) = NaN;
            am(k, 2) = NaN;
            am(k, 3) = NaN;
            vm(k, :) = NaN;
            vm(k+n(1), :) = NaN;
            vm(k+n(1)*2, :) = NaN;
            Mm(k) = NaN;
            Mm(k+n(1)) = NaN;
            Mm(k+n(1)*2) = NaN;
        end
    end
    am = reshape(am, [n(1)*n(2), 1]);
    am = am - Mm;
    am = am(~isnan(am));
    vm(any(isnan(vm), 2), :) = [];
    Mm = Mm(~isnan(Mm));

    w1 = pinv(vm) * am;
    recon1 = v * w1;
    err1 = mae(recon1, a1, n);
    out = reshape(recon1+M, [n(1), n(2)]);
    path = fullfile('output/removeEyes', theFiles(file_num).name);
    plyWrite(out,f,path);



    % % remove nose
    am = a;
    vm = v;
    Mm = M;
    for k = 1 : n(1)
        if a(k, 1) < 20 & a(k, 1) > -20 & a(k, 2) < 30 & a(k, 2) > -20
            am(k, 1) = NaN;
            am(k, 2) = NaN;
            am(k, 3) = NaN;
            vm(k, :) = NaN;
            vm(k+n(1), :) = NaN;
            vm(k+n(1)*2, :) = NaN;
            Mm(k) = NaN;
            Mm(k+n(1)) = NaN;
            Mm(k+n(1)*2) = NaN;
        end
    end
    am = reshape(am, [n(1)*n(2), 1]);
    am = am - Mm;
    am = am(~isnan(am));
    vm(any(isnan(vm), 2), :) = [];
    Mm = Mm(~isnan(Mm));

    w1 = pinv(vm) * am;
    recon1 = v * w1;
    err1 = mae(recon1, a1, n);
    out = reshape(recon1+M, [n(1), n(2)]);
    path = fullfile('output/removeNose', theFiles(file_num).name);
    plyWrite(out,f,path);


    % % remove mouth
    am = a;
    vm = v;
    Mm = M;
    for k = 1 : n(1)
        if a (k, 1) < 35 & a(k, 1) > -35 & a(k, 2) < -25 & a(k, 2) > -55  % mouth missing
            am(k, 1) = NaN;
            am(k, 2) = NaN;
            am(k, 3) = NaN;
            vm(k, :) = NaN;
            vm(k+n(1), :) = NaN;
            vm(k+n(1)*2, :) = NaN;
            Mm(k) = NaN;
            Mm(k+n(1)) = NaN;
            Mm(k+n(1)*2) = NaN;
        end
    end
    am = reshape(am, [n(1)*n(2), 1]);
    am = am - Mm;
    am = am(~isnan(am));
    vm(any(isnan(vm), 2), :) = [];
    Mm = Mm(~isnan(Mm));

    w1 = pinv(vm) * am;
    recon1 = v * w1;
    err1 = mae(recon1, a1, n);
    out = reshape(recon1+M, [n(1), n(2)]);
    path = fullfile('output/removeMouth', theFiles(file_num).name);
    plyWrite(out,f,path);
    
end
