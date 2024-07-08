function [alpha_V1_UL, alpha_E2_UL, alpha_V1_DL, alpha_E2_DL] = Low_Complexity_Heuristic_Solution(beta_V1_UL, beta_E2_UL, beta_V1_DL, beta_E2_DL, N_UL, N_DL, S_eff_UL, S_eff_DL, S_eff_SL, B, F_d, S_m, R_b, omega, num_packet, num_UE)
        % Initialize alpha values
        
        [Psi_1_sel_UL, Psi_2_sel_UL] = Psi_sel_UL_Function(beta_V1_UL, beta_E2_UL, N_UL, S_eff_UL, S_eff_DL, S_eff_SL, F_d, B, S_m, R_b, num_packet, num_UE);

        [Psi_1_sel_DL, Psi_2_sel_DL] = Psi_sel_DL_Function(beta_V1_DL, beta_E2_DL, N_DL, S_eff_UL, S_eff_DL, S_eff_SL, F_d, B, S_m, R_b, num_packet, num_UE);
        % Check conditions and update alpha values accordingly
        if (Psi_1_sel_UL < 1) && (Psi_2_sel_UL > 1)
            Delta_C_2_UL = (1 - Psi_2_sel_UL) * omega;
            alpha_E2_UL = beta_E2_UL - Delta_C_2_UL;
            alpha_V1_UL = beta_V1_UL + Delta_C_2_UL;
            if (alpha_E2_UL > 1 || alpha_E2_UL < 0)
                alpha_V1_UL = beta_V1_UL;
                alpha_E2_UL = beta_E2_UL;
            end
        elseif (Psi_1_sel_UL > 1) && (Psi_2_sel_UL < 1)
            Delta_C_1_UL = (1 - Psi_1_sel_UL) * omega;
            alpha_V1_UL = beta_V1_UL - Delta_C_1_UL;
            alpha_E2_UL = beta_E2_UL + Delta_C_1_UL;
            if (alpha_V1_UL > 1 || alpha_V1_UL < 0)
                alpha_V1_UL = beta_V1_UL;
                alpha_E2_UL = beta_E2_UL;
            end
        else 
            alpha_V1_UL = beta_V1_UL;
            alpha_E2_UL = beta_E2_UL;
        end
        
        if (Psi_1_sel_DL < 1) && (Psi_2_sel_DL > 1)
            Delta_C_2_DL = (1 - Psi_2_sel_DL) * omega;
            alpha_E2_DL = beta_E2_DL - Delta_C_2_DL;
            alpha_V1_DL = beta_V1_DL + Delta_C_2_DL;
            if (alpha_E2_DL > 1 || alpha_E2_DL < 0)
                alpha_V1_DL = beta_V1_DL;
                alpha_E2_DL = beta_E2_DL;
            end
        elseif (Psi_1_sel_DL > 1) && (Psi_2_sel_DL < 1)
            Delta_C_1_DL = (1 - Psi_1_sel_DL) * omega;
            alpha_V1_DL = beta_V1_DL - Delta_C_1_DL;
            alpha_E2_DL = beta_E2_DL + Delta_C_1_DL;
            if (alpha_V1_DL > 1 || alpha_V1_DL < 0)
                alpha_V1_DL = beta_V1_DL;
                alpha_E2_DL = beta_E2_DL;
            end
        else
            alpha_V1_DL = beta_V1_DL;
            alpha_E2_DL = beta_E2_DL;
        end
  end
