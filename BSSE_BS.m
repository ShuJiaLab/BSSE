function [output_image] = BSSE_BS(input_image,varargin)

if nargin == 0 || isempty(input_image)
    input_image = uigetimagefile;
end

a = input_image;

if size(a,3)==3
    a = rgb2gray(a);
end

parameters = {'high'; 'auto'; 512; 0};

if numel(varargin)>0
    for j = 1:numel(varargin)
        if not(isempty(varargin{j}))
            parameters{j} = varargin{j};
        end
    end
end

method = parameters{1};
% 'low' for non-unif bkg removal
% 'inter' for TVL denoising
% 'high' for the basic method
modality = parameters{2}; %  'manual'; %
% 'auto' for RF3D
% 'manual' for BM3D
N = parameters{3}; % tiling size
alpha = parameters{4}; % 0 or 1 threshold


%% Gaussian filter
a0 = a-imgaussfilt(a,1);

igauss = imgaussfilt(a,1);
igauss = igauss./max(igauss(:));
igauss(igauss<0)=0;

m1 = max(a0(:));
m2 = min(a0(:));
a1 = (a0 - m2)./(m1 - m2); %normalized
%a0(a0<0)=0;
%a1 = a0;


%% Denoising

switch modality
    
    case 'manual'
        
        prompt = {'Enter sigma value:'};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'1',};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        
        % BM3D
        
        [~ ,a2] = BM3D([],a1,str2double(answer));
%         
        
        
    case 'auto'
        
        % RF3D
        A = im2tiles(a1,N);
        
        PoolStart
        
        parfor idx = 1:numel(A)
            
            %             A2{idx} = RF3D(A{idx},[],[],'dct');
            [~ ,A2{idx}] = BM3D([],A{idx});
            
        end
        
        A2 = reshape(A2,size(A));
        
        a2 = cell2mat(A2);
        
        clear A2;
        
end

%% Thesholding

a3 = (a2).*(m1-m2)+ m2;

% a4 = (max(mean2(a3(1:20,1:20))-std2(a3(1:20,1:20)),a3));
a4 = (max(mean2(a3)-alpha.*std2(a3),a3));


%% Bkg removal
switch method
    
    case 'low'
        % non uniform bkg removal
        background = imopen(a,strel('disk',25));
        aa = a - background;
       
        % create mask from a4
        level = graythresh(a4);
        BW = imbinarize(a4,level);
        % smooth the mask
        [~, BW2] = BM3D([],BW,1e3);
        
        output_image = BW2.*aa;
        
    case 'inter'
        % Total Variation denoising to estimate low frequencies
        a_tvl = TVL1denoise(a, .1, 10);
        aa = (1.1.*nrm(a)-nrm(a_tvl));
        aa(aa<0)=0 ;
        
        % create mask from a4
        level = graythresh(a4);
        BW = imbinarize(a4,level);
        
        % smooth the mask
        [~, BW2] = BM3D([],BW,1e3);
        
        output_image = BW2.*aa;
        
    case 'high'
        output_image = a4;
end


%% Show final image

% figure;imshowpair(a,output_image,'montage')

function out = nrm(input)
        
        Max = max(input(:));
        Min = min(input(:));
        out = (input-Min)./(Max-Min);
        
end

end

