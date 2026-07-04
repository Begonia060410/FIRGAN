function calculateDeltaE2000Images(fusionFolder, visibleFolder, outputFolder)
    % 计算融合图像与可见光图像的DeltaE2000差异图像（无图例版本）
    %
    % 输入参数:
    %   fusionFolder   - 融合图像所在文件夹路径
    %   visibleFolder  - 可见光图像所在文件夹路径
    %   outputFolder   - 差异图像保存文件夹路径
    %
    % 输出:
    %   保存到outputFolder的DeltaE2000差异图像（无颜色条和图例）
    
    % 固定颜色映射范围为0-60
    fixedMin = 0;
    fixedMax = 60;
    
    % 检查输入文件夹是否存在
    if ~exist(fusionFolder, 'dir')
        error('融合图像文件夹不存在: %s', fusionFolder);
    end
    if ~exist(visibleFolder, 'dir')
        error('可见光图像文件夹不存在: %s', visibleFolder);
    end
    
    % 创建输出文件夹
    if ~exist(outputFolder, 'dir')
        [status, msg] = mkdir(outputFolder);
        if ~status
            error('无法创建输出文件夹: %s，错误: %s', outputFolder, msg);
        end
        fprintf('已创建输出文件夹: %s\n', outputFolder);
    end
    
    % 获取所有融合图像
    imageExts = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};
    fusionFiles = [];
    for i = 1:length(imageExts)
        fusionFiles = [fusionFiles; dir(fullfile(fusionFolder, imageExts{i}))];
    end
    
    % 按名称排序
    [~, idx] = sort({fusionFiles.name});
    fusionFiles = fusionFiles(idx);
    numFusion = length(fusionFiles);
    
    if numFusion == 0
        error('融合图像文件夹中未找到任何图像');
    end
    
    fprintf('找到 %d 张融合图像，开始计算DeltaE2000差异图...\n', numFusion);
    
    % 处理每张融合图像
    for i = 1:numFusion
        close all hidden;
        drawnow;
        
        fusionName = fusionFiles(i).name;
        fprintf('处理第 %d/%d 张: %s\n', i, numFusion, fusionName);
        
        % 构建可见光图像路径
        visiblePath = fullfile(visibleFolder, fusionName);
        
        % 检查可见光图像是否存在
        if ~exist(visiblePath, 'file')
            warning('未找到对应的可见光图像: %s，已跳过', fusionName);
            continue;
        end
        
        % 读取图像
        try
            fusionImg = imread(fullfile(fusionFolder, fusionName));
            visibleImg = imread(visiblePath);
        catch err
            warning('读取图像失败: %s，错误: %s，已跳过', fusionName, err.message);
            continue;
        end
        
        % 确保图像尺寸相同
        if ~isequal(size(fusionImg), size(visibleImg))
            warning('图像尺寸不匹配: %s，已跳过', fusionName);
            continue;
        end
        
        % 确保图像是RGB格式
        fusionImg = ensureRGB(fusionImg);
        visibleImg = ensureRGB(visibleImg);
        
        % 转换为双精度并归一化
        fusionImg = im2double(fusionImg);
        visibleImg = im2double(visibleImg);
        
        % 转换到LAB颜色空间
        labFusion = rgb2lab(fusionImg);
        labVisible = rgb2lab(visibleImg);
        
        % 计算DeltaE2000图
        deltaE_map = calculateDeltaE2000Map(labFusion, labVisible);
        
        % 计算统计值
        avgDE = mean(deltaE_map(:));
        maxDE = max(deltaE_map(:));
        minDE = min(deltaE_map(:));
        fprintf('  DeltaE2000统计: 平均=%.4f, 最小=%.4f, 最大=%.4f\n', avgDE, minDE, maxDE);
        
        % 生成输出文件名
        [name, ~] = fileparts(fusionName);
        validName = regexprep(name, '[^a-zA-Z0-9_.-]', '_');
        if isempty(validName)
            validName = sprintf('image_%04d', i);
        end
        outputName = sprintf('%s_deltaE2000.jpg', validName);
        outputPath = fullfile(outputFolder, outputName);
        
        % 保存差异图像（无图例）
        saveDeltaEImage(deltaE_map, outputPath, fixedMin, fixedMax);
    end
    
    fprintf('所有处理完成！结果保存在: %s\n', outputFolder);
end

% 辅助函数：确保图像为RGB格式
function img = ensureRGB(img)
    if size(img, 3) == 1
        img = repmat(img, [1, 1, 3]);
    elseif size(img, 3) > 3
        img = img(:, :, 1:3);
    end
end

% 核心函数：计算DeltaE2000差异图
function deltaE_map = calculateDeltaE2000Map(lab1, lab2)
    [h, w, ~] = size(lab1);
    deltaE_map = zeros(h, w);
    
    lab1_reshaped = reshape(lab1, h*w, 3);
    lab2_reshaped = reshape(lab2, h*w, 3);
    
    for p = 1:h*w
        deltaE_map(p) = computeDeltaE2000(lab1_reshaped(p,:), lab2_reshaped(p,:));
    end
    
    deltaE_map = reshape(deltaE_map, h, w);
end

% 具体实现DeltaE2000计算公式
function de = computeDeltaE2000(lab1, lab2)
    L1 = lab1(1); a1 = lab1(2); b1 = lab1(3);
    L2 = lab2(1); a2 = lab2(2); b2 = lab2(3);
    
    deltaL = L2 - L1;
    L_avg = (L1 + L2) / 2;
    
    C1 = sqrt(a1^2 + b1^2);
    C2 = sqrt(a2^2 + b2^2);
    C_avg = (C1 + C2) / 2;
    
    G = 0.5 * (1 - sqrt(C_avg^7 / (C_avg^7 + 25^7)));
    a1_prime = a1 * (1 + G);
    a2_prime = a2 * (1 + G);
    
    C1_prime = sqrt(a1_prime^2 + b1^2);
    C2_prime = sqrt(a2_prime^2 + b2^2);
    C_avg_prime = (C1_prime + C2_prime) / 2;
    deltaC_prime = C2_prime - C1_prime;
    
    h1_prime = atan2(b1, a1_prime) * 180 / pi;
    h2_prime = atan2(b2, a2_prime) * 180 / pi;
    
    h1_prime = adjustHue(h1_prime);
    h2_prime = adjustHue(h2_prime);
    
    if C1_prime * C2_prime ~= 0
        if abs(h1_prime - h2_prime) <= 180
            h_avg_prime = (h1_prime + h2_prime) / 2;
        else
            if h1_prime + h2_prime < 360
                h_avg_prime = (h1_prime + h2_prime + 360) / 2;
            else
                h_avg_prime = (h1_prime + h2_prime - 360) / 2;
            end
        end
    else
        h_avg_prime = h1_prime + h2_prime;
    end
    
    deltaH_prime = 0;
    if C1_prime * C2_prime ~= 0
        if abs(h2_prime - h1_prime) <= 180
            deltaH_prime = h2_prime - h1_prime;
        else
            if h2_prime > h1_prime
                deltaH_prime = h2_prime - h1_prime - 360;
            else
                deltaH_prime = h2_prime - h1_prime + 360;
            end
        end
    end
    
    deltaH_double_prime = 2 * sqrt(C1_prime * C2_prime) * sin(deltaH_prime * pi / 360);
    
    T = 1 - 0.17 * cosd(h_avg_prime - 30) + 0.24 * cosd(2 * h_avg_prime) ...
        + 0.32 * cosd(3 * h_avg_prime + 6) - 0.2 * cosd(4 * h_avg_prime - 63);
    
    SL = 1 + (0.015 * (L_avg - 50)^2) / sqrt(20 + (L_avg - 50)^2);
    SC = 1 + 0.045 * C_avg_prime;
    SH = 1 + 0.015 * C_avg_prime * T;
    
    RT = -2 * sqrt(C_avg_prime^7 / (C_avg_prime^7 + 25^7)) * sind(60 * exp(-((h_avg_prime - 275)/25)^2));
    
    de = sqrt( ...
        (deltaL / SL)^2 + ...
        (deltaC_prime / SC)^2 + ...
        (deltaH_double_prime / SH)^2 + ...
        RT * (deltaC_prime / SC) * (deltaH_double_prime / SH) ...
    );
end

% 辅助函数：调整色相角范围
function h = adjustHue(h)
    if h < 0
        h = h + 360;
    elseif h > 360
        h = h - 360;
    end
end

% 辅助函数：保存无图例的DeltaE图像
function saveDeltaEImage(deltaE_map, outputPath, fixedMin, fixedMax)
    % 创建图窗（不显示）
    fig = figure('Visible', 'off', 'NumberTitle', 'off', ...
                 'Position', [100 100 size(deltaE_map,2) size(deltaE_map,1)]);
    if ~ishandle(fig)
        warning('无法创建图窗，图像保存失败');
        return;
    end
    
    % 创建坐标轴，充满整个图窗
    ax = axes(fig);
    if ~ishandle(ax)
        warning('无法创建坐标轴，图像保存失败');
        close(fig);
        return;
    end
    set(ax, 'Position', [0 0 1 1]);  % 坐标轴充满整个图窗
    
    % 显示差异图并固定颜色范围
    imagesc(ax, deltaE_map);
    caxis(ax, [fixedMin fixedMax]);  % 保持0-50的颜色映射范围
    colormap(ax, jet(256));
    axis(ax, 'image', 'off');  % 隐藏坐标轴，保持图像比例
    
    % 不添加标题和颜色条（完全无图例）
    set(get(ax, 'Title'), 'String', '');  % 确保标题为空
    
    % 确保图像正确渲染
    drawnow;
    
    % 保存图像
    try
        print(fig, outputPath, '-djpeg', '-r300');
        fprintf('  差异图已保存: %s\n', outputPath);
    catch err
        warning('保存图像失败: %s，错误信息: %s', outputPath, err.message);
    end
    
    % 关闭图窗
    if ishandle(fig)
        close(fig);
    end
end
