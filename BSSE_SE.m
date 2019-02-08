function SE_done = BSSE_SE(image)
%%
% Prameter %
lambda = 520; %[nm]
%lambda = 680;
%NA = 1.45;
NA = 0.5;
nw = 1;
%
M = 2; %Sub-pixelated Magnification
%%
% Initiate %
d=(lambda)./(2*NA);
fwhm=d;
sd=fwhm./(2*sqrt(2*log(2)));
aaa=(1./(sd*sqrt(2*pi)))*exp(-1/2);
aaatop = (1./(sd*sqrt(2*pi)));
%%
% Analysis %
pixelX=size(image,1);pixelY=size(image,2);
G0 = imresize(image, M, {@(image)Mitchell_vect(image,0,1/2),3}); %Intensity
G = G0;
G  = G - min(G(:));
%      if min(G(:))~=0
%      G = G-min(G(:)); % offset removal
%      G(G<0)=0;
%      disp('Offset removal');
%      end

if max(G(:))~=0
   G=G./max(G(:)); % normalized
end
G=G*aaatop;     % scaled
G1 = G;
        
[Gx1,Gy1]=imgradientxy(G1);
Gmag = hypot(Gx1,Gy1);
w=aaa./max(Gmag(:));

%%
% Intensity Weighting 
%         for xi=1:pixelX*M
%             for yj=1:pixelY*M
%                 Gmag(xi,yj)=Gmag(xi,yj)*G1(xi,yj);
%             end
%         end
%         grass=G1.^2-Gmag;
%         wgrass=G1.^2-Gmag*w;
%%

grass=G1-Gmag;
wgrass=G1-Gmag*w;
grass(grass<0)=0;
wgrass(wgrass<0)=0;

 % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
[f1xx_M fxy_M]=imgradientxy(Gx1); %%Hessian matrix coefficient for 2nd driv.
[fyx_M f1yy_M]=imgradientxy(Gy1);
fxxsum=f1xx_M+f1yy_M;
 % % % % % % % % % % % % % % % S S D % % % % % % % % % % % % % % % % % % % %
wgrass_zero=wgrass;
for j=2:M*pixelX-1
            for i=2:M*pixelY-1
                if abs(wgrass(j,i)-grass(j,i))>0
                    k=1;
                    if fxxsum(j,i)>0 && fxxsum(j,i+k)>0
                        wgrass_zero(j,i)=0;
                    end
                    if fxxsum(j,i)>0 && fxxsum(j+k,i)>0
                        wgrass_zero(j,i)=0;
                    end
                    if fxxsum(j,i)>0 && fxxsum(j+k,i+1)>0
                        wgrass_zero(j,i)=0;
                    end
                    if fxxsum(j,i)>0 && fxxsum(j-k,i-k)>0
                        wgrass_zero(j,i)=0;
                    end
                    if fxxsum(j,i)>0 && fxxsum(j-k,i)>0
                        wgrass_zero(j,i)=0;
                    end
                    if fxxsum(j,i)>0 && fxxsum(j,i-k)>0
                        wgrass_zero(j,i)=0;
                    end
                    if fxxsum(j,i)>0 && fxxsum(j+k,i-k)>0
                        wgrass_zero(j,i)=0;
                    end
                    if fxxsum(j,i)>0 && fxxsum(j-k,i+k)>0
                        wgrass_zero(j,i)=0;
                    end
                end
            end
end

%%
% Smoothing
SE_done=wgrass_zero;
PQ=2.*(size(SE_done));
Fp=fft2(SE_done,PQ(1),PQ(2));
%SIG=0.025*PQ(2); %0.05 default - tissue:0.025
SIG=0.05*PQ(2); %0.05 default - beads : 0.05
Hp=lpfilter('gaussian', PQ(1), PQ(2), 2*SIG);
Gp=Hp.*Fp;
gp=ifft2(Gp);
SE_done=imcrop(gp,[0,0,pixelY*M, pixelX*M]);
SE_done(SE_done<0)=0;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

function [outputs] = Mitchell_vect(x,M_B,M_C)
        outputs= zeros(size(x,1),size(x,2));
        ax = abs(x);
        temp = ((12-9*M_B-6*M_C) .* ax.^3 + (-18+12*M_B+6*M_C) .* ax.^2 + (6-2*M_B))./6;
        temp2 = ((-M_B-6*M_C) .* ax.^3 + (6*M_B+30*M_C) .* ax.^2 + (-12*M_B-48*M_C) .* ax + (8*M_B + 24*M_C))./6;
        index = find(ax<1);
        %outputs(index)=-temp(index);
        %outputs(index)=0;
        outputs(index)=temp(index);
        index = find(ax>=1 & ax<2);
        outputs(index)=temp2(index);
 end

end