fcast <- function(y0 = 0, d_y0 = 0, dd_y = c()){
  
  steps <- length(dd_y)
  sum(dd_y[steps:1]*(1:steps)) + steps*d_y0 + y0
}
apply_fcast <- function(train = c(), forecast = c(), diff = 1){
  
  if(length(train) < 2) stop("'train' does not contain enough observations.")
  if(length(forecast) < 1) stop("'forecast' is empty.")
  if(!diff %in% 1:2) stop("'diff' must be either 1 or 2.")
  
  vec <- rep(NA, length(forecast))
  
  if(diff == 1){
    
    y0 = train[1]
    return(cumsum(forecast) + y0)
  } else {
    
    y0 = train[length(train)]
    d_y0 = diff(train[length(train) - 1:0])
    dd_y <- forecast
    for(i in 1:length(dd_y)) vec[i] <- fcast(y0 = y0, d_y0 = d_y0, dd_y[1:i])
    return(vec)
  }
}

# k <- sample(1:10, 24, TRUE)
# obj <- ts(k, start = c(2010, 1), frequency = 12)
# obj2 <- ts.union(obj, d = diff(obj), dd = diff(diff(obj)))
# obj2

# obj2[3,3] + obj2[2,2] + obj2[2,1]
# obj2[4,3] + 2*obj2[3,3] + 2*obj2[2,2] + obj2[2,1]
# obj2[5,3] + 2*obj2[4,3] + 3*obj2[3,3] + 3*obj2[2,2] + obj2[2,1]

# apply_fcast(train = obj2[1:2,1],
#             forecast = obj2[3:24,3],
#             diff = 2) -> test
# cbind(obj2[,1], c(NA, NA, test))
# 
# apply_fcast(train = obj2[1:2,1],
#             forecast = obj2[2:24,2],
#             diff = 1) -> test
# cbind(obj2[,1], c(NA, test))
