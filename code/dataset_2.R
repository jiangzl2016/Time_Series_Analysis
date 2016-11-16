ds_2 <- read.csv("../data/2DS.csv",stringsAsFactors = FALSE, header = FALSE)
gogl_ts_2 <- ts(ds_2, start = 1, frequency = 52)
plot.ts(gogl_ts_2)

library(forecast)
bestfit <- list(aicc = Inf)
for (i in 1:25){
  fit <- auto.arima(gogl_ts_2, xreg = fourier(gogl_ts_2, K = i), seasonal = FALSE)
  if (fit$aicc < bestfit$aicc)
    bestfit <- fit
  else break;
}

fc <- forecast(bestfit, xreg=fourier(gogl_ts_2, K=14, h=52))
plot(fc)

Predicted_2 <- fc$mean
write.table(Predicted_2, file = '../data/Q2_Zhongling_Jiang_3032197416.txt', sep=',')
