ReturnN_column <- function(target_column){
  n_of_all <- length(target_values)
  n_of_missing <- length(target_)
}
# ' demog.R
# ' Created date: 2019/2/19
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
# Constant section ------
kRegist_date_colname <- "regist_date"
# Main section ------
#' ## Number of patients (%)
number_of_patients <- paste0("n=", all_qualification, " (", all_qualification / all_qualification * 100, "%)")
#' ### `r number_of_patients`
# 登録時年齢
#' ## Median age [IQR] (range), years *1
df_age_sex <- merge(ptdata, birth_date_sex[ ,c("症例登録番号", "生年月日", "性別")],
                    all=F, by.x="SUBJID", by.y="症例登録番号")
df_age_sex$age <- NA
for (i in 1:nrow(df_age_sex)) {
  if (!is.na(df_age_sex[i, kRegist_date_colname])) {
    df_age_sex[i, "age"] <- length(seq(df_age_sex[i, "生年月日"], df_age_sex[i, kRegist_date_colname], "year")) - 1
  }
}
age_summary <- SummaryValue(df_age_sex$age)
kable(age_summary, format = "markdown")
#' ## 性別
sp_sex <- subset(df_age_sex, df_age_sex$自動割付 == kSP)
mr_sex <- subset(df_age_sex, df_age_sex$自動割付 == kMR)
sex <- Aggregate_sp_mr(sp_sex, mr_sex, "性別", c("sex", "count", "per"))
kable(KableList(sex), format="markdown", align="r")
#' ## 身長
hight <- Summary_sp_mr(sp_ptdata, mr_ptdata, "hight")
kable(hight, format = "markdown")
#' ## 体重
weight <- Summary_sp_mr(sp_ptdata, mr_ptdata, "weight")
kable(weight, format = "markdown")
#' ## BMI
bmi <- Summary_sp_mr(sp_ptdata, mr_ptdata, "BMI")
kable(bmi, format = "markdown")
#' ## ASA
temp_colname <- "ASA"
asa <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(KableList(asa), format="markdown", align="r")
#kable(unlist(asa[1:4]), format = "markdown")
#kable(asa[[5]], format = "markdown")
#' ## 原因疾患
temp_colname <- "cause_disease"
cause_disease <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(KableList(cause_disease), format="markdown", align="r")
#' ## 術前の呼吸状態
#' ### 術前酸素投与の有無
temp_colname <- "O2"
o2 <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(KableList(o2), format="markdown", align="r")
#' ### 術前P/F比
temp_colname <- "pre_PF"
pre_PF <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(KableList(pre_PF), format="markdown", align="r")
#' ## 気道の狭窄部位(主気管を含むか否か)
ptdata$pre_aw_stenosis
ptdata$aw_stenosis
#' ## 予定、緊急
temp_colname <- "ope"
ope <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(KableList(ope), format="markdown", align="r")
#' ## 心機能異常の有無
temp_colname <- "ab_cardio_func"
ab_cardio_func <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(KableList(ab_cardio_func), format="markdown", align="r")
#' ## 肺気腫の有無
temp_colname <- "emphysema"
emphysema <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(KableList(emphysema), format="markdown", align="r")
