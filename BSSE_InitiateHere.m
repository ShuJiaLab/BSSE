
%% 
clc
clear all
%%
fname='PUT_FILE_DIRECTION_AND_NAME.tif';
info = imfinfo(fname);
num_images = numel(info);
clear k; clear img; clear A;
for k=1:num_images
A = im2double(imread(fname,k, 'Info', info));
A_norm = A./max(A(:));
img = BSSE_BS(A,'low', 'auto'); %Background suppression
disp(k);

done = BSSE_SE(img);  %Signal Enhancement
done = done./max(done(:));
end
disp('done');
%%