# ' ope.R
# ' Created date: 2019/2/19
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
# Constant section ------
# Main section ------
# 狭窄部位 主気管
# 気管分岐部
# 左主気管支
# 右主気管支(気管支ファイ バー観察時目視にて%評価)
ptdata$aw_stenosis_p
#' ## 麻酔時間(分)
anesthesia_time <- Summary_sp_mr(sp_ptdata, mr_ptdata, "anesthesia_time")
kable(anesthesia_time, format = "markdown")
#' ## 手術時間(分)
ope_time <- Summary_sp_mr(sp_ptdata, mr_ptdata, "ope_time")
kable(ope_time, format = "markdown")
#' ## 術式
temp_colname <- "ope_style"
ope_style <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(ope_style, format = "markdown")
#' ## 合計無換気時間(秒)
sum_venti_time <- Summary_sp_mr(sp_ptdata, mr_ptdata, "sum_venti_time")
kable(sum_venti_time, format = "markdown")
#' ## 無換気回数
non_ventilation <- Summary_sp_mr(sp_ptdata, mr_ptdata, "non_ventilation")
kable(non_ventilation, format = "markdown")
#' ## 最大無換気時間(秒)
max_venti_time <- Summary_sp_mr(sp_ptdata, mr_ptdata, "max_venti_time")
kable(max_venti_time, format = "markdown")
#' ## オペレータ(S、O)
temp_colname <- "operator"
operator <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(operator, format = "markdown")
#' ## ステントの種類
temp_colname <- "stent"
stent <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(stent, format = "markdown")
#' ## ステントの数
temp_colname <- "stent_n"
stent_n <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(stent_n, format = "markdown")
#' ## 焼灼の有無
temp_colname <- "cauterization"
cauterization <- Aggregate_sp_mr(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, "count", "per"))
kable(cauterization, format = "markdown")
#' ## バッキングの回数
bucking <- Summary_sp_mr(sp_ptdata, mr_ptdata, "bucking")
kable(bucking, format = "markdown")
#' ## 陽圧呼吸による実際のアシストの回数
assist_n <- Summary_sp_mr(sp_ptdata, mr_ptdata, "assist_n")
kable(assist_n, format = "markdown")
#' ## 陽圧呼吸によるアシストの時間(秒)
assist_time <- Summary_sp_mr(sp_ptdata, mr_ptdata, "assist_time")
kable(assist_time, format = "markdown")
#' ## SpO2<95%となった回数(ノイズを除く)
#ptdata$SpO2_2
#df_SpO2_1 <- subset(ptdata, ptdata$SpO2_1 == "なし")
#sp_SpO2_1 <- subset(sp_ptdata, SUBJID %in% df_SpO2_1$SUBJID)
#mr_SpO2_1 <- subset(mr_ptdata, SUBJID %in% df_SpO2_1$SUBJID)
#spO2_n <- Summary_sp_mr(sp_SpO2_1, mr_SpO2_1, "SpO2_n")
#kable(spO2_n, format = "markdown")
#' ## 術中 SpO2 最低値(ノイズを除く)
#'
#              術中血液ガス分析 pH 平均値
#' ## PaCO2 平均値
#' ## PaO2 平均値
#' ## P/F 比平均値
#          ETCO2 最大値(mmHg)
#              術中最高 BIS 値 術中最低 BIS 値
#            最低プロポフォール TCI 濃度 (μg/ml) 最高プロポフォール TCI 濃度 (μg/ml)
#' ## 平均プロポフォール維持濃度 (μg/ml)
#            レミフェンタニル最低流量レ ミフェンタニル最低 (μg/kg/min) レミフェンタニル最高流量レ ミフェンタニル最高 (μg/kg/min) 平均レミフェンタニル維持濃 度(μg/kg/min)
#             フェンタニル総投与量(μg) レミフェンタニル総投与量 (μg)
# ロクロニウム総投与量(mg)
