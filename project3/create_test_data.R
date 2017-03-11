require(dplyr)
require(tidyr)
require(stringr)
require(lubridate)

setwd("~/Documents/Winter2017/IEMS393-1/project3/")
schedule2017 <- read.csv("2017_schedule.csv")

# create homecoming field
schedule2017$homecoming <- ifelse(grepl("\\(H\\)", as.character(schedule2017$opponent)), 1, 0)
schedule2017$opponent <- as.factor(gsub(" \\(H\\)", "", as.character(schedule2017$opponent)))

# create am/pm field
schedule2017$morning_kickoff <- ifelse(grepl("AM", as.character(schedule2017$time_kickoff)), 1, 0)

# create hour field (int)
schedule2017$hour <- lubridate::hm(schedule2017$time_kickoff)@hour
schedule2017$hour[schedule2017$hour < 11] <- schedule2017$hour[schedule2017$hour < 11] + 12

# separate dates
date_data <- 
  as.character(schedule2017$date) %>% 
  str_split_fixed(pattern = "\\, | ", n=4) %>% 
  data.frame() %>% 
  rename(day_of_week=X1, month=X2, day_of_month=X3, year=X4) %>% 
  select(-day_of_week)
schedule2017 <- bind_cols(date_data, schedule2017) %>% select(-date)
schedule2017$day_of_month <- as.integer(as.character(schedule2017$day_of_month))
schedule2017$year <- as.factor(as.character(schedule2017$year))

# big ten
big_ten <- c("Illinois", "Indiana", "Iowa State", "Maryland", "Michigan",
             "Michigan State", "Midwestern", "Minnesota", "Nebraska", 
             "Northwestern", "Ohio State", "Penn State", "Purdue", "Rutgers", "Wisconsin")
schedule2017$big_ten <- ifelse(schedule2017$opponent %in% big_ten, 1, 0)

# school sizes
school_sizes <- data.frame(school=big_ten)

# pokey
schedule2017$coach_pokey <- ifelse(schedule2017$year %in% c(2006, 2007), 1, 0)

# correct northwestern
schedule2017$opponent[schedule2017$opponent == "Northwestern "] <- "Northwestern"


# perform same filtering as on test
schedule2017_lm <- schedule2017 %>% 
  select(-time_kickoff) %>% 
  filter(coach_pokey != 1) %>%  # take out old coach game
  select(-coach_pokey) %>% 
  filter(!(month == "August" & day_of_month == 30 & opponent == "Nebraska")) %>% 
  select(-opponent) %>% 
  mutate(year = as.integer(as.character(year))) %>% 
  filter(!month %in% c("August", "December"))

schedule2017_lm$month <- droplevels(schedule2017_lm$month)
