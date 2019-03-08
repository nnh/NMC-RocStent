# ' glm_binomial.R
# ' Created date: 2019/3/8
# ' author: mariko ohtsuka
#' # `r temp_binomial_header`
#' ## n=`r temp_binomial_nrow`
kable(KableList(temp_binomial_aggregate), format = "markdown", align="r")
df_biominal <- ConvertFactor(df_biominal)
#' # 検定
#+ message=FALSE
glm_binomial_list <- GlmList_binomial(temp_formula, df_biominal, 0.90)
#+ message=TRUE
#' ### formula
formula(temp_formula)
#' - `r temp_header_string_1`
#'     - `r temp_header_string_2`
#' - allocation
#'     - 0:SP 1:MR
#' - pre_PF
#'     - 0:250を超える 1:250以下
#' - pre_aw_stenosis
#'     - 0:なし 1:あり
#'
#' ### glm
kable(glm_binomial_list[[1]]$coefficients, format = "markdown", align="r")
#' ### summary
glm_binomial_list[[2]]
#' ### odds
kable(glm_binomial_list[[3]], format = "markdown", align="r")
#' ### ci
kable(glm_binomial_list[[4]], format = "markdown", align="r")
