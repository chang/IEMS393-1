packages <- c("ggplot2", "dplyr", "magrittr", "tidyr", "lubridate")
new_packages <- packages[!(packages %in% installed.packages())]
if(length(new_packages)){install.packages(new_packages)}
rm(packages)
rm(new_packages)
