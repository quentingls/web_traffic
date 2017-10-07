


file = "./data/train_2.csv/train_2.csv"

x = readLines(file)
header = x[1]

x = x[2:length(x)]


for (i in 1:10){

  print(i)

  start = (i - 1) * 15000 + 1
  end = pmin(start + 15000 - 1, length(x))

  out = c(header, x[start:end])

  writeLines(out, sprintf("split/train_%d.csv", i))

}
