function main()
    % Test case parameters
    addpath('C:\Users\Admin\OneDrive\Documents\MATLAB\Network Slicing');
    NUL = 200; % Number of Rbs for UL per cell
    NDL = 200; % Number of Rbs for DL per cell
    S = 2; % Number of slice
    actions = 1:20; % Number of actions
    S_eff_UL = 2; % Spectral efficiency for UL 
    S_eff_DL = 3; % Spectral efficiency for DL
    S_eff_SL = 2; % Spectral efficiency for SL
    F_d = 0.01; % TTI duration
    %time_window = 1; % unit s
    B = 36e4; % Bandwidth
    %T = time_window / F_d; % Number of TTIs
    
    % V2X parameter
    %lambda_a = 1; % Vehicle arrival rate (UE/s)
    lambda_v = 1; % Packet arrival rate (packets/s)
    S_m = 300 * 8; % Length of the messages for V2X

    % eMBB parameter
    % eMBB parameter
    session_duration = 120; % Average session duration in seconds
    lambda_eMBB = 1; % eMBB UE arrival rate (UE/s)
    R_b = 1e6; % Guaranteed bit rate in bps (1 Mbps)
    
    omega = 0.5;
    
    % Prepare to store results
    SesRate = linspace(0.2, 1.2, 100);
    lambda_process = 1;
    utilization_avarage_proposed_rl_UL = zeros(size(SesRate));
    utilization_avarage_proposed_rl_heuristic_UL = zeros(size(SesRate));

    utilization_avarage_proposed_rl_DL = zeros(size(SesRate));
    utilization_avarage_proposed_rl_heuristic_DL = zeros(size(SesRate));
        
    for idx = 1:length(SesRate)
        
        % Calculate number of eMBB users based on session generation rate and duration
        number_UE_offline = poissrnd(lambda_eMBB * lambda_process); % Số lượng người dùng ngẫu nhiên dựa trên Poisson
       
        number_packet_offline = poissrnd(lambda_v * lambda_process);
     
        % Run RL_Slicing_Algorithm
        [Q_UL_final, Q_DL_final] = RL_Slicing_Algorithm(NUL, NDL, S, actions, S_eff_UL, S_eff_DL, S_eff_SL, B, F_d, S_m, R_b, number_packet_offline, number_UE_offline);
        % Display final Q values
        disp("Final Q values for UL:");
        disp(Q_UL_final);

        disp("Final Q values for DL:");
        disp(Q_DL_final);
        % Extract best action for UL
        best_action_UL = extract_best_action(Q_UL_final);
        disp("Best action for UL:");
        disp(best_action_UL);

        % Extract best action for DL
        best_action_DL = extract_best_action(Q_DL_final);
        disp("Best action for DL:");
        disp(best_action_DL);

        beta_V1_UL = 0.05 * best_action_UL;
        beta_V1_DL = 0.05 * best_action_DL;
        beta_E2_UL = 1 - 0.05 * best_action_UL;
        beta_E2_DL = 1 - 0.05 * best_action_DL;
        % Display results
        disp("Beta values for UL:");
        disp("Beta_V1_UL: " + beta_V1_UL);
        disp("Beta_E2_UL: " + beta_E2_UL);

        disp("Beta values for DL:");
        disp("Beta_V1_DL: " + beta_V1_DL);
        disp("Beta_E2_DL: " + beta_E2_DL);

        [number_eMBB_process, number_packet_process] = Gen_traffic(session_duration, SesRate(idx), lambda_v, lambda_process);  
        length_number_eMBB_process = length(number_eMBB_process);
        number_session = length_number_eMBB_process;
        
        RB_assigned_UL_V1_RL = zeros(1, number_session);
        RB_assigned_DL_V1_RL = zeros(1, number_session);
        RB_assigned_SL_V1_RL = zeros(1, number_session);
        RB_assigned_UL_E2_RL = zeros(1, number_session);
        RB_assigned_DL_E2_RL = zeros(1, number_session);
        RB_assigned_UL_RL = zeros(1, number_session);
        RB_assigned_DL_RL = zeros(1, number_session);
        utilization_avarage_proposed_rl_UL1 = zeros(1, number_session);
        utilization_avarage_proposed_rl_DL1 = zeros(1, number_session);
        RB_assigned_UL_V1_RL_HEU = zeros(1, number_session);
        RB_assigned_DL_V1_RL_HEU = zeros(1, number_session);
        RB_assigned_SL_V1_RL_HEU = zeros(1, number_session);
        RB_assigned_UL_E2_RL_HEU = zeros(1, number_session);
        RB_assigned_DL_E2_RL_HEU = zeros(1, number_session);
        RB_assigned_UL_RL_HEU = zeros(1, number_session);
        RB_assigned_DL_RL_HEU = zeros(1, number_session);
        utilization_avarage_proposed_rl_heuristic_UL1 = zeros(1, number_session);
        utilization_avarage_proposed_rl_heuristic_DL1 = zeros(1, number_session);
        for k = 1:number_session
            num_packet = number_packet_process(k);
            num_UE = number_eMBB_process(k);
            [Gamma_2_UL, Gamma_2_DL] = compute_Gamma_2(R_b, S_eff_UL, S_eff_DL, B, num_UE);
            [Gamma_1_UL, Gamma_1_DL, Gamma_1_SL] = compute_Gamma_1(S_eff_UL, S_eff_DL, S_eff_SL, F_d, B, S_m, num_packet);
            RB_assigned_UL_V1_RL(k) = min_value(Gamma_1_UL, (beta_V1_UL * 0.35 * NUL));
            RB_assigned_SL_V1_RL(k) = min_value(Gamma_1_SL, (beta_V1_UL * 0.65 * NUL));
            RB_assigned_DL_V1_RL(k) = min_value(Gamma_1_DL, (beta_V1_DL * NDL));

            RB_assigned_UL_E2_RL(k) = min_value(Gamma_2_UL, (beta_E2_UL * NUL));
            RB_assigned_DL_E2_RL(k) = min_value(Gamma_2_DL, (beta_E2_DL * NDL));
            
            RB_assigned_UL_RL(k) = RB_assigned_UL_V1_RL(k) + RB_assigned_UL_E2_RL(k) + RB_assigned_SL_V1_RL(k);
            RB_assigned_DL_RL(k) = RB_assigned_DL_V1_RL(k) + RB_assigned_DL_E2_RL(k);

            utilization_avarage_proposed_rl_UL1(k) = RB_assigned_UL_RL(k) / NUL;
            utilization_avarage_proposed_rl_DL1(k) = RB_assigned_DL_RL(k) / NDL;

            [alpha_V1_UL, alpha_E2_UL, alpha_V1_DL, alpha_E2_DL] = Low_Complexity_Heuristic_Solution(beta_V1_UL, beta_E2_UL, beta_V1_DL, beta_E2_DL, NUL, NDL, S_eff_UL, S_eff_DL, S_eff_SL, B, F_d, S_m, R_b, omega, num_packet, num_UE);
            disp("Alpha values for UL:");
            disp("Alpha_V1_UL: " + alpha_V1_UL);
            disp("Alpha_E2_UL: " + alpha_E2_UL);
                
            disp("Alpha values for DL:");
            disp("Alpha_V1_DL: " + alpha_V1_DL);
            disp("Alpha_E2_DL: " + alpha_E2_DL);

            RB_assigned_UL_V1_RL_HEU(k) = min_value(Gamma_1_UL, (alpha_V1_UL * 0.35 * NUL));
            RB_assigned_SL_V1_RL_HEU(k) = min_value(Gamma_1_UL, (alpha_V1_UL * 0.65 * NUL));
            RB_assigned_DL_V1_RL_HEU(k) = min_value(Gamma_1_DL, (alpha_V1_DL * NDL));

            RB_assigned_UL_E2_RL_HEU(k) = min_value(Gamma_2_UL, (alpha_E2_UL * NUL));
            RB_assigned_DL_E2_RL_HEU(k) = min_value(Gamma_2_DL, (alpha_E2_DL * NDL));

            RB_assigned_UL_RL_HEU(k) = RB_assigned_UL_V1_RL_HEU(k) + RB_assigned_UL_E2_RL_HEU(k) + RB_assigned_SL_V1_RL_HEU(k);
            RB_assigned_DL_RL_HEU(k) = RB_assigned_DL_V1_RL_HEU(k) + RB_assigned_DL_E2_RL_HEU(k);

            utilization_avarage_proposed_rl_heuristic_UL1(k) = RB_assigned_UL_RL_HEU(k) / NUL;
            utilization_avarage_proposed_rl_heuristic_DL1(k) = RB_assigned_DL_RL_HEU(k) / NDL;
        end
        
        utilization_avarage_proposed_rl_UL(idx) = sum(utilization_avarage_proposed_rl_UL1, 'all') / number_session;
        disp(['utilization_avarage_proposed_rl_UL: ', num2str(utilization_avarage_proposed_rl_UL(idx))]);
        utilization_avarage_proposed_rl_DL(idx) = sum(utilization_avarage_proposed_rl_DL1, 'all') / number_session;
        disp(['utilization_avarage_proposed_rl_DL: ', num2str(utilization_avarage_proposed_rl_DL(idx))]);


        utilization_avarage_proposed_rl_heuristic_UL(idx) = sum(utilization_avarage_proposed_rl_heuristic_UL1, 'all') / number_session;
        disp(['utilization_avarage_proposed_rl_heuristic_UL: ', num2str(utilization_avarage_proposed_rl_heuristic_UL(idx))]);
        utilization_avarage_proposed_rl_heuristic_DL(idx) = sum(utilization_avarage_proposed_rl_heuristic_DL1, 'all') / number_session;
        disp(['utilization_avarage_proposed_rl_heuristic_DL: ', num2str(utilization_avarage_proposed_rl_heuristic_DL(idx))]);
        lambda_process = lambda_process + 1;
    end
    
    % Plot the results for UL
    figure;
    hold on;
    plot(SesRate, utilization_avarage_proposed_rl_UL, 'g-', 'DisplayName', 'RL- Scheme');
    plot(SesRate, utilization_avarage_proposed_rl_heuristic_UL, 'r--', 'DisplayName', 'RL+ Heuristic Scheme');
    
    xlabel('Session Arrival Rate (\lambda_e)');
    ylabel('Resource Blocks (RBs) Utilization');
    legend('show');
    title('Uplink RB utilization as a function of the eMBB session generation rate \lambda_e (sessions/s)');
    grid on;
    
    % Plot the results for DL
    figure;
    hold on;
    plot(SesRate, utilization_avarage_proposed_rl_DL, 'g-', 'DisplayName', 'RL- Scheme');
    plot(SesRate, utilization_avarage_proposed_rl_heuristic_DL, 'r--', 'DisplayName', 'RL+ Heuristic Scheme');
    
    xlabel('Session Arrival Rate (\lambda_e)');
    ylabel('Resource Blocks (RBs) Utilization');
    legend('show');
    title('Downlink RB utilization as a function of the eMBB session generation rate \lambda_e (sessions/s)');
    grid on;
end

function best_action = extract_best_action(Q_final)
    [~, best_action_index] = max(Q_final);
    best_action = best_action_index;
end

function min_val = min_value(a, b)
    % Hàm trả về giá trị nhỏ hơn giữa hai số a và b
    if a < b
        min_val = a;
    else
        min_val = b;
    end
end