# ' demog.R
# ' Created date: 2019/2/19
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
#' ## Number of patients (%)
number_of_patients <- paste0("n=", all_qualification, " (", all_qualification / all_qualification * 100, "%)")
#' ### `r number_of_patients`
#'
#' ## 登録時年齢
temp_variable <- "age"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## 性別
temp_colname <- "sex"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ## 身長
temp_variable <- "hight"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## 体重
temp_variable <- "weight"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## BMI
temp_variable <- "BMI"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## ASA
temp_colname <- "ASA"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ## 原因疾患
temp_colname <- "cause_disease"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ## 術前の呼吸状態
#' ### 術前酸素投与の有無
temp_colname <- "O2"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ### 術前P/F比
temp_colname <- "pre_PF"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ## 気道の狭窄部位(主気管を含むか否か)
temp_colname <- "pre_aw_stenosis"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ## 予定、緊急
temp_colname <- "ope"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ## 心機能異常の有無
temp_colname <- "ab_cardio_func"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ## 肺気腫の有無
temp_colname <- "emphysema"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
