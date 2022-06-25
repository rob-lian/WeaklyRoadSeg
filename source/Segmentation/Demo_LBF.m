% This Matlab file demomstrates a level set method in Chunming Li et al's paper
%    "Minimization of Region-Scalable Fitting Energy for Image Segmentation",
%    IEEE Trans. Image Processing, vol. 17 (10), pp.1940-1949, 2008.
% Author: Chunming Li, all rights reserved
% E-mail: li_chunming@hotmail.com
% URL:  http://www.engr.uconn.edu/~cmli/
%
% Note 1: This method with a small scale parameter sigma, such as sigma = 3, is sensitive to 
%         initialization of the level set function. Appropriate initial level set functions are given in 
%         this code for different test images. 
% Note 2: There are several ways to improve the original LBF model to make it robust to initialization.
%         One of the improved LBF algorithms is implemented by the code in the folder LBF_v0.1

tic
clc;clear all;close all;
c0 = 2;
imgID = 3; % 1,2,3,4,5  % choose one of the five test images
addpath('C:\Program Files\MATLAB\R2016b\lib\jsonlab-master')

Img = imread([num2str(imgID),'.png']);
Img = double(Img(:,:,1));
% w=fspecial('gaussian',[7 7],7);
% Img=imfilter(Img,w);

switch imgID    
    case {1,2,3,4,5,6,7,8,9,10}
        iterNum =10;
        lambda1 = 1.0;
        lambda2 = 1.0;
        nu = 0.005*255*255;% coefficient of the length term
        
        [height, width] = size(Img);
        
        seeds_json = loadjson([num2str(imgID),'.json']);
        rs = seeds_json.road_seeds;
        [cnt, junk] = size(rs);
        
        
        seed_map = zeros(size(Img(:,:,1)));
        for i = 1:cnt
            row = rs(i, 1);
            col = rs(i, 2);
            seed_map(row, col) = 1;
        end
        
        % 筛选种子点，如果一个种子点的周围32*32的范围内种子点少于4个，则去除该种子点
%         seed_thred=4;
%         seed_win = 32
%         for i = 1:cnt
%             row = rs(i, 1);
%             col = rs(i, 2);
%             if row-32 < 1 || row+32>height || col-32<1 || col+32>width % 靠近图像周围的种子点删除
%                 seed_map(row, col) = 0;
%                 continue
%             end
%             
%             if sum(sum(seed_map(row-seed_win:row+seed_win, col-seed_win:col+seed_win)))<seed_thred
%                 seed_map(row, col) = 0;
%             end            
%         end
        
        % 筛选种子，种子点所在的道路概率要大于所有种子点的概率平均值
        pdf_mean = mean(mean(Img(seed_map==1)));
        for i = 1:cnt
            row = rs(i, 1);
            col = rs(i, 2);
            if Img(row, col) < pdf_mean
                seed_map(row, col) = 0;
            end            
        end
        
        [m, n] = find(seed_map==1);
        
        initialLSF = ones(size(Img(:,:,1))).*c0;
        seed_map = zeros(size(Img(:,:,1)));
        
        for i = 1:size(m)
            row = m(i);
            col = n(i);
            initialLSF(row-5:row+5, col-5:col+5) = -c0;
%             break
        end
end

u = initialLSF;
figure(1);imagesc(Img, [0, 255]);colormap(gray);hold on;axis off,axis equal
title('Initial contour');
[c,h] = contour(u,[0 0],'r');
pause(0.1);

timestep = .1;% time step
mu = 1;% coefficient of the level set (distance) regularization term P(\phi)

epsilon = 1.0;% the papramater in the definition of smoothed Dirac function
sigma=3.0;    % scale parameter in Gaussian kernel
              % Note: A larger scale parameter sigma, such as sigma=10, would make the LBF algorithm more robust 
              %       to initialization, but the segmentation result may not be as accurate as using
              %       a small sigma when there is severe intensity inhomogeneity in the image. If the intensity
              %       inhomogeneity is not severe, a relatively larger sigma can be used to increase the robustness of the LBF
              %       algorithm.
K=fspecial('gaussian',round(2*sigma)*2+1,sigma);     % the Gaussian kernel
I = Img;
KI=conv2(Img,K,'same');     % compute the convolution of the image with the Gaussian kernel outside the iteration
                            % See Section IV-A in the above IEEE TIP paper for implementation.
                                                 
KONE=conv2(ones(size(Img)),K,'same');  % compute the convolution of Gassian kernel and constant 1 outside the iteration
                                       % See Section IV-A in the above IEEE TIP paper for implementation.

% start level set evolution
for n=1:iterNum   
    disp(['iteration=',num2str(n)])
    [u, f1, f2]=LSE_LBF(u,I,K,KI,KONE, nu,timestep,mu,lambda1,lambda2,epsilon,1);
%     if mod(n,20)==0
%         figure(1);imagesc(Img, [0, 255]);colormap(gray);hold on;%axis off,axis equal
%         [c,h] = contour(u,[0 0],'r');
%         iterNum=[num2str(n), ' iterations'];
%         title(iterNum);
%         hold off;
%         %figure(2);imagesc(f1,[0 255]); colormap(gray);title('f1');
%         %figure(3);imagesc(f2,[0 255]); colormap(gray);title('f2');
%         %pause(1);
%     end
end
% save the segmentation
segmentation = u<=0;
imwrite(uint8(segmentation * 255), [num2str(imgID),'_seg.tif']);

figure(1);imagesc(Img, [0, 255]);colormap(gray);hold on;axis off,axis equal
[c,h] = contour(u,[0 0],'r');

% clabel(c, h)
totalIterNum=[num2str(n), ' iterations'];
title(['Final contour, ', totalIterNum]);

figure;
mesh(u);
title('Final level set function');
toc
disp(['运行时间: ',num2str(toc)]);
