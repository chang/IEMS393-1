# Scatterplot on year scale
d %>% sample_frac(.5) %>% 
  ggplot() + geom_point(aes(x=date_complete, y=callers, color=country), alpha=0.1, size=.5) + 
  scale_x_datetime("Year") + facet_grid(. ~ country) +
  ggtitle("Scatterplot of hourly caller volume: Year") + xlab("Year") + ylab("Callers per hour") +
  theme(axis.text.x = element_text(angle = 90))

# Scatterplot on day scale
d %>% sample_frac(.5) %>% 
  ggplot() + geom_point(aes(x=day, y=callers, color=country), alpha=0.1, size=.5) + 
  facet_grid(. ~ country) +
  ggtitle("Scatterplot of hourly caller volume: Day") + xlab("Day") + ylab("Callers per hour") +
  theme(axis.text.x = element_text(angle = 90))

# Scatterplot on hourly scale
d %>% sample_frac(.5) %>% 
  ggplot() + geom_point(aes(x=hour, y=callers, color=country), alpha=0.1, size=.5) + 
  facet_grid(. ~ country) +
  ggtitle("Scatterplot of hourly caller volume: Hour") + xlab("Hour") + ylab("Callers per hour") +
  theme(axis.text.x = element_text(angle = 90))

# Histogram of hourly arrival rates (callers per hour)
d %>% 
  ggplot() + geom_histogram(aes(x=callers, fill=country), binwidth=1) + facet_grid(country ~ .) +
  ggtitle("Histogram of hourly caller volume") + xlab("Count of callers per hour") + ylab("Frequency count")