load('../data/gogl_ts_1.RData')
load('../data/training_and_testing.RData')
#remove linear trend and seasonality trend
d1 <- diff(training_set_1)
plot.ts(d1)

#remove 
d2 <- diff(d1, lag=52)
length(d2)

png('../images/d2.png')
par(mfrow = c(2,2))
plot.ts(training_set_1, title = 'training_set_1')
plot.ts(d2, title = 'trend_seasonality_removed')
acf(d2, lag.max = 40)
pacf(d2, lag.max = 40)
dev.off()

#we notice that there is a indication of ARMA(1,1) model, however, we still
#see some significance for large value of lags in ACF plot

#We can either use auto.arima
#or use arma and adjust coefficients manually
library(tseries)
model_1 <- arima(training_set_1, order = c(1,1,1), seasonal = list(order = c(0,1,0),period = 52))
save(model_1, file = '../data/model_1.RData')
png('../images/model_1.png')
par(mfrow = c(2,2))
plot(model_1$residuals)
acf(model_1$residuals, na.action=na.pass)
pacf(model_1$residuals,na.action=na.pass) #ARMA(1,1) model fits well
dev.off()
tsdiag(model_1)
# Ljung-Box
Box.test(model_1$residuals,lag = 1, type="Ljung-Box")

library(TSA)
library(stats)
png('../images/tsdiag.png')
tsdiag(model_1)
dev.off()
###compute MSE
computemse <- function(train.dt, test.dt, order.totry, seasorder.totry){
    mod <- arima(train.dt, order = order.totry, seasonal =
                   list(order = seasorder.totry, period = 52))
    fcast <- predict(mod, n.ahead = 52)
    MSE <- mean((fcast$pred - test.dt)^2)
  return(MSE)
}

computemse(training_set_1, testing_set_1, c(1,1,1), c(0,1,0))

AIC(model_1)

## fit on full model
Model <- arima(gogl_ts_1, order = c(1,1,1), seasonal = list(order = c(0,1,0),period = 52))
Prediction <- predict(Model, n.ahead = 52)$pred

write.table(Prediction, file = '../data/Q1_Zhongling_Jiang_3032197416.txt', sep=',')

plot.ts(gogl_ts_1)

png('../images/prediction1.png')
require(tseries)
require(astsa)
ts.plot(gogl_ts_1,Prediction, lty = c(1,1), col=c(1,2))
dev.off()

# HoltWinters Filtering 
d2forecasts <- HoltWinters(d2, beta = FALSE,gamma =FALSE)
d2forecasts

d2forecasts$SSE
plot(d2forecasts)
d2forecasts2 <- forecast.HoltWinters(d2forecasts, h =52)
save(d2forecasts, d2forecasts2, 
     file = '../data/d2forcast.RData')
png('../images/d2forecast2.png')
par(mfrow = c(2,1))
plot.forecast(d2forecasts2)
acf(d2forecasts2$residuals, lag.max=20, na.action = na.pass)
dev.off()
Box.test(d2forecasts2$residuals, lag=20, type="Ljung-Box")
