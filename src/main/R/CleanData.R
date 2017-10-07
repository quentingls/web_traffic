####################################################################################
####################################################################################

rm(list = ls())
setwd("/Users/khn/projects/webTraffic/")

####################################################################################
####################################################################################
## 

#key1Df = read.csv("data/key_1.csv")
#key2Df = read.csv("data/key_2.csv")

#trainDf = read.csv("data/train_1.csv")
#save(trainDf, file = "data/trainDf.RData")
load("data/trainDf.RData")
trainLongDf = melt(trainDf, id.var = "Page")
trainLongDf = trainLongDf[1:10000, ]

keepIndexSplitLoL = lapply(as.character(trainLongDf$Page), function(x) strsplit(x, "\\."))
keepIndexSplitL = lapply(keepIndexSplitLoL, "[[", 1)
keepSplitIndex = sapply(keepIndexSplitL, length) == 3
trainDf = trainDf[keepSplitIndex, ]

#train2Df = read.csv("data/train_2.csv")

####################################################################################
####################################################################################
## 

library(reshape2)
library(lubridate)
library(mice)

####################################################################################
####################################################################################
## 

trainLongDf$Page = as.character(trainLongDf$Page)
trainLongDf$Date = as.Date(gsub("X", "", trainLongDf$variable), format = "%Y.%m.%d")
trainLongDf$variable = NULL
trainLongDf$Visit = as.numeric(trainLongDf$value)
trainLongDf$value = NULL

trainLongDf$dayOfTheWeek = wday(trainLongDf$Date, label = TRUE)
trainLongDf$month = month(trainLongDf$Date)

splitStringLofL = lapply(trainLongDf$Page, function(x) strsplit(x, "\\."))

trainLongDf$Page = NULL
splitStringL = lapply(splitStringLofL, "[[", 1)
splitStringDf = data.frame(do.call(rbind, splitStringL))

splitStringDf$Page = gsub('_[a-zA-Z^]+^', '', splitStringDf$X1)
splitStringDf$Country = gsub('.*_(.*)', '\\1', splitStringDf$X1)
splitStringDf$Platform = gsub('.*_(.*)', '\\1', splitStringDf$X3)

splitStringDf$X1 = splitStringDf$X2 = splitStringDf$X3 = NULL

trainIncompleteDf = data.frame(splitStringDf, trainLongDf)

trainCompleteDf = trainIncompleteDf
trainCompleteDf[is.na(trainCompleteDf)] = 0
trainCompleteDf = trainCompleteDf[trainCompleteDf$Country %in% c("fr", "zh"), ]

print(dim(trainCompleteDf))
save(trainCompleteDf, file = "data/trainCompleteDf.RData")
write.csv(trainCompleteDf, file = "data/trainCompleteDf.csv")

table(trainCompleteDf$Country)

####################################################################################
####################################################################################
## 638