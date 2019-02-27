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
  total_sae_count <- sum(sae_table[ ,2]) + sum(sae_table[ ,4])
  sae_table[ ,3] <- round(sae_table[ ,2] / total_sae_count * 100, digits=1)
  sae_table[ ,5] <- round(sae_table[ ,4] / total_sae_count * 100, digits=1)
  rownames(sae_table) <- NULL
  output_sae <- list(sae_list[1], sae_list[2], sae_list[3], sae_list[4], sae_table)
  return(output_sae)
}
# Constant section ------
# Main section ------
#' # 重篤な有害事象発生割合
#' ## n=`r all_treatment`
output_sae <- SaeReport_Group("sae1_trm", sp_sae_report, mr_sae_report)
kable(KableList(output_sae), format = "markdown", align="r")
#' # グレード別(最悪 grade)
temp_colname <- "ae_trm"
sp_ae <- sp_sae_report
mr_ae <- mr_sae_report
names(sp_ae)[which(names(sp_ae)=="sae1_trm")] <- temp_colname
names(mr_ae)[which(names(mr_ae)=="sae1_trm")] <- temp_colname
for (i in kCTCAEGrade) {
  temp_sp <- subset(sp_ae, sae1_grd == as.character(i))
  temp_mr <- subset(mr_ae, sae1_grd == as.character(i))
  output_df_name <- paste0("output_ae_", as.character(i))
  if (nrow(temp_sp) > 0 | nrow(temp_mr) > 0) {
    assign(output_df_name, SaeReport_Group(temp_colname, temp_sp, temp_mr))
  } else {
    assign(output_df_name, list(NA, NA, NA, NA, "該当なし"))
  }
}
#' # Grade 1
#' ## n=`r all_treatment`
kable(KableList(output_ae_1), format="markdown", align="r")
#' # Grade 2
#' ## n=`r all_treatment`
kable(KableList(output_ae_2), format="markdown", align="r")
#' # Grade 3
#' ## n=`r all_treatment`
kable(KableList(output_ae_3), format="markdown", align="r")
#' # Grade 4
#' ## n=`r all_treatment`
kable(KableList(output_ae_4), format="markdown", align="r")
#' # Grade 5
#' ## n=`r all_treatment`
kable(KableList(output_ae_5), format="markdown", align="r")
