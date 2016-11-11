# read the dataset
ds_1 <- read.csv("../data/1DS.csv",stringsAsFactors = FALSE, header = FALSE)
head(ds_1)
dim(ds_1)

#create time series object
gogl_ts_1 <- ts(ds_1)
save(gogl_ts_1, file = '../data/gogl_ts_1.RData')

#summary 
sink('../data/summary_1.txt')
print(summary(ds_1))
cat('\n')
print(head(gogl_ts_1))
sink()

#plot
png('../images/gogl_ts_1.png')
plot.ts(gogl_ts_1, main = '1DS.csv')
dev.off()
# The plot shows that data has a descending trend plus a seasonality trend