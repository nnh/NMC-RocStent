# ' sae.R
# ' Created date: 2019/2/26
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
SaeReport_Group <- function(column_name, df_group_a, df_group_b){
  sae_list <- Aggregate_Group(df_group_a, df_group_b, column_name, c(column_name, kCount, kPercentage))
  temp_df <- sae_list[[kTableIndex]]
  sae_table <- subset(temp_df, (temp_df[ ,2] > 0 | temp_df[ ,4] > 0))
  # set percentage
#  total_sae_count <- sum(sae_table[ ,2]) + sum(sae_table[ ,4])
  sae_table[ ,3] <- round(sae_table[ ,2] / all_treatment * 100, digits=1)
  sae_table[ ,5] <- round(sae_table[ ,4] / all_treatment * 100, digits=1)
  rownames(sae_table) <- NULL
  output_sae <- list(sae_list[1], sae_list[2], sae_list[3], sae_list[4], sae_table)
  return(output_sae)
}
# Constant section ------
# Main section ------
#' # n=`r all_treatment`
#' ## 重篤な有害事象発生割合
output_sae <- SaeReport_Group("sae1_trm", sp_sae_report, mr_sae_report)
kable(KableList(output_sae), format = "markdown", align="r")
#' ## グレード別(最悪 grade)
temp_colname <- "ae_trm"
sp_ae <- sp_sae_report
mr_ae <- mr_sae_report
names(sp_ae)[which(names(sp_ae)=="sae1_trm")] <- temp_colname
names(mr_ae)[which(names(mr_ae)=="sae1_trm")] <- temp_colname
#+ results='asis'
for (i in kCTCAEGrade) {
  temp_sp <- subset(sp_ae, sae1_grd == as.character(i))
  temp_mr <- subset(mr_ae, sae1_grd == as.character(i))
  if (nrow(temp_sp) > 0 | nrow(temp_mr) > 0) {
    temp_output <- SaeReport_Group(temp_colname, temp_sp, temp_mr)
  } else {
    temp_output <- list(NA, NA, NA, NA, "該当なし")
  }
  cat("# ", paste0("Grade ", i), "  \n", "  \n")
  cat("## n=", all_treatment, "  \n", "  \n")
  print(kable(KableList(temp_output), format = "markdown", align="r"))
  cat("  \n")
  cat("  \n")
}
