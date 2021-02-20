
folder = 'testply';               % read testset
filePattern = fullfile(folder, '*.ply');
theFiles = dir(filePattern);

errors = zeros(7, 89, 18);

for file_num = 1 : length(theFiles)
    path = fullfile(theFiles(file_num).folder, theFiles(file_num).name);

    [a, f] = plyRead(path, 1);
    face1.Vertices = a;
    face1.Faces = f;
    
    theFiles_pred = ["2Dlandmarks", "3Dlandmarks", "fullhead", "remove10kpts", "removeEyes", "removeMouth", "removeNose", "removeZ", "set68pts", "set80pts", "set100pts", "set120pts", "set140pts", "set160pts", "set180pts" "set200pts", "set500pts", "set800pts"];
    for file_num_pred = 1 : length(theFiles_pred)
        path = fullfile('output/eigen1', theFiles_pred(file_num_pred), theFiles(file_num).name)
        
        [a, f] = plyRead(path, 1);
        face2.Vertices = a;
        face2.Faces = f;

        e = plotPlyError(face2, face1, [0 1] ,strcat(path, ".png"));
        errors(:, file_num, file_num_pred) = e;
    end
end

save('output/eigen1/errors.mat', 'errors');

