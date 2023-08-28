---
title: "Seasonality"
subtitle: "Week 7"
author: "Alex Cardazzi"
institute: "Old Dominion University"
format:
  revealjs:
    #chalkboard: true

    echo: true
    code-fold: show
    code-summary: "Code"
    code-tools: true
    code-copy: hover
    link-external-newwindow: true
    tbl-cap-location: top
    fig-cap-location: bottom
    #smaller: true
    
    scrollable: true
    incremental: true 
    slide-number: c/t
    show-slide-number: all
    menu: false
    
    logo: https://www.odu.edu/content/dam/odu/logos/univ/png-72dpi/odu-secondarytm-blu.png
    footer: "ECON 707/807: Econometrics II"
  
self-contained: true
  
editor: source
---




## Topics

- Trends + Cycles
- Seasonality
- Statistical Inference

## Time Series Models

$$Y_{t} = T_t + C_t + S_t$$

. . .

$Y_t = T_t$: ```lm(y ~ t, df)```

. . .

$Y_t = C_t$: ```arima(df$y, c(p, 0, q))```

. . .

$Y_t = T_t + C_t$: ?

. . .

Again, ignore $S_t$ for now. How do we estimate a model of the form $Y_t = T_t + C_t$?

## Deterministic vs Stochastic Trends

$$\begin{align} Y_t = t + e_t \qquad\qquad\qquad Y_t = 1 + Y_{t-1} + e_t \end{align}$$


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
shocks <- rnorm(100, 0, 2)
v1 <- 0:99 + shocks
v2 <- rep(0, 100)
for(i in 2:100) v2[i] <- 1 + v2[i-1] + shocks[i]

plot(1:100, v1, col = "tomato", type = "l",
     xlab = "", ylab = "", ylim = range(v1, v2))
lines(1:100, v2, col = "dodgerblue")
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-1-1.png){fig-align='center' width=90%}
:::
:::


## Deterministic vs Stochastic {visibility="uncounted"}

:::: {.columns}

::: {.column width="45%"}

::: {.fragment .fade-up}
$$\small Y_t = \alpha t + e_t$$
:::

::: {.fragment .fade-up}
$$\small \begin{align} \\ E[Y_t] = \alpha t \end{align}$$
:::

::: {.fragment .fade-up}
$$\small \begin{align} \\ \\ \text{Var}(Y_t) = \sigma^2 \end{align}$$
:::

:::

::: {.column width="45%"}

::: {.fragment .fade-up}
$$\small \begin{align} Y_t &= \alpha + Y_{t-1} + e_t \\&= \alpha + (\alpha + Y_{t-2} + e_{t-1}) +e_t \end{align}$$
:::

::: {.fragment .fade-up}
$$\small E[Y_t] = E[ \ \sum_{i=0}^{t}\alpha + \sum_{i=0}^{t}e_i \ ] = \alpha t$$
:::

::: {.fragment .fade-up}
$$\small \begin{align} \text{Var}(Y_t) &= \text{Var}( \ \sum_{i=0}^{t}\alpha + \sum_{i=0}^{t}e_i \ ) \\ &= 0 + \sum_{i=0}^{t}\text{Var}(e_i) \end{align}$$

:::

:::

::::

## Deterministic vs Stochastic  {visibility="uncounted"}

How can we tell these two things apart?

. . .

$$\begin{align}
Y_t &= \gamma + \beta Y_{t-1} + e_t \\
Y_t - Y_{t-1}&= \gamma + \beta Y_{t-1} - Y_{t-1} + e_t \\
\Delta Y_t &= \gamma + (\beta-1) Y_{t-1} + e_t \\
\Delta Y_t &= \gamma + \alpha Y_{t-1} + e_t \\
^{*}\Delta Y_t &= \gamma + \rho t + \alpha Y_{t-1} \\&+ \omega_1 \Delta Y_{t-1} + ... + \omega_{p-1} \Delta Y_{t-p+1} + e_t \\
\end{align}$$

. . .

If $\alpha = 0$, then $\beta - 1 = 0 \implies \beta = 1$.  In other words, there exists a unit root and it is non-stationary.

## Moore's Law Aside {visibility="uncounted"}

The number of transistors is doubling every year.  Assume we have reason to believe that the relationship is deterministic.  Therefore, our model should be:

. . .

$$Y_t = e^{\alpha + \beta t + \epsilon_t} \implies log(Y_t) = \alpha + \beta t + \epsilon_t$$

. . .

If $\frac{Y_t}{Y_{t-2}} = 2$ is true, then: $\frac{e^{\alpha + \beta t + \epsilon_t}}{e^{\alpha + \beta (t-2) + \epsilon_t}}  = \frac{e^{\alpha}e^{\beta t}}{e^{\alpha}e^{\beta t}e^{-2\beta}} = e^{2\beta}$.

. . . 

From here, we get $2 = e^{2\beta} \implies log(2) = 2\beta \implies \beta = \frac{log(2)}{2}$

## Moore's Law Aside {visibility="uncounted"}

Since we now have a theoretical value of $\beta$ ($\frac{log(2)}{2}$), we can use regression to test this.

. . .

Calculate the coefficients for the regression: $log(Y_t) = \alpha + \beta t + \epsilon_t$

. . .

Calculate a $t$-statistic by $\frac{\hat{\beta} - \frac{log(2)}{2}}{s.e._{\hat{\beta}}}$

## Moore's Law Aside {visibility="uncounted"}

We could also do the following:

. . .

$$\begin{align}
log(Y_t) &= \alpha + \beta t + \epsilon_t \\
log(Y_t) - \frac{log(2)}{2}t &= \alpha + \beta t + \epsilon_t - \frac{log(2)}{2}t \\
log(Y_t) - \frac{log(2)}{2}t &= \alpha + (\beta - \frac{log(2)}{2} )t + \epsilon_t \\
log(Y_t) - \frac{log(2)}{2}t &= \alpha + \gamma t + \epsilon_t \\
\end{align}$$

. . .

$\hat{\gamma} = 0 \implies \hat{\beta} - \frac{log(2)}{2} = 0 \implies \hat{\beta} = \frac{log(2)}{2}$

## Deterministic vs Stochastic  {visibility="uncounted"}

How can we tell these two things apart?

- If the series is trend-stationary, the detrended series will appear stationary.
- If the difference-stationary model is detrended, the residuals will not be stationary.

## Deterministic vs Stochastic  {visibility="uncounted"}

Which is which?


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
plot(1:100, v1, col = "tomato", type = "l",
     xlab = "", ylab = "", ylim = range(v1, v2))
lines(1:100, v2, col = "dodgerblue")
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-2-1.png){fig-align='center' width=90%}
:::
:::


## Deterministic vs Stochastic  {visibility="uncounted"}

Which is which?


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
plot(1:100, v1, col = "tomato", type = "l",
     xlab = "", ylab = "", ylim = range(v1, v2))
lines(1:100, v2, col = "dodgerblue")
legend("topleft", legend = c("Deterministic", "Stochastic"),
       bty = "n", lty = 1, cex = 1.25, lwd = 2,
       col = c("tomato", "dodgerblue"))
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-3-1.png){fig-align='center' width=90%}
:::
:::


## Deterministic vs Stochastic  {visibility="uncounted"}

Detrended:

::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
t <- 1:100
r1 <- lm(v1~t)$residuals
r2 <- lm(v2~t)$residuals
plot(r1, col = "tomato", type = "l",
     xlab = "", ylab = "", ylim = range(r1, r2))
lines(r2, col = "dodgerblue")
legend("topleft", legend = c("Deterministic", "Stochastic"),
       bty = "n", lty = 1, cex = 1.25, lwd = 2,
       col = c("tomato", "dodgerblue"))
abline(h = 0, lty = 2)
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-4-1.png){fig-align='center' width=90%}
:::
:::


## Deterministic vs Stochastic  {visibility="uncounted"}

Differenced:

::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
plot(diff(v1), col = "tomato", type = "l",
     xlab = "", ylab = "", ylim = range(diff(v1), diff(v2)))
lines(diff(v2), col = "dodgerblue")
legend("topleft", legend = c("Deterministic", "Stochastic"),
       bty = "n", lty = 1, cex = 1.25, lwd = 2,
       col = c("tomato", "dodgerblue"))
abline(h = 0, lty = 2)
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-5-1.png){fig-align='center' width=90%}
:::
:::


## Deterministic vs Stochastic  {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
tseries::adf.test(v1)
tseries::adf.test(v2)
```

::: {.cell-output .cell-output-stdout}
```

	Augmented Dickey-Fuller Test

data:  v1
Dickey-Fuller = -4.3961, Lag order = 4, p-value = 0.01
alternative hypothesis: stationary


	Augmented Dickey-Fuller Test

data:  v2
Dickey-Fuller = -1.8871, Lag order = 4, p-value = 0.6234
alternative hypothesis: stationary
```
:::
:::


## Time Series Models {visibility="uncounted"}

Suppose $T_t$ is a constant and $C_t$ is an AR(1) process.

$$\begin{align}
Y_{t} &= T_t + C_t \\
&= (\alpha) + (\gamma Y_{t-1} + e_t)
\end{align}$$

. . .

Suppose $T_t$ is a linear trend and $C_t$ is an AR(1) process.

$$\begin{align}
Y_{t} &= T_t + C_t \\
&= (\alpha + \beta t) + (\gamma Y_{t-1} + e_t)
\end{align}$$



## Time Series Models {visibility="uncounted"}

$Y_t = t + e_t$ -- ```auto.arima```:


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
reg1 <- forecast::auto.arima(v1)
reg1
```

::: {.cell-output .cell-output-stdout}
```
Series: v1 
ARIMA(2,1,0) with drift 

Coefficients:
          ar1      ar2   drift
      -0.6834  -0.4862  0.9954
s.e.   0.0891   0.0898  0.0948

sigma^2 = 4.254:  log likelihood = -211.01
AIC=430.01   AICc=430.44   BIC=440.39
```
:::
:::


## Time Series Models {visibility="uncounted"}

$Y_t = t + e_t$ -- ```auto.arima``` with a trend:


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
reg2 <- forecast::auto.arima(v1, xreg = 1:100)
reg2
```

::: {.cell-output .cell-output-stdout}
```
Series: v1 
Regression with ARIMA(0,0,0) errors 

Coefficients:
      intercept    xreg
        -1.0728  1.0050
s.e.     0.3649  0.0063

sigma^2 = 3.345:  log likelihood = -201.26
AIC=408.53   AICc=408.78   BIC=416.34
```
:::
:::


## Time Series Models {visibility="uncounted"}

$Y_t = 1 + Y_{t-1} + e_t$ -- ```auto.arima```:


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
reg1 <- forecast::auto.arima(v2)
reg1
```

::: {.cell-output .cell-output-stdout}
```
Series: v2 
ARIMA(0,1,0) with drift 

Coefficients:
      drift
      1.194
s.e.  0.183

sigma^2 = 3.349:  log likelihood = -199.81
AIC=403.62   AICc=403.74   BIC=408.81
```
:::
:::


## Time Series Models {visibility="uncounted"}

$Y_t = 1 + Y_{t-1} + e_t$ -- ```auto.arima``` with a trend:


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
reg2 <- forecast::auto.arima(v2, xreg = 1:100)
reg2
```

::: {.cell-output .cell-output-stdout}
```
Series: v2 
Regression with ARIMA(1,0,0) errors 

Coefficients:
         ar1    xreg
      0.8943  1.1179
s.e.  0.0457  0.0266

sigma^2 = 3.216:  log likelihood = -200.1
AIC=406.19   AICc=406.44   BIC=414.01
```
:::
:::


## Time Series Models {visibility="uncounted"}

Liquor -- ```auto.arima```:


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
liquor <- read.csv("../data/liquor.csv")
liquor$date <- mdy(liquor$date)
liquor <- liquor[liquor$date < ymd("2020-01-01"),]
liquor$t <- interval(min(liquor$date), liquor$date) %/% months(1)
reg1 <- forecast::auto.arima(log(liquor$sales_adj))
reg1
```

::: {.cell-output .cell-output-stdout}
```
Series: log(liquor$sales_adj) 
ARIMA(1,1,1) with drift 

Coefficients:
          ar1      ma1   drift
      -0.1448  -0.2917  0.0031
s.e.   0.1220   0.1163  0.0004

sigma^2 = 0.0001347:  log likelihood = 1019.16
AIC=-2030.31   AICc=-2030.19   BIC=-2015.06
```
:::
:::



## Time Series Models {visibility="uncounted"}

Liquor -- ```auto.arima``` with a trend:


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
reg2 <- forecast::auto.arima(log(liquor$sales_adj), xreg = liquor[,"t"])
reg2
```

::: {.cell-output .cell-output-stdout}
```
Series: log(liquor$sales_adj) 
Regression with ARIMA(2,0,1) errors 

Coefficients:
         ar1     ar2      ma1  intercept    xreg
      0.7764  0.1712  -0.2338     7.4318  0.0032
s.e.  0.1306  0.1199   0.1272     0.0159  0.0001

sigma^2 = 0.0001323:  log likelihood = 1025.13
AIC=-2038.26   AICc=-2038   BIC=-2015.36
```
:::
:::



## Time Series Models {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code}
tmp <- data.frame(matrix(NA, ncol = ncol(liquor), nrow = 36))
colnames(tmp) <- colnames(liquor)
tmp$date <- max(liquor$date) + months(1:36)
tmp$t <- max(liquor$t) + 1:36
```
:::


## Time Series Models {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
p <- predict(reg2, newxreg = tmp[,"t"], n.ahead = 36)
p_u <- p$pred + 1.645*p$se
p_l <- p$pred - 1.645*p$se

plot(c(liquor$date, tmp$date),
     c(log(liquor$sales_adj), log(tmp$sales_adj)),
     col = "black", type = "l",
     ylim = range(log(liquor$sales), p_u),
     xlab = "", ylab = "log(Sales)")
lines(tmp$date, p$pred, col = "tomato")
lines(tmp$date, p_u, col = "tomato", lty = 2)
lines(tmp$date, p_l, col = "tomato", lty = 2)
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-14-1.png){fig-align='center' width=90%}
:::
:::











## Misspecification, Bias

It is unlikely that we exactly pin down the true DGP.  So, what are the consequences?

Truth: $Y_t = \mu_1 + \mu_2 t$

. . .

$$\small \begin{align}
Y_t &= \mu_1 + \mu_2 t \\
Y_{t-1} &= \mu_1 + \mu_2 (t-1)
\end{align}$$

. . . 

$$\small \mu_2 t = \mu_2 - \mu_1 + Y_{t-1}$$

. . . 

$$\small \begin{align}
Y_t &= \mu_1 + (\mu_2 - \mu_1 + Y_{t-1}) \\
&= \mu_2 + Y_{t-1}
\end{align}$$

## Misspecification, Bias {visibility="uncounted"}

$$Y_t = .1t + e_t$$


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
v3 <- .1*1:100 + rnorm(100)
arima(v3, c(1, 0, 0))
```

::: {.cell-output .cell-output-stdout}
```

Call:
arima(x = v3, order = c(1, 0, 0))

Coefficients:
         ar1  intercept
      0.9026     4.8111
s.e.  0.0440     1.3383

sigma^2 estimated as 2.011:  log likelihood = -177.68,  aic = 361.35
```
:::
:::


## Misspecification, Bias {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
vec <- rep(0, 100)
for(i in 1:100){
  
  v3 <- .1*1:100 + rnorm(100)
  vec[i] <- arima(v3, c(1, 0, 0))$coef[1]
}

plot(table(round(vec, 2)),
     ylab = "Frequency (%)",
     xlab = "Coefficient Estimate")
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-16-1.png){fig-align='center' width=90%}
:::
:::


## Misspecification, Bias {visibility="uncounted"}

$$Y_t = .1t + .1Y_{t-1} + e_t$$


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
v4 <- rep(0, 100)
for(i in 2:100) v4[i] <- .1*i + .1*v4[i-1] + rnorm(1)
arima(v4, c(1, 0, 0))
```

::: {.cell-output .cell-output-stdout}
```

Call:
arima(x = v4, order = c(1, 0, 0))

Coefficients:
         ar1  intercept
      0.9534     5.8911
s.e.  0.0323     2.1043

sigma^2 estimated as 1.355:  log likelihood = -158.29,  aic = 322.57
```
:::
:::


# Seasonality

## Seasonality

Deterministic seasonality is any (completely) repeating pattern *within* the course of a year.

- Number of Tide arrivals on a given day of the week.

. . .

Stochastic seasonality is a roughly repeating pattern

- Snowfall and other weather outcomes.$^*$

. . .

Think of this like deterministic vs stochastic trend.  Consider peak/trough magnitudes.

. . .

Seasonality can change over time.


## Deterministic Seasonality {visibility="uncounted"}

If seasonality is deterministic, we simply need a different intercept for each season.

$$
S_{t} =
    \begin{cases}
      \gamma_1 & \text{if t = Monday}\\
      \gamma_2 & \text{if t = Tuesday}\\
      \hspace{.3em}. & \hspace{2em}.\\
      \hspace{.3em}. & \hspace{2em}. \\
      \hspace{.3em}. & \hspace{2em}. \\
      \gamma_7 & \text{if t = Sunday}
    \end{cases}       
$$

This can be hourly, daily, weekly, monthly, quarterly, or any combination.

## Deterministic Seasonality {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
liquor$season <- as.factor(month(liquor$date))
t <- 2:nrow(liquor)
liquor$l_sales_d <- NA
liquor$l_sales_d[t] <- log(liquor$sales[t]) - log(liquor$sales_adj[t-1])
reg <- lm(l_sales_d ~ season, liquor)

lim <- (nrow(liquor)-60):nrow(liquor)
plot(liquor$date[lim], liquor$l_sales_d[lim], type = "l",
     ylim = range(liquor$l_sales_d[lim]) * c(1.2, 1),
     xlab = "Month",
     ylab = "Change in Log(Sales)")
lines(liquor$date[lim], reg$fitted[lim-1], col = "tomato")
legend("bottomright", bty = "n", lty = 1,
       col = c("black", "tomato"),
       legend = c("Actual", "Fitted"), horiz = T)
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-18-1.png){fig-align='center' width=90%}
:::
:::


## Deterministic Seasonality {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
reg1 <- lm(log(sales) ~ t + season, liquor)
reg2 <- lm(log(sales) ~ t + season - 1, liquor)
stargazer::stargazer(reg1, reg2, type = "text", omit.stat = c("ser", "f"))
```

::: {.cell-output .cell-output-stdout}
```

=========================================
                 Dependent variable:     
             ----------------------------
                      log(sales)         
                  (1)            (2)     
-----------------------------------------
t               0.003***      0.003***   
               (0.00002)      (0.00002)  
                                         
season1                       7.266***   
                               (0.007)   
                                         
season2          -0.006       7.260***   
                (0.009)        (0.007)   
                                         
season3         0.093***      7.359***   
                (0.009)        (0.007)   
                                         
season4         0.093***      7.359***   
                (0.009)        (0.007)   
                                         
season5         0.177***      7.443***   
                (0.009)        (0.007)   
                                         
season6         0.166***      7.432***   
                (0.009)        (0.007)   
                                         
season7         0.208***      7.474***   
                (0.009)        (0.007)   
                                         
season8         0.177***      7.443***   
                (0.009)        (0.007)   
                                         
season9         0.119***      7.385***   
                (0.009)        (0.007)   
                                         
season10        0.147***      7.413***   
                (0.009)        (0.007)   
                                         
season11        0.182***      7.447***   
                (0.009)        (0.007)   
                                         
season12        0.474***      7.739***   
                (0.009)        (0.007)   
                                         
Constant        7.266***                 
                (0.007)                  
                                         
-----------------------------------------
Observations      336            336     
R2               0.991          1.000    
Adjusted R2      0.990          1.000    
=========================================
Note:         *p<0.1; **p<0.05; ***p<0.01
```
:::
:::


## Deterministic Seasonality {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
lim <- (nrow(liquor)-60):nrow(liquor)
plot(liquor$date[lim], log(liquor$sales)[lim], type = "l",
     ylim = range(log(liquor$sales[lim])),
     xlab = "Month",
     ylab = "Change in Log(Sales)")
lines(liquor$date[lim], reg2$fitted[lim], col = "tomato")
legend("bottomright", bty = "n", lty = 1,
       col = c("black", "tomato"),
       legend = c("Actual", "Fitted"), horiz = T)
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-20-1.png){fig-align='center' width=90%}
:::
:::


## Seasonal Adjustment {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
liquor1 <- liquor
liquor1$season <- liquor$season[8]
f <- predict(reg1, newdata = liquor1)
plot(liquor$date, liquor$sales, type = "l",
     col = alpha("black", .4), lwd = 2,
     xlab = "Month", ylab = "Sales")
lines(liquor$date, liquor1$sales_adj, lwd = 2,
      col = alpha("tomato", .4))
lines(liquor$date, exp(f), lwd = 2,
      col = alpha("dodgerblue", .4))
legend("topleft", bty = "n", col = c("black", "tomato", "dodgerblue"),
       pch = 15, legend = c("Actual", "Seasonally Adjusted - FRED", "Seasonally Adjusted - Alex"))
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-21-1.png){fig-align='center' width=90%}
:::
:::



## Deterministic Seasonality {visibility="uncounted"}

<!-- file:///C:/Users/alexc/Dropbox/teaching/Fall%202022/econ707/notes_adam/hansen/390Lecture13.pdf -->


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
liquor$season <- as.factor(month(liquor$date))
mat <- model.matrix( ~ season, liquor)
# mat <- cbind(mat, t = liquor$t)
reg4 <- auto.arima(log(liquor$sales), xreg = mat[,c(2:ncol(mat))])
reg4
```

::: {.cell-output .cell-output-stdout}
```
Series: log(liquor$sales) 
Regression with ARIMA(3,1,2) errors 

Coefficients:
          ar1     ar2     ar3      ma1      ma2  drift  season2  season3
      -0.3377  0.1015  0.3680  -0.5391  -0.2404  3e-03  -0.0058   0.0930
s.e.   0.1817  0.1206  0.0871   0.1832   0.1094  3e-04   0.0061   0.0057
      season4  season5  season6  season7  season8  season9  season10  season11
       0.0941   0.1780   0.1669   0.2094   0.1786   0.1204    0.1487    0.1841
s.e.   0.0050   0.0062   0.0059   0.0057   0.0059   0.0062    0.0050    0.0057
      season12
        0.4756
s.e.    0.0061

sigma^2 = 0.0005542:  log likelihood = 788.74
AIC=-1541.48   AICc=-1539.32   BIC=-1472.83
```
:::
:::


## Deterministic Seasonality {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
N <- 24
tmp <- data.frame(matrix(ncol = ncol(liquor), nrow = N))
colnames(tmp) <- colnames(liquor)
tmp$t <- max(liquor$t) + 1:N
tmp$date <- max(liquor$date) + months(1:N)
liquor$h <- 0; tmp$h <- 1
liquor <- rbind(liquor, tmp); rm(tmp)

liquor$season <- as.factor(month(liquor$date))
mat <- model.matrix( ~ season, liquor)
# mat <- cbind(mat, t = liquor$t)

if("drift" %in% colnames(reg4$xreg)) mat <- cbind(drift = 1:nrow(mat), mat)

p <- predict(reg4, n.ahead = N, newxreg = mat[liquor$h == 1,colnames(mat) %in% colnames(reg4$xreg)])
liquor$pred <- c(fitted(reg4), p$pred)

tmp <- read.csv("../data/liquor.csv")
tmp$date <- mdy(tmp$date)
tmp <- tmp[tmp$date >= ymd("2020-01-01") & tmp$date <= ymd("2021-12-01"),]

lim <- liquor$date > ymd("2014-12-01")
plot(liquor$date[lim],
     exp(liquor$pred[lim]), type = "n",
     ylim = c(min(exp(liquor$pred[lim])),
              max(tmp$sales)))
polygon(x = c(liquor$date[liquor$h == 1],
              rev(liquor$date[liquor$h == 1])),
        y = c(exp(p$pred + 1.96*p$se),
              rev(exp(p$pred - 1.96*p$se))),
        border = NA, col = scales::alpha("tomato", .33))
lines(liquor$date[lim & liquor$h == 0],
     exp(liquor$pred[lim & liquor$h == 0]), type = "l")
lines(liquor$date[lim & liquor$h == 1],
     exp(liquor$pred[lim & liquor$h == 1]), type = "l",
     col = "tomato")
lines(tmp$date, tmp$sales, col = "dodgerblue")
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-23-1.png){fig-align='center' width=90%}
:::
:::




## SARIMA


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
liquor <- liquor[liquor$h == 0,]

par(mfrow = c(1, 2))
acf(diff(log(liquor$sales)))
acf(diff(log(liquor$sales), lag = 12))
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-24-1.png){fig-align='center' width=90%}
:::
:::


## SARIMA {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
par(mfrow = c(1, 2))
pacf(diff(log(liquor$sales)))
pacf(diff(log(liquor$sales), lag = 12))
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-25-1.png){fig-align='center' width=90%}
:::
:::


## SARIMA {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
par(mfrow = c(1, 2))
plot(diff(log(liquor$sales)), type = "l")
plot(diff(log(liquor$sales), lag = 12), type = "l")
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-26-1.png){fig-align='center' width=90%}
:::
:::


## SARIMA {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
plot(diff(diff(log(liquor$sales), lag = 12)), type = "l")
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-27-1.png){fig-align='center' width=90%}
:::
:::


## SARIMA {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
r <- arima(log(liquor$sales), c(0, 1, 0), seasonal = list(order = c(0, 1, 0), period = 12))
plot(r$residuals)
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-28-1.png){fig-align='center' width=90%}
:::
:::


## SARIMA {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
reg5_1 <- arima(log(liquor$sales[liquor$h == 0]),
                c(1, 1, 1))
reg5_2 <- arima(log(liquor$sales[liquor$h == 0]),
                c(1, 1, 1),
                seasonal = list(order = c(0, 1, 0), period = 12))
reg5_3 <- arima(log(liquor$sales[liquor$h == 0]),
                c(1, 1, 1),
                seasonal = list(order = c(1, 0, 0), period = 12))
reg5_1; reg5_2; reg5_3
```

::: {.cell-output .cell-output-stdout}
```

Call:
arima(x = log(liquor$sales[liquor$h == 0]), order = c(1, 1, 1))

Coefficients:
         ar1      ma1
      0.0400  -0.8876
s.e.  0.0581   0.0185

sigma^2 estimated as 0.01681:  log likelihood = 208.3,  aic = -410.6

Call:
arima(x = log(liquor$sales[liquor$h == 0]), order = c(1, 1, 1), seasonal = list(order = c(0, 
    1, 0), period = 12))

Coefficients:
          ar1     ma1
      -0.2655  -0.546
s.e.   0.0730   0.061

sigma^2 estimated as 0.0008351:  log likelihood = 686.04,  aic = -1366.08

Call:
arima(x = log(liquor$sales[liquor$h == 0]), order = c(1, 1, 1), seasonal = list(order = c(1, 
    0, 0), period = 12))

Coefficients:
          ar1      ma1    sar1
      -0.2436  -0.5628  0.9789
s.e.   0.0738   0.0616  0.0070

sigma^2 estimated as 0.0008264:  log likelihood = 694.23,  aic = -1380.46
```
:::
:::


## SARIMA {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
lim <- liquor$date %in% ymd("2015-01-01"):ymd("2020-01-01")
plot(liquor$date[lim], liquor$sales[lim], type = "l",
     col = scales::alpha("black", .6), lwd = 2)
lines(liquor$date[liquor$h==0], exp(fitted(reg5_1)),
      col = scales::alpha("tomato", .6), lwd = 2)
lines(liquor$date[liquor$h==0], exp(fitted(reg5_2)),
      col = scales::alpha("dodgerblue", .6), lwd = 2)
lines(liquor$date[liquor$h==0], exp(fitted(reg5_3)),
      col = scales::alpha("mediumseagreen", .6), lwd = 2)
legend("bottomleft", bty = "n", horiz = T, pch = 15,
       col = c("black", "tomato", "dodgerblue", "mediumseagreen"),
       legend = c("Actual", "ARIMA(1,1,1)", "SARIMA(1,1,1)(0,1,0)", "SARIMA(1,1,1)(1,0,0)"))
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-30-1.png){fig-align='center' width=90%}
:::
:::




# Standard Errors

<!-- file:///C:/Users/alexc/Dropbox/teaching/Fall%202022/econ707/notes_adam/hansen/390Lecture15.pdf -->
<!-- file:///C:/Users/alexc/Dropbox/teaching/Fall%202022/econ707/notes_adam/hansen/390Lecture16.pdf -->

## Standard Errors

- Analytic
- HC (White)
- HAC (Newey-West)

## HC

- Const: What R's ```summary()``` produces.
- HC0: White's original standard errors.
- HC1: White's SE + small sample correction.
- HC2: STATA Default.
- HC3$^*$: ```sandwich``` Default.
- HC4, HC4m, HC5: Further advancements...

<!-- https://cran.r-project.org/web/packages/sandwich/sandwich.pdf -->

## HC {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
library("lmtest")
library("sandwich")
N <- 50
df <- data.frame(shock1_1 = rnorm(N, 0, 1:N),
                 shock1_2 = rnorm(N, 0, 1:N / (N)),
                 shock2_1 = rnorm(N, 0, abs(1:N - median(1:N))),
                 shock2_2 = rnorm(N, 0, ifelse(1:N - median(1:N) > 0, N - 1:N, 1:N - 1)),
                 t = 1:N)
df$y1_1 <- 5 + (.5 * df$t) + df$shock1_1
df$y1_2 <- 5 + (.5 * df$t) + df$shock1_2
df$y2_1 <- 5 + (.5 * df$t) + df$shock2_1
df$y2_2 <- 5 + (.5 * df$t) + df$shock2_2

par(mfrow = c(2,2))
plot(df$t, df$y1_1, xlab = "", ylab = "", main = "Series 1", type = "b", pch = 20)
plot(df$t, df$y1_2, xlab = "", ylab = "", main = "Series 2", type = "b", pch = 20)
plot(df$t, df$y2_1, xlab = "", ylab = "", main = "Series 3", type = "b", pch = 20)
plot(df$t, df$y2_2, xlab = "", ylab = "", main = "Series 4", type = "b", pch = 20)
```

::: {.cell-output-display}
![](seasonality_07_files/figure-revealjs/unnamed-chunk-31-1.png){fig-align='center' width=90%}
:::
:::


## HC - Series 1 {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
r1 <- lm(y1_1 ~ t, df)
r1_0 <- coeftest(r1, vcov = vcovHC(r1, "HC0"))
r1_1 <- coeftest(r1, vcov = vcovHC(r1, "HC1"))
r1_2 <- coeftest(r1, vcov = vcovHC(r1, "HC2"))
r1_3 <- coeftest(r1, vcov = vcovHC(r1, "HC3"))

stargazer::stargazer(r1,
                     r1_0,
                     r1_1,
                     r1_2, r1_3,
                     type = "text", omit.stat = c("ser", "f"))
```

::: {.cell-output .cell-output-stdout}
```

====================================================
                       Dependent variable:          
             ---------------------------------------
              y1_1                                  
               OLS             coefficient          
                                  test              
               (1)     (2)     (3)     (4)     (5)  
----------------------------------------------------
t             0.220   0.220   0.220   0.220   0.220 
             (0.253) (0.240) (0.245) (0.248) (0.255)
                                                    
Constant      9.398  9.398*  9.398*  9.398*  9.398* 
             (7.401) (4.868) (4.968) (4.992) (5.120)
                                                    
----------------------------------------------------
Observations   50                                   
R2            0.016                                 
Adjusted R2  -0.005                                 
====================================================
Note:                    *p<0.1; **p<0.05; ***p<0.01
```
:::
:::


## HC - Series 2 {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
r2 <- lm(y1_2 ~ t, df)
r2_0 <- coeftest(r2, vcov = vcovHC(r2, "HC0"))
r2_1 <- coeftest(r2, vcov = vcovHC(r2, "HC1"))
r2_2 <- coeftest(r2, vcov = vcovHC(r2, "HC2"))
r2_3 <- coeftest(r2, vcov = vcovHC(r2, "HC3"))

stargazer::stargazer(r2,
                     r2_0,
                     r2_1,
                     r2_2, r2_3,
                     type = "text", omit.stat = c("ser", "f"))
```

::: {.cell-output .cell-output-stdout}
```

=========================================================
                         Dependent variable:             
             --------------------------------------------
               y1_2                                      
               OLS                coefficient            
                                     test                
               (1)      (2)      (3)      (4)      (5)   
---------------------------------------------------------
t            0.496*** 0.496*** 0.496*** 0.496*** 0.496***
             (0.007)  (0.008)  (0.008)  (0.008)  (0.009) 
                                                         
Constant     5.097*** 5.097*** 5.097*** 5.097*** 5.097***
             (0.193)  (0.136)  (0.138)  (0.140)  (0.144) 
                                                         
---------------------------------------------------------
Observations    50                                       
R2            0.992                                      
Adjusted R2   0.991                                      
=========================================================
Note:                         *p<0.1; **p<0.05; ***p<0.01
```
:::
:::


## HC - Series 3 {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
r3 <- lm(y2_1 ~ t, df)
r3_0 <- coeftest(r3, vcov = vcovHC(r3, "HC0"))
r3_1 <- coeftest(r3, vcov = vcovHC(r3, "HC1"))
r3_2 <- coeftest(r3, vcov = vcovHC(r3, "HC2"))
r3_3 <- coeftest(r3, vcov = vcovHC(r3, "HC3"))

stargazer::stargazer(r3,
                     r3_0,
                     r3_1,
                     r3_2, r3_3,
                     type = "text", omit.stat = c("ser", "f"))
```

::: {.cell-output .cell-output-stdout}
```

==============================================================
                            Dependent variable:               
             -------------------------------------------------
               y2_1                                           
                OLS                  coefficient              
                                        test                  
                (1)       (2)       (3)       (4)       (5)   
--------------------------------------------------------------
t             0.334**   0.334**   0.334**   0.334**   0.334** 
              (0.125)   (0.156)   (0.159)   (0.161)   (0.166) 
                                                              
Constant     11.959*** 11.959*** 11.959*** 11.959*** 11.959***
              (3.660)   (3.895)   (3.976)   (4.017)   (4.143) 
                                                              
--------------------------------------------------------------
Observations    50                                            
R2             0.130                                          
Adjusted R2    0.112                                          
==============================================================
Note:                              *p<0.1; **p<0.05; ***p<0.01
```
:::
:::


## HC - Series 4 {visibility="uncounted"}


::: {.cell layout-align="center"}

```{.r .cell-code  code-fold="true"}
r4 <- lm(y2_2 ~ t, df)
r4_0 <- coeftest(r4, vcov = vcovHC(r4, "HC0"))
r4_1 <- coeftest(r4, vcov = vcovHC(r4, "HC1"))
r4_2 <- coeftest(r4, vcov = vcovHC(r4, "HC2"))
r4_3 <- coeftest(r4, vcov = vcovHC(r4, "HC3"))

stargazer::stargazer(r4,
                     r4_0,
                     r4_1,
                     r4_2, r4_3,
                     type = "text", omit.stat = c("ser", "f"))
```

::: {.cell-output .cell-output-stdout}
```

========================================================
                         Dependent variable:            
             -------------------------------------------
              y2_2                                      
               OLS               coefficient            
                                    test                
               (1)     (2)      (3)      (4)      (5)   
--------------------------------------------------------
t            0.384** 0.384*** 0.384*** 0.384*** 0.384***
             (0.151) (0.071)  (0.072)  (0.072)  (0.074) 
                                                        
Constant      7.062  7.062**  7.062**  7.062**  7.062** 
             (4.424) (3.019)  (3.081)  (3.067)  (3.117) 
                                                        
--------------------------------------------------------
Observations   50                                       
R2            0.119                                     
Adjusted R2   0.101                                     
========================================================
Note:                        *p<0.1; **p<0.05; ***p<0.01
```
:::
:::


## HAC

<!-- https://www.econometrics-with-r.org/15-4-hac-standard-errors.html -->

The Newey-West Standard errors simultaneously corrects for heteroskedasticity *and* autocorrelation amongst the errors.

. . .

This occurs when you leave out serially correlated factors impacting Y of the statistical model.


## Next Class

- X Variables
- Cointegration
- Coefficient Dynamics

# Seattle's Fremont Bridge

## {visibility="uncounted" background-image="https://www.myballard.com/wp-content/uploads/Fremont-bridge-076-750x410.jpg" background-size="contain"}

## Fremont Bridge {visibility="uncounted"}

[Link to Fremont Bridge Bicyle Counter](https://data.seattle.gov/Transportation/Fremont-Bridge-Bicycle-Counter/65db-xm6k)

. . .

It is December 31$^{\text{st}}$, 2016.  The city of Seattle has asked you to forecast bicycle ridership for the Fremont Bridge in 2017.

- Use data from 2013-01-01 00:00:00 to 2016-12-31 23:00:00 to forecast 2017.
