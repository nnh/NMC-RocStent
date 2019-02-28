# ' spo2.R
# ' Created date: 2019/2/19
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
# Constant section ------
# Main section ------
col_sp_count <- paste0(kGroup_A, "_", kCount)
col_mr_count <- paste0(kGroup_B, "_", kCount)
col_over1_SpO2_n <- "over1_SpO2_n"
col_sum_count <- paste0("sum_", kCount)

sp_SpO2_1[col_over1_SpO2_n] <- ifelse(sp_SpO2_1$SpO2_n > 0, "あり", "なし")
mr_SpO2_1[col_over1_SpO2_n] <- ifelse(mr_SpO2_1$SpO2_n > 0, "あり", "なし")

over1_SpO2_n <- Aggregate_Group(sp_SpO2_1, mr_SpO2_1, col_over1_SpO2_n, c(col_over1_SpO2_n, kCount, kPercentage))
over1_SpO2_n[[kTableIndex]][col_sum_count] <- apply(over1_SpO2_n[[kTableIndex]][c(col_sp_count, col_mr_count)], 1, sum)
over1_SpO2_n[[kTableIndex]]$sum_per <- apply(over1_SpO2_n[[kTableIndex]][col_sum_count], 2, function(x){
  return(round(x / (over1_SpO2_n[[1]] + over1_SpO2_n[[3]]) * 100, digits=1))
})
#' # 低酸素イベントの有無
#' ## n=`r all_treatment`
kable(KableList(over1_SpO2_n), format = "markdown", align="r")
