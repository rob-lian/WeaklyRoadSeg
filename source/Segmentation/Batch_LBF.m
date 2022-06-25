% 本程序用于批量处理TGRS2020论文中的参数研究部分的多个参数组成
% LBF-Snake部分验证参数nu=0.005*255*255和0.01*255*255
clc;clear all; close all;
addpath('C:\Program Files\MATLAB\R2016b\lib\jsonlab-master')
nus = [0.005*255*255 0.01*255*255];
nus = [0.005*255*255];
steps = [16 32 48 64];
steps = [32];
for nu = nus
    iterNum =50;
    lambda1 = 1.0;
    lambda2 = 1.0;
    c0 = 2;
    
    for step = steps 
%         seed_dir = ['E:\study\data\MassachusettsRoads\TGRS2020_paper\seeds\sliding', num2str(step),'\'];
%         roadpot_dir = ['E:\study\data\MassachusettsRoads\TGRS2020_paper\resm-mmgf-snake\sliding', num2str(step), '\roadpot\'];
%         out_dir = ['E:\study\data\MassachusettsRoads\TGRS2020_paper\rsem-mmgf-snake\sliding', num2str(step), '\LBFseg', num2str(fix(nu)),'\'];
        seed_dir = ['E:\study\data\GoogleEarth\chengguangliang\Dataset_for_TGRS2017_paper\TGRS2020_paper\seeds\sliding', num2str(step),'\'];
        roadpot_dir = ['E:\study\data\GoogleEarth\chengguangliang\Dataset_for_TGRS2017_paper\TGRS2020_paper\rsem-mmgf-snake\sliding', num2str(step), '\roadpot\'];
        out_dir = ['E:\study\data\GoogleEarth\chengguangliang\Dataset_for_TGRS2017_paper\TGRS2020_paper\rsem-mmgf-snake\sliding', num2str(step), '\LBFseg', num2str(fix(nu)),'\'];
        
        if exist(out_dir,'dir')==0
           mkdir(out_dir);
        end
        
        
        % 获得所有roadpot文件
        files = dir(fullfile(roadpot_dir,'*.png'));
        roadpot_files = {files.name};
        times = [];
        [~, filenum] = size(roadpot_files);
        for ii = 1:filenum
            
            roadpot_file = roadpot_files(ii);       
            roadpot_file = [roadpot_dir, roadpot_file{1}];
            [pathstr,name,suffix]=fileparts(roadpot_file);
            fileid = name(1: strlength(name)-strlength('_roadpot'));
            
            if exist([out_dir,fileid,'_seg.png'], 'file')
                disp([out_dir,fileid,'_seg.png', '--skipped']);
                continue;
            end
            tic

            Img = imread(roadpot_file);
            Img = double(Img(:,:,1));
            [height, width] = size(Img);
       
            seeds_file = [seed_dir, fileid ,'_seeds.json']
            seeds_json = loadjson(seeds_file);
            rs = seeds_json.road_seeds;
            [cnt, junk] = size(rs);

            seed_map = zeros(size(Img(:,:,1)));
            for i = 1:cnt
                row = rs(i, 1);
                col = rs(i, 2);
                seed_map(row, col) = 1;
            end

            % 筛选种子点，如果一个种子点的周围32*32的范围内种子点少于4个，则去除该种子点
%             seed_thred=4;
%             seed_win = 32
%             for i = 1:cnt
%                 row = rs(i, 1);
%                 col = rs(i, 2);
%                 if row-32 < 1 || row+32>height || col-32<1 || col+32>width % 靠近图像周围的种子点删除
%                     seed_map(row, col) = 0;
%                     continue
%                 end
%                 
%                 if sum(sum(seed_map(row-seed_win:row+seed_win, col-seed_win:col+seed_win)))<seed_thred
%                     seed_map(row, col) = 0;
%                 end            
%             end

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
                if (row-5<1) 
                    top = 1;
                    bottom = top + 10;
                elseif (row+5>height)
                    bottom = height;
                    top = bottom - 10;
                else
                    bottom = row + 5;
                    top = row - 5;
                end
                if (col-5<1)
                    left = 1;
                    right = left + 10;
                elseif (col+5>width)
                    right = width;
                    left = right - 10;
                else
                    left = col - 5;
                    right = col + 5;
                end
                initialLSF(top:bottom, left:right) = -c0;
            end

            u = initialLSF;
%             figure(1);imagesc(Img, [0, 255]);colormap(gray);hold on;axis off,axis equal
%             title('Initial contour');
%             [c,h] = contour(u,[0 0],'r');
%             pause(0.1);

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
%                 disp(['iteration=',num2str(n)])
                [u, f1, f2]=LSE_LBF(u,I,K,KI,KONE, nu,timestep,mu,lambda1,lambda2,epsilon,1);
%                 if mod(n,20)==0
%                     figure(1);imagesc(Img, [0, 255]);colormap(gray);hold on;%axis off,axis equal
%                     [c,h] = contour(u,[0 0],'r');
%                     iterNum=[num2str(n), ' iterations'];
%                     title(iterNum);
%                     hold off;
%                     %figure(2);imagesc(f1,[0 255]); colormap(gray);title('f1');
%                     %figure(3);imagesc(f2,[0 255]); colormap(gray);title('f2');
%                     %pause(1);
%                 end
            end
            
%             figure(1);imagesc(Img, [0, 255]);colormap(gray);hold on;axis off,axis equal
%             [c,h] = contour(u,[0 0],'r');
% 
%             % clabel(c, h)
%             totalIterNum=[num2str(n), ' iterations'];
%             title(['Final contour, ', totalIterNum]);
% 
%             figure;
%             mesh(u);
%             title('Final level set function');
            
            % save the segmentation
            segmentation = u<=0;
            imwrite(uint8(segmentation * 255), [out_dir,fileid,'_seg.png']);
            
            times(end+1) = toc;  
            
            disp([num2str(step), ': ', name, ' done']);
            
%             break;
        end
        if isempty(times)
            continue;
        end
        % 保存统计信息
        filename = fullfile(out_dir, 'staticinfo.txt');
        fid=fopen(filename,'wt');
        fprintf(fid,'average time: %f\n', mean(times(:)));
        fprintf(fid,'==============================\n');

        for ii = 1:filenum
            filename = roadpot_files(ii);
            fprintf(fid,'filename: %s\n', filename{1});
            fprintf(fid,'time: %f\n', times(ii));
        end
        fclose(fid);
        
    end
end

