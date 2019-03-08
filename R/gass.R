# ' gass.r
# ' Created date: 2019/2/28
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
par(family = "HiraKakuProN-W3")
#+ results='asis'
header_str <- c("術中pH 平均値", "術中PaCO2 平均値", "術中P/F 比平均値", "術中 SpO2 最低値")
header_n <- c(all_treatment, all_treatment, all_treatment, ope_spo2_n)
temp_variable <- c("pH", "PaCO2", "PF","SpO2_min")
for (i in 1:length(temp_variable)) {
  cat("## ", header_str[i], "  \n", "  \n")
  cat("### n=", header_n[i], "  \n", "  \n")
  print(kable(KableList(get(temp_variable[i])), format = "markdown", align="r"))
  cat("  \n")
  boxplot(sp_ptdata[ ,temp_variable[i]], mr_ptdata[ ,temp_variable[i]], xlab="Muscle relaxation",
          ylab=temp_variable[i], names=c("SP", "MR"))
  cat("  \n")
  # glm
  temp_formula <- paste0(temp_variable[i]," ~ allocation + glm_pre_PF + glm_pre_aw_stenosis")
  rst <- glm(formula=temp_formula, data=ptdata, family=gaussian)
  smr <- summary(rst)
  cat("  \n")
  cat("### ", "formula", "  \n", "  \n")
  print(formula(temp_formula))
  cat("  \n")
  cat("- ", "allocation", "  \n")
  cat("\t", "- ", "0:SP 1:MR", "  \n", "  \n")
  cat("- ", "glm_pre_PF", "  \n")
  cat("\t", "- ", "0:250を超える 1:250以下", "  \n", "  \n")
  cat("- ", "glm_pre_aw_stenosis", "  \n")
  cat("\t", "- ", "0:なし 1:あり", "  \n", "  \n")
  cat("### ", "glm_coefficients", "  \n", "  \n")
  print(kable(rst$coefficients, format = "markdown", align="r"))
  cat("  \n")
  cat("### ", "summary_coefficients", "  \n", "  \n")
  print(kable(smr$coefficients, format = "markdown", align="r"))
  cat("  \n")
}
