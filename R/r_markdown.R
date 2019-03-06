# output html files
# Created date: 2019/2/5
# Author: mariko ohtsuka

# library, function section ------
# install.packages("rmarkdown")
library(rmarkdown)
library(rstudioapi)
library(knitr)
knitr::opts_chunk$set(echo=F, comment=NA)
# Getting the path of this program path
if (Sys.getenv("R_PLATFORM") == "") {
  this_program_path <- ""   # Windows
} else {
  this_program_path <- rstudioapi::getActiveDocumentContext()$path   # Mac
}
source_path <- getwd()
if (this_program_path != "") {
  temp_path <- unlist(strsplit(this_program_path, "/"))
  source_path <- paste(temp_path[-length(temp_path)], collapse="/")
}
# all treatment
source(paste0(source_path, "/common.R"))
source(paste0(source_path, "/common_function.R"))
saihi_flag <- F
source(paste0(source_path, "/edit_ptdata.R"))
render(paste0(source_path, "/demog.R"), output_dir=output_path, output_file="demog.html")
render(paste0(source_path, "/ope.R"), output_dir=output_path, output_file="ope.html")
render(paste0(source_path, "/sae.R"), output_dir=output_path, output_file="sae.html")
render(paste0(source_path, "/spo2.R"), output_dir=output_path, output_file="spo2.html")
render(paste0(source_path, "/completed.R"), output_dir=output_path, output_file="completed.html")
render(paste0(source_path, "/gass.R"), output_dir=output_path, output_file="gass.html")
# initialize
obj_list <- ls()
# leave only "source_path", remove objects
obj_list <- obj_list[-which(obj_list == "source_path")]
rm(list=obj_list)
# FAS
source(paste0(source_path, "/common.R"))
source(paste0(source_path, "/common_function.R"))
saihi_flag <- T
source(paste0(source_path, "/edit_ptdata.R"))
render(paste0(source_path, "/demog.R"), output_dir=output_path, output_file="demog_fas.html")
render(paste0(source_path, "/ope.R"), output_dir=output_path, output_file="ope_fas.html")
render(paste0(source_path, "/spo2.R"), output_dir=output_path, output_file="spo2_fas.html")
render(paste0(source_path, "/gass.R"), output_dir=output_path, output_file="gass_fas.html")
