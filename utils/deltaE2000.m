function deltaE_std = deltaE2000(img1, img2)
% deltaE2000 计算两张 RGB 图像之间每个像素的 ΔE2000 色差，并返回平均值
% 输入：
%   img1, img2 - RGB 图像，大小相同
% 输出：
%   deltaE_ave - 图像所有像素的 ΔE2000 平均值

img1 = im2double(img1);
img2 = im2double(img2);

% 转换为 Lab 空间
Lab1 = rgb2lab(img1);
Lab2 = rgb2lab(img2);

% 获取图像尺寸并展开为 N×3 矩阵
[h, w, ~] = size(img1);
Lab1 = reshape(Lab1, [], 3);
Lab2 = reshape(Lab2, [], 3);

% 解包颜色通道
L1 = Lab1(:,1); a1 = Lab1(:,2); b1 = Lab1(:,3);
L2 = Lab2(:,1); a2 = Lab2(:,2); b2 = Lab2(:,3);

% CIEDE2000 参数
kL = 1; kC = 1; kH = 1;

% 中间变量计算
C1 = sqrt(a1.^2 + b1.^2);
C2 = sqrt(a2.^2 + b2.^2);
Cm = (C1 + C2) / 2;
G = 0.5 * (1 - sqrt(Cm.^7 ./ (Cm.^7 + 25^7)));

a1p = (1 + G) .* a1;
a2p = (1 + G) .* a2;
C1p = sqrt(a1p.^2 + b1.^2);
C2p = sqrt(a2p.^2 + b2.^2);

h1p = atan2(b1, a1p); h1p(h1p < 0) = h1p(h1p < 0) + 2*pi;
h2p = atan2(b2, a2p); h2p(h2p < 0) = h2p(h2p < 0) + 2*pi;

% ΔL、ΔC、ΔH
dLp = L2 - L1;
dCp = C2p - C1p;
dhp = h2p - h1p;
dhp(abs(dhp) > pi) = dhp(abs(dhp) > pi) - sign(dhp(abs(dhp) > pi)) * 2*pi;
dHp = 2 .* sqrt(C1p .* C2p) .* sin(dhp / 2);

% 平均值
Lm = (L1 + L2) / 2;
Cp = (C1p + C2p) / 2;
hp = (h1p + h2p) / 2;
hp(abs(h1p - h2p) > pi) = hp(abs(h1p - h2p) > pi) + pi;
hp(hp > 2*pi) = hp(hp > 2*pi) - 2*pi;

T = 1 - 0.17*cos(hp - pi/6) + 0.24*cos(2*hp) + 0.32*cos(3*hp + pi/30) - 0.20*cos(4*hp - 63*pi/180);
dTheta = 30 * exp(-((180/pi*hp*180/pi - 275)/25).^2);
RC = 2 * sqrt((Cp.^7) ./ (Cp.^7 + 25^7));
SL = 1 + (0.015 * (Lm - 50).^2) ./ sqrt(20 + (Lm - 50).^2);
SC = 1 + 0.045 * Cp;
SH = 1 + 0.015 * Cp .* T;
RT = -sin(2*dTheta*pi/180) .* RC;

% ΔE2000
deltaE = sqrt( ...
    (dLp ./ (kL * SL)).^2 + ...
    (dCp ./ (kC * SC)).^2 + ...
    (dHp ./ (kH * SH)).^2 + ...
    RT .* (dCp ./ (kC * SC)) .* (dHp ./ (kH * SH)) ...
);

 % 平均 ΔE2000
 % deltaE_ave = mean(deltaE);
 % 方差 ΔE2000
   deltaE_var = var(deltaE);  
 % 标准差 ΔE2000
   deltaE_std = std(deltaE);  
 % 还原为图像形状
 % deltaE_img = reshape(deltaE, h, w);

 % 可视化 ΔE 图
 % figure; imagesc(deltaE_img); axis image; colorbar;
 % title('ΔE2000 Difference Map');
end

