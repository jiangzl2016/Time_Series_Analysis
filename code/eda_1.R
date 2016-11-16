# read the dataset
ds_1 <- read.csv("../data/1DS.csv",stringsAsFactors = FALSE, header = FALSE)
head(ds_1)
dim(ds_1)

#create time series object
gogl_ts_1 <- ts(ds_1, start = 1, frequency = 52)
save(gogl_ts_1, file = '../data/gogl_ts_1.RData')

#create training set and test set
len <- length(gogl_ts_1)
training_set_1 <- ts(gogl_ts_1[1:(len - 52)], frequency = 52)
testing_set_1 <- gogl_ts_1[(len - 52 + 1):len]
save(training_set_1,testing_set_1, file = '../data/training_and_testing.RData')

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