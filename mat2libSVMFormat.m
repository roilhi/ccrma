function [] = mat2libSVMFormat(data,label,filename)
% Output files to the libSVM format

fid = fopen(filename, 'wt');
for i = 1:size(data,1)      
    fprintf(fid, '%s ',num2str(label(i)));
    for j = 1:size(data,2)          
        fprintf(fid, '%1.0i:%-12.8f',j, data(i,j));
    end
    fprintf(fid,'\n'); 
end
fclose(fid)       