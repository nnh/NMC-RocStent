# ' gass.r
# ' Created date: 2019/2/28
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
par(family = "HiraKakuProN-W3")
#' ## 術中pH 平均値
#' ### n=`r all_treatment`
temp_variable <- "pH"
kable(KableList(get(temp_variable)), format = "markdown", align="r")
boxplot(sp_ptdata[ ,temp_variable], mr_ptdata[ ,temp_variable], xlab="Muscle relaxation	",
        ylab=temp_variable, names=c("SP", "MR"))
#' ## 術中PaCO2 平均値
#' ### n=`r all_treatment`
temp_variable <- "PaCO2"
kable(KableList(get(temp_variable)), format = "markdown", align="r")
boxplot(sp_ptdata[ ,temp_variable], mr_ptdata[ ,temp_variable], xlab="Muscle relaxation	",
        ylab=temp_variable, names=c("SP", "MR"))
#' ## 術中P/F 比平均値
#' ### n=`r all_treatment`
temp_variable <- "PF"
kable(KableList(get(temp_variable)), format = "markdown", align="r")
boxplot(sp_ptdata[ ,temp_variable], mr_ptdata[ ,temp_variable], xlab="Muscle relaxation	",
        ylab=temp_variable, names=c("SP", "MR"))
#' ## 術中 SpO2 最低値
#' ### n=`r ope_spo2_n`
temp_variable <- "SpO2_min"
kable(KableList(get(temp_variable)), format = "markdown", align="r")
boxplot(sp_ptdata[ ,temp_variable], mr_ptdata[ ,temp_variable], xlab="Muscle relaxation	",
        ylab=temp_variable, names=c("SP", "MR"))
