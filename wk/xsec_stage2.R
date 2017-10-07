


xsec = read.csv("processed/xsec_stage1.csv",
                stringsAsFactors = FALSE) %>%
  mutate(platform = gsub(".*\\.org_", "", Page),
         Page2 = substring(Page, 1, nchar(Page) - nchar(platform) - 1))


xsec = xsec %>%
  mutate(url = gsub(".*_", "", Page2),
         page = gsub("_$", "", substring(Page2, 1, nchar(Page2) - nchar(url))))


xsec$Page2 = NULL

head(xsec)



xsec = xsec %>%
  arrange(desc(tot_traffic))


head(xsec)



write.csv(xsec, "processed/xsec_stage2.csv", row.names = FALSE)
