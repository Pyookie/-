clear; clc; close all;
%1. 参数设置
monsterHP = 50;       % 怪物血量
monsterAttack = 8;    % 怪物每回合攻击力
numSimulations = 1000;% 模拟次数

disp('开始模拟战斗...');
tic; % 开始计时
[meanLoss, hpLossArray] = simulateStS2Combat(monsterHP, monsterAttack, numSimulations);
toc; % 结束计时

%2. 输出结果
disp(['模拟完成！耗时: ', num2str(toc), ' 秒']);
disp(['平均 HP 损失 (期望值 E[ΔHP]): ', num2str(meanLoss)]);

%3. 绘制 HP Loss 分布图 (直方图)
figure('Color', 'w'); % 创建白色背景图
histogram(hpLossArray, 'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'k');
title('1000次模拟 HP Loss 分布图');
xlabel('单次战斗总 HP Loss');
ylabel('频数 (次数)');
grid on;