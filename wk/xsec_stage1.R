library(readr)
library(dplyr)
library(tidyr)
library(eble)

# Load data ---------------------------------------------------------------

files = list.files("split", full.names = TRUE)

# length(readLines(file))

i = 1
for (i in 1:length(files)){

  print(i)
  data = read_csv(files[i],
                  col_types = cols(.default = col_character())) %>%
    gather(Date, Traffic, -Page) %>%
    mutate(Date = as.Date(Date),
           t_copy = Traffic,
           Traffic = as.numeric(Traffic)) %>%
    arrange(Page, Date)

  xsec[[i]] = data %>%
    mutate(Traffic = as.numeric(Traffic)) %>%
    group_by(Page) %>%
    summarize(na_count = sum(is.na(Traffic)),
              nobs = n(),
              first_valid_date = Date[which(!is.na(Traffic))[1]],
              min_traffic = min(Traffic, na.rm = TRUE),
              max_traffic = max(Traffic, na.rm = TRUE),
              tot_traffic = sum(Traffic, na.rm = TRUE))

  print(head(xsec[[i]]))

}


xsec = bind_rows(xsec)

write_csv(xsec, "processed/xsec_stage1.csv")



View(xsec)
