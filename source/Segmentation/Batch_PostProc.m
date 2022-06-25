% 本程序用于批量处理TGRS2020论文中的参数研究部分的多个参数组成_后处理
% LBF-Snake部分验证参数nu=0.005*255*255和0.01*255*255

clc;clear all; close all;
addpath('C:\Program Files\MATLAB\R2016b\lib\jsonlab-master')
nus = [0.005*255*255 0.01*255*255];
steps = [16 32 48 64];
for nu = nus
    for step = steps
        seed_dir = ['E:\study\data\GoogleEarth\chengguangliang\Dataset_for_TGRS2017_paper\TGRS2020_paper\sliding', num2str(step),'\'];
        roadpot_dir = ['E:\study\data\GoogleEarth\chengguangliang\Dataset_for_TGRS2017_paper\TGRS2020_paper\sliding', num2str(step), '\roadpot\'];
        seg_dir = ['E:\study\data\GoogleEarth\chengguangliang\Dataset_for_TGRS2017_paper\TGRS2020_paper\sliding', num2str(step), '\LBFseg', num2str(nu),'\'];
        out_dir = ['E:\study\data\GoogleEarth\chengguangliang\Dataset_for_TGRS2017_paper\TGRS2020_paper\sliding', num2str(step), '\Refineseg', num2str(nu),'\'];
        
        if exist(out_dir,'dir')==0
           mkdir(out_dir);
        end
        
        seg_files = dir(fullfile(seg_dir, '*.png'));
        seg_files = {seg_files.name};
        [filenum, ~] = size(seg_files);
        
        times = [];
        for ii = 1:filenum
            tic
            seg_file = seg_files(ii);       
            seg_file = [seg_dir, seg_file{1}];
            seg_Img = imread(seg_file);
            seg_Img = seg_Img > 0;
            
            [pathstr,name,suffix]=fileparts(seg_file);
            fileid = strsplit(name, '_');
            fileid = fileid{1};
            
            pdf_file = [roadpot_dir, fileid ,'_roadpot.png'];
            pdf_Img = imread(pdf_file);
            pdf_Img = double(pdf_Img(:,:,1));
            
            seeds_file = [seed_dir, fileid ,'_seeds.json']
            seeds_json = loadjson(seeds_file);
            rs = seeds_json.road_seeds;      
            [cnt, junk] = size(rs);
                        
            [height, width] = size(seg_Img);               

            % 种子地图
            seed_map = zeros(size(seg_Img));
            for i = 1:cnt
                row = rs(i, 1);
                col = rs(i, 2);
                seed_map(row, col) = 1;
            end

            % 开运算
%             figure();imshow(seg_Img,[0 1]);colormap(gray); title('origin');axis equal;
            se=strel('square',3);
            fo=imopen(seg_Img,se);
%             figure();imshow(fo,[0 1]);colormap(gray); title('open');axis equal; hold on;
%             scatter(rs(:, 2), rs(:, 1), '.r');        
%             hold off

            % 对分割图做标号
            [L, num] = bwlabel(fo, 4);

            % 如果一个道路段中没有道路种子点，删除
            for i = 1:num
                if sum(sum(seed_map(L==i)))==0
                    fo(L == i) = 0;
                end
            end

%            figure();imshow(fo,[0 1]);colormap(gray); title('种子点过滤'); axis equal; hold on;
%            scatter(rs(:, 2), rs(:, 1), '.r');
%            hold off

            % 如果一个道路段的平均灰度小于整体图像的道路段平均灰度，删除
            filtered_pdf_mean = mean(mean(pdf_Img(fo>0))) * 0.5;
            filtered_area_mean = sum(sum(fo>0)) / size(unique(L(fo>0)),1) * 1;
            for i = 1:num
                if mean(mean(pdf_Img(L==i)))<filtered_pdf_mean
                    fo(L == i) = 0;
                end
    %             if sum(fo(L==i)) < filtered_area_mean
    %                 fo(L == i) = 0;
    %             end

            end

%            figure();imshow(fo,[0 1]);colormap(gray); title('增加灰度过滤'); axis equal; hold on;
%             scatter(rs(:, 2), rs(:, 1), '.r');hold off;

            % 填充小孔
            

            save_file = [out_dir, fileid, '_seg.png'];
            imwrite(fo, save_file);          
            
            times(end+1) = toc;  
            
            disp([num2str(step), ': ', fileid, ' done']);
        end
        
        % 保存统计信息
        filename = fullfile(out_dir, 'staticinfo.txt');
        fid=fopen(filename,'wt');
        fprintf(fid,'average time: %f\n', mean(times(:)));
        fprintf(fid,'==============================\n');

        for ii = 1:filenum
            filename = seg_files(ii);
            fprintf(fid,'filename: %s\n', filename{1});
            fprintf(fid,'time: %f\n', times(ii));
        end
        fclose(fid);        

    end
    
end


