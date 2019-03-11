# ' ope.R
# ' Created date: 2019/2/19
# ' author: mariko ohtsuka
# ' output:
# '   html_document:
# Constant section ------
kCheckBox_head <- "aw_stenosis_"
# Main section ------
#' ## 気道狭窄状態
#' ### 狭窄部位
#' ### n=`r all_treatment`
aw_stenosis <- AggregateCheckbox("気道狭窄部位", T, kCheckBox_head, list(sp_ptdata, mr_ptdata))
kable(KableList(aw_stenosis), format = "markdown")
#' ### 狭窄程度(%)
#' ### n=`r all_treatment`
temp_variable <- "aw_stenosis_p"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## 麻酔時間(分)
#' ### n=`r all_treatment`
temp_variable <- "anesthesia_time"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## 手術時間(分)
#' ### n=`r all_treatment`
temp_variable <- "ope_time"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## 術式
#' ### n=`r all_treatment`
temp_colname <- "ope_style"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ## 合計無換気時間(秒)
#' ### n=`r all_treatment`
temp_variable <- "sum_venti_time"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## 無換気回数
#' ### n=`r all_treatment`
temp_variable <- "non_ventilation"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## 最大無換気時間(秒)
#' ### n=`r all_treatment`
temp_variable <- "max_venti_time"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## オペレータ(S、O)
#' ### n=`r all_treatment`
temp_colname <- "operator"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ## ステントの種類
#' ### n=`r all_treatment`
temp_colname <- "stent"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ## ステントの数
#' ### n=`r all_treatment`
temp_colname <- "stent_n"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ## 焼灼の有無
#' ### n=`r all_treatment`
temp_colname <- "cauterization"
assign(temp_colname,  Aggregate_Group(sp_ptdata, mr_ptdata, temp_colname, c(temp_colname, kCount, kPercentage)))
kable(KableList(get(temp_colname)), format="markdown", align="r")
#' ## バッキングの回数
#' ### n=`r all_treatment`
temp_variable <- "bucking"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## 陽圧呼吸による実際のアシストの回数
#' ### n=`r all_treatment`
temp_variable <- "assist_n"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## 陽圧呼吸によるアシストの時間(秒)
#' ### n=`r all_treatment`
temp_variable <- "assist_time"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## SpO2<95%となった回数(ノイズを除く)
df_SpO2_1 <- subset(ptdata, ptdata$SpO2_1 == "なし")
sp_SpO2_1 <- subset(sp_ptdata, SUBJID %in% df_SpO2_1$SUBJID)
mr_SpO2_1 <- subset(mr_ptdata, SUBJID %in% df_SpO2_1$SUBJID)
temp_variable <- "SpO2_n"
spO2_n <- Summary_Group(sp_SpO2_1, mr_SpO2_1, temp_variable)
ope_spo2_n <- spO2_n[[1]] + spO2_n[[3]]
#' ### n=`r ope_spo2_n`
kable(KableList(spO2_n), format = "markdown", align="r")
#' ## 術中 SpO2 最低値(ノイズを除く)
#' ### n=`r ope_spo2_n`
temp_variable <- "SpO2_min"
assign(temp_variable, Summary_Group(sp_SpO2_1, mr_SpO2_1, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ## 術中血液ガス分析
#' ### pH 平均値
#' ### n=`r all_treatment`
temp_variable <- "pH"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### PaCO2 平均値
#' ### n=`r all_treatment`
temp_variable <- "PaCO2"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### PaO2 平均値
#' ### n=`r all_treatment`
temp_variable <- "PaO2"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### P/F 比平均値
#' ### n=`r all_treatment`
temp_variable <- "PF"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### ETCO2 最大値(mmHg)
#' ### n=`r all_treatment`
temp_variable <- "ETCO2"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### 術中最高 BIS 値
#' ### n=`r all_treatment`
temp_variable <- "max_BIS"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### 術中最低 BIS 値
#' ### n=`r all_treatment`
temp_variable <- "min_BIS"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### 最低プロポフォール TCI 濃度 (μg/ml)
#' ### n=`r all_treatment`
temp_variable <- "min_TCI"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### 最高プロポフォール TCI 濃度 (μg/ml)
#' ### n=`r all_treatment`
temp_variable <- "max_TCI"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### 平均プロポフォール維持濃度 (μg/ml)
#' ### n=`r all_treatment`
temp_variable <- "mean_TCI"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### レミフェンタニル最低流量 (μg/kg/min)
#' ### n=`r all_treatment`
temp_variable <- "min_remifentanil"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### レミフェンタニル最高流量 (μg/kg/min)
#' ### n=`r all_treatment`
temp_variable <- "max_remifentanil"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### 平均レミフェンタニル維持濃度(μg/kg/min)
#' ### n=`r all_treatment`
temp_variable <- "mean_remifentanil"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### フェンタニル総投与量(μg)
#' ### n=`r all_treatment`
temp_variable <- "fentanil"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### レミフェンタニル総投与量 (μg)
#' ### n=`r all_treatment`
temp_variable <- "total_remifentanil"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
#' ### ロクロニウム総投与量(mg)
#' ### n=`r all_treatment`
temp_variable <- "total_rocuronium"
assign(temp_variable, Summary_Group(sp_ptdata, mr_ptdata, temp_variable))
kable(KableList(get(temp_variable)), format = "markdown", align="r")
