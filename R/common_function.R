# Common function
# Created date: 2019/3/1
# Author: mariko ohtsuka
# function section ------
#' @title
#' AggregateLength
#' @description
#' Returns the total and percentage of the argument's columns
#' @param
#' target_column : Column to be summed
#' column_name : Name of output columns
#' @return
#' List of length 3
#' [[1]] number of not NA in number of samples
#' [[2]] number of NA in number of samples
#' [[3]] dataframe of total and percentage
#'       : columns[1]:items, columns[2]:number of items, columns[3]:percentage of items
#' @examples
#' AggregateLength(df$col1, "col1_count")
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
#' EditColnames
#' @param
#' header : first character string of column name
#' columns_name : string for column name
#' @return
#' vector of string
#' returns the first character string of the vector as it is
#' for the second and subsequent cases, return the combination of arguments
#' @examples
#' EditColnames("a_", c("SEQ", "SUBJID", "OUTPUT"))
#' return -> c("SEQ", "a_SUBJID", "a_OUTPUT")
EditColnames <- function(header, columns_name){
  temp_colnames <- paste0(header, columns_name)
  temp_colnames[1] <- columns_name[1]
  return(temp_colnames)
}
#' @title
#' Aggregate_Group
#' @description
#' execute 'AggregateLength' function with two dataframe
#' @param
#' df_A : input dataframe
#' df_B : input dataframe
#' input_column_name : Column to be summed
#' output_column_name : Name of output columns
#' @return
#' List of length 3
#' [[1]] number of not NA in number of samples
#' [[2]] number of NA in number of samples
#' [[3]] dataframe of total and percentage
#'       : columns[1]:items, columns[2]:number of df_A's items, columns[3]:percentage of df_A's items
#'       : columns[4]:number of df_B's items, columns[5]:percentage of df_B's items
#' @examples
#' Aggregate_Group(df_group_a, df_group_b, "ASA", c("ASA", "cnt", "per"))
Aggregate_Group <- function(df_A, df_B, input_column_name, output_column_name){
  temp_A <- AggregateLength(df_A[, input_column_name], output_column_name)
  output_df_A <- temp_A[[kDfIndex]]
  colnames(output_df_A) <- EditColnames(paste0(kGroup_A, "_"), output_column_name)
  temp_B <- AggregateLength(df_B[, input_column_name], output_column_name)
  output_df_B <- temp_B[[kDfIndex]]
  colnames(output_df_B) <- EditColnames(paste0(kGroup_B, "_"), output_column_name)
  df <- merge(output_df_A, output_df_B, by=output_column_name[1], all=T, incomparables=NA)
  return_list <- list(temp_A[[kN_index]], temp_A[[kNA_index]], temp_B[[kN_index]], temp_B[[kNA_index]], df)
  names(return_list) <- c(paste0(kGroup_A, "_例数"), paste0(kGroup_A, "_欠測数"),
                          paste0(kGroup_B, "_例数"), paste0(kGroup_B, "_欠測数"), NULL)
  return(return_list)
}
#' @title
#' Aggregate_Sum_Group
#' @description
#' set the total in the ’Aggregate_Group’ function execution result
#' @param
#' df_A : input dataframe
#' df_B : input dataframe
#' input_column_name : Column to be summed
#' output_column_name : Name of output column
#' @return
#' List of length 3
#' [[1]] number of not NA in number of samples
#' [[2]] number of NA in number of samples
#' [[3]] dataframe of total and percentage
#'       : columns[1]:items, columns[2]:number of df_A's items, columns[3]:percentage of df_A's items
#'       : columns[4]:number of df_B's items, columns[5]:percentage of df_B's items
#'       : columns[6]:number of df_A and df_B's items, columns[5]:percentage of df_A and df_B's items
#' @examples
#' Aggregate_Sum_Group(df_group_a, df_group_b, "over1_SpO2_n", "SPO2")
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
#' List of length 3
#' [[1]] number of not NA in number of samples
#' [[2]] number of NA in number of samples
#' [[3]] Summary and standard deviation vector
#'       : "Mean", "Sd.", "Median", "1st Qu.", "3rd Qu.", "Min.", "Max."
#' @examples
#' SummaryValue(df$col2)
SummaryValue <- function(input_column){
  target_na <- subset(input_column, is.na(input_column))
  target_column <- subset(input_column, !is.na(input_column))
  temp_mean <- format(round(mean(target_column), digits=1), nsmall=1)
  temp_summary <- summary(target_column)
  temp_median <- median(target_column)
  temp_quantile <- quantile(target_column, type=2)
  temp_min <- min(target_column)
  temp_max <- max(target_column)
  temp_sd <- format(round(sd(target_column), digits=1), nsmall=1)
  return_list <- c(temp_mean, temp_sd, temp_median, temp_quantile[2], temp_quantile[4], temp_min, temp_max)
  names(return_list) <- c("Mean", "Sd.", "Median", "1st Qu.", "3rd Qu.", "Min.", "Max.")
  return(list(length(target_column), length(target_na), return_list))
}
#' @title
#' Summary_Group
#' @description
#' execute 'SummaryValue' function with two dataframe
#' @param
#' df_A : input dataframe
#' df_B : input dataframe
#' column_name : Column to be summarized
#' @return
#' List of length 3
#' [[1]] number of not NA in number of samples
#' [[2]] number of NA in number of samples
#' [[3]] Summary and standard deviation vector
#'       : "Mean", "Sd.", "Median", "1st Qu.", "3rd Qu.", "Min.", "Max."
#' @examples
#' Summary_Group(df_group_a, df_group_b, "hight")
Summary_Group <- function(df_A, df_B, column_name){
  temp_A <- SummaryValue(df_A[ , column_name])
  temp_B <- SummaryValue(df_B[ , column_name])
  df <- cbind(data.frame(temp_A[[kDfIndex]]), data.frame(temp_B[[kDfIndex]]))
  colnames(df) <- c(paste0(kGroup_A, "_", column_name), paste0(kGroup_B, "_", column_name))
  return_list <- list(temp_A[[kN_index]], temp_A[[kNA_index]], temp_B[[kN_index]], temp_B[[kNA_index]], df)
  names(return_list) <- c(paste0(kGroup_A, "_例数"), paste0(kGroup_A, "_欠測数"),
                          paste0(kGroup_B, "_例数"), paste0(kGroup_B, "_欠測数"), NULL)
  return(return_list)
}
#' @title
#' AggregateCheckbox
#' @description
#' 'AggregateLength' function for checkbox
#' @param
#' option_name : option name in option.csv
#' group_flag : fixed value 'T'
#' checkbox_head : string excluding numbers from checkbox names
#' input_df_list : list of data frames
#' @return
#' List of length 3
#' [[1]] number of not NA in number of samples
#' [[2]] number of NA in number of samples
#' [[3]] dataframe of total and percentage
#'       : columns[1]:items, columns[2]:number of df_A's items, columns[3]:percentage of df_A's items
#'       : columns[4]:number of df_B's items, columns[5]:percentage of df_B's items
#' @examples
#' AggregateCheckbox("気道狭窄部位", T, "aw_", list(df_group_a, df_group_b))
AggregateCheckbox <- function(option_name, group_flag, checkbox_head, input_df_list){
  if (group_flag == T) {
    col_count <- 5
  } else {
    col_count <- NA
  }
  option_checkbox <- subset(option_csv, Option.name == option_name)
  # create an empty data frame
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
#' @title
#' KableList
#' @description
#' Format the list
#' @param
#' input_list : list of summary or aggregate results
#' @return
#' combined list of input lists
KableList <- function(input_list){
  return(list(unlist(input_list[1:kTableIndex-1]), input_list[[kTableIndex]]))
}
#' @title
#' ConvertFactor
#' @description
#' Convert factor to numeric or string
#' @param
#' df : data frame
#' @return
#' converted data frame
ConvertFactor <- function(df){
  for (i in 1:ncol(df)) {
    if (class(df[ , i]) == "factor") {
      if (is.numeric(df[ , i])) {
        df[ , i] <- as.numeric(df[ , i])
      } else {
        df[ , i] <- as.character(df[ , i])
      }
    }
  }
  return(df)
}
#' @title
#' GlmList_binomial
#' @description
#' Perform logistic regression analysis
#' Return analysis result, odds ratio, confidence interval
#' @param
#' str_formula : value of option "formula" of glm function
#' input_df : dataframe to be analyzed
#' ci_level : percentage of confidence intervals
#' @return
#' List of length 4
#' [[1]] return value of glm function
#' [[2]] summary of return values of glm function
#' [[3]] odds ratio
#' [[4]] confidence intervals
#' @examples
#' glm_SpO2 <- GlmList("grm_SpO2_n ~ allocation+pre_PF+pre_aw_stenosis", df_SpO2, 0.90)
GlmList_binomial <- function(str_formula, input_df, ci_level){
  temp_glm <- glm(str_formula, data=input_df, family=binomial)
  temp_summary <- summary(temp_glm)
  temp_coef <- exp(coef(temp_glm))
  temp_confint <- exp(confint(temp_glm, level=ci_level, type="Wald"))
  return(list(temp_glm, temp_summary, temp_coef, temp_confint))
}
