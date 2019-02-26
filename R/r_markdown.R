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
source(paste0(source_path, "/common.R"))
render(paste0(source_path, "/demog.R"), output_dir=output_path)
render(paste0(source_path, "/ope.R"), output_dir=output_path)
