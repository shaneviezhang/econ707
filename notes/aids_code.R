library("lubridate")
library("tseries")
library("forecast")
rm(list = ls())
# setwd(paste0("C:/Users/",Sys.info()["users"],"/Dropbox/teaching/Fall 2022/econ707/data"))
tmp3 <- readRDS("../data/aids.RDS")

tmp <- aggregate(list(death = tmp3$deaths,
                      diag = tmp3$diag),
                 list(month = tmp3$month),
                 sum, na.rm = TRUE)
ifelse(tmp$death == 0, NA, tmp$death) -> tmp$death
ifelse(tmp$diag == 0, NA, tmp$diag) -> tmp$diag
tmp <- tmp[year(tmp$month) >= 1987,]

lim1 <- tmp$month <= ymd("1994-04-01") & !is.na(tmp$death)

plot_all <- function(months = 0){
  
  plot(tmp$month, tmp$diag, type = "n",
       xlab = "Month", ylab = "Quantity")
  lines(tmp$month[lim1], tmp$diag[lim1], type = "l", col = "black", lwd = 3)
  lines(tmp$month[lim1] - months(months), tmp$death[lim1], col = "dodgerblue", lwd = 3)
  abline(v = ymd(c("1993-01-01", "1994-04-15")), lty = c(1, 2))
  legend("topright", bty = "n", col = c("black", "dodgerblue"), lty = 1,
         legend = c("Diagnoses", "Deaths"), lwd = 2)
}

plot_all()

## ARIMA

aids_ts <- ts(tmp[lim1,2:3], start = c(min(year(tmp$month[lim1]))), frequency = 12)

adf.test(diff(aids_ts[,"death"]))
acf(diff(aids_ts[,"death"]))
pacf(diff(aids_ts[,"death"]))

adf.test(diff(diff(aids_ts[,"death"], lag = 12)))
acf(diff(diff(aids_ts[,"death"], lag = 12)))
pacf(diff(diff(aids_ts[,"death"], lag = 12)))

reg1 <- auto.arima(aids_ts[,"death"])
H <- 24
p1 <- predict(reg1, n.ahead = H)
plot_all()
lines(tmp$month[!lim1][1:H],
      p1$pred, col = "tomato", lwd = 3)
lines(tmp$month[!lim1][1:H],
      tmp$death[!lim1][1:H], col = "mediumseagreen", lwd = 3)
legend("bottomright", bty = "n", col = c("tomato", "mediumseagreen"), lty = 1,
       legend = c("ARIMA", "Actual"), lwd = 2)

## ARDL

plot_all()

keep <- c()
for(i in 1:48){
  
  keep[i] <- cor.test(tmp$diag[1:(sum(lim1) - i)], tmp$death[lim1][(1+i):sum(lim1)])$statistic
}

plot(keep, type = "b", pch = 19)
abline(v = c(which(keep == max(keep)), 24), col = "tomato")

ccf(tmp$death[lim1], tmp$diag[lim1], lag.max = 48)

plot_all(12)
plot_all(19)
plot_all(24)



acf(diff(diff(aids_ts[,"diag"], lag = 12)))
pacf(diff(diff(aids_ts[,"diag"], lag = 12)))

aids_ts2 <- ts(cbind(death = diff(diff(aids_ts[,"death"], lag = 12)),
                     diag = diff(diff(aids_ts[,"diag"], lag = 12))),
               start = c(1988, 2), frequency = 12)
aids_ts2 <- aids_ts

acf(aids_ts2, lag.max = 24)

rmv.q <- c() # y-vars
rmv.p <- list(diag = c(0:18)) # x-vars
rmv <- list(p = rmv.p, q = rmv.q)
main <- ardlDlm(formula = death ~ diag,
                data = as.data.frame(aids_ts2),
                p = 19,
                q = 2,
                remove = rmv)
summary(main)

auto.arima(aids_ts[,"diag"]) -> r
p <- predict(r, 24-19)



dLagM::forecast(model = main,
                x = c(tmp$diag[lim1][sum(lim1) - 18:0], p$pred),
                h = 24,
                interval = FALSE) -> f

plot_all()
lines(tmp$month[!lim1][1:24], f$forecasts, col = "tomato")
lines(tmp$month[!lim1][1:24], tmp$death[!lim1][1:24], col = "dodgerblue")


# adf.test(lm(death ~ diag,
#             data = tmp[lim1,])$residuals)
# adf.test(lm(death ~ diag,
#             data = tmp[lim1 & tmp$month < ymd("1993-01-01"),])$residuals)




