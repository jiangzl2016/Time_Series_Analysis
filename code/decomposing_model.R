load('../data/gogl_ts_1.RData')
load('../data/training_and_testing.RData')
#using smoothing method to evaluate the trend
library(TTR)
training_set_1SMA12 <- SMA(training_set_1, n = 8)
par(mfrow = c(1,1))
png('../images/SMA12.png')
plot.ts(training_set_1SMA12) #which shows there is a decencding trend and seaonsal
dev.off()

#decompose seasonal data
training_set_1components <- decompose(training_set_1)
png('../images/components.png')
plot(training_set_1components)
dev.off()
# we see the trend component is linear, and the random follows a nearly
#white noise distirbution, but still need varification.

training_set_1components_adjusted <- training_set_1 - training_set_1components$seasonal
plot(training_set_1components_adjusted)

#Apply Holtwinters model
library(forecast)
training_set_1forecasts <- HoltWinters(training_set_1components_adjusted, beta = FALSE,gamma =FALSE,
                                       l.start = 60.1, b.start = 6.96)
training_set_1forecasts
training_set_1forecasts$SSE
plot(training_set_1forecasts)
training_set_1forecasts2 <- forecast.HoltWinters(training_set_1forecasts, h =52)

save(training_set_1forecasts, training_set_1forecasts2, 
    file = '../data/training_set_1forcast.RData')

png('../images/forecast2.png')
par(mfrow = c(2,1))
plot.forecast(training_set_1forecasts2)
acf(training_set_1forecasts2$residuals, lag.max=20, na.action = na.pass)
dev.off()

acf(training_set_1forecasts2$residuals, lag.max=20, na.action = na.pass)
Box.test(training_set_1forecasts2$residuals, lag=20, type="Ljung-Box")

#RECOVER
training_set_1predicted <- training_set_1components$seasonal[2: 53] + training_set_1forecasts2$mean

testMSE <- mean((training_set_1predicted - testing_set_1)^2)
testMSE



