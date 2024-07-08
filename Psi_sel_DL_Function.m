function [Psi_1_sel_DL, Psi_2_sel_DL] = Psi_sel_DL_Function(beta_V1_DL, beta_E2_DL, N_DL, S_eff_UL, S_eff_DL, S_eff_SL, F_d, B, S_m, R_b, num_packet, num_UE)
    % Compute Gamma values for slice 1 (V2X)
    [Gamma_1_UL, Gamma_1_DL, Gamma_1_SL] = compute_Gamma_1(S_eff_UL, S_eff_DL, S_eff_SL, F_d, B,S_m, num_packet);
    
    % Compute Gamma values for slice 2 (eMBB)
    [Gamma_2_UL, Gamma_2_DL] = compute_Gamma_2(R_b, S_eff_UL, S_eff_DL, B, num_UE);

    % Compute Psi values for slice 1 (V2X)
    
    Psi_1_sel_DL = (Gamma_1_DL) / (beta_V1_DL * N_DL);
    disp("Psi_1_sel_DL");
    disp(Psi_1_sel_DL);

    % Compute Psi values for slice 2 (eMBB)
    Psi_2_sel_DL = (Gamma_2_DL) / (beta_E2_DL * N_DL);
    
    disp("Psi_2_sel_DL");
    disp(Psi_2_sel_DL);
end