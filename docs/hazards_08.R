## Read Data ####

setwd("C:/Users/acardazz/Dropbox/teaching/Fall 2022/econ707/data")
sd <- readRDS("sandiego_fd.RDS")

## Create Dataset ####

library("lubridate")
library("scales")
library("forecast")
library("tseries")

# collapse date to month
sd$m <- floor_date(ymd_hms(sd$date_response), "month")
# collapse data to month-by-type counts
tbl <- as.data.frame(table(m = sd$m, type = sd$call_category))

# fix variables
tbl$m <- ymd(as.character(tbl$m))
tbl$type <- as.character(tbl$type)

# keep only hazards
tbl <- tbl[tbl$type == "HAZARD",]

# make horizon
tbl$h <- ifelse(tbl$m >= ymd("2017-01-01"), 1, 0)

## Exploratory Plots

plot(tbl$m, tbl$Freq, type = "l", lwd = 3)
lines(tbl$m[tbl$h == 1], tbl$Freq[tbl$h == 1], col = "tomato", lwd = 5)

plot(tbl$m, log(tbl$Freq), type = "l", lwd = 3)
lines(tbl$m[tbl$h == 1], log(tbl$Freq[tbl$h == 1]), col = "tomato", lwd = 5)

## Pre-Modeling Diagnostics ####

# is this stationary in levels?
adf.test(tbl$Freq[tbl$h == 0])

# what does the autocorrelation function look like?
acf(tbl$Freq, lag.max = 24)

# there is strong seasonality, so look at ACF/PACF of the 12 month
acf(diff(tbl$Freq, lag = 12))
pacf(diff(tbl$Freq, lag = 12))

## Model "drafts" ####

r1 <- arima(tbl$Freq[tbl$h == 0], c(0, 0, 0),
            seasonal = list(order = c(0, 1, 1),
                            period = 12))
r2 <- arima(tbl$Freq[tbl$h == 0], c(0, 0, 0),
            seasonal = list(order = c(1, 0, 1),
                            period = 12))

r1
r2

acf(r1$residuals)
pacf(r1$residuals) # ma1? #ar1?

acf(r2$residuals)
pacf(r2$residuals) # same as above?

## Tightening Up Models ####

r1 <- arima(tbl$Freq[tbl$h == 0], c(1, 0, 0),
            seasonal = list(order = c(0, 1, 1),
                            period = 12))
r2 <- arima(tbl$Freq[tbl$h == 0], c(1, 0, 0),
            seasonal = list(order = c(1, 0, 1),
                            period = 12))


rauto1 <- auto.arima(tbl$Freq[tbl$h == 0])
rauto2 <- auto.arima(ts(tbl$Freq[tbl$h == 0],
                        start = c(2010, 1, 1), frequency = 12))

acf(rauto1$residuals)
pacf(rauto1$residuals)

acf(rauto2$residuals)
pacf(rauto2$residuals)

## Make Forecasts ####

plot(tbl$m, tbl$Freq, type = "l", lwd = 3,
     xlim = ymd(c("2015-01-01", "2018-01-01")),
     xlab = "Month", ylab = "Hazard Calls")
lines(tbl$m[tbl$h == 1], tbl$Freq[tbl$h == 1], col = "tomato", lwd = 5)

p1 <- predict(r1, n.ahead = 12)
p2 <- predict(r2, n.ahead = 12)
pauto1 <- predict(rauto1, n.ahead = 12)
pauto2 <- predict(rauto2, n.ahead = 12)

lines(tbl$m[tbl$h == 1],
      p1$pred, lwd = 3,
      col = alpha("mediumseagreen", .6))
lines(tbl$m[tbl$h == 1],
      p2$pred, lwd = 3,
      col = alpha("dodgerblue", .6))
lines(tbl$m[tbl$h == 1],
      pauto1$pred, lwd = 3,
      col = alpha("orchid", .6))
lines(tbl$m[tbl$h == 1],
      pauto2$pred, lwd = 3,
      col = alpha("Goldenrod", .6))

## Evaluate ####

mape <- function(a, f){
  
  mean(abs((a-f)/a))
}

mape(tbl$Freq[tbl$h == 1], p1$pred)
mape(tbl$Freq[tbl$h == 1], p2$pred)

mape(tbl$Freq[tbl$h == 1], pauto1$pred)
mape(tbl$Freq[tbl$h == 1], pauto2$pred)

## Model Average ####

v1 <- as.numeric(p1$pred)
v2 <- as.numeric(p2$pred)
v3 <- as.numeric(pauto1$pred)
v4 <- as.numeric(pauto2$pred)

mape(tbl$Freq[tbl$h == 1],
     (v1 + v2 + v3 + v4)/4)

## Final Plot ####

plot(tbl$m, tbl$Freq, type = "l", lwd = 3,
     xlim = ymd(c("2015-01-01", "2018-01-01")),
     xlab = "Month", ylab = "Hazard Calls")
lines(tbl$m[tbl$h == 1], tbl$Freq[tbl$h == 1], col = "tomato", lwd = 5)

lines(tbl$m[tbl$h == 1],
      p1$pred, lwd = 3,
      col = alpha("mediumseagreen", .6))
lines(tbl$m[tbl$h == 1],
      p2$pred, lwd = 3,
      col = alpha("dodgerblue", .6))
lines(tbl$m[tbl$h == 1],
      pauto1$pred, lwd = 3,
      col = alpha("orchid", .6))
lines(tbl$m[tbl$h == 1],
      pauto2$pred, lwd = 3,
      col = alpha("Goldenrod", .6))

lines(tbl$m[tbl$h == 1],
      (v1 + v2 + v3 + v4)/4, lwd = 3,
      col = alpha("black", .6))

legend("bottomright", bty = "n",
       pch = 15, col = c("tomato",
                         "mediumseagreen",
                         "dodgerblue",
                         "orchid",
                         "goldenrod",
                         "black"),
       legend = c("actual", "alex 1", "alex 2",
                  "auto 1", "auto 2", "mean"),
       ncol = 2, cex = 2)