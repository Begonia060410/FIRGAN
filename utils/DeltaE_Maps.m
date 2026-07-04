clc
clear all

% 调用示例
% 计算融合图像与可见光图像的DeltaE差异图像
% 设置文件夹路径（请根据实际情况修改）
fusionFolder = '..\Image\Algorithm\ATGAN_org100_vehicle';   % 融合图像文件夹
visibleFolder = '..\Image\Source-Image\vehicle\vi'; % 可见光图像文件夹
outputFolder = '..\Image\Algorithm\ATGAN_org100_vehicle\DeltaE2000';  % 差异图像保存文件夹


% 计算DeltaE2000差异图像（默认方法）
calculateDeltaEImages(fusionFolder, visibleFolder, outputFolder);

% 计算其他方法的差异图像（如CIE94）
% calculateDeltaEImages(fusionFolder, visibleFolder, outputFolder, 'CIE94');