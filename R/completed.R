# ' completed.r
# ' Created date: 2019/2/28
# ' author: mariko ohtsuka
# ' output:
# '   html_document:


completed <- Aggregate_Sum_Group(sp_ptdata, mr_ptdata, "cancel1", "completed")
#' # プロトコル治療完遂割合
#' ## n=`r all_treatment`
kable(KableList(completed), format = "markdown", align="r")

df_completed <- ptdata[, c("cancel1","自動割付", "pre_PF", "pre_aw_stenosis")]
df_completed$cancel1 <- ifelse(df_completed$cancel1 == "完了", 0, 1)
df_completed$allocation <- ifelse(df_completed$自動割付 == "A", kGroup_A, kGroup_B)
df_completed <- ConvertFactor(df_completed)
glm_completed <- glm(cancel1 ~ allocation+pre_PF+pre_aw_stenosis, data=df_completed, family=binomial)
summary_glm_completed <- summary(glm_completed)
coef_completed <- exp(coef(summary_glm_completed))
confint_completed <- exp(confint(glm_completed, level=0.90))
#' ### summary
kable(summary_glm_completed$coefficients, format = "markdown", align="r")
#' ### odds
kable(coef_completed, format = "markdown", align="r")
#' ### ci
kable(confint_completed, format = "markdown", align="r")

#ld_completed <- logistic.display(glm_completed, alpha=0.1, simplified=F)
#' ### logistic.display
#kable(ld_completed, format = "markdown", align="r")
