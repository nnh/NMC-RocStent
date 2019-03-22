# Common processing
# Created date: 2019/2/19
# Author: mariko ohtsuka
# Constant section ------
kOption_csv_name <- "option.csv"
kOption_csv_fileEncoding <- "cp932"
kNA_lb <- -1
kCTCAEGrade <- c(1:5)
kBirth_Sex_xlsx <- "/RocStent_生年月日,性別.xlsx"
kAllocation_csv_name <- "RocStent_[0-9]{6}_[0-9]{4}.csv"
kAllocation_csv_fileEncoding <- "cp932"
kRegist_date_colname <- "regist_date"
# The following constants are used for common_function.R
kGroup_A <- "sp"
kGroup_B <- "mr"
kCount <- "count"
kPercentage <- "per"
kTableIndex <- 5
kN_index <- 1
kNA_index <- 2
kDfIndex <- 3
# initialize ------
Sys.setenv("TZ" = "Asia/Tokyo")
parent_path <- "/Users/admin/Desktop/NMC-RocStent"
# log output path
log_path <- paste0(parent_path, "/log")
if (file.exists(log_path) == F) {
  dir.create(log_path)
}
# Setting of input/output path
input_path <- paste0(parent_path, "/input/dst")
allocation_path <- paste0(parent_path, "/rawdata")
external_path <<- paste0(parent_path, "/external")
# If the output folder does not exist, create it
output_path <- paste0(parent_path, "/output")
if (file.exists(output_path) == F) {
  dir.create(output_path)
}
# load dataset
dst_list <- list.files(input_path)
for (i in 1:length(dst_list)) {
  tryCatch(load(paste0(input_path, "/", dst_list[i])),
           error = function(e){warning(paste0("load skip:", dst_list[i]))})
}
# Input saihi.csv
saihi_csv <- read.csv(paste0(external_path, "/", "RocStent_saihi.csv"), as.is=T, fileEncoding="cp932",
                      stringsAsFactors=F)
# Input option.csv
option_csv <- read.csv(paste0(external_path, "/", kOption_csv_name), as.is=T, fileEncoding=kOption_csv_fileEncoding,
                       stringsAsFactors=F)
# Input birth date and sex
birth_date_sex <- read_excel(paste0(external_path, kBirth_Sex_xlsx), sheet=1, col_names=T)
colnames(birth_date_sex) <- birth_date_sex[1, ]
birth_date_sex <- birth_date_sex[-1, ]
birth_date_sex$生年月日 <- as.Date(as.numeric(birth_date_sex$生年月日), origin="1899-12-30")
sortlist <- order(as.numeric(birth_date_sex$症例登録番号))
birth_date_sex <- birth_date_sex[sortlist, ]
birth_date_sex <- subset(birth_date_sex, birth_date_sex[ ,5] == 0)
# Merge birth date and sex
ptdata <- merge(ptdata, birth_date_sex[ ,c("症例登録番号", "生年月日", "性別")],
                    all=F, by.x="SUBJID", by.y="症例登録番号")
ptdata$age <- NA
for (i in 1:nrow(ptdata)) {
  if (!is.na(ptdata[i, kRegist_date_colname])) {
    ptdata[i, "age"] <- length(seq(ptdata[i, "生年月日"], ptdata[i, kRegist_date_colname], "year")) - 1
  }
}
names(ptdata)[which(names(ptdata)=="性別")] <- "sex"
# Input allocation.csv
rawdata_list <- list.files(allocation_path)
for (i in 1:length(rawdata_list)) {
  if (length(grep(kAllocation_csv_name,rawdata_list[i]) > 0)) {
    allocation_csv <- read.csv(paste0(allocation_path, "/", rawdata_list[i]), as.is=T,
                               fileEncoding=kAllocation_csv_fileEncoding, stringsAsFactors=F)
  }
}
# Set allocation data
ptdata <- ptdata[order(ptdata$SUBJID), ]
allocation_csv <- allocation_csv[order(allocation_csv$症例登録番号), ]
ptdata <- merge(ptdata, allocation_csv, by.x="SUBJID", by.y="症例登録番号", all=T)
# for glm
ptdata$allocation <- ifelse(ptdata$自動割付 == "A", 0, 1)
ptdata$glm_pre_PF <- ifelse(ptdata$pre_PF == "250を超える", 0, 1)
ptdata$glm_pre_aw_stenosis <- ifelse(ptdata$pre_aw_stenosis == "なし", 0, 1)
# All registration
all_ptdata <- ptdata
all_registration <- as.numeric(nrow(all_ptdata))
