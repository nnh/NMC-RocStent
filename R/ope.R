# ' ope.R
# ' Created date: 2019/2/19
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
# Constant section ------
# Main section ------
#' ## 気道狭窄状態
#' ### 狭窄部位
option_aw_stenosis <- subset(option_csv, Option.name == "気道狭窄部位")
temp_colname <- "aw_stenosis"
for (i in 1:2) {

}
sp_aw_stenosis_all <- AggregateLength(sp_ptdata[ ,temp_colname],temp_colname)
sp_aw_stenosis_n <- sp_aw_stenosis_all[[1]]
sp_aw_stenosis_na <- sp_aw_stenosis_all[[2]]
mr_aw_stenosis_all <- AggregateLength(mr_ptdata[ ,temp_colname],temp_colname)
mr_aw_stenosis_n <- mr_aw_stenosis_all[[1]]
mr_aw_stenosis_na <- mr_aw_stenosis_all[[2]]
for (i in 1:nrow(option_aw_stenosis)) {
  temp_colname <- paste0("aw_stenosis_", option_aw_stenosis[i, "Option..Value.code"])
  temp_count <- nrow(subset(sp_ptdata, sp_ptdata[temp_colname] == T))
  AggregateLength(sp_ptdata[ ,temp_colname], temp_colname)
#  sp_ptdata_aw_stenosis[ ,temp_colname] <- ifelse(sp_ptdata_aw_stenosis[ ,temp_colname] == T, 1, 0)
#  mr_ptdata_aw_stenosis[ ,temp_colname] <- ifelse(mr_ptdata_aw_stenosis[ ,temp_colname] == T, 1, 0)
#  aw_stenosis <- Aggregate_sp_mr(sp_ptdata_aw_stenosis, mr_ptdata_aw_stenosis, temp_colname, c(temp_colname, "count", "per"))
}
#kable(KableList(aw_stenosis), format = "markdown")
#' ### 狭窄程度(%)
aw_stenosis_p <- Summary_sp_mr(sp_ptdata, mr_ptdata, "aw_stenosis_p")
kable(KableList(aw_stenosis_p), format = "markdown", align="r")
#' ## 麻酔時間(分)
anesthesia_time <- Summary_sp_mr(sp_ptdata, mr_ptdata, "anesthesia_time")
kable(KableList(anesthesia_time), format = "markdown", align="r")
#' ## 手術時間(分)
ope_time <- Summary_sp_mr(sp_ptdata, mr_ptdata, "ope_time")
kable(KableList(ope_time), format = "markdown", align="r")
#' ## 術式
temp_colname <- "ope_style"
ope_style <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(KableList(ope_style), format = "markdown")
#' ## 合計無換気時間(秒)
sum_venti_time <- Summary_sp_mr(sp_ptdata, mr_ptdata, "sum_venti_time")
kable(KableList(sum_venti_time), format = "markdown", align="r")
#' ## 無換気回数
non_ventilation <- Summary_sp_mr(sp_ptdata, mr_ptdata, "non_ventilation")
kable(KableList(non_ventilation), format = "markdown", align="r")
#' ## 最大無換気時間(秒)
max_venti_time <- Summary_sp_mr(sp_ptdata, mr_ptdata, "max_venti_time")
kable(KableList(max_venti_time), format = "markdown", align="r")
#' ## オペレータ(S、O)
temp_colname <- "operator"
operator <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(KableList(operator), format = "markdown")
#' ## ステントの種類
temp_colname <- "stent"
stent <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(KableList(stent), format = "markdown")
#' ## ステントの数
temp_colname <- "stent_n"
stent_n <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(KableList(stent_n), format = "markdown")
#' ## 焼灼の有無
temp_colname <- "cauterization"
cauterization <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(KableList(cauterization), format = "markdown")
#' ## バッキングの回数
bucking <- Summary_sp_mr(sp_ptdata, mr_ptdata, "bucking")
kable(KableList(bucking), format = "markdown", align="r")
#' ## 陽圧呼吸による実際のアシストの回数
assist_n <- Summary_sp_mr(sp_ptdata, mr_ptdata, "assist_n")
kable(KableList(assist_n), format = "markdown", align="r")
#' ## 陽圧呼吸によるアシストの時間(秒)
assist_time <- Summary_sp_mr(sp_ptdata, mr_ptdata, "assist_time")
kable(KableList(assist_time), format = "markdown", align="r")
#' ## SpO2<95%となった回数(ノイズを除く)
df_SpO2_1 <- subset(ptdata, ptdata$SpO2_1 == "なし")
sp_SpO2_1 <- subset(sp_ptdata, SUBJID %in% df_SpO2_1$SUBJID)
mr_SpO2_1 <- subset(mr_ptdata, SUBJID %in% df_SpO2_1$SUBJID)
spO2_n <- Summary_sp_mr(sp_SpO2_1, mr_SpO2_1, "SpO2_n")
kable(KableList(spO2_n), format = "markdown", align="r")
#' ## 術中 SpO2 最低値(ノイズを除く)

#' ## 術中血液ガス分析
#' ### pH 平均値
#' ### PaCO2 平均値
#' ### PaO2 平均値
#' ### P/F 比平均値
#          ETCO2 最大値(mmHg)
#              術中最高 BIS 値 術中最低 BIS 値
#            最低プロポフォール TCI 濃度 (μg/ml) 最高プロポフォール TCI 濃度 (μg/ml)
#' ## 平均プロポフォール維持濃度 (μg/ml)
#            レミフェンタニル最低流量レ ミフェンタニル最低 (μg/kg/min) レミフェンタニル最高流量レ ミフェンタニル最高 (μg/kg/min) 平均レミフェンタニル維持濃 度(μg/kg/min)
#             フェンタニル総投与量(μg) レミフェンタニル総投与量 (μg)
# ロクロニウム総投与量(mg)
