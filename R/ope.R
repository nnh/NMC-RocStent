# ' ope.R
# ' Created date: 2019/2/19
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
# Constant section ------
kCheckBox_head <- "aw_stenosis_"
# Main section ------
#' # n=`r all_treatment`
#' ## 気道狭窄状態
#' ### 狭窄部位
aw_stenosis <- AggregateCheckbox("気道狭窄部位", T, kCheckBox_head, list(sp_ptdata, mr_ptdata))
kable(KableList(aw_stenosis), format = "markdown")
#' ### 狭窄程度(%)
aw_stenosis_p <- Summary_Group(sp_ptdata, mr_ptdata, "aw_stenosis_p")
kable(KableList(aw_stenosis_p), format = "markdown", align="r")
#' ## 麻酔時間(分)
anesthesia_time <- Summary_Group(sp_ptdata, mr_ptdata, "anesthesia_time")
kable(KableList(anesthesia_time), format = "markdown", align="r")
#' ## 手術時間(分)
ope_time <- Summary_Group(sp_ptdata, mr_ptdata, "ope_time")
kable(KableList(ope_time), format = "markdown", align="r")
#' ## 術式
temp_colname <- "ope_style"
ope_style <- Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage))
kable(KableList(ope_style), format = "markdown")
#' ## 合計無換気時間(秒)
sum_venti_time <- Summary_Group(sp_ptdata, mr_ptdata, "sum_venti_time")
kable(KableList(sum_venti_time), format = "markdown", align="r")
#' ## 無換気回数
non_ventilation <- Summary_Group(sp_ptdata, mr_ptdata, "non_ventilation")
kable(KableList(non_ventilation), format = "markdown", align="r")
#' ## 最大無換気時間(秒)
max_venti_time <- Summary_Group(sp_ptdata, mr_ptdata, "max_venti_time")
kable(KableList(max_venti_time), format = "markdown", align="r")
#' ## オペレータ(S、O)
temp_colname <- "operator"
operator <- Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage))
kable(KableList(operator), format = "markdown")
#' ## ステントの種類
temp_colname <- "stent"
stent <- Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage))
kable(KableList(stent), format = "markdown")
#' ## ステントの数
temp_colname <- "stent_n"
stent_n <- Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage))
kable(KableList(stent_n), format = "markdown")
#' ## 焼灼の有無
temp_colname <- "cauterization"
cauterization <- Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage))
kable(KableList(cauterization), format = "markdown")
#' ## バッキングの回数
bucking <- Summary_Group(sp_ptdata, mr_ptdata, "bucking")
kable(KableList(bucking), format = "markdown", align="r")
#' ## 陽圧呼吸による実際のアシストの回数
assist_n <- Summary_Group(sp_ptdata, mr_ptdata, "assist_n")
kable(KableList(assist_n), format = "markdown", align="r")
#' ## 陽圧呼吸によるアシストの時間(秒)
assist_time <- Summary_Group(sp_ptdata, mr_ptdata, "assist_time")
kable(KableList(assist_time), format = "markdown", align="r")
#' ## SpO2<95%となった回数(ノイズを除く)
df_SpO2_1 <- subset(ptdata, ptdata$SpO2_1 == "なし")
sp_SpO2_1 <- subset(sp_ptdata, SUBJID %in% df_SpO2_1$SUBJID)
mr_SpO2_1 <- subset(mr_ptdata, SUBJID %in% df_SpO2_1$SUBJID)
spO2_n <- Summary_Group(sp_SpO2_1, mr_SpO2_1, "SpO2_n")
kable(KableList(spO2_n), format = "markdown", align="r")
#' ## 術中 SpO2 最低値(ノイズを除く)
SpO2_min <- Summary_Group(sp_SpO2_1, mr_SpO2_1, "SpO2_min")
kable(KableList(SpO2_min), format = "markdown", align="r")
#' ## 術中血液ガス分析
#' ### pH 平均値
temp_variable <- "pH"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### PaCO2 平均値
temp_variable <- "PaCO2"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### PaO2 平均値
temp_variable <- "PaO2"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### P/F 比平均値
temp_variable <- "PF"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### ETCO2 最大値(mmHg)
temp_variable <- "ETCO2"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### 術中最高 BIS 値
temp_variable <- "max_BIS"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### 術中最低 BIS 値
temp_variable <- "min_BIS"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### 最低プロポフォール TCI 濃度 (μg/ml)
temp_variable <- "min_TCI"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### 最高プロポフォール TCI 濃度 (μg/ml)
temp_variable <- "max_TCI"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### 平均プロポフォール維持濃度 (μg/ml)
temp_variable <- "mean_TCI"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### レミフェンタニル最低流量 (μg/kg/min)
temp_variable <- "min_remifentanil"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### レミフェンタニル最高流量 (μg/kg/min)
temp_variable <- "max_remifentanil"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### 平均レミフェンタニル維持濃度(μg/kg/min)
temp_variable <- "mean_remifentanil"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### フェンタニル総投与量(μg)
temp_variable <- "fentanil"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### レミフェンタニル総投与量 (μg)
temp_variable <- "total_remifentanil"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### ロクロニウム総投与量(mg)
temp_variable <- "total_rocuronium"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
