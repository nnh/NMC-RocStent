# ' spo2.R
# ' Created date: 2019/2/19
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
col_over1_SpO2_n <- "over1_SpO2_n"
sp_SpO2_1[col_over1_SpO2_n] <- ifelse(sp_SpO2_1$SpO2_n > 0, "あり", "なし")
mr_SpO2_1[col_over1_SpO2_n] <- ifelse(mr_SpO2_1$SpO2_n > 0, "あり", "なし")
over1_SpO2_n <- Aggregate_Sum_Group(sp_SpO2_1, mr_SpO2_1, col_over1_SpO2_n, "SpO2")
#' # 低酸素イベントの有無
#' ## n=`r all_treatment`
kable(KableList(over1_SpO2_n), format = "markdown", align="r")
