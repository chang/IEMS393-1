require(dplyr)
require(tidyr)
require(stringr)
require(lubridate)

setwd("~/Documents/Winter2017/IEMS393-1/project3/")
dat <- read.csv("MidwesternProgramsData_17_2.csv")

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
dat$hour[dat$hour < 11] <- dat$hour[dat$hour < 11] + 12

# separate dates
date_data <- 
  as.character(dat$date) %>% 
  str_split_fixed(pattern = "\\, | ", n=4) %>% 
  data.frame() %>% 
  rename(day_of_week=X1, month=X2, day_of_month=X3, year=X4) %>% 
  select(-day_of_week)
dat <- bind_cols(date_data, dat) %>% select(-date)
dat$day_of_month <- as.integer(as.character(dat$day_of_month))
dat$year <- as.factor(as.character(dat$year))

# big ten
big_ten <- c("Illinois", "Indiana", "Iowa State", "Maryland", "Michigan",
             "Michigan State", "Midwestern", "Minnesota", "Nebraska", 
             "Northwestern", "Ohio State", "Penn State", "Purdue", "Rutgers", "Wisconsin")
dat$big_ten <- ifelse(dat$opponent %in% big_ten, 1, 0)

# school sizes
school_sizes <- data.frame(school=big_ten)

# pokey
dat$coach_pokey <- ifelse(dat$year %in% c(2006, 2007), 1, 0)

# correct northwestern
dat$opponent[dat$opponent == "Northwestern "] <- "Northwestern"

### Regression Analyses
dat_lm <- select(dat, -programs_ordered, -time_kickoff) %>% 
          filter(coach_pokey != 1) %>%  # take out old coach
          select(-coach_pokey) %>% 
          filter(!(month == "August" & day_of_month == 30 & opponent == "Nebraska"))  # take out first game of 2008
dat_fit <- lm(programs_sold ~ ., select(dat_lm, -opponent))


# # refactoring opponents
# MIN_GAMES = 2
# other_teams <- table(dat$opponent)[table(dat$opponent) <= MIN_GAMES] %>% names()
# 
# dat$opponent_refactored <- dat$opponent %>% as.character()
# dat$opponent_refactored[dat$opponent_refactored %in% other_teams] <- "Other"
# dat$opponent_refactored <- as.factor(dat$opponent_refactored)
