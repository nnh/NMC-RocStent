# edit_ptdata.R
# Created date: 2019/3/5
# Author: mariko ohtsuka
# All qualification(Full Analysis Set)
ptdata <- subset(ptdata, SUBJID %in% birth_date_sex$症例登録番号)
if (saihi_flag == T) {
  ptdata <- subset(ptdata, !(SUBJID %in% saihi_csv$症例登録番号))
} else {
  ptdata <- ptdata
}
# A:SP
# B:MR
sp_ptdata <- subset(ptdata, ptdata$自動割付 == "A")
mr_ptdata <- subset(ptdata, ptdata$自動割付 == "B")
#+ {r}
all_qualification <- as.numeric(nrow(ptdata))
# 全治療例
all_treatment <- all_qualification
# safety analysis set

# sae_report
sae_report <- sae_report[order(sae_report$SUBJID), ]
sae_report <- merge(sae_report, allocation_csv, by.x="SUBJID", by.y="症例登録番号", all.x=T)
# A:SP
# B:MR
sp_sae_report <- subset(sae_report, sae_report$自動割付 == "A")
mr_sae_report <- subset(sae_report, sae_report$自動割付 == "B")
