########################################################
# Exploratory Data Analysis
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

#plot
png('../images/gogl_ts_1.png')
plot.ts(gogl_ts_1, main = '1DS.csv')
dev.off()
# The plot shows that data has a descending trend plus a seasonality trend

################################################################
#Data Set 1
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

##############################################################
#Exponential Method / HoltWinters Filtering
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

###############################################################
#Data Set 2
#Fourier Transform Method
ds_2 <- read.csv("../data/2DS.csv",stringsAsFactors = FALSE, header = FALSE)
gogl_ts_2 <- ts(ds_2, start = 1, frequency = 52)
plot.ts(gogl_ts_2)
#I observe that data contains multi-seasonal trend
library(forecast)
bestfit <- list(aicc = Inf)
# Through conditioning the number of fourier termsfinding the optimal AICc, 
#I could find the optimal AICc and the best preditive model
for (i in 1:25){
  fit <- auto.arima(gogl_ts_2, xreg = fourier(gogl_ts_2, K = i), seasonal = FALSE)
  if (fit$aicc < bestfit$aicc)
    bestfit <- fit
  else break;
}

#The best model use 14 pairs of Fourier terms
# Series: gogl_ts_2 
# ARIMA(0,1,1) with drift         
# 
# Coefficients:
#   ma1   drift    S1-52   C1-52    S2-52   C2-52    S3-52
# -0.7885  0.1342  15.9282  1.5018  -4.4347  6.7261  -1.0116
# s.e.   0.0417  0.0631   0.8391  0.8102   0.5259  0.5149   0.4442
# C3-52   S4-52   C4-52   S5-52    C5-52   S6-52    C6-52
# 3.0165  2.7351  1.4685  2.7059  -3.6575  0.6421  -2.2276
# s.e.  0.4390  0.4118  0.4091  0.3958   0.3946  0.3868   0.3865
# S7-52    C7-52    S8-52   C8-52    S9-52   C9-52  S10-52
# -1.0061  -1.4506  -2.4702  2.1163  -0.1833  1.8302  1.0626
# s.e.   0.3813   0.3816   0.3776  0.3785   0.3751  0.3763  0.3733
# C10-52  S11-52   C11-52  S12-52   C12-52  S13-52   C13-52
# 1.7900  1.8956  -0.1462  1.4840  -1.3391  0.1965  -2.0284
# s.e.  0.3747  0.3719   0.3735  0.3709   0.3726  0.3702   0.3719
# S14-52   C14-52
# -1.4649  -1.0108
# s.e.   0.3697   0.3712
# 
# sigma^2 estimated as 20.7:  log likelihood=-594.55
# AIC=1251.1   AICc=1262.37   BIC=1354.56
fc <- forecast(bestfit, xreg=fourier(gogl_ts_2, K=14, h=52))
plot(fc)

Predicted_2 <- fc$mean
write.table(Predicted_2, file = '../data/Q2_Zhongling_Jiang_3032197416.txt', sep=',')

