function [Gamma_1_UL, Gamma_1_DL, Gamma_1_SL] = compute_Gamma_1(S_eff_UL, S_eff_DL, S_eff_SL, F_d, B,S_m, num_packet)

    % Tính tổng số bits đã truyền
    total_bits = num_packet * S_m;
    
    % Tính Gamma
    Gamma_1_UL = total_bits / (S_eff_UL * B * F_d);
    Gamma_1_DL = total_bits / (S_eff_DL * B * F_d);
    Gamma_1_SL = total_bits / (S_eff_SL * B * F_d);

    Gamma_1_UL = round(Gamma_1_UL, 2);
    Gamma_1_DL = round(Gamma_1_DL, 2);
    Gamma_1_SL = round(Gamma_1_SL, 2);
    fprintf('Gamma_1_UL: %.4f RBs\n', Gamma_1_UL);
    fprintf('Gamma_1_DL: %.4f RBs\n', Gamma_1_DL);
    fprintf('Gamma_1_SL: %.4f RBs\n', Gamma_1_SL);
 end