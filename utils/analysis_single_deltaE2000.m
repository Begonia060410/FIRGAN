% 读取图像（RGB）
img = im2double(imread('50vi.jpg'));

% 转换为 Lab 色彩空间
lab_img = rgb2lab(img);

% 设置参考颜色（假设为灰色：RGB [0.5, 0.5, 0.5]）
ref_rgb = [0.5, 0.5, 0.5];
ref_lab = rgb2lab(reshape(ref_rgb, 1, 1, 3));
ref_L = ref_lab(:,:,1);
ref_a = ref_lab(:,:,2);
ref_b = ref_lab(:,:,3);

% 获取图像尺寸
[h, w, ~] = size(img);
lab_reshaped = reshape(lab_img, [], 3);
ref_matrix = repmat([ref_L, ref_a, ref_b], h*w, 1);

% 计算 ΔE2000
deltaE = deltaE2000(lab_reshaped, ref_matrix);

% 重构为图像形式
deltaE_img = reshape(deltaE, h, w);

% 显示结果
figure; imagesc(deltaE_img); axis image; colorbar;
title('ΔE2000 Map to Reference Color');
