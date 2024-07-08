function [Gamma_2_UL, Gamma_2_DL] = compute_Gamma_2(R_b, S_eff_UL, S_eff_DL, B, num_UE)
    T = 1;
    % Tính rho_x(m,t) cho uplink và downlink
    rho_UL = R_b / (S_eff_UL * B); % Số lượng RBs cần thiết cho uplink
    rho_DL = R_b / (S_eff_DL * B); % Số lượng RBs cần thiết cho downlink
    

    % Tính tổng số RBs cần thiết cho UL và DL
    total_RBs_UL = rho_UL * num_UE;
    total_RBs_DL = rho_DL * num_UE; 
    
    % Tính Gamma_2_x cho UL và DL
    Gamma_2_UL = total_RBs_UL / T;
    Gamma_2_DL = total_RBs_DL / T;
    
    Gamma_2_UL = round(Gamma_2_UL, 2);
    Gamma_2_DL = round(Gamma_2_DL, 2);
    % Hiển thị kết quả
    fprintf('Gamma_2_UL: %.4f RBs\n', Gamma_2_UL);
    fprintf('Gamma_2_DL: %.4f RBs\n', Gamma_2_DL);
end