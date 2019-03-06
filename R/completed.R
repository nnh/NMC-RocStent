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
df_completed$cancel1 <- ifelse(df_completed$cancel1 == "中止", 0, 1)
df_completed$allocation <- ifelse(df_completed$自動割付 == "A", 0, 1)
df_completed <- ConvertFactor(df_completed)
#' # 検定
temp_formula <- "cancel1 ~ allocation+pre_PF+pre_aw_stenosis"
#+ message=FALSE
glm_completed <- GlmList(temp_formula, df_completed, 0.90)
#+ message=TRUE
#' ### formula
formula(temp_formula)
#' - cancel1
#' -- 0:中止 1:完了
temp_levels <- levels(factor(df_completed$allocation))
#' - allocation
#' -- 0:SP 1:MR
temp_levels <- levels(factor(df_completed$pre_PF))
#' - pre_PF
#' -- `r temp_levels`
temp_levels <- levels(factor(df_completed$pre_aw_stenosis))
#' - pre_aw_stenosis
#' -- `r temp_levels`
#'
#' ### glm
kable(glm_completed[[1]]$coefficients, format = "markdown", align="r")
#' ### summary
glm_completed[[2]]
#' ### odds
kable(glm_completed[[3]], format = "markdown", align="r")
#' ### ci
kable(glm_completed[[4]], format = "markdown", align="r")
