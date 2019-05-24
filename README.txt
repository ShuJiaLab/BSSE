1. BSSE_Matlab
----------------------------------------------------------------------------------------------------------------
Initiate BSSE by 'BSSE_InitiateHere.m'
----------------------------------------------------------------------------------------------------------------
In 'BSSE_BS.m',
optically you can change the baseline frequency at "a0 = a-imgaussfilt(a,1);"
----------------------------------------------------------------------------------------------------------------
In 'BSSE_SE.m',
(1) Please change the parameters to match your expentimental specification. 
e.g.
% Prameter %
lambda = 520; %[nm]
NA = 0.5;

(2) We used sub-pixelated magnification as 2 in order to minimize further artefact by intensity-interpolation.
e.g.
M = 2;

(3) For tissue images, a post-smoothing step using a Gaussian filter is included to maintain the continuity of biological structures  [33,38], in manuscript. 
e.g. 
SIG=0.05*PQ(2); %0.05 default - tissues : 0.025


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------


2. Calcium_ROI
We used the manual ROI selection and signal extraction from
W. A. Liberti, L. N. Perkins, D. P. Leman, and T. J. Gardner, 
“An open source, wireless capable miniature microscope system,” J. Neural Eng., vol. 14, no. 4, p. 045001, Aug. 2017.
https://github.com/gardner-lab/FinchScope


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
README.txt written by
Jeonghwan Son (Dylan), json71@gatech.edu
