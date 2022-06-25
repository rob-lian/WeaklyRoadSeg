%This matlab file filters the undesirable components

tic
clc;clear all;close all;
c0 = 2;
imgID = 10; % 1,2,3,4,5  % choose one of the five test images
addpath('C:\Program Files\MATLAB\R2016b\lib\jsonlab-master')

pdf_Img = imread([num2str(imgID),'.png']);
pdf_Img = double(pdf_Img(:,:,1));
seg_Img = imread([num2str(imgID),'_seg.tif']);
seg_Img = seg_Img > 0;

switch imgID    
    case {1,2,3,4,5,7,8,10}
        [height, width] = size(seg_Img);
        
        seeds_json = loadjson([num2str(imgID),'.json']);
        rs = seeds_json.road_seeds;
        [cnt, junk] = size(rs);
        
        % ���ӵ�ͼ
        seed_map = zeros(size(pdf_Img(:,:,1)));
        for i = 1:cnt
            row = rs(i, 1);
            col = rs(i, 2);
            seed_map(row, col) = 1;
        end

        % ������
        figure();imshow(seg_Img,[0 1]);colormap(gray); title('origin');axis equal;
        se=strel('square',3);
        fo=imopen(seg_Img,se);
        figure();imshow(fo,[0 1]);colormap(gray); title('open');axis equal; hold on;
        scatter(rs(:, 2), rs(:, 1), '.r');        
        hold off
        
        % �Էָ�ͼ�����
        [L, num] = bwlabel(fo, 4);
        
        % ���һ����·����û�е�·���ӵ㣬ɾ��
        for i = 1:num
            if sum(sum(seed_map(L==i)))==0
                fo(L == i) = 0;
            end
        end
        
       figure();imshow(fo,[0 1]);colormap(gray); title('���ӵ����'); axis equal; hold on;
       scatter(rs(:, 2), rs(:, 1), '.r');
       hold off
       
        % ���һ����·�ε�ƽ���Ҷ�С������ͼ��ĵ�·��ƽ���Ҷȣ�ɾ��
        filtered_pdf_mean = mean(mean(pdf_Img(fo>0))) * 0.5;
        filtered_area_mean = sum(sum(fo>0)) / size(unique(L(fo>0)),1) * 1
        for i = 1:num
            if mean(mean(pdf_Img(L==i)))<filtered_pdf_mean
                fo(L == i) = 0;
            end
%             if sum(fo(L==i)) < filtered_area_mean
%                 fo(L == i) = 0;
%             end
            
        end
        
       figure();imshow(fo,[0 1]);colormap(gray); title('���ӻҶȹ���'); axis equal; hold on;
       imwrite(fo, [num2str(imgID),'_refine.jpg']);
       %scatter(rs(:, 2), rs(:, 1), '.r');
       
       hold off
       
end
