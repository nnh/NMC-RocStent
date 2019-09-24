# ' spo2_ci95.R
# ' Created date: 2019/9/24
# ' author: mariko ohtsuka
spo2_output_name <- "spo2"
spo2_output_name <- paste0(spo2_output_name, "_ci95.html")
col_over1_SpO2_n <- "over1_SpO2_n"
sp_SpO2_1[col_over1_SpO2_n] <- ifelse(sp_SpO2_1$SpO2_n > 0, "あり", "なし")
mr_SpO2_1[col_over1_SpO2_n] <- ifelse(mr_SpO2_1$SpO2_n > 0, "あり", "なし")
temp_binomial_aggregate <- Aggregate_Sum_Group(sp_SpO2_1, mr_SpO2_1, col_over1_SpO2_n, "SpO2")
temp_binomial_header <- "低酸素イベントの有無"
temp_binomial_nrow <- nrow(sp_SpO2_1) + nrow(mr_SpO2_1)
temp_header_string_1 <- "grm_SpO2_n"
temp_header_string_2 <- "0:低酸素イベントなし 1:低酸素イベントあり"
df_biominal <- rbind(sp_SpO2_1, mr_SpO2_1)
df_biominal$grm_SpO2_n <- ifelse(df_biominal$SpO2_n > 0, 1, 0)
temp_formula <- "grm_SpO2_n ~ allocation + glm_pre_PF + glm_pre_aw_stenosis"
temp_binomial_title <- "SpO2"
render(paste0(source_path, "/glm_binomial_ci95.R"), output_dir=output_path, output_file=spo2_output_name)
