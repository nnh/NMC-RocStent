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
#' @title
#'
EditColnames <- function(header, columns_name){
  temp_colnames <- paste0(header, columns_name)
  temp_colnames[1] <- columns_name[1]
  return(temp_colnames)
}
#' @title
#'
Aggregate_Group <- function(df_A, df_B, input_column_name, output_column_name){
  temp_sp <- AggregateLength(df_A[, input_column_name], output_column_name)
  output_df_A <- temp_sp[[kDfIndex]]
  colnames(output_df_A) <- EditColnames(paste0(kGroup_A, "_"), output_column_name)
  temp_mr <- AggregateLength(df_B[, input_column_name], output_column_name)
  output_df_B <- temp_mr[[kDfIndex]]
  colnames(output_df_B) <- EditColnames(paste0(kGroup_B, "_"), output_column_name)
  df <- merge(output_df_A, output_df_B, by=output_column_name[1], all=T, incomparables=NA)
  return_list <- list(temp_sp[[kN_index]], temp_sp[[kNA_index]], temp_mr[[kN_index]], temp_mr[[kNA_index]], df)
  names(return_list) <- c(paste0(kGroup_A, "_例数"), paste0(kGroup_A, "_欠測数"),
                          paste0(kGroup_B, "_例数"), paste0(kGroup_B, "_欠測数"), NULL)
  return(return_list)
}
#' @title
Aggregate_Sum_Group <- function(df_A, df_B, input_column_name, output_column_name){
  col_A_count <- paste0(kGroup_A, "_", kCount)
  col_B_count <- paste0(kGroup_B, "_", kCount)
  col_sum_count <- paste0("sum_", kCount)

  output_df <- Aggregate_Group(df_A, df_B, input_column_name, c(output_column_name, kCount, kPercentage))
  output_df[[kTableIndex]][col_sum_count] <- apply(output_df[[kTableIndex]][c(col_A_count, col_B_count)], 1, sum)
  output_df[[kTableIndex]]$sum_per <- apply(output_df[[kTableIndex]][col_sum_count], 2, function(x){
    return(round(x / (output_df[[1]] + output_df[[3]]) * 100, digits=1))
  })
  return(output_df)
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
#' @title
Summary_Group <- function(df_A, df_B, column_name){
  temp_sp <- SummaryValue(df_A[ , column_name])
  temp_mr <- SummaryValue(df_B[ , column_name])
  df <- cbind(data.frame(temp_sp[[kDfIndex]]), data.frame(temp_mr[[kDfIndex]]))
  colnames(df) <- c(paste0(kGroup_A, "_", column_name), paste0(kGroup_B, "_", column_name))
  return_list <- list(temp_sp[[kN_index]], temp_sp[[kNA_index]], temp_mr[[kN_index]], temp_mr[[kNA_index]],
                      round(df, digits=1))
  names(return_list) <- c(paste0(kGroup_A, "_例数"), paste0(kGroup_A, "_欠測数"),
                          paste0(kGroup_B, "_例数"), paste0(kGroup_B, "_欠測数"), NULL)
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
      temp_aggregate <- Aggregate_Group(input_df_list[[1]], input_df_list[[2]], temp_colname,
                                        c(checkbox_head, kCount, kPercentage))
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
  return(list(unlist(input_list[1:kTableIndex-1]), input_list[[kTableIndex]]))
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

# sae_report
sae_report <- sae_report[order(sae_report$SUBJID), ]
sae_report <- merge(sae_report, allocation_csv, by.x="SUBJID", by.y="症例登録番号", all.x=T)
# A:SP
# B:MR
sp_sae_report <- subset(sae_report, sae_report$自動割付 == "A")
mr_sae_report <- subset(sae_report, sae_report$自動割付 == "B")
