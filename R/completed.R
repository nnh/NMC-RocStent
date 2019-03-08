# ' completed.r
# ' Created date: 2019/2/28
# ' author: mariko ohtsuka
temp_binomial_aggregate <- Aggregate_Sum_Group(sp_ptdata, mr_ptdata, "cancel1", "completed")
temp_binomial_header <- "プロトコル治療完遂割合"
temp_binomial_nrow <- all_treatment
temp_header_string_1 <- "cancel1"
temp_header_string_2 <- "0:中止 1:完了"
df_biominal <- ptdata
df_biominal$cancel1 <- ifelse(df_biominal$cancel1 == "中止", 0, 1)
temp_formula <- "cancel1 ~ allocation + glm_pre_PF + glm_pre_aw_stenosis"
render(paste0(source_path, "/glm_binomial.R"), output_dir=output_path, output_file="completed.html")
