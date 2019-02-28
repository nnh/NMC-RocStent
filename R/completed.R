# ' completed.r
# ' Created date: 2019/2/28
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
completed <- Aggregate_Sum_Group(sp_ptdata, mr_ptdata, "cancel1", "completed")
#' # プロトコル治療完遂割合
#' ## n=`r all_treatment`
kable(KableList(completed), format = "markdown", align="r")
