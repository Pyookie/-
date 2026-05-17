function [meanHPLoss, hpLossArray] = simulateStS2Combat(monsterHP, monsterAttack, numSimulations)
    % 模型目标：模拟《杀戮尖塔2》固定卡组对单一怪物的战斗，计算HP损失期望。
    % 模型假设：
    % ①怪物的意图只有攻击
    % ②卡组为五张打击和五张防御
    % ③玩家能根据手里的牌打出最优解
    % 输入：
    %   monsterHP - 怪物生命值
    %   monsterAttack - 怪物每回合固定攻击力
    %   numSimulations - 蒙特卡洛模拟次数
    % 输出：
    %   meanHPLoss - 平均HP损失（期望值）
    %   hpLossArray - 每次模拟的HP损失数组（用于绘图）

    % 初始化结果数组
    hpLossArray = zeros(1, numSimulations);
    
    % 卡组配置：5张打击（1费，6伤），5张防御（1费，5格挡）
    % 用1代表打击，2代表防御
    deck = [ones(1,5), 2*ones(1,5)];
    totalCards = length(deck);
    
    % 模拟循环
    for sim = 1:numSimulations
        %初始化每场战斗的状态
        % 牌库：初始为完整卡组，并洗牌
        drawPile = deck(randperm(totalCards));
        discardPile = [];
        playerHP = 100; % 假设玩家血量足够高，不会死亡（或根据需要修改）
        totalHPLoss = 0;
        
        % 每场战斗先进行"回合开始"抽牌
        % 如果抽牌堆不足5张，则弃牌堆洗回
        if length(drawPile) < 5
            drawPile = [drawPile, discardPile];
            discardPile = [];
            % 重新洗牌（如果牌库不为空）
            if ~isempty(drawPile)
                drawPile = drawPile(randperm(length(drawPile)));
            end
        end
        hand = drawPile(1:5); % 抽5张手牌
        drawPile(1:5) = [];   % 从抽牌堆移除
        
        %战斗主循环
        while monsterHP > 0
            %玩家回合
            energy = 3;      % 每回合3点能量
            currentBlock = 0; % 本回合格挡
            currentDamage = 0;% 本回合伤害
            
            % 手牌排序：优先使用防御牌（贪心策略：先保命，再输出）
            % 这是一个简化的策略，避免复杂组合枚举，防止卡死
            handDefense = hand(hand == 2); % 筛选出防御牌
            handStrike = hand(hand == 1);  % 筛选出打击牌
            
            % 1. 先打出所有能打的防御牌（1费）
            for i = 1:length(handDefense)
                if energy >= 1
                    currentBlock = currentBlock + 5; % 防御牌提供5格挡
                    energy = energy - 1;
                else
                    break;
                end
            end
            
            % 2. 再用剩余能量打打击牌（1费）
            for i = 1:length(handStrike)
                if energy >= 1
                    currentDamage = currentDamage + 6; % 打击牌造成6伤害
                    energy = energy - 1;
                else
                    break;
                end
            end
            
            % 对怪物造成伤害
            monsterHP = monsterHP - currentDamage;
            
            %怪物回合
            % 怪物攻击，玩家受到净伤害
            damageTaken = max(0, monsterAttack - currentBlock);
            totalHPLoss = totalHPLoss + damageTaken;
            % 注意：这里简化，不扣除玩家HP，只统计损失
            
            % 玩家回合结束：手牌进入弃牌堆
            discardPile = [discardPile, hand];
            hand = []; % 清空手牌
            
            % === 检查战斗是否结束 ===
            if monsterHP <= 0
                break; % 怪物死亡，战斗结束
            end
            
            % === 下一回合开始：抽牌 ===
            % 如果抽牌堆不足5张，则弃牌堆洗回
            if length(drawPile) < 5
                drawPile = [drawPile, discardPile];
                discardPile = [];
                % 重新洗牌（如果牌库不为空）
                if ~isempty(drawPile)
                    drawPile = drawPile(randperm(length(drawPile)));
                end
            end
            hand = drawPile(1:5); % 抽5张手牌
            drawPile(1:5) = [];   % 从抽牌堆移除
            
        end % 战斗结束
        
        % 记录本次模拟的HP损失
        hpLossArray(sim) = totalHPLoss;
        
        % 重置怪物血量，准备下一次模拟
        monsterHP = 50; % 重置为初始值
        
    end % 模拟循环结束
    
    % 计算期望HP损失
    meanHPLoss = mean(hpLossArray);
    
end