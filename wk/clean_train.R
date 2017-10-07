library(readr)
library(dplyr)
library(tidyr)
library(lubridate)

# Load data ---------------------------------------------------------------

files = list.files("split", full.names = TRUE, pattern = "\\.csv$")

i = 1
for (i in 1:length(files)){
  print(i)
  data = read_csv(files[i],
                  col_types = cols(.default = col_character())) %>%
    gather(Date, Traffic, -Page) %>%
    mutate(Date = as.Date(Date),
           Traffic = as.numeric(Traffic)) %>%
    arrange(Page, Date)


  data = data %>%
    group_by(Page) %>%
    mutate(keep_date = Date >= (Date[which(!is.na(Traffic))[1]])) %>%
    ungroup %>%
    filter(keep_date)

  data = data %>%
    group_by(Page) %>%
    mutate(imp_traffic = (lag(Traffic, 7) + lead(Traffic, 7)) / 2) %>%
    ungroup %>%
    mutate(Traffic2 = ifelse(is.na(Traffic), imp_traffic, Traffic)) %>%
    group_by(Page) %>%
    mutate(Traffic3 = ifelse(is.na(Traffic2), lag(Traffic2, 7), Traffic2),
           Traffic4 = ifelse(is.na(Traffic3), lag(Traffic3, 7), Traffic3))

  data = data %>%
    group_by(Page, wday(Date)) %>%
    mutate(wimp_traffic = mean(Traffic, na.rm = TRUE)) %>%
    ungroup %>%
    mutate(Traffic5 = ifelse(is.na(Traffic4), wimp_traffic, Traffic4))

  data = data %>%
    group_by(Page) %>%
    mutate(Traffic6 = ifelse(is.na(Traffic5), mean(Traffic, na.rm = TRUE), Traffic5)) %>%
    ungroup

  data = data %>%
    select(Page, Date, Traffic, imp_traffic = Traffic6)

  print(summary(data))

  write_csv(data, sprintf("split/cleaned/train_%d.csv", i))

}

