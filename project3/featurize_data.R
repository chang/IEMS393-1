require(dplyr)
require(tidyr)
require(stringr)
require(lubridate)

setwd("~/Documents/Winter2017/IEMS393/project3/")
dat <- read.csv("MidwesternProgramsData_17.csv")

# format numbers
dat$programs_ordered <- gsub(",", "", as.character(dat$programs_ordered)) %>% as.numeric()
dat$programs_sold <- gsub(",", "", as.character(dat$programs_sold)) %>% as.numeric()

# create homecoming field
dat$homecoming <- ifelse(grepl("\\(H\\)", as.character(dat$opponent)), 1, 0)
dat$opponent <- as.factor(gsub(" \\(H\\)", "", as.character(dat$opponent)))

# create am/pm field
dat$morning_kickoff <- ifelse(grepl("AM", as.character(dat$time_kickoff)), 1, 0)

# create hour field (int)
dat$hour <- lubridate::hm(dat$time_kickoff)@hour
dat$hour[dat$hour < 12] <- dat$hour[dat$hour < 12] + 12

# separate dates
date_data <- 
  as.character(dat$date) %>% 
    str_split_fixed(pattern = "\\, | ", n=4) %>% 
    data.frame() %>% 
    rename(day_of_week=X1, month=X2, day_of_month=X3, year=X4) %>% 
    select(-day_of_week)
dat <- bind_cols(date_data, dat) %>% select(-date)

# big ten
big_ten <- c("Illinois", "Indiana", "Iowa State", "Maryland", "Michigan",
             "Michigan State", "Midwestern", "Minnesota", "Nebraska", 
             "Northwestern", "Ohio State", "Penn State", "Purdue", "Rutgers", "Wisconsin")
dat$big_ten <- ifelse(dat$opponent %in% big_ten, 1, 0)

# pokey
dat$coach_pokey <- ifelse(dat$year == 2006 | dat$year == 2007, 1, 0)
