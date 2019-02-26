# Common processing
# Created date: 2019/2/19
# Author: mariko ohtsuka
# library, function section ------
# install.packages('readxl')
library("readxl")
#' @title
#' AggregateLength
#' @description
#' Returns the total and percentage of the argument's columns
#' @param
#' target_column : Column to be summed
#' column_name : Name of output columns
#' @return
#' data frame
AggregateLength <- function(target_column, column_name){
  target_na <- subset(target_column, is.na(target_column))
  target_not_na <- subset(target_column, !is.na(target_column))
  df <- aggregate(target_column, by=list(target_column), length, drop=F)
  df[is.na(df)] <- 0
  df$per <- round(prop.table(df[2]) * 100, digits=1)
  colnames(df) <- column_name
  return(list(length(target_not_na), length(target_na), df))
}
EditColnames <- function(header, columns_name){
  temp_colnames <- paste0(header, columns_name)
  temp_colnames[1] <- columns_name[1]
  return(temp_colnames)
}
Aggregate_sp_mr <- function(df_sp, df_mr, input_column_name, output_column_name){
  temp_sp <- AggregateLength(df_sp[, input_column_name], output_column_name)
  output_df_sp <- temp_sp[[3]]
  colnames(output_df_sp) <- EditColnames("sp_", output_column_name)
  temp_mr <- AggregateLength(df_mr[, input_column_name], output_column_name)
  output_df_mr <- temp_mr[[3]]
  colnames(output_df_mr) <- EditColnames("mr_", output_column_name)
  df <- merge(output_df_sp, output_df_mr, by=output_column_name[1], all=T, incomparables=NA)
  return_list <- list(temp_sp[[1]], temp_sp[[2]], temp_mr[[1]], temp_mr[[2]], df)
  names(return_list) <- c("sp_例数", "sp_欠測数", "mr_例数", "mr_欠測数", NULL)
  return(return_list)
}
#' @title
#' SummaryValue
#' @description
#' Return summary and standard deviation of the column of arguments
#' @param
#' input_column : Column to be summarized
#' @return
#' Summary and standard deviation vector
SummaryValue <- function(input_column){
  target_na <- subset(input_column, is.na(input_column))
  target_column <- subset(input_column, !is.na(input_column))
  temp_mean <- mean(target_column)
  temp_summary <- summary(target_column)
  temp_median <- median(target_column)
  temp_quantile <- quantile(target_column, type=2)
  temp_min <- min(target_column)
  temp_max <- max(target_column)
  temp_sd <- sd(target_column)
  return_list <- c(temp_mean, temp_sd, temp_median, temp_quantile[2], temp_quantile[4], temp_min, temp_max)
  names(return_list) <- c("Mean", "Sd.", "Median", "1st Qu.", "3rd Qu.", "Min.", "Max.")
  return(list(length(target_column), length(target_na), return_list))
}
Summary_sp_mr <- function(df_sp, df_mr, column_name){
  temp_sp <- SummaryValue(df_sp[ , column_name])
  output_df_sp <- temp_sp[[3]]
  temp_mr <- SummaryValue(df_mr[ , column_name])
  output_df_mr <- temp_mr[[3]]
  df <- cbind(data.frame(temp_sp[[3]]), data.frame(temp_mr[[3]]))
  colnames(df) <- c(paste0("sp_", column_name), paste0("mr_", column_name))
  return_list <- list(temp_sp[[1]], temp_sp[[2]], temp_mr[[1]], temp_mr[[2]], round(df, digits=1))
  names(return_list) <- c("sp_例数", "sp_欠測数", "mr_例数", "mr_欠測数", NULL)
  return(return_list)
}
AggregateCheckbox <- function(option_name, group_flag, checkbox_head, input_df_list){
  if (group_flag == T) {
    col_count <- 5
  } else {
    col_count <- NA
  }
  option_checkbox <- subset(option_csv, Option.name == option_name)
  df_table <- data.frame(matrix(rep(NA, 5), nrow=col_count))[numeric(0), ]
  for (i in 1:nrow(option_checkbox)) {
    temp_colname <- paste0(checkbox_head, option_checkbox[i, "Option..Value.code"])
    if (group_flag == T) {
      temp_aggregate <- Aggregate_sp_mr(input_df_list[[1]], input_df_list[[2]], temp_colname,
                                        c(checkbox_head, "count", "per"))
      temp_aggregate_df <- temp_aggregate[[kTableIndex]]
      temp_T <- subset(temp_aggregate_df, temp_aggregate_df[ ,checkbox_head] == T)
    }
    temp_T[1, 1] <- option_checkbox[i, "Option..Value.name"]
    df_table <- rbind(df_table, data.frame(as.matrix(temp_T), row.names=NULL))
  }
  output_df <- list(temp_aggregate[1], temp_aggregate[2], temp_aggregate[3], temp_aggregate[4], df_table)
  return(output_df)
}
KableList <- function(input_list){
  return(list(unlist(input_list[1:4]), input_list[[kTableIndex]]))
}
# Constant section ------
kOption_csv_name <- "option.csv"
kOption_csv_fileEncoding <- "cp932"
kNA_lb <- -1
kCTCAEGrade <- c(1:5)
kBirth_Sex_xlsx <- "/RocStent_生年月日,性別.xlsx"
kExclude_FAS_flag <- 1
kExclude_SAS_flag <- 2
kAllocation_csv_name <- "RocStent_[0-9]{6}_[0-9]{4}.csv"
kAllocation_csv_fileEncoding <- "cp932"
kSP <- "A"
kMR <- "B"
kTableIndex <- 5
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
# All registration
all_ptdata <- ptdata
all_registration <- as.numeric(nrow(all_ptdata))
# All qualification(Full Analysis Set)
ptdata <- subset(ptdata, SUBJID %in% birth_date_sex$症例登録番号)
ptdata <- ptdata
# A:SP
# B:MR
sp_ptdata <- subset(ptdata, ptdata$自動割付 == "A")
mr_ptdata <- subset(ptdata, ptdata$自動割付 == "B")
#+ {r}
all_qualification <- as.numeric(nrow(ptdata))
# 全治療例
all_treatment <- all_qualification
# safety analysis set
