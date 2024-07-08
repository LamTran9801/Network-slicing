function [Q_final_UL, Q_final_DL] = RL_Slicing_Algorithm(NUL, NDL, S, actions, S_eff_UL, S_eff_DL, S_eff_SL, B, F_d, S_m, R_b, num_packet, num_UE)
    % Initialize parameters
    t = 0;
    learning_period = 100;
   
    % Number of actions
    num_actions = length(actions);
    
    
    % Initialize Q values for UL and DL
    Q_UL = zeros(1, num_actions);
    Q_DL = zeros(1, num_actions);
    for k = 1:num_actions
        % Define actions for UL and DL
        ak_UL = actions(k);
        ak_DL = actions(k);

        % Compute β1;x(k) and β2;x(k)
        beta_V1_UL = @(k) 0.05 * k;
        beta_V1_DL = @(k) 0.05 * k;
        beta_E2_UL = @(k) 1 - 0.05 * k;
        beta_E2_DL = @(k) 1 - 0.05 * k;

        % Initialize Q-values
        Q_UL(k) = 0;
        Q_DL(k) = 0;
    end
    % Learning iterations
    while t < learning_period % Learning period
        % For each link (UL, DL)
        for x = ["UL", "DL"]
            disp(x);
            % Xác định biến số phù hợp
            if x == "UL"
                Q = Q_UL;
                N = NUL;
                beta_V1 = beta_V1_UL;
                beta_E2 = beta_E2_UL;
            else
                Q = Q_DL;
                N = NDL;
                beta_V1 = beta_V1_DL;
                beta_E2 = beta_E2_DL;
            end
            
            % Áp dụng hành động đã chọn và đánh giá Psi
            if x == "UL"
                tau = 0.1;
                ak = select_action_softmax(Q, tau);
                disp("select action: ");
                disp(ak);
                % Tính Psi
                [Psi_1_UL, Psi_2_UL] = Psi_UL_Function(ak, beta_V1, beta_E2, N, S_eff_UL, S_eff_DL, S_eff_SL, F_d, B, S_m, R_b, num_packet, num_UE);
                % Tính tổng phần thưởng
                RTOT_UL = RTOT_UL_Function(Psi_1_UL, Psi_2_UL, S);
                % Cập nhật Q value
                Q_UL = update_Q(Q_UL, ak, RTOT_UL); 
            else 
                tau = 0.1;
                ak = select_action_softmax(Q, tau);
                disp("select action: ");
                disp(ak);
                % Tính Psi
                [Psi_1_DL, Psi_2_DL] = Psi_DL_Function(ak, beta_V1, beta_E2, N, S_eff_UL, S_eff_DL, S_eff_SL, F_d, B, S_m, R_b, num_packet, num_UE);
                % Tính tổng phần thưởng
                RTOT_DL = RTOT_DL_Function(Psi_1_DL, Psi_2_DL, S);
                % Cập nhật Q_values
                Q_DL = update_Q(Q_DL, ak, RTOT_DL); 
            end

        end
        
        t = t + 1;
    end
    
    % Trả lại giá trị Q cuối cùng cho UL và DL
    Q_final_UL = Q_UL;
    Q_final_DL = Q_DL;
end

function selected_action = select_action_softmax(Q, tau)
% Tính tổng các giá trị mũ chia cho tau
total = sum(exp(Q / tau));

% Tính xác suất cho từng phần tử trong Q
probs = exp(Q / tau) / total;

% Sinh số ngẫu nhiên trong khoảng từ 0 đến 1
threshold = rand();

% Tính xác suất tích lũy
cumulative_prob = 0.0;
for i = 1:length(probs)
    cumulative_prob = cumulative_prob + probs(i);
    if cumulative_prob > threshold
        selected_action = i;
        return;
    end
end

% Nếu không tìm thấy phần tử thỏa mãn, trả về chỉ số của phần tử có xác suất cao nhất
[~, selected_action] = max(probs);
end

function RTOT_UL = RTOT_UL_Function(Psi_1_UL, Psi_2_UL, S)
    % Compute reward for slice 1 (V2X) in UL and DL
    R_1_UL = compute_Reward(Psi_1_UL);
    R_1_UL = round(R_1_UL, 2);
    %disp("R1_UL");
    %disp(R_1_UL);
    
    % Compute reward for slice 2 (eMBB) in UL and DL
    R_2_UL = compute_Reward(Psi_2_UL);
    R_2_UL = round(R_2_UL, 2);
    %disp("R2_UL");
    %disp(R_2_UL);
    % Compute total reward for link x (UL and DL)
    RTOT_UL = (R_1_UL * R_2_UL)^(1/S);
    RTOT_UL = round(RTOT_UL, 2);
    %disp("RTOT_UL");
    %disp(RTOT_UL);
end

function RTOT_DL = RTOT_DL_Function(Psi_1_DL, Psi_2_DL, S)
    % Compute reward for slice 1 (V2X) in UL and DL
    R_1_DL = compute_Reward(Psi_1_DL);
    R_1_DL = round(R_1_DL, 2);
    %disp("R1_DL");
    %disp(R_1_DL);
    % Compute reward for slice 2 (eMBB) in UL and DL
    R_2_DL = compute_Reward(Psi_2_DL);
    R_2_DL = round(R_2_DL, 2);
    %disp("R2_DL");
    %disp(R_2_DL);
    % Compute total reward for link x (UL and DL)
   
    RTOT_DL = (R_1_DL * R_2_DL)^(1/S);
    RTOT_DL = round(RTOT_DL, 2);
    %disp("RTOT_DL");
    %disp(RTOT_DL);
    
end

function R = compute_Reward(Psi)
    if Psi <= 1
        R = exp(Psi);
    else
        R = 1 / Psi;
    end
    R = round(R, 2);
end

function updated_Q = update_Q(Q, ak, reward)
    % Cập nhật Q-value dựa trên phương trình (15)
    alpha = 0.1; % Tốc độ học
    if ak <= length(Q)
        updated_Q = Q; % Sao chép giá trị Q hiện tại
        updated_Q(ak) = (1 - alpha) * Q(ak) + alpha * reward; % Cập nhật Q cho hành động 'ak'
    else
        updated_Q = Q; % Trường hợp chỉ số không hợp lệ
    end
end