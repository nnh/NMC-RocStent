# ' spo2.R
# ' Created date: 2019/2/19
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
col_over1_SpO2_n <- "over1_SpO2_n"
sp_SpO2_1[col_over1_SpO2_n] <- ifelse(sp_SpO2_1$SpO2_n > 0, "あり", "なし")
mr_SpO2_1[col_over1_SpO2_n] <- ifelse(mr_SpO2_1$SpO2_n > 0, "あり", "なし")
over1_SpO2_n <- Aggregate_Sum_Group(sp_SpO2_1, mr_SpO2_1, col_over1_SpO2_n, "SpO2")
spo2_nrow <- nrow(sp_SpO2_1) + nrow(mr_SpO2_1)
#' # 低酸素イベントの有無
#' ## n=`r spo2_nrow`
kable(KableList(over1_SpO2_n), format = "markdown", align="r")

df_SpO2 <- rbind(sp_SpO2_1, mr_SpO2_1)
df_SpO2$allocation <- ifelse(df_SpO2$自動割付 == "A", 0, 1)
df_SpO2$grm_SpO2_n <- ifelse(df_SpO2$SpO2_n > 0, 1, 0)
df_SpO2 <- ConvertFactor(df_SpO2)
#' # 検定
temp_formula <- "grm_SpO2_n ~ allocation+pre_PF+pre_aw_stenosis"
#+ message=FALSE
glm_SpO2 <- GlmList(temp_formula, df_SpO2, 0.90)
#+ message=TRUE
#' ### formula
formula(temp_formula)
#' - grm_SpO2_n
#' -- 0:低酸素イベントなし 1:低酸素イベントあり
temp_levels <- levels(factor(df_SpO2$allocation))
#' - allocation
#' -- 0:SP 1:MR
temp_levels <- levels(factor(df_SpO2$pre_PF))
#' - pre_PF
#' -- `r temp_levels`
temp_levels <- levels(factor(df_SpO2$pre_aw_stenosis))
#' - pre_aw_stenosis
#' -- `r temp_levels`
#'
#' ### glm
kable(glm_SpO2[[1]]$coefficients, format = "markdown", align="r")
#' ### summary
glm_SpO2[[2]]
#' ### odds
kable(glm_SpO2[[3]], format = "markdown", align="r")
#' ### ci
kable(glm_SpO2[[4]], format = "markdown", align="r")
